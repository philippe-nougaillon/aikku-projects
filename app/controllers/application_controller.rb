class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :detect_device_format
  before_action :set_layout_variables
  before_action :prepare_exception_notifier

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_layout_variables
    @ctrl = params[:controller]
    @themes = User::THEMES
  end

  def detect_device_format
    case request.user_agent
    when /iPhone/i
      request.variant = :phone
    when /Android/i && /mobile/i
      request.variant = :phone
    when /Windows Phone/i
      request.variant = :phone
      # when /Android/i
      #  request.variant = :tablet
      # when /iPad/i
      #  request.variant = :tablet
    end
  end

  def after_sign_in_path_for(_resource)
    if request.variant.include?(:phone)
      todos_path(filter: "todo")
    else
      projects_path
    end
  end

  def user_not_authorized
    flash[:alert] = "Vous n'êtes pas autorisé à effectuer cette action."
    if user_signed_in?
      redirect_to(request.referrer || root_path)
    else
      redirect_back(fallback_location: new_user_session_path)
    end
  end

  def prepare_exception_notifier
    request.env["exception_notifier.exception_data"] = {
      current_user: current_user
    }
  end

end
