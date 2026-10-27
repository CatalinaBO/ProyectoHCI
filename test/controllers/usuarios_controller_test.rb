# frozen_string_literal: true

require 'test_helper'

class UsuariosControllerTest < ActionDispatch::IntegrationTest
  fixtures :usuarios

  setup do
    @usuario = usuarios(:usuario_normal)
  end

  # Test 14: Verifica que nuevo registro funciona correctamente.
  test "[GET] new muestra el formulario para registrar" do
    get signup_url
    assert_response :success
  end

  # Test 15: Se crea un usuario válido y reidirige al inicio exitosamente.
  test "[POST] create con datos válidos y redirige" do
    assert_difference("Usuario.count", 1) do
      post usuarios_url, params: {
        usuario: {nombre: "Nuevo", email: "testing@uc.cl", password: "abc123", password_confirmation: "abc123"}}
    end
    assert_redirected_to root_url
  end

  # Test 16: NO se crea usuario con datos inválidos.
  test "[POST] no se crea usuario con datos válidos y arroja error" do
    assert_no_difference("Usuario.count") do
      post usuarios_url, params: {usuario: {nombre: "", email: "imeil", password: "abc", password_confirmation: "000"}}
    end
    assert_response :unprocessable_entity
  end

end