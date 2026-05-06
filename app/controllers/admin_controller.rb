class AdminController < ApplicationController
  skip_before_action :authenticate_user!, only: [:mentions_legales]
  before_action :user_authorized?

  def stats
    @users = User.all.order('users.current_sign_in_at DESC NULLS LAST')
    @users = @users.page(params[:page]).per(50)
  end

  def suppression_compte
    account = Account.find_by(slug: params[:account])
    account.destroy

    respond_to do |format|
      format.html { redirect_to admin_stats_path }
      format.json { head :no_content }
    end
  end

  def mentions_legales; end

  private

  def user_authorized?
    authorize :admin
  end
end
