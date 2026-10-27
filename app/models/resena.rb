# frozen_string_literal: true

class Resena < ApplicationRecord
  belongs_to :usuario
  belongs_to :espacio
  belongs_to :reserva
end
