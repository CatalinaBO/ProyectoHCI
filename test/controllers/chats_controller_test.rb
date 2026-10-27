# frozen_string_literal: true

require "test_helper"

class ChatsControllerTest < ActionController::TestCase
  fixtures :usuarios, :usuario_admins, :espacios, :reservas

  def setup
    @usuario      = usuarios(:usuario_normal)
    @usuario_admin = usuarios(:usuario_admin)
    @admin_record = usuario_admins(:admin_base)
    @espacio      = espacios(:CAI)
    @reserva      = reservas(:reserva_usuario_hoy_m1)
  end

  def log_in(usuario)
    @request.session[:usuario_id] = usuario.id
  end

  # Test 6 (S3): Comprueba que un usuario normal puede acceder al índice de chats.
  test "usuario normal ve index de chats correctamente" do
    log_in(@usuario)
    get :index
    assert_response :success
  end

  # Test 7 (S3): Comprueba que un usuario admin puede acceder al índice de chats.
  test "usuario admin ve index de chats correctamente" do
    log_in(@usuario_admin)
    get :index
    assert_response :success
  end

  # Test 8 (S3): Comprueba que crear un chat genera un nuevo registro y redirige al show.
  test "crear chat genera registro y redirige" do
    log_in(@usuario)
    assert_difference("Chat.count", 1) do
      post :create, params: {
        espacio_id: @espacio.id,
        reserva_id: @reserva.id
      }
    end
    assert_redirected_to chat_path(Chat.last)
  end

  # Test 9 (S3): Comprueba que el usuario dueño del chat puede ver el show.
  test "usuario dueño puede ver show de su chat" do
    log_in(@usuario)
    chat = Chat.create!(
      usuario:       @usuario,
      usuario_admin: @admin_record,
      espacio:       @espacio,
      reserva:       @reserva
    )
    get :show, params: { id: chat.id }
    assert_response :success
  end

  # Test 10 (S3): Comprueba que un usuario no dueño es redirigido al intentar ver un chat ajeno.
  test "usuario no dueño es redirigido al ver chat ajeno" do
    log_in(@usuario)
    chat = Chat.create!(
      usuario:       @usuario_admin,
      usuario_admin: @admin_record,
      espacio:       @espacio,
      reserva:       @reserva
    )
    get :show, params: { id: chat.id }
    assert_redirected_to chats_path
  end
end

