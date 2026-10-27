# frozen_string_literal: true

class CreateEspacios < ActiveRecord::Migration[7.1]
  def change
    create_table :espacios do |t|
      t.string :nombre
      t.string :tipo
      t.string :ubicacion
      t.string :capacidad
      t.boolean :activo
      t.boolean :reservable

      t.timestamps
    end
    add_index :espacios, :nombre, unique: true
  end
end
