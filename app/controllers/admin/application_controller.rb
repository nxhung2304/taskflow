class Admin::ApplicationController < ApplicationController
  before_action :set_locale

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_root_path, alert: exception.message
  end

  protected

  def current_ability
    @current_ability ||= Ability.new(nil)
  end

  def set_locale
    locale = resolve_locale
    session[:admin_locale] = locale
    I18n.locale = locale
  end

  private

  def resolve_locale
    requested = params[:locale]&.to_sym
    return requested if I18n.available_locales.include?(requested)

    stored = session[:admin_locale]&.to_sym
    return stored if I18n.available_locales.include?(stored)

    I18n.default_locale
  end
end
