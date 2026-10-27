# frozen_string_literal: true

require "test_helper"

class ResenasControllerTest < ActionDispatch::IntegrationTest
  fixtures :usuarios, :espacios, :reservas, :resenas

  setup do
    @usuario = usuarios(:usuario_normal)
    @espacio = espacios(:CAI)
    @reserva = reservas(:reserva_usuario_hoy_m1)
    @resena  = resenas(:resena_usuario_sobre_cai)
  end

  # Test 13 (S3): Verifica que buscar_resenas_admin carga reseñas y responde OK.
  test "[GET] buscar_resenas_admin muestra reseñas para admin" do
    get "/resenas/buscar_resenas_admin/#{@espacio.id}"
    assert_response :success
    assert_includes response.body, @resena.comentario
  end

  # Test 14 (S3): Comprueba que crear_resena guarda una reseña válida y redirige a la reserva.
  test "[POST] crear_resena crea reseña válida y redirige a reserva" do
    assert_difference("Resena.count", 1) do
      post "/resenas", params: {
        usuario_id:  @usuario.id,
        espacio_id:  @espacio.id,
        reserva_id:  @reserva.id,
        rating:      5,
        comentario:  "Buen servicio"
      }
    end
    assert_response :redirect
    assert_redirected_to "/reservas/#{@reserva.id}"
  end

  # Test 15 (S3): Comprueba que eliminar_resena borra la reseña y vuelve a la reserva.
  test "[DELETE] eliminar_resena borra reseña y redirige a la reserva" do
    assert_difference("Resena.count", -1) do
      delete "/resenas/#{@resena.id}"
    end
    assert_response :redirect
    assert_redirected_to "/reservas/#{@reserva.id}"
  end
end

