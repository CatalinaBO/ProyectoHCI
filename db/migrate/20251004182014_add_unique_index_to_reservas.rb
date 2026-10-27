# frozen_string_literal: true

class AddUniqueIndexToReservas < ActiveRecord::Migration[7.1]
  def change
    add_index :reservas, %i[espacio_id fecha modulo_id],
              unique: true,
              name: 'idx_reservas_unicas_por_espacio_fecha_modulo'
  end
end
