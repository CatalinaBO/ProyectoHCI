# frozen_string_literal: true
require "test_helper"

class EspaciosControllerTest < ActionDispatch::IntegrationTest
  fixtures :usuarios, :espacios

  setup do
    @usuario = usuarios(:usuario_normal)
    @admin = usuarios(:usuario_admin)
    @espacio = espacios(:CAI)
  end

  # Test 1: Verifica que index funciona correctamente.
  test "[GET] usuario puede ver los espacios" do
    as_user(@usuario) {get espacios_url}
    assert_response :success
  end

  # Test 2: Verifica que new funciona correctamente.
  test "[GET] usuario puede crear nuevo espacio (formulario)" do
    as_user(@usuario) {get new_espacio_url}
    assert_response :success
  end

  # Test 18: Crea un espacio válido correctamente.
  test "[POST] create con datos válidos redirige a new" do
    as_user(@admin) do
      assert_difference("Espacio.count", 1) do
        post espacios_url, params: {
          espacio: {
            nombre: "Nuevo",
            tipo: "Sala de Estudio",
            ubicacion: "Ing",
            capacidad: 10,
            activo: true,
            reservado: false
          }
        }
      end
      assert_redirected_to new_espacio_url
    end
  end

  # Test 19: NO crea espacio con datos inválidos (nombre vacío).
  test "[POST] no crea espacio con datos inválidos" do
    as_user(@admin) do
      assert_no_difference("Espacio.count") do
        post espacios_url, params: {
          espacio: {
            nombre: "",
            activo: true,
            tipo: "Sala para descansar",
            ubicacion: "sin ubi",
            capacidad: 0,
            reservado: false
          }
        }
      end
      assert_response :unprocessable_entity
    end
  end

  # Test 20: Verifica que index carga todos los espacios.
  test "[GET] index lista los espacios" do
    as_user(@admin) {get "/espacios/index"}
    assert_response :success
  end

  # Test 21: Verifica que se puede filtrar espacios (búsqueda).
  test "[GET] busqueda_espacios responde correctamente" do
    as_user(@usuario) {get "/espacios/busqueda_espacios"}
    assert_redirected_to espacios_url
  end

  # Test 22.1: Filtra correctamente espacios por tipo (Sala de Estudio).
  test "[GET] filtra correctamente (1)" do
    get espacios_por_tipo_url("Sala de Estudio")
    assert_redirected_to espacios_url
  end

  # Test 22.2: Filtra correctamente espacios por tipo (Locker).
  test "[GET] filtra correctamente (2)" do
    get espacios_por_tipo_url("Locker")
    assert_redirected_to espacios_url
  end

  # Test 22.3: Filtra correctamente espacios por tipo (Mesa).
  test "[GET] filtra correctamente (3)" do
    get espacios_por_tipo_url("Mesa")
    assert_redirected_to espacios_url
  end

  # Test 23: destroy elimina un espacio sin reservas (espacio_prueba del .yml).
  test "[DELETE] elimina espacio y redirige a eliminar" do
    as_user(@admin) do
      espacio = espacios(:espacio_prueba)
      assert_difference("Espacio.count", -1) do
        delete "/espacios/#{espacio.id}"
      end
      assert_redirected_to "/espacios/espacios_eliminar"
    end
  end
end
