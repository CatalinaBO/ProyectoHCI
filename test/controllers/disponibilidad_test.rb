# frozen_string_literal: true
require "test_helper"

class DisponibilidadTest < ActionDispatch::IntegrationTest
  fixtures :usuarios, :espacios, :modulos, :reservas

  setup do
    @espacio = espacios(:CAI)
    @espacio.update!(ubicacion: "Edificio CAI")
    @reserva = reservas(:reserva_usuario_hoy_m1)
  end

  test "la cuadrícula muestra salas, módulos y estados" do
    travel_to(Time.zone.local(@reserva.fecha.year, @reserva.fecha.month, @reserva.fecha.day, 7, 0)) do
      get espacios_url(fecha: @reserva.fecha)
      assert_response :success
      assert_select "h1", "Disponibilidad de salas CAI"
      assert_select "table.grilla th", /08:20 - 09:30/
      assert_select "table.grilla .badge-estado", "Reservada"
      assert_select "input[name='modulo_ids[]']", 1 # solo m2 queda disponible
      assert_select "button#btn-continuar", /Continuar con la reserva/
      assert_select ".ficha h6", /Modalidad de uso/
    end
  end

  test "entrar como invitado crea un usuario y retoma la selección" do
    post invitado_url
    assert_redirected_to espacios_url
    assert Usuario.where("email LIKE ?", "invitado-%@demo.local").exists?
  end
end
