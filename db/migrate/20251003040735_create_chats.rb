# frozen_string_literal: true

class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.references :usuario, null: false, foreign_key: true
      t.references :usuario_admin, null: false, foreign_key: { to_table: :usuario_admins }
      t.references :espacio, null: false, foreign_key: true
      t.references :reserva, null: false, foreign_key: true

      t.timestamps
    end
  end
end
