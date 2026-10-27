# frozen_string_literal: true

class MensajesController < ApplicationController
  before_action :require_login
  before_action :set_chat

def create
  contenido = mensaje_params[:contenido].to_s.strip
  return redirect_to @chat, alert: "El mensaje no puede ir vacío." if contenido.blank?

  @mensaje = @chat.mensajes.build(usuario: current_user, contenido: contenido)

  if @mensaje.save
    @chat.touch
    respond_to do |format|
      format.turbo_stream { head :no_content }
      format.html        { redirect_to @chat }
    end
  else
    redirect_to @chat, alert: @mensaje.errors.full_messages.to_sentence
  end
end


  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
    return if admin_user? || @chat.usuario_id == current_user.id
    redirect_to chats_path, alert: "No autorizado."
  end

  def mensaje_params
    params.require(:mensaje).permit(:contenido)
  end

end
