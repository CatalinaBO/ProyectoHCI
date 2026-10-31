# frozen_string_literal: true

class ReservasController < ApplicationController
  before_action :require_login, except: [:create]
  before_action :set_grupo, only: %i[mi_reserva registrada iniciar cancelar finalizar]

  # "Mis reservas": una fila por solicitud (grupo de módulos).
  def index
    reservas = Reserva.includes(:espacio, :modulo)
                      .where(usuario_id: current_user.id)
                      .where.not(estado: 'rechazada')
                      .order(fecha: :desc)
    @grupos = reservas.group_by(&:grupo).values
                      .map { |rs| rs.sort_by { |r| r.modulo.hora_inicio } }
                      .sort_by { |rs| [rs.first.fecha, rs.first.modulo.hora_inicio] }
                      .reverse
  end

  # La reserva se hace desde la cuadrícula de disponibilidad.
  def new
    redirect_to espacios_path(espacio_id: params[:espacio_id])
  end

  def create
    seleccion = {
      'espacio_id' => params[:espacio_id],
      'fecha' => params[:fecha],
      'modulo_ids' => Array(params[:modulo_ids])
    }

    unless logged_in?
      session[:seleccion_pendiente] = seleccion
      redirect_to login_path, alert: 'Para confirmar tu reserva, entra como invitado o inicia sesión.'
      return
    end

    resultado = crear_grupo(seleccion)
    if resultado[:ok]
      redirect_to reserva_registrada_path(resultado[:grupo])
    else
      redirect_to espacios_path(fecha: seleccion['fecha']), alert: resultado[:error]
    end
  end

  # Ruta antigua por id: lleva a la vista "Mi reserva".
  def show
    reserva = Reserva.find_by(id: params[:id], usuario_id: current_user.id)
    if reserva
      redirect_to mi_reserva_path(reserva.grupo)
    else
      redirect_to mis_reservas_path, alert: 'No tienes permiso para ver esta reserva.'
    end
  end

  def edit
    redirect_to mis_reservas_path, alert: 'Para cambiar una reserva, cancélala y elige nuevos módulos.'
  end

  def update
    edit
  end

  # Ruta antigua por id.
  def cancel
    reserva = Reserva.find_by(id: params[:id], usuario_id: current_user.id)
    return redirect_to(mis_reservas_path, alert: 'Reserva no encontrada.') unless reserva

    redirect_to mi_reserva_path(reserva.grupo)
  end

  def registrada; end

  def mi_reserva; end

  # D5: el titular declara que comenzó a usar la sala.
  def iniciar
    unless puede_iniciar_uso?(@reservas)
      redirect_to mi_reserva_path(@grupo), alert: 'Solo puedes registrar el inicio de uso durante el horario reservado.'
      return
    end

    ahora = Time.current
    Reserva.transaction do
      @reservas.select(&:confirmada?).each { |r| r.update!(estado: 'en_uso', inicio_uso_en: ahora) }
    end
    redirect_to mi_reserva_path(@grupo),
                notice: 'Inicio de uso registrado. Lo declaraste tú: no es una verificación de presencia.'
  end

  # D6: antes del inicio de uso.
  def cancelar
    unless grupo_cancelable?(@reservas)
      redirect_to mi_reserva_path(@grupo), alert: 'Esta reserva ya no se puede cancelar.'
      return
    end

    Reserva.transaction do
      @reservas.select { |r| r.confirmada? || r.pendiente? }.each { |r| r.update!(estado: 'cancelada') }
    end
    redirect_to mi_reserva_path(@grupo), notice: 'Reserva cancelada. Los módulos quedaron disponibles para otros estudiantes.'
  end

  # D6: después del inicio de uso, libera el módulo en curso y los siguientes.
  def finalizar
    unless @reservas.any?(&:en_uso?)
      redirect_to mi_reserva_path(@grupo), alert: 'Primero debes registrar el inicio de uso.'
      return
    end

    ahora = Time.current
    Reserva.transaction do
      @reservas.select { |r| r.en_uso? || r.confirmada? }.each do |r|
        nuevo = r.terminada? ? 'finalizada' : 'liberada'
        r.update!(estado: nuevo, finalizada_en: ahora)
      end
    end
    redirect_to mi_reserva_path(@grupo), notice: 'Uso finalizado. Los módulos restantes quedaron liberados.'
  end

  private

  def set_grupo
    @grupo = params[:grupo].to_s
    @reservas = Reserva.includes(:espacio, :modulo)
                       .where(grupo: @grupo, usuario_id: current_user.id)
                       .to_a
                       .sort_by { |r| r.modulo.hora_inicio }
    if @reservas.empty?
      redirect_to mis_reservas_path, alert: 'No encontramos esa reserva.'
      return
    end

    @espacio = @reservas.first.espacio
    @fecha = @reservas.first.fecha
    @estado_grupo = helpers.estado_grupo(@reservas)
    @puede_iniciar = puede_iniciar_uso?(@reservas)
    @cancelable = grupo_cancelable?(@reservas)
    @finalizable = @reservas.any?(&:en_uso?)
  end

  def crear_grupo(seleccion)
    espacio = Espacio.find_by(id: seleccion['espacio_id'], activo: true)
    modulos = Modulo.where(id: seleccion['modulo_ids'].map(&:to_i).uniq).order(:hora_inicio).to_a
    fecha = begin
      Date.parse(seleccion['fecha'].to_s)
    rescue ArgumentError
      nil
    end

    return { ok: false, error: 'Selecciona una sala.' } unless espacio
    return { ok: false, error: 'Selecciona al menos un módulo.' } if modulos.empty?
    return { ok: false, error: 'La fecha no es válida.' } if fecha.nil? || fecha < Date.current

    terminado = modulos.find { |m| m.terminado?(fecha) }
    return { ok: false, error: "El módulo #{terminado.etiqueta} ya terminó." } if terminado

    grupo = SecureRandom.uuid
    Reserva.transaction do
      modulos.each do |m|
        r = Reserva.new(usuario: current_user, espacio: espacio, modulo: m, fecha: fecha,
                        estado: 'confirmada', grupo: grupo)
        next if r.save

        raise ConflictoReserva, "El módulo #{m.etiqueta} de #{espacio.nombre} ya no está disponible; " \
                                'no se registró la reserva.'
      end
    end
    { ok: true, grupo: grupo }
  rescue ConflictoReserva => e
    { ok: false, error: e.message }
  rescue ActiveRecord::RecordNotUnique
    { ok: false, error: 'Alguien reservó uno de esos módulos recién; no se registró la reserva. Elige otro bloque.' }
  end

  def puede_iniciar_uso?(reservas)
    return false unless reservas.any?(&:confirmada?)
    return false unless reservas.first.fecha == Date.current

    inicio = reservas.first.inicio_datetime - Reserva::TOLERANCIA_MIN.minutes
    fin = reservas.last.fin_datetime
    Time.current.between?(inicio, fin)
  end

  def grupo_cancelable?(reservas)
    reservas.none?(&:en_uso?) && reservas.any? { |r| (r.confirmada? || r.pendiente?) && !r.terminada? }
  end

  class ConflictoReserva < StandardError; end
end
