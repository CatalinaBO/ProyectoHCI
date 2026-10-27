# frozen_string_literal: true

require "test_helper"

class ChatTest < ActiveSupport::TestCase
  fixtures :usuarios, :usuario_admins, :espacios, :reservas

  def setup
    @usuario = usuarios(:usuario_normal)
    @admin   = usuario_admins(:admin_base)
    @espacio = espacios(:CAI)
    @reserva = reservas(:reserva_usuario_hoy_m1)

    @chat = Chat.new(
      usuario:       @usuario,
      usuario_admin: @admin,
      espacio:       @espacio,
      reserva:       @reserva
    )
  end

  # Test 1 (S3): Comprueba que un chat es válido con usuario, admin, espacio y reserva asociados.
  test "chat válido con usuario, admin, espacio y reserva" do
    assert @chat.valid?
  end

  # Test 2 (S3): Verifica que el chat tenga asociado un usuario normal.
  test "tiene asociado un usuario normal" do
    assert_equal @usuario, @chat.usuario
  end

  # Test 3 (S3): Verifica que el chat tenga asociado un usuario administrador.
  test "tiene asociado un usuario admin" do
    assert_equal @admin, @chat.usuario_admin
  end

  # Test 4 (S3): Verifica que el chat tenga asociado un espacio.
  test "tiene asociado un espacio" do
    assert_equal @espacio, @chat.espacio
  end

  # Test 5 (S3): Verifica que el chat tenga asociada una reserva.
  test "tiene asociada una reserva" do
    assert_equal @reserva, @chat.reserva
  end
end