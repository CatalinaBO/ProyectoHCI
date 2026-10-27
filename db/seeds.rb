# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

admin_user = Usuario.find_or_create_by!(email: 'admin@mail.com') do |usuario|
  usuario.nombre = 'Administrador'
  usuario.password = '12345'
  usuario.rol = 'admin'
  usuario.estado = 'activo'
end

UsuarioAdmin.find_or_create_by!(usuario: admin_user)

moderador_sanjoaquin = Usuario.find_or_create_by!(email: 'moderadorsj@mail.com') do |usuario|
  usuario.nombre = 'Moderador San Joaquín'
  usuario.password = '12345'
  usuario.rol = 'moderador'
  usuario.estado = 'activo'
end

Moderador.find_or_create_by!(usuario: moderador_sanjoaquin) do |moderador|
  moderador.por_ubicacion = 'Biblioteca San Joaquín'
end

moderador_cai = Usuario.find_or_create_by!(email: 'moderadorcai@mail.com') do |usuario|
  usuario.nombre = 'Moderador CAI'
  usuario.password = '12345'
  usuario.rol = 'moderador'
  usuario.estado = 'activo'
end

Moderador.find_or_create_by!(usuario: moderador_cai) do |moderador|
  moderador.por_ubicacion = 'Edificio CAI'
end

moderador_gauss = Usuario.find_or_create_by!(email: 'moderadorgauss@mail.com') do |usuario|
  usuario.nombre = 'Moderador GAUSS'
  usuario.password = '12345'
  usuario.rol = 'moderador'
  usuario.estado = 'activo'
end

Moderador.find_or_create_by!(usuario: moderador_gauss) do |moderador|
  moderador.por_ubicacion = 'Biblioteca GAUSS'
end

MODULOS = [
  ["08:20", "09:30"],
  ["09:40", "10:50"],
  ["11:00", "12:10"],
  ["12:20", "13:30"],
  ["14:50", "16:00"],
  ["16:10", "17:20"],
  ["17:30", "18:40"],
  ["18:50", "20:00"]
]

MODULOS.each do |inicio, fin|
  Modulo.find_or_create_by!(hora_inicio: inicio, hora_fin: fin)
end