# frozen_string_literal: true

class CreateMesas < ActiveRecord::Migration[7.1]
  def change
    create_table :mesas do |t|
      t.references :espacio, null: false, foreign_key: true

      t.timestamps
    end
  end
end
