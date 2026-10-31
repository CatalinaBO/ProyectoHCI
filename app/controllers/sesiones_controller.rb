class SesionesController < ApplicationController
  def new
  end

  def create
    usuario = Usuario.find_by(email: params[:email])

    if usuario&.authenticate(params[:password])
      session[:usuario_id] = usuario.id
      redirigir_despues_de_entrar("¡Bienvenido, #{usuario.nombre.presence || usuario.email}!")
    else
      flash.now[:alert] = 'Email o contraseña incorrectos'
      render :new, status: :unprocessable_entity
    end
  end

  # Entrar sin crear cuenta: genera un usuario temporal.
  def invitado
    clave = SecureRandom.hex(16)
    usuario = Usuario.create!(
      nombre: 'Invitado',
      email: "invitado-#{SecureRandom.uuid}@demo.local",
      password: clave,
      password_confirmation: clave,
      rol: 'registrado',
      estado: 'activo'
    )
    session[:usuario_id] = usuario.id
    redirigir_despues_de_entrar('Entraste como invitado.')
  end

  def destroy
    session.delete(:usuario_id)
    redirect_to root_path, notice: 'Sesión cerrada correctamente.'
  end

  private

  # Si venía de elegir módulos sin sesión, vuelve a la cuadrícula con esa selección marcada.
  def redirigir_despues_de_entrar(mensaje)
    seleccion = session.delete(:seleccion_pendiente)
    if seleccion.present?
      redirect_to espacios_path(fecha: seleccion['fecha'], espacio_id: seleccion['espacio_id'],
                                modulo_ids: seleccion['modulo_ids']),
                  notice: "#{mensaje} Revisa tu selección y presiona \"Continuar con la reserva\"."
    else
      redirect_to espacios_path, notice: mensaje
    end
  end
end
