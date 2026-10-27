class ModeradorController < ApplicationController

  def vista_inicial
    @moderador = Moderador.find_by(usuario: current_user)
  end

  def espacios_ubicacion
    ubicacion = params[:ubicacion]
    @espacios = Espacio.where(ubicacion: ubicacion)
  end

  def reservas_pendientes
    ubicacion = params[:ubicacion]
    @reservas = Reserva.joins(:espacio)
                .where(estado: 'pendiente', espacios: { ubicacion: ubicacion })
                .includes(:espacio, :modulo, :usuario)
  end

  

end
