class CreateMensajes < ActiveRecord::Migration[7.1]
  def change
    create_table :mensajes do |t|
      t.references :chat, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: true
      t.text :contenido

      t.timestamps
    end
  end
end
