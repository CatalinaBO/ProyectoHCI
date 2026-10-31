# frozen_string_literal: true
require "test_helper"

class ReservasControllerTest < ActionDispatch::IntegrationTest
  fixtures :usuarios, :espacios, :modulos, :reservas

  setup do
    @user    = usuarios(:usuario_normal)
    @admin   = usuarios(:usuario_admin)
    @espacio = espacios(:CAI)
    @m1      = modulos(:m1)
    @m2      = modulos(:m2)
    @reserva = reservas(:reserva_usuario_hoy_m1)
    @fecha   = @reserva.fecha
  end

  def antes_del_dia(&)
    travel_to(Time.zone.local(@fecha.year, @fecha.month, @fecha.day, 7, 0), &)
  end

  test "[GET] mis reservas funciona" do
    as_user(@user) do
      get mis_reservas_url
      assert_response :success
      assert_select "h1", /Mis reservas/
    end
  end

  test "[GET] new redirige a la cuadrícula de disponibilidad" do
    as_user(@user) do
      get new_reserva_url
      assert_redirected_to espacios_url
    end
  end

  test "[POST] crea varios módulos en una sola solicitud y muestra 'Reserva registrada'" do
    as_user(@user) do
      antes_del_dia do
        otra_fecha = @fecha + 2
        assert_difference("Reserva.count", 2) do
          post reservas_url, params: { espacio_id: @espacio.id, fecha: otra_fecha, modulo_ids: [@m1.id, @m2.id] }
        end
        nuevas = Reserva.order(:id).last(2)
        assert_equal 1, nuevas.map(&:grupo).uniq.size
        assert_redirected_to reserva_registrada_url(nuevas.first.grupo)
        follow_redirect!
        assert_select "h1", "Reserva registrada"
      end
    end
  end

  test "[POST] no registra nada si un módulo ya está ocupado" do
    as_user(@user) do
      antes_del_dia do
        assert_no_difference("Reserva.count") do
          post reservas_url, params: { espacio_id: @espacio.id, fecha: @fecha, modulo_ids: [@m1.id, @m2.id] }
        end
        assert_redirected_to espacios_url(fecha: @fecha.to_s)
        assert_match "ya no está disponible", flash[:alert]
      end
    end
  end

  test "[POST] se puede volver a reservar un bloque cancelado" do
    as_user(@user) do
      antes_del_dia do
        @reserva.update!(estado: "cancelada")
        assert_difference("Reserva.count", 1) do
          post reservas_url, params: { espacio_id: @espacio.id, fecha: @fecha, modulo_ids: [@m1.id] }
        end
      end
    end
  end

  test "[GET] show antiguo lleva a 'Mi reserva' y bloquea ajenas" do
    as_user(@user) do
      get reserva_url(@reserva)
      assert_redirected_to mi_reserva_url(@reserva.grupo)

      get mi_reserva_url(reservas(:reserva_admin_hoy_m2).grupo)
      assert_redirected_to mis_reservas_url
    end
  end

  test "[PATCH] cancelar antes del inicio libera el bloque" do
    as_user(@user) do
      antes_del_dia do
        patch cancelar_mi_reserva_url(@reserva.grupo)
        assert_redirected_to mi_reserva_url(@reserva.grupo)
        assert_equal "cancelada", @reserva.reload.estado
      end
    end
  end

  test "[PATCH] iniciar solo funciona dentro del horario reservado" do
    as_user(@user) do
      antes_del_dia do
        patch iniciar_mi_reserva_url(@reserva.grupo)
        assert_equal "confirmada", @reserva.reload.estado
      end
      travel_to(@reserva.inicio_datetime + 5.minutes) do
        patch iniciar_mi_reserva_url(@reserva.grupo)
        @reserva.reload
        assert_equal "en_uso", @reserva.estado
        assert_not_nil @reserva.inicio_uso_en
      end
    end
  end

  test "[PATCH] finalizar uso deja liberados los módulos que no han terminado" do
    as_user(@user) do
      travel_to(@reserva.inicio_datetime + 20.minutes) do
        @reserva.update!(estado: "en_uso", inicio_uso_en: Time.current)
        patch finalizar_mi_reserva_url(@reserva.grupo)
        assert_redirected_to mi_reserva_url(@reserva.grupo)
        assert_equal "liberada", @reserva.reload.estado
        assert_equal "Liberada", @reserva.estado_visible

        # El bloque liberado se puede volver a reservar
        assert_difference("Reserva.count", 1) do
          post reservas_url, params: { espacio_id: @espacio.id, fecha: @fecha, modulo_ids: [@m1.id] }
        end
      end
    end
  end

  test "estado 'Sin información confirmada' si nadie declara el inicio" do
    travel_to(@reserva.inicio_datetime + 5.minutes) { assert_equal "Reservada", @reserva.estado_visible }
    travel_to(@reserva.inicio_datetime + 16.minutes) { assert_equal "Sin información confirmada", @reserva.estado_visible }
  end
end
