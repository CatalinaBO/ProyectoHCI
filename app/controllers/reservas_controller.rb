# frozen_string_literal: true

class ReservasController < ApplicationController
  before_action :require_login
  before_action :set_reserva, only: [:show, :edit, :update, :cancel]
  

  def index
    @reservas = Reserva.includes(:espacio, :modulo).where(usuario_id: current_user.id).order(fecha: :asc, 
                                                                                             modulo_id: :asc)
  end

  def new
    @reserva  = Reserva.new
    @modulos  = Modulo.all.order(:hora_inicio)
    @espacios = Espacio.where(activo: true, reservado: false, tipo: 'Sala de Estudio', ubicacion: 'Edificio CAI').order(:nombre)

    if params[:espacio_id].present?
      @espacio = @espacios.find_by(id: params[:espacio_id])
      if @espacio
        @reserva.espacio = @espacio
      else
        redirect_to espacios_path, alert: 'La sala seleccionada no está disponible.'
      end
    end
  end

  def create
    @reserva = Reserva.new(reserva_params)
    @reserva.usuario = current_user
    @reserva.estado  = 'confirmada' 

     @espacios = Espacio.where(activo: true, reservado: false, tipo: 'Sala de Estudio', ubicacion: 'Edificio CAI').order(:nombre)
    @modulos  = Modulo.all.order(:hora_inicio)

    if @reserva.save
      redirect_to reservas_path, notice: 'Reserva creada exitosamente!'
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
    
    unless puede_ver?(@reserva) && @reserva.editable?
      redirect_to reservas_path, alert: 'Esta reserva no puede modificarse.'
      return
    end

    @espacios = Espacio.where(activo: true, reservado: false, tipo: 'Sala de Estudio', ubicacion: 'Edificio CAI').order(:nombre)
    @modulos  = Modulo.order(:hora_inicio)
  end

  def update

    unless puede_ver?(@reserva) && @reserva.editable?
      redirect_to reservas_path, alert: 'Esta reserva no puede modificarse.'
      return
    end

    if @reserva.update(reserva_params)
      redirect_to mis_reservas_path, notice: 'Reserva actualizada correctamente.'
    else
      @espacios = Espacio.where(activo: true, reservado: false, tipo: 'Sala de Estudio', ubicacion: 'Edificio CAI').order(:nombre)
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

  

  private

  def reserva_params
    params.require(:reserva).permit(:espacio_id, :modulo_id, :fecha)
  end


  def puede_ver?(reserva)
   current_user.present? && reserva.usuario_id == current_user.id
  end

  def set_reserva
    @reserva = Reserva.find(params[:id])
  end


  def reserva_empezada?(reserva)
    return false unless reserva.fecha && reserva.modulo&.hora_inicio

    inicio = Time.zone.local(
      reserva.fecha.year, reserva.fecha.month, reserva.fecha.day,
      reserva.modulo.hora_inicio.hour, reserva.modulo.hora_inicio.min
    )
    Time.current >= inicio
  end

end