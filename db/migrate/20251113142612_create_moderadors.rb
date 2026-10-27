class CreateModeradors < ActiveRecord::Migration[7.1]
  def change
    create_table :moderadors do |t|
      t.references :usuario, null: false, foreign_key: true
      t.text :tipo_espacio

      t.timestamps
    end
  end
end
