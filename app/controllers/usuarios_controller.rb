# frozen_string_literal: true

class UsuariosController < ApplicationController
  before_action :require_login, only: %i[show edit update edit_password update_password destroy]
  before_action :set_usuario, only: %i[show edit update edit_password update_password destroy]

  def new
    @usuario = Usuario.new
  end

  def create
    @usuario = Usuario.new(usuario_params_create)
    @usuario.rol    ||= 'registrado'
    @usuario.estado ||= 'activo'

    if @usuario.save
      redirect_to root_path, notice: '¡Cuenta creada con éxito!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @usuario.update(usuario_params)
      redirect_to perfil_path, notice: 'Foto de perfil actualizada.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit_password
  end

  def update_password
    if @usuario.authenticate(params[:usuario][:current_password])
      if @usuario.update(password_params)
        redirect_to perfil_path, notice: 'Contraseña actualizada con éxito.'
      else
        render :edit_password, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = 'La contraseña actual es incorrecta.'
      render :edit_password, status: :unprocessable_entity
    end
  end

  def destroy
    if @usuario.destroy
      reset_session
      redirect_to root_path, notice: 'Cuenta eliminada con éxito.'
    else
      redirect_to perfil_path, alert: 'No se pudo eliminar la cuenta.'
    end
  end


  private

  def set_usuario
    @usuario = current_user
  end

  def usuario_params_create
    params.require(:usuario).permit(:nombre, :email, :password, :password_confirmation, :info_personal)
  end

  def usuario_params
    params.require(:usuario).permit(:foto_perfil, :info_personal)
  end

  def password_params
    params.require(:usuario).permit(:password, :password_confirmation)
  end
end
