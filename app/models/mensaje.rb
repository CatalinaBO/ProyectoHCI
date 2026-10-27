class Mensaje < ApplicationRecord
  belongs_to :chat
  belongs_to :usuario
  validates :contenido, presence: true

  after_create_commit -> {
    broadcast_append_to(
      "chat_#{chat_id}",
      target:  "mensajes",
      partial: "mensajes/mensaje",
      locals:  { mensaje: self }
    )
  }
end
