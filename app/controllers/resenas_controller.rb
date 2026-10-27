# frozen_string_literal: true

class ResenasController < ApplicationController

  def crear_resena
    @resena = Resena.new(resena_params)

    if @resena.save
      redirect_to "/reservas/#{@resena.reserva_id}"
    else
      flash.now[:alert] = @reserva.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  
  end 

  def eliminar_resena
    @resena_eliminar = Resena.find(params[:id])
    @reserva = Reserva.find_by(id: @resena_eliminar.reserva_id)
    @resena_eliminar.destroy

    redirect_to "/reservas/#{@reserva.id}"
  end

  def buscar_resenas_espacio
    @resenas = Resena.where(espacio_id: params[:id])
    @tipo_espacio = Espacio.find_by(id: params[:id])&.tipo

    render "index"
  end

  def buscar_resenas_admin
    @resenas = Resena.where(espacio_id: params[:id])
    @espacio = Espacio.find_by(id: params[:id])

    render "resenas_admin"
  end

  def eliminar_resena_admin
    @resena_eliminar = Resena.find(params[:id])
    @espacio = Espacio.find_by(id: @resena_eliminar.espacio_id)
    @resena_eliminar.destroy

    redirect_to "/resenas/buscar_resenas_admin/#{@espacio.id}"
  end


  private

  def resena_params
    params.permit(:usuario_id, :espacio_id, :reserva_id, :rating, :comentario)
  end

end
