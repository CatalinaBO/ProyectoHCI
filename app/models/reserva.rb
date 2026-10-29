# frozen_string_literal: true

class Reserva < ApplicationRecord
  belongs_to :usuario
  belongs_to :espacio
  belongs_to :modulo

  enum estado: {
    pendiente:  'pendiente',
    confirmada: 'confirmada',
    rechazada:  'rechazada',
    cancelada:  'cancelada'
  }


  #Validaciones
  validates :fecha, :espacio_id, :modulo_id, presence: true

  after_initialize :establecer_estado_por_defecto

  #Validación reserva empezada y cancelable según hora de acción
  def inicio_datetime
    return unless fecha && modulo&.hora_inicio
    Time.zone.local(
      fecha.year, fecha.month, fecha.day,
      modulo.hora_inicio.hour, modulo.hora_inicio.min
    )
  end

  def empezada?
    hora = inicio_datetime
    hora.present? && Time.current >= hora
  end

  def editable?
    !cancelada? && !empezada? && !rechazada?
  end
  
  def cancelable?
    !cancelada? && !empezada? && !rechazada?
  end

  #Validación espacio no ocupado
  validate :espacio_disponible

  private # PRIVATE

  def establecer_estado_por_defecto
    self.estado = 'confirmada' if new_record? && estado.blank?
  end
  
  def espacio_disponible
    return if espacio_id.blank? || fecha.blank? || modulo_id.blank?

    conflicto = Reserva
                .where(espacio_id: espacio_id, fecha: fecha, modulo_id: modulo_id)
                .where(estado: %w[pendiente confirmada])
                .where.not(id: id)
                .exists?

    if conflicto
      errors.add(:base, 'El espacio ya está reservado en ese módulo y fecha')
    end
  end
end

