# frozen_string_literal: true

class RenombrarPassword < ActiveRecord::Migration[7.1]
  def change
    rename_column :usuarios, :password, :password_digest
  end
end
