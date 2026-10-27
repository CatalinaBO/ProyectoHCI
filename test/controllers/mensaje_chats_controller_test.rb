# frozen_string_literal: true

require "test_helper"

class MensajesControllerTest < ActionController::TestCase
  fixtures :usuarios, :usuario_admins, :espacios, :reservas

  def setup
    @usuario       = usuarios(:usuario_normal)
    @usuario_otro  = usuarios(:usuario_admin)
    @admin_record  = usuario_admins(:admin_base)
    @espacio       = espacios(:CAI)
    @reserva       = reservas(:reserva_usuario_hoy_m1)

    @chat = Chat.create!(
      usuario:       @usuario,
      usuario_admin: @admin_record,
      espacio:       @espacio,
      reserva:       @reserva
    )
  end

  def log_in(usuario)
    @request.session[:usuario_id] = usuario.id
  end

  # Test 11 (S3): Comprueba que el usuario dueño del chat puede crear un mensaje válido.
  test "usuario dueño puede crear mensaje válido" do
    log_in(@usuario)
    assert_difference("Mensaje.count", 1) do
      post :create, params: {
        chat_id: @chat.id,
        mensaje: { contenido: "Hola, testeando" }
      } end
    assert_redirected_to chat_path(@chat)
  end

  # Test 12 (S3): Comprueba que un mensaje vacío no se guarda y redirige al chat.
  test "mensaje vacío no se guarda" do
    log_in(@usuario)
    assert_no_difference("Mensaje.count") do
      post :create, params: {
        chat_id: @chat.id,
        mensaje: { contenido: "   " }
      } end
    assert_redirected_to chat_path(@chat)
  end

end

