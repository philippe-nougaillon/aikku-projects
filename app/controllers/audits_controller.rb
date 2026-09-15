class AuditsController < ApplicationController
  before_action :user_authorized?

  def index
    if current_user.admin?
      @audits  = Audited::Audit.where(user_id: current_user.account.users.pluck(:id)).order('id DESC')
    else
      @audits  = Audited::Audit.where(user_id: current_user.id).order('id DESC')
    end
    @actions = @audits.pluck(:action).compact.uniq.sort
    @types   = @audits.pluck(:auditable_type).compact.uniq.sort

    @audits = @audits.where('DATE(created_at) = ?', params[:date]) unless params[:date].blank?
    @audits = @audits.where(action: params[:audit_action]) unless params[:audit_action].blank?
    @audits = @audits.where(auditable_type: params[:type]) unless params[:type].blank?
    @audits = @audits.where(user_id: User.find_by(email: params[:user_email])&.id) unless params[:user_email].blank?

    @audits = @audits.page(params[:page]).per(20)
  end

  private

  def user_authorized?
    authorize :audit
  end
end
