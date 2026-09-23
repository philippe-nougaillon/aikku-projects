# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def update_resource(resource, params)
    if resource.provider == 'google_oauth2'
      params.delete('current_password')
      resource.password = params['password']
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    # Account.transaction do
    #   begin
    #     account = Account.create(name: params[:user][:account])
    #     account.users.create(name: params[:user][:name], username: params[:user][:username], email: params[:user][:email], password: params[:user][:password])
    #   rescue
    #     render 'new'
    #   end
    # end
    #if verify_recaptcha
      account = Account.create(name: params[:account])
      params[:user][:account_id] = account.id
      super
      if account.users.any?
        account.users.first.update(role: "admin")
        #Création du projet de démonstration
        CreateWelcomeProject.new(account.id).call
        flash[:notice] = "Votre compte a bien été créé, bienvenue !"

        Notifier.welcome_admin(params[:user][:email]).deliver_now
        Notifier.with(account: account).new_account_notification.deliver_now
      else
        account.destroy
      end
    #else
    #  render 'new'
    #end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :username, :account_id])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :username, :theme])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
