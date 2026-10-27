# frozen_string_literal: true

class Chat < ApplicationRecord
  belongs_to :usuario
  belongs_to :usuario_admin, class_name: 'UsuarioAdmin'
  belongs_to :espacio
  belongs_to :reserva

  has_many :mensajes, dependent: :destroy
  validates :usuario_id, :usuario_admin_id, :espacio_id, :reserva_id, presence: true

  scope :por_usuario, ->(user) { where(usuario_id: user.id) }
end
