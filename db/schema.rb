# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_10_31_120000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "chats", force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.integer "usuario_admin_id", null: false
    t.integer "espacio_id", null: false
    t.integer "reserva_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["espacio_id"], name: "index_chats_on_espacio_id"
    t.index ["reserva_id"], name: "index_chats_on_reserva_id"
    t.index ["usuario_admin_id"], name: "index_chats_on_usuario_admin_id"
    t.index ["usuario_id"], name: "index_chats_on_usuario_id"
  end

  create_table "espacios", force: :cascade do |t|
    t.string "nombre"
    t.string "tipo"
    t.string "ubicacion"
    t.string "capacidad"
    t.boolean "activo"
    t.boolean "reservado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_espacios_on_nombre", unique: true
  end

  create_table "lockers", force: :cascade do |t|
    t.integer "espacio_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["espacio_id"], name: "index_lockers_on_espacio_id"
  end

  create_table "mensaje_chats", force: :cascade do |t|
    t.integer "chat_id", null: false
    t.integer "usuario_id", null: false
    t.integer "usuario_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_mensaje_chats_on_chat_id"
    t.index ["usuario_admin_id"], name: "index_mensaje_chats_on_usuario_admin_id"
    t.index ["usuario_id"], name: "index_mensaje_chats_on_usuario_id"
  end

  create_table "mensajes", force: :cascade do |t|
    t.integer "chat_id", null: false
    t.integer "usuario_id", null: false
    t.text "contenido"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_mensajes_on_chat_id"
    t.index ["usuario_id"], name: "index_mensajes_on_usuario_id"
  end

  create_table "mesas", force: :cascade do |t|
    t.integer "espacio_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["espacio_id"], name: "index_mesas_on_espacio_id"
  end

  create_table "moderadors", force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.text "por_ubicacion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["usuario_id"], name: "index_moderadors_on_usuario_id"
  end

  create_table "modulos", force: :cascade do |t|
    t.time "hora_inicio"
    t.time "hora_fin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "activo"
  end

  create_table "resenas", force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.integer "espacio_id", null: false
    t.integer "reserva_id", null: false
    t.integer "rating"
    t.text "comentario"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["espacio_id"], name: "index_resenas_on_espacio_id"
    t.index ["reserva_id"], name: "index_resenas_on_reserva_id"
    t.index ["usuario_id"], name: "index_resenas_on_usuario_id"
  end

  create_table "reservas", force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.integer "espacio_id", null: false
    t.date "fecha"
    t.integer "modulo_id", null: false
    t.string "estado"
    t.integer "confirmada_por"
    t.datetime "confirmada_en"
    t.integer "rechazada_por"
    t.string "rechazo_motivo", limit: 250
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "grupo"
    t.datetime "inicio_uso_en"
    t.datetime "finalizada_en"
    t.index ["espacio_id", "fecha", "modulo_id"], name: "idx_reservas_activas_unicas", unique: true, where: "estado IN ('pendiente', 'confirmada', 'en_uso')"
    t.index ["espacio_id"], name: "index_reservas_on_espacio_id"
    t.index ["grupo"], name: "index_reservas_on_grupo"
    t.index ["modulo_id"], name: "index_reservas_on_modulo_id"
    t.index ["usuario_id"], name: "index_reservas_on_usuario_id"
  end

  create_table "sala_estudios", force: :cascade do |t|
    t.integer "espacio_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["espacio_id"], name: "index_sala_estudios_on_espacio_id"
  end

  create_table "usuario_admins", force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["usuario_id"], name: "index_usuario_admins_on_usuario_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "nombre"
    t.string "email"
    t.string "password_digest"
    t.string "rol"
    t.string "estado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "info_personal"
    t.index ["email"], name: "index_usuarios_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chats", "espacios"
  add_foreign_key "chats", "reservas"
  add_foreign_key "chats", "usuario_admins"
  add_foreign_key "chats", "usuarios"
  add_foreign_key "lockers", "espacios"
  add_foreign_key "mensaje_chats", "chats"
  add_foreign_key "mensaje_chats", "usuario_admins"
  add_foreign_key "mensaje_chats", "usuarios"
  add_foreign_key "mensajes", "chats"
  add_foreign_key "mensajes", "usuarios"
  add_foreign_key "mesas", "espacios"
  add_foreign_key "moderadors", "usuarios"
  add_foreign_key "resenas", "espacios"
  add_foreign_key "resenas", "reservas"
  add_foreign_key "resenas", "usuarios"
  add_foreign_key "reservas", "espacios"
  add_foreign_key "reservas", "modulos"
  add_foreign_key "reservas", "usuarios"
  add_foreign_key "sala_estudios", "espacios"
  add_foreign_key "usuario_admins", "usuarios"
end
