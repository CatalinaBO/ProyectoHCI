# frozen_string_literal: true

class AgregarActivoAModulos < ActiveRecord::Migration[7.1]
  def change
    add_column :modulos, :activo, :boolean
  end
end
