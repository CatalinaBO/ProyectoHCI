# frozen_string_literal: true

class CreateReservas < ActiveRecord::Migration[7.1]
  def change
    create_table :reservas do |t|
      t.references :usuario, null: false, foreign_key: true
      t.references :espacio, null: false, foreign_key: true
      t.date :fecha
      t.references :modulo, null: false, foreign_key: true
      t.string :estado
      t.integer :confirmada_por
      t.datetime :confirmada_en
      t.integer :rechazada_por
      t.string :rechazo_motivo, limit: 250

      t.timestamps
    end
  end
end
