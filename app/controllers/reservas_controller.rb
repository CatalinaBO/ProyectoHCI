# frozen_string_literal: true

class ReservasController < ApplicationController
  before_action :require_login
  before_action :set_reserva, only: [:show, :edit, :update, :cancel]
  # before_action :autorizar_duenio_o_admin!, only: [:show, :edit, :update, :cancel]


  def index
    @reservas = Reserva.includes(:espacio, :modulo).where(usuario_id: current_user.id).order(fecha: :asc, 
                                                                                             modulo_id: :asc)
  end

  def new
    @reserva  = Reserva.new
    @modulos  = Modulo.all.order(:hora_inicio)

    if params[:espacio_id].present?
      @espacio = Espacio.find(params[:espacio_id])
      @reserva.espacio = @espacio
    else
      @espacios = Espacio.where(activo: true)
    end
  end

  def create
    @reserva = Reserva.new(reserva_params)
    @reserva.usuario = current_user
    @reserva.estado  = 'pendiente' ### PENDIENTE para que sea aceptada ###

    # ** aún no implementado
    @espacios = Espacio.where(activo: true)
    @modulos  = Modulo.all.order(:hora_inicio)

    if @reserva.save
      redirect_to reservas_path, notice: 'Reserva creada exitosamente.'
    else
      flash.now[:alert] = @reserva.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @reserva = Reserva.find(params[:id])
    @resena = Resena.find_by(reserva_id: @reserva.id)
    unless puede_ver?(@reserva)
      redirect_to reservas_path, alert: 'No tienes permiso para ver esta reserva.'
    end
  end

  def edit
    unless puede_ver?(@reserva)
      redirect_to mis_reservas_path, alert: 'No tienes permiso.'
      return
    end

    unless @reserva.editable?
      redirect_to mis_reservas_path, alert: 'Esta reserva no puede modificarse.'
      return
    end

    @espacios = Espacio.where(activo: true)
    @modulos  = Modulo.order(:hora_inicio)
  end

  def update
    unless puede_ver?(@reserva)
      redirect_to mis_reservas_path, alert: 'No tienes permiso.'
      return
    end

    unless @reserva.editable?
      redirect_to mis_reservas_path, alert: 'Esta reserva no puede modificarse.'
      return
    end

    if @reserva.update(reserva_params)
      redirect_to mis_reservas_path, notice: 'Reserva actualizada correctamente.'
    else
      @espacios = Espacio.where(activo: true)
      @modulos  = Modulo.order(:hora_inicio)
      flash.now[:alert] = @reserva.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end


  def cancel
    if @reserva.cancelada?
      redirect_back fallback_location: @reserva, notice: "La reserva ya estaba cancelada."
      return
    end
    if reserva_empezada?(@reserva)
      redirect_to @reserva, alert: "No puedes cancelar una reserva que ya comenzó."
      return
    end
    
    if @reserva.update(estado: 'cancelada')
      redirect_to mis_reservas_path, notice: "Reserva cancelada correctamente."
    else
      redirect_to mis_reservas_path, alert: @reserva.errors.full_messages.to_sentence
    end
  end

  def reservas_pendientes
    @reservas = Reserva.where('estado = ?', 'pendiente').includes(:espacio, :modulo, :usuario)
  end

  def aceptar_reserva
    @reserva = Reserva.find(params[:id])
    @reserva.estado = 'confirmada'
    @reserva.confirmada_en = Time.zone.now
    @ubicacion = @reserva.espacio.ubicacion 

    #@espacio = Reserva.find(params[:espacio_id])
    #@modulo = Reserva.find(params[:modulo_id])
    #@modulo = 

    if @reserva.save && admin_user?
      redirect_to '/reservas/reservas_pendientes', notice: 'Reserva confirmada con éxito.'

    elsif @reserva.save && moderador_user?
      redirect_to moderador_reservas_pendientes_path(@ubicacion), notice: 'Reserva confirmada con éxito.'

    else
      redirect_to '/reservas/reservas_pendientes', alert: 'Error al confirmar la reserva.'
    end
  end

  def rechazar_reserva
    @reserva = Reserva.find(params[:id])
    @reserva.estado = 'rechazada'
    @reserva.rechazo_motivo = params[:mensaje] if params[:mensaje].present?
    @ubicacion = @reserva.espacio.ubicacion 
    
    if @reserva.save && admin_user?
      redirect_to '/reservas/reservas_pendientes', notice: 'Reserva rechazada con éxito.'
    
    elsif @reserva.save && moderador_user?
      redirect_to moderador_reservas_pendientes_path(@ubicacion), notice: 'Reserva rechazada con éxito.'

    else
      redirect_to '/reservas/reservas_pendientes', alert: 'Error al rechazar la reserva.'
    end
  end
  
  private

  def reserva_params
    params.require(:reserva).permit(:espacio_id, :modulo_id, :fecha)
  end

  # *** Autoriza usuario sea dueño o admin (aún no implementado)
  def puede_ver?(reserva)
    return false unless current_user
    reserva.usuario_id == current_user.id || (current_user.respond_to?(:admin?) && current_user.admin?)
  end

  def set_reserva
    @reserva = Reserva.find(params[:id])
  end

 # Combina fecha + hora_inicio del módulo (si existen) para saber si ya empezó
  def reserva_empezada?(reserva)
    return false unless reserva.fecha && reserva.modulo&.hora_inicio

    inicio = Time.zone.local(
      reserva.fecha.year, reserva.fecha.month, reserva.fecha.day,
      reserva.modulo.hora_inicio.hour, reserva.modulo.hora_inicio.min
    )
    Time.current >= inicio
  end

end