class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy icalendar]
  before_action :user_authorized?, except: %i[ index new create icalendar ]
  skip_before_action :authenticate_user!, only: %i[icalendar]

  # GET /users or /users.json
  def index
    authorize User

    if params[:project_id].blank?
      @users = User.where(id: current_user.account.users)
    else
      @users = Project.find_by(slug: params[:project_id]).users
    end

    @users = @users.order('role DESC, name')
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    authorize User

    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    authorize User

    @user = User.new(user_params)
    @user.account = current_user.account

    respond_to do |format|
      if @user.save

        # notifier par mail le nouveau mot de passe
        mailer_response = Notifier.account_welcome_with_password(@user).deliver_now
        MailLog.create(account_id: current_user.account.id, message_id:mailer_response.message_id, to:@user.email, subject: "Bienvenue.")

        format.html { redirect_to users_path, notice: 'Utilisateur créé avec succès.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_url(@user), notice: 'Utilisateur modifié avec succès.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy

    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: 'Utilisateur supprimé avec succès.' }
      format.json { head :no_content }
    end
  end

  def icalendar
    authorize User

    return unless @user

    if @user.admin?
      @projects = @user.account.projects.where('duedate is not null')
      @todolists = @user.account.todolists.where('todolists.duedate is not null')
      @todos = @user.account.todos.where('todos.duedate is not null')
    else
      @projects = @user.projects.where('duedate is not null')
      @todolists = Todolist.where(project_id: @user.projects.pluck(:id)).where('todolists.duedate is not null')
      @todos = @user.todos.where('duedate is not null')
    end

    filename = "Camino_Agenda_iCal"
    response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.ics"'
    headers['Content-Type'] = "text/calendar; charset=UTF-8"
    render plain: AgendaToIcalendar.new(@projects, @todos).call
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find_by(slug: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name, :username, :picturelink, :email, :password, :password_confirmation, :avatar, :role, :theme)
  end

  def user_authorized?
    authorize @user
  end
end
