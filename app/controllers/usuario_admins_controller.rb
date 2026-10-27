# frozen_string_literal: true

class UsuarioAdminsController < ApplicationController

  def vista_inicial
    @admin = UsuarioAdmin.new
  end
  
end
