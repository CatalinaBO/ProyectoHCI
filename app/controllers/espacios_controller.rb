# frozen_string_literal: true

class EspaciosController < ApplicationController
  TIPOS = ['Mesa', 'Sala de Estudio', 'Locker'].freeze
  UBICACIONES = [
    { label: 'Biblioteca San Joaquín', value: 'Biblioteca San Joaquín' },
    { label: 'Biblioteca Gauss',       value: 'Biblioteca GAUSS' },
    { label: 'CAI',                    value: 'Edificio CAI' }   
  ].freeze

  def new
    @espacio = Espacio.new
  end

  def create
    @espacio = Espacio.new(espacio_params)
    @espacio.reservado = false

    if @espacio.save

      SalaEstudio.create(espacio_id: @espacio.id) if @espacio.tipo == 'Sala de Estudio'

      Locker.create(espacio_id: @espacio.id) if @espacio.tipo == 'Locker'

      Mesa.create(espacio_id: @espacio.id) if @espacio.tipo == 'Mesa'

      flash[:notice] = 'Espacio guardado correctamente :)'
      redirect_to '/espacios/new'

    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    base = Espacio.where(reservado: false)
    @counts = base.group(:tipo).count
  end

  def todos_los_espacios
    @espacios = Espacio.all

    if moderador_user?
      moderador = Moderador.find_by(usuario_id: current_user.id)
      @ubicacion = moderador.por_ubicacion

      redirect_to espacios_ubicacion_path(@ubicacion)
    end

  end

  def espacios_eliminar
    @espacios = Espacio.all
  end

  def destroy
    @espacio_eliminado = Espacio.find(params[:id])
    @espacio_eliminado.destroy
    redirect_to '/espacios/espacios_eliminar'
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
    raise ActiveRecord::RecordNotFound unless TIPOS.include?(@tipo)

    @ubicaciones = UBICACIONES
    @ubicacion   = params[:ubicacion].presence

    scope = Espacio.where(activo: true, reservado: false, tipo: @tipo)
    scope = scope.where(ubicacion: @ubicacion) if @ubicacion.present?
    @espacios = scope.order(:nombre)

    @titulo = case @tipo
              when 'Mesa' then 'Mesas disponibles'
              when 'Sala de Estudio' then 'Salas de estudio disponibles'
              when 'Locker' then 'Lockers disponibles'
              end
  end

  private

  def espacio_params
    # parametros que vienen desde el cuerpo
    params.require(:espacio).permit(:nombre, :tipo, :ubicacion, :capacidad, :activo)
  end
end