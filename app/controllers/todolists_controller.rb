class TodolistsController < ApplicationController
  before_action :set_todolist, only: %i[show edit update destroy]
  before_action :user_authorized?, except: %i[ new create ]

  # GET /todolists/1
  # GET /todolists/1.json
  def show
    @todo = Todo.new
    @todo.todolist_id = @todolist.id
    @todo.user = current_user
    @todos = @todolist.todos
    @project = @todolist.project
    
    unless params[:search].blank?
      @todos = @todos.where('todos.name ILIKE ?', "%#{params[:search]}%")
    end
  end

  # GET /todolists/new
  def new
    @todolist = Todolist.new
    @todolist.project = Project.find_by(slug: params[:id])
    @placeholder = "Todo List ##{@todolist.project.todolists.count + 1}"

    authorize @todolist
  end

  # GET /todolists/1/edit
  def edit
    return unless @todolist.project.workflow?

    # liste des indices avec nom de la todolist
    @rows = []
    @todolists = @todolist.project.todolists.order(:row)
    (1..@todolists.count).each do |i|
      @rows << (@todolists.find_by(row: i) || Todolist.new(row: i))
    end
  end

  # POST /todolists
  # POST /todolists.json
  def create
    @todolist = Todolist.new(todolist_params)

    authorize @todolist

    if @todolist.project.workflow? # l'indice de la nouvelle liste est le maxi de toutes les listes +1
      @todolist.row = if @todolist.project.todolists.any?
                        (@todolist.project.todolists.maximum(:row) || 0) + 1
                      else
                        1
                      end
    end

    respond_to do |format|
      if @todolist.valid?
        @todolist.id = if Todolist.any?
                         Todolist.maximum(:id) + 1
                       else
                         1
                       end
        @todolist.log_changes(:add, current_user.id)
        @todolist.save
        format.html { redirect_to @todolist, notice: "'#{@todolist.name}' vient d'être ajouté au projet" }
        format.json { render action: 'show', status: :created, location: @todolist }
      else
        flash[:notice] = 'Il manque un titre à cette liste...'
        format.html { redirect_to project_path(@todolist.project) }
        format.json { render json: @todolist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todolists/1
  # PATCH/PUT /todolists/1.json
  def update
    @todolist.attributes = todolist_params
    @todolist.log_changes(:edit, current_user.id)

    if @todolist.project.workflow? and @todolist.changes.include?('row')
      logger.debug "DEBUG! #{@todolist.changes}"
      row = @todolist.changes[:row]
      @todolist.project.todolists.find_by(row: row.last).update(row: row.first)
    end

    respond_to do |format|
      if @todolist.save(validates: false)
        format.html { redirect_to @todolist.project, notice: "'#{@todolist.name}' vient d'être modifié" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @todolist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todolists/1
  # DELETE /todolists/1.json
  def destroy

    @project = @todolist.project
    @todolist.log_changes(:delete, current_user.id)
    @todolist.destroy
    respond_to do |format|
      format.html { redirect_to @project }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_todolist
    @todolist = Todolist.find_by(slug: params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def todolist_params
    params.require(:todolist).permit(:project_id, :name, :row, :duedate)
  end

  def user_authorized?
    authorize @todolist
  end
end
