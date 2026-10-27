class AgregarInfopersonalAUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_column :usuarios, :info_personal, :text
  end
end
