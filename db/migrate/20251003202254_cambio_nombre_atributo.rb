# frozen_string_literal: true

class CambioNombreAtributo < ActiveRecord::Migration[7.1]
  def change
    rename_column :espacios, :reservable, :reservado
  end
end
