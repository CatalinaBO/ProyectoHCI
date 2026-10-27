# frozen_string_literal: true

class CreateModulos < ActiveRecord::Migration[7.1]
  def change
    create_table :modulos do |t|
      t.time :hora_inicio
      t.time :hora_fin

      t.timestamps
    end
  end
end
