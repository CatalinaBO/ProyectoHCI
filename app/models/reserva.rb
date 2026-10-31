# frozen_string_literal: true

class Reserva < ApplicationRecord
  belongs_to :usuario
  belongs_to :espacio
  belongs_to :modulo

  enum estado: {
    pendiente: 'pendiente',
    confirmada: 'confirmada',
    en_uso: 'en_uso',
    liberada: 'liberada',
    finalizada: 'finalizada',
    rechazada: 'rechazada',
    cancelada: 'cancelada'
  }

  # Estados que ocupan el bloque (no se puede volver a reservar).
  ESTADOS_ACTIVOS = %w[pendiente confirmada en_uso].freeze
  # Minutos de tolerancia para declarar el inicio de uso.
  TOLERANCIA_MIN = 15

  scope :activas, -> { where(estado: ESTADOS_ACTIVOS) }

  validates :fecha, :espacio_id, :modulo_id, presence: true
  validate :espacio_disponible

  after_initialize :establecer_estado_por_defecto
  before_validation :asignar_grupo, on: :create

  def inicio_datetime
    return unless fecha && modulo&.hora_inicio

    modulo.inicio_en(fecha)
  end

  def fin_datetime
    return unless fecha && modulo&.hora_fin

    modulo.fin_en(fecha)
  end

  def empezada?
    hora = inicio_datetime
    hora.present? && Time.current >= hora
  end

  def terminada?
    hora = fin_datetime
    hora.present? && Time.current >= hora
  end

  def activa?
    ESTADOS_ACTIVOS.include?(estado)
  end

  # Reserva registrada cuyo inicio de uso nadie declaró a tiempo.
  def sin_informacion_confirmada?
    return false unless confirmada? || pendiente?

    inicio = inicio_datetime
    return false if inicio.nil?

    # Si se reservó con el módulo ya en curso, la tolerancia corre desde la reserva.
    referencia = [inicio, created_at || inicio].max
    Time.current >= referencia + TOLERANCIA_MIN.minutes
  end

  # Texto que se muestra en la cuadrícula de disponibilidad.
  def estado_visible
    return 'Sin información confirmada' if sin_informacion_confirmada?

    case estado
    when 'pendiente', 'confirmada' then 'Reservada'
    when 'en_uso' then 'Uso iniciado'
    when 'liberada' then 'Liberada'
    when 'finalizada' then 'Finalizada'
    when 'cancelada' then 'Cancelada'
    else 'Disponible'
    end
  end

  def editable?
    false
  end

  def cancelable?
    (confirmada? || pendiente?) && !empezada?
  end

  private

  def establecer_estado_por_defecto
    self.estado = 'confirmada' if new_record? && estado.blank?
  end

  def asignar_grupo
    self.grupo ||= SecureRandom.uuid
  end

  def espacio_disponible
    return if espacio_id.blank? || fecha.blank? || modulo_id.blank?
    return unless activa?

    conflicto = Reserva.activas
                       .where(espacio_id: espacio_id, fecha: fecha, modulo_id: modulo_id)
                       .where.not(id: id)
                       .exists?

    errors.add(:base, 'El espacio ya está reservado en ese módulo y fecha') if conflicto
  end
end
