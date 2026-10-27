# frozen_string_literal: true

class CreateResenas < ActiveRecord::Migration[7.1]
  def change
    create_table :resenas do |t|
      t.references :usuario, null: false, foreign_key: true
      t.references :espacio, null: false, foreign_key: true
      t.references :reserva, null: false, foreign_key: true
      t.integer :rating
      t.text :comentario

      t.timestamps
    end
  end
end
