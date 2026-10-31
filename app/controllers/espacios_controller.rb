# frozen_string_literal: true

class EspaciosController < ApplicationController
  TIPO_SALA = 'Sala de Estudio'.freeze

  UBICACION_CAI = 'Edificio CAI'.freeze

  # Vista "Disponibilidad de salas CAI": cuadrícula salas x módulos.
  def index
    @hoy = Date.current
    @fecha = parse_fecha(params[:fecha])
    @espacios = Espacio.where(activo: true, tipo: TIPO_SALA, ubicacion: UBICACION_CAI).order(:id)
    @modulos = Modulo.order(:hora_inicio)
    @celdas = celdas_para(@fecha, @espacios)
    @actualizado_en = Time.current

    # Selección que quedó pendiente antes de entrar (invitado/login).
    @espacio_preseleccionado = params[:espacio_id].to_i if params[:espacio_id].present?
    @modulos_preseleccionados = Array(params[:modulo_ids]).map(&:to_i)
  end

  def todos_los_espacios
    @espacios = Espacio.all

    return unless moderador_user?

    moderador = Moderador.find_by(usuario_id: current_user.id)
    @ubicacion = moderador.por_ubicacion

    redirect_to espacios_ubicacion_path(@ubicacion)
  end

  def filtrar_espacios
    redirect_to espacios_path
  end

  def por_tipo
    redirect_to espacios_path
  end

  private

  def parse_fecha(valor)
    fecha = Date.parse(valor.to_s)
    fecha < Date.current ? Date.current : fecha
  rescue ArgumentError
    Date.current
  end

  # { [espacio_id, modulo_id] => Reserva } con la reserva que define el estado de cada celda.
  # Una reserva activa tiene prioridad; si no hay, se usa la última liberada/finalizada.
  def celdas_para(fecha, espacios)
    celdas = {}
    Reserva.where(fecha: fecha, espacio_id: espacios.map(&:id))
           .where.not(estado: %w[cancelada rechazada])
           .includes(:modulo)
           .order(:updated_at)
           .each do |r|
      clave = [r.espacio_id, r.modulo_id]
      actual = celdas[clave]
      celdas[clave] = r if actual.nil? || !actual.activa?
    end
    celdas
  end

  def espacio_params
    params.require(:espacio).permit(:nombre, :tipo, :ubicacion, :capacidad, :activo)
  end
end
