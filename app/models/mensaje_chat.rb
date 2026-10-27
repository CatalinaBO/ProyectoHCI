# frozen_string_literal: true

class MensajeChat < ApplicationRecord
  belongs_to :chat
  belongs_to :usuario
  belongs_to :usuario_admin, class_name: 'UsuarioAdmin'
end
