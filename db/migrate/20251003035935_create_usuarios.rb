# frozen_string_literal: true

class CreateUsuarios < ActiveRecord::Migration[7.1]
  def change
    create_table :usuarios do |t|
      t.string :nombre
      t.string :email
      t.string :password
      t.string :rol
      t.string :estado

      t.timestamps
    end
    add_index :usuarios, :email, unique: true
  end
end
