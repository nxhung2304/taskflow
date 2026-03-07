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
    if params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
  end
end
