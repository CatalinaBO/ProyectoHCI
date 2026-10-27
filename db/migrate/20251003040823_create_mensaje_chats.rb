# frozen_string_literal: true

class CreateMensajeChats < ActiveRecord::Migration[7.1]
  def change
    create_table :mensaje_chats do |t|
      t.references :chat, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: true
      t.references :usuario_admin, null: false, foreign_key: { to_table: :usuario_admins }

      t.timestamps
    end
  end
end
