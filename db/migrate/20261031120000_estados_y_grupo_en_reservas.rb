# frozen_string_literal: true

class EstadosYGrupoEnReservas < ActiveRecord::Migration[7.1]
  def up
    add_column :reservas, :grupo, :string
    add_column :reservas, :inicio_uso_en, :datetime
    add_column :reservas, :finalizada_en, :datetime
    add_index :reservas, :grupo

    execute "UPDATE reservas SET grupo = 'r' || id WHERE grupo IS NULL"

    remove_index :reservas, name: 'idx_reservas_unicas_por_espacio_fecha_modulo'
    add_index :reservas, %i[espacio_id fecha modulo_id],
              unique: true,
              where: "estado IN ('pendiente', 'confirmada', 'en_uso')",
              name: 'idx_reservas_activas_unicas'
  end

  def down
    remove_index :reservas, name: 'idx_reservas_activas_unicas'
    add_index :reservas, %i[espacio_id fecha modulo_id], unique: true,
                                                         name: 'idx_reservas_unicas_por_espacio_fecha_modulo'
    remove_index :reservas, :grupo
    remove_column :reservas, :finalizada_en
    remove_column :reservas, :inicio_uso_en
    remove_column :reservas, :grupo
  end
end
