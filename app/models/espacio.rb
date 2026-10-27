# frozen_string_literal: true

class Espacio < ApplicationRecord
  validates :nombre, presence: true, uniqueness: true
  validates :tipo, presence: true
  validates :ubicacion, presence: true
  validates :capacidad, presence: true
  validates :activo, presence: true

  has_many :locker, dependent: :destroy
  has_many :sala_estudio, dependent: :destroy
  has_many :mesa, dependent: :destroy
  has_many :reservas, dependent: :destroy
  
end
