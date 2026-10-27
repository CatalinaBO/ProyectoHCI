# frozen_string_literal: true
require "test_helper"

class ReservasControllerTest < ActionDispatch::IntegrationTest
  fixtures :usuarios, :espacios, :modulos, :reservas

  setup do
    @user    = usuarios(:usuario_normal)
    @admin   = usuarios(:usuario_admin)
    @espacio = espacios(:CAI)
    @modulo  = modulos(:m1)
    @reserva = reservas(:reserva_usuario_hoy_m1)
  end

  # Test 3: verifica que el usuario registrado pueda acceder a la lista de sus reservas.
  test "[GET] index funciona para usuario registrado" do
    as_user(@user) do
      get mis_reservas_url
      assert_response :success
    end
  end

  # Test 4: verifica que el formulario para crear una reserva nueva funcione adecauadamente.
  test "[GET] new funciona" do
    as_user(@user) do
      get new_reserva_url
      assert_response :success
    end
  end

  # Test 5: Comprueba que se guarda la reserva y redirige.
  test "[POST] crea una reserva válida y redirige" do
    as_user(@user) do
      assert_difference("Reserva.count", 1) do
        post reservas_url, params: {
          reserva: {espacio_id: espacios(:DIPRE).id,modulo_id: @modulo.id,fecha: @reserva.fecha}}
      end
      assert_response :redirect
      assert_redirected_to reservas_url
    end
  end

  # Test 6: Comprueba que no se cree reserva repetida o inválida.
  test "[POST] rechaza crear reserva duplicada" do
    as_user(@user) do
      assert_no_difference("Reserva.count") do
        post reservas_url, params: {
          reserva: {espacio_id: @espacio.id,modulo_id: @modulo.id,fecha: @reserva.fecha}}
      end
      assert_response :unprocessable_entity
    end
  end

  # Test 7: Un usuario solo debe ver sus propias reservas.
  test "[GET] show permite ver la propia reserva y bloquea ajenas" do
    as_user(@user) do
      get reserva_url(@reserva)
      assert_response :success

      ajena = reservas(:reserva_admin_hoy_m2)
      get reserva_url(ajena)
      assert_response :redirect
      assert_redirected_to reservas_url
    end
  end

  # Test 8: Simula que el usuario intenta cancelar antes de comenzar la reserva.
  test "[PATCH] cancel cancela si aún no comienza y redirige a lista" do
    as_user(@user) do
      inicio = @reserva.inicio_datetime
      travel_to(inicio - 10.minutes) do
        patch cancel_reserva_url(@reserva)
        assert_response :redirect
        assert_redirected_to mis_reservas_url
        @reserva.reload
        assert_equal "cancelada", @reserva.estado
      end
    end
  end

  # Test 9: Simula que el usuario intenta cancelar después de comenzada la reserva.
  test "[PATCH] cancel NO permite cancelar si la reserva ya comenzó" do
    as_user(@user) do
      inicio = @reserva.inicio_datetime
      travel_to(inicio + 5.minutes) do
        patch cancel_reserva_url(@reserva)
        assert_response :redirect
        assert_redirected_to reserva_url(@reserva)
        @reserva.reload
        refute_equal "cancelada", @reserva.estado
      end
    end
  end

  # Test 10: Comprueba que no se pueda editar una reserva si está cancelada.
  test "[GET] edit bloquea si la reserva NO es editable" do
    as_user(@user) do
      @reserva.update!(estado: "cancelada")
      get edit_reserva_url(@reserva)
      assert_response :redirect
      assert_redirected_to mis_reservas_url
    end
  end

  # Test 11: Comprueba que la reserva se puede cancelar dado que no ha comenzado.
  test "[PATCH] update actualiza si la reserva SÍ es editable" do
    as_user(@user) do
      inicio = @reserva.inicio_datetime
      travel_to(inicio - 10.minutes) do
        otro_modulo = modulos(:m2)
        patch reserva_url(@reserva), params: { reserva: { modulo_id: otro_modulo.id } }
        assert_response :redirect
        assert_redirected_to mis_reservas_url
        @reserva.reload
        assert_equal otro_modulo.id, @reserva.modulo_id
      end
    end
  end

  # Test 13 (S3): Comprueba que no se vuelve a cancelar una reserva que ya está cancelada.
  test "[PATCH] cancel no cambia una reserva ya cancelada" do
    as_user(@user) do
      @reserva.update!(estado: "cancelada")
      assert_no_difference("Reserva.where(estado: 'cancelada').count") do
        patch cancel_reserva_url(@reserva)
      end
      assert_response :redirect
      @reserva.reload
      assert_equal "cancelada", @reserva.estado
    end
  end

end