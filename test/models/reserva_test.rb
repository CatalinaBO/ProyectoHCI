# frozen_string_literal: true

require "test_helper"

class ReservaTest < ActiveSupport::TestCase
  fixtures :usuarios, :espacios, :modulos, :reservas

  setup do
    @reserva = reservas(:reserva_usuario_hoy_m1)
  end

  # Test 12: Comprueba que se requiera usuario, espacio y módulo en la reserva.
  test "requiere usuario, espacio y módulo" do
    r = Reserva.new(fecha: Date.today, estado: "pendiente")
    refute r.valid?

    r.usuario = usuarios(:usuario_normal)
    refute r.valid?

    r.espacio = Espacio.first
    refute r.valid?

    r.modulo = Modulo.first
    assert r.valid?
  end

  # Test 13: Comprueba que reserva con estado cancelada no se pueda editar.
  test "estado cancelada no es editable" do
    r = @reserva
    r.update!(estado: "cancelada")
    assert_not r.editable?
  end
  
end
