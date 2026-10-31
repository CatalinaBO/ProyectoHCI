# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  root 'home#inicio'

# Usuarios
  get '/signup', to: 'usuarios#new', as: :signup
  post '/usuarios', to: 'usuarios#create'
  get '/perfil', to: 'usuarios#show', as: :perfil
  get '/perfil/editar', to: 'usuarios#edit', as: :editar_perfil
  patch '/perfil', to: 'usuarios#update'
  delete '/perfil', to: 'usuarios#destroy', as: :eliminar_cuenta
  get '/perfil/editar_contrasena',    to: 'usuarios#edit_password', as: :editar_contrasena
  patch '/perfil/actualizar_contrasena',to: 'usuarios#update_password', as: :actualizar_contrasena


  # Rutas para Espacios
  get '/espacios', to: 'espacios#index',  as: 'espacios'
  get '/espacios/new', to: 'espacios#new', as: 'new_espacio'
  post '/espacios', to: 'espacios#create'
  get '/espacios/index', to: 'espacios#todos_los_espacios'
  get '/espacios/espacios_eliminar', to: 'espacios#espacios_eliminar'
  delete '/espacios/:id', to: 'espacios#destroy'
  get '/espacios/busqueda_espacios', to: 'espacios#filtrar_espacios'
  get '/espacios/tipo/:tipo', to: 'espacios#por_tipo', as: 'espacios_por_tipo'

  # Rutas para Reservas
  get '/reservas/new', to: 'reservas#new', as: 'new_reserva'
  get '/reservas', to: 'reservas#index', as: 'index_reservas'
  post '/reservas', to: 'reservas#create', as: 'reservas'
  get '/reservas/reservas_pendientes', to: 'reservas#reservas_pendientes', as: :reservas_pendientes
  patch '/reservas/aceptar_reserva/:id', to: 'reservas#aceptar_reserva', as: :aceptar_reserva
  patch '/reservas/rechazar_reserva/:id', to: 'reservas#rechazar_reserva', as: :rechazar_reserva
  get '/reservas/:id', to: 'reservas#show', as: 'reserva'
  delete '/reservas/:id', to: 'reservas#destroy' # (sin uso)
  get '/mis_reservas', to: 'reservas#index', as: :mis_reservas
  get '/espacios/busqueda_espacios', to: 'espacios#filtrar_espacios'
  get '/reservas/:id/edit', to: 'reservas#edit', as: :edit_reserva
  patch '/reservas/:id', to: 'reservas#update', as: :update_reserva
  patch  '/reservas/:id/cancel', to: 'reservas#cancel', as: :cancel_reserva

  # Gestión de una solicitud (grupo de módulos)
  get   '/reserva_registrada/:grupo', to: 'reservas#registrada', as: :reserva_registrada
  get   '/mi_reserva/:grupo', to: 'reservas#mi_reserva', as: :mi_reserva
  patch '/mi_reserva/:grupo/iniciar', to: 'reservas#iniciar', as: :iniciar_mi_reserva
  patch '/mi_reserva/:grupo/cancelar', to: 'reservas#cancelar', as: :cancelar_mi_reserva
  patch '/mi_reserva/:grupo/finalizar', to: 'reservas#finalizar', as: :finalizar_mi_reserva

  # Rutas para Reseñas
  post '/resenas', to: 'resenas#crear_resena', as: 'resenas'
  delete '/resenas/:id', to: 'resenas#eliminar_resena'
  get '/resenas/buscar_resenas/:id', to: 'resenas#buscar_resenas_espacio'
  get '/resenas/buscar_resenas_admin/:id', to: 'resenas#buscar_resenas_admin'
  delete '/resenas/admin/:id', to: 'resenas#eliminar_resena_admin', as: :eliminar_resena_id


  # Admin
  get '/admin/inicio', to: 'usuario_admins#vista_inicial', as: :admin_inicio

  #Moderador
  get '/moderador/inicio', to: 'moderador#vista_inicial'
  get '/espacios/index/:ubicacion', to: 'moderador#espacios_ubicacion', as: :espacios_ubicacion
  get '/moderador/reservas_pendientes/:ubicacion', to: 'moderador#reservas_pendientes', as: :moderador_reservas_pendientes

  # Sesiones
  get '/login',  to: 'sesiones#new', as: :login
  post '/login',  to: 'sesiones#create'
  post '/invitado', to: 'sesiones#invitado', as: :invitado
  delete '/logout', to: 'sesiones#destroy', as: :logout

  # Rutas para Chats
  get    '/chats',     to: 'chats#index',  as: :chats
  post   '/chats',     to: 'chats#create'
  get    '/chats/:id', to: 'chats#show',   as: :chat
  post   '/chats/:chat_id/mensajes', to: 'mensajes#create', as: :chat_mensajes

  mount ActionCable.server => '/cable'

end
