# frozen_string_literal: true

module ReservasHelper
  # Clases de color para cada estado visible (D2).
  ESTADO_CLASES = {
    'Disponible' => 'estado-disponible',
    'Liberada' => 'estado-liberada',
    'Reservada' => 'estado-reservada',
    'Uso iniciado' => 'estado-uso',
    'Sin información confirmada' => 'estado-sin-info',
    'Finalizada' => 'estado-finalizada',
    'Uso finalizado' => 'estado-finalizada',
    'Cancelada' => 'estado-cancelada'
  }.freeze

  def estado_badge(texto)
    content_tag(:span, texto, class: "badge-estado #{ESTADO_CLASES.fetch(texto, 'estado-finalizada')}")
  end

  # Estado de una solicitud completa (varios módulos de una misma sala).
  def estado_grupo(reservas)
    return 'Uso iniciado' if reservas.any?(&:en_uso?)
    return 'Cancelada' if reservas.all?(&:cancelada?)
    return 'Uso finalizado' if reservas.any? { |r| r.liberada? || r.finalizada? }
    return 'Sin información confirmada' if reservas.any?(&:sin_informacion_confirmada?)
    return 'Finalizada' if reservas.all?(&:terminada?)

    'Reservada'
  end

  def rango_modulos(reservas)
    "#{reservas.first.modulo.hora_inicio.strftime('%H:%M')} - #{reservas.last.modulo.hora_fin.strftime('%H:%M')}"
  end

  def fecha_larga(fecha)
    dias = %w[domingo lunes martes miércoles jueves viernes sábado]
    meses = %w[enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre]
    texto = "#{dias[fecha.wday]} #{fecha.day} de #{meses[fecha.month - 1]}"
    fecha == Date.current ? "Hoy, #{texto}" : texto.capitalize
  end
end
