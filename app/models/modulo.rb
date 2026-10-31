# frozen_string_literal: true

class Modulo < ApplicationRecord
  def etiqueta
    "#{hora_inicio.strftime('%H:%M')} - #{hora_fin.strftime('%H:%M')}"
  end

  def inicio_en(fecha)
    Time.zone.local(fecha.year, fecha.month, fecha.day, hora_inicio.hour, hora_inicio.min)
  end

  def fin_en(fecha)
    Time.zone.local(fecha.year, fecha.month, fecha.day, hora_fin.hour, hora_fin.min)
  end

  def terminado?(fecha)
    Time.current >= fin_en(fecha)
  end
end
