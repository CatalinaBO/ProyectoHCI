# frozen_string_literal: true

class Usuario < ApplicationRecord
  has_secure_password
  has_many :reservas, dependent: :destroy
  has_one_attached :foto_perfil

  validates :email, presence: true, uniqueness: true
  validates :rol, inclusion: { in: %w[registrado admin moderador] }
  validates :estado, inclusion: { in: %w[activo bloqueado] }

  def admin?
    self.rol == 'admin'
  end

  def moderador?
    self.rol == 'moderador'
  end
  
end
