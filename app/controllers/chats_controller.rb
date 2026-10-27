# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :require_login
  before_action :set_chat, only: [:show]

    # Usuario ve chat propio; admin ve todos.
  def index
    if admin_user?
      @chats = Chat.includes(:usuario, :reserva, :espacio).order(updated_at: :desc)
    else
      @chats = Chat.where(usuario_id: current_user.id)
                   .includes(:reserva, :espacio).order(updated_at: :desc)
    end
  end

    # Crear/abrir chat
  def create
    admin = UsuarioAdmin.first or return redirect_back fallback_location: chats_path, 
                                                       alert: "No hay admin disponible."
      espacio = Espacio.find(params[:espacio_id])
      reserva = Reserva.find(params[:reserva_id])

      @chat = Chat.find_or_create_by!(
          usuario: current_user,
          usuario_admin: admin,
          espacio: espacio,
          reserva: reserva)
      redirect_to @chat
  end

  def show
    autorizar_chat!(@chat)
      @mensaje = Mensaje.new
      @mensajes = @chat.mensajes.order(:created_at)
  end


    private

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def autorizar_chat!(chat)
    return if admin_user? || chat.usuario_id == current_user.id
      redirect_to chats_path, alert: "No autorizado."
  end

end

