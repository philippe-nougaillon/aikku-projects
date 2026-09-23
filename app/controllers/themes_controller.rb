# frozen_string_literal: true

class ThemesController < ApplicationController
  wrap_parameters false

  def update
    theme = if params[:theme].is_a?(String)
      params[:theme]
    else
      params.dig(:user, :theme) || params.dig(:theme, :theme)
    end

    if User::THEMES.include?(theme) && current_user.update(theme: theme)
      respond_to do |format|
        format.json { render json: { theme: current_user.theme }, status: :ok }
        format.html { redirect_back fallback_location: root_path }
      end
    else
      respond_to do |format|
        format.json { render json: { error: "Thème invalide" }, status: :unprocessable_entity }
        format.html { redirect_back fallback_location: root_path }
      end
    end
  end
end
