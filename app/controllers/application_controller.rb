# frozen_string_literal: true

class ApplicationController < ActionController::Base

  helper_method :current_user, :logged_in?, :admin_user?, :moderador_user?

  def current_user
    @current_user ||= Usuario.find_by(id: session[:usuario_id]) if session[:usuario_id]
  end

  def logged_in?
    current_user.present?
  end

  def admin_user?
    current_user&.respond_to?(:rol) && current_user.rol == 'admin'
  end

  def moderador_user?
    current_user&.respond_to?(:rol) && current_user.rol == 'moderador'
  end

  def require_login
    return if logged_in?
    redirect_to login_path, alert: "Debes iniciar sesión."
  end

end
