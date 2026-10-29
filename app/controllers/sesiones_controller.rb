class SesionesController < ApplicationController
  def new
  end

  def create
    usuario = Usuario.find_by(email: params[:email])

    if usuario&.authenticate(params[:password])
      session[:usuario_id] = usuario.id
      redirect_to root_path, notice: "¡Bienvenido, #{usuario.nombre.presence || usuario.email}!"
  
    else
      flash.now[:alert] = 'Email o contraseña incorrectos'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:usuario_id)
    redirect_to root_path, notice: 'Sesión cerrada correctamente.'
  end
end
