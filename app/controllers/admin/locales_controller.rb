class Admin::LocalesController < Admin::ApplicationController
  def update
    locale = params[:locale].to_s
    session[:admin_locale] = locale if I18n.available_locales.map(&:to_s).include?(locale)

    redirect_back fallback_location: admin_root_path
  end
end
