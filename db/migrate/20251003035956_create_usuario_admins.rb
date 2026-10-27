# frozen_string_literal: true

class CreateUsuarioAdmins < ActiveRecord::Migration[7.1]
  def change
    create_table :usuario_admins do |t|
      t.references :usuario, null: false, foreign_key: true

      t.timestamps
    end
  end
end
