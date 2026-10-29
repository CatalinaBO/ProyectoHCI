# frozen_string_literal: true

class EspaciosController < ApplicationController
  TIPO_SALA = 'Sala de Estudio'.freeze

  UBICACION_CAI = 'Edificio CAI'.freeze

  def index
    @espacios = Espacio.where(activo: true, reservado: false, tipo: TIPO_SALA, ubicacion: UBICACION_CAI).order(:nombre)
    @counts = { TIPO_SALA => @espacios.count }
  end

  def todos_los_espacios
    @espacios = Espacio.all

    if moderador_user?
      moderador = Moderador.find_by(usuario_id: current_user.id)
      @ubicacion = moderador.por_ubicacion

      redirect_to espacios_ubicacion_path(@ubicacion)
    end

  end


  def filtrar_espacios
    @espacios = Espacio.where(reservado: false)
    @espacios = @espacios.where(tipo: params[:tipos]) if params[:tipos].present?
    @counts   = Espacio.where(reservado: false).group(:tipo).count
    @tipos_seleccionados = Array(params[:tipos])
    render :index
  end

  def por_tipo
    @tipo = params[:tipo].to_s
    raise ActiveRecord::RecordNotFound unless @tipo == TIPO_SALA

    @espacios = Espacio.where(activo: true, reservado: false, tipo: TIPO_SALA, ubicacion: UBICACION_CAI).order(:nombre)
    @titulo = 'Salas de estudio disponibles en CAI'
  end

  private

  def espacio_params
    # parametros que vienen desde el cuerpo
    params.require(:espacio).permit(:nombre, :tipo, :ubicacion, :capacidad, :activo)
  end
end