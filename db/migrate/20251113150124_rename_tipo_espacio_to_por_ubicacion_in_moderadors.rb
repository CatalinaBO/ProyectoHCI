class RenameTipoEspacioToPorUbicacionInModeradors < ActiveRecord::Migration[7.1]
  def change
    rename_column :moderadors, :tipo_espacio, :por_ubicacion
  end
end
