class TablesController < ApplicationController
  before_action :set_table, only: %i[show show_attrs fill fill_do edit update destroy delete_record link link_do]
  before_action :user_authorized?, except: %i[index new create]

  # GET /tables
  # GET /tables.json
  def index
    authorize Table
    # test si l'utilisateur est le propriétaire du compte
    if current_user != current_user.account.users.first
      redirect_to root_path, notice: "Désolé mais vous n'êtes pas autorisé à afficher les tables..."
      return
    end
    @tables = current_user.account.tables
  end

  # GET /tables/1
  # GET /tables/1.json
  def show
    @values = @table.values

    unless params[:project].blank?
      @values = @table.values.where(todo_id: Project.find_by(slug: params[:project]).todos.ids)
    end

    @values = @values.where('data ILIKE ?', "%#{params[:search].strip}%") unless params[:search].blank?

    respond_to do |format|
      format.html
      format.xls do
        book = TableToXls.new(@table).call
        file_contents = StringIO.new
        book.write file_contents
        filename = "#{@table.name}_#{DateTime.now}.xls"
        send_data file_contents.string.force_encoding('binary'), filename: filename
      end
    end
  end

  def show_attrs
    authorize @table

    @field = Field.new(table_id: @table.id)
  end

  def fill
    @record_index = (params[:record_index] || @table.record_index + 1).to_i

    @todo = Todo.find_by(slug: params[:todo_id]) if params[:todo_id].present?
  end

  def fill_do
    if params[:data].blank?
      redirect_to @table, alert: 'Aucune donnée à enregistrer'
      return
    end

    @user = current_user
    data = params[:data]
    record_index = (params[:record_index] || data.keys.first).to_i
    values = data[record_index.to_s] || data[record_index] || {}

    todo = Todo.find_by(slug: params[:todo_id]) if params[:todo_id].present?

    if values.values.any?(&:present?) # test si au moins un champ est renseigné

      # modification = si données existent déjà, on les supprime pour pouvoir ajouter les données modifiées
      update = @table.values.where(record_index: record_index).any?

      created_at_date = nil
      if update
        created_at_date = @table.values.where(record_index: record_index).first.created_at
        @table.values.where(record_index: record_index).destroy_all
      end

      # ajout des données
      @table.fields.each do |field|
        record_attrs = {
          record_index: record_index,
          field_id: field.id,
          todo_id: todo&.id,
          data: values[field.id.to_s],
          user_id: @user.id
        }
        record_attrs[:created_at] = created_at_date if created_at_date.present?
        record = @table.values.new(record_attrs)
        record.save
      end

      # incrémenter le nombre d'enregistrements
      @table.update(record_index: [@table.record_index.to_i, record_index].max) unless update

      flash[:notice] = if todo.blank?
                         "Test OK. Enregistrement #{update ? 'modifié' : 'ajouté'}. Vous pourrez ajouter des données à chaque tâche terminée"
                       else
                         "Enregistrement #{update ? 'modifié' : 'ajouté'}"
                       end
    else
      flash[:alert] = "L'enregistrement n'a pas été ajouté"
    end

    respond_to do |format|
      format.html do |variant|
        variant.phone do
          if todo
            redirect_to edit_todo_path(todo)
          else
            redirect_to @table
          end
        end
        variant.none do
          if todo
            redirect_to edit_todo_path(todo)
          else
            redirect_to @table
          end
        end
      end
    end
  end

  def delete_record
    if params[:record_index]
      @table.values.where(record_index: params[:record_index]).destroy_all
      # @table.update_attributes(size:@table.size - 1)
    end

    redirect_to @table
  end

  # GET /tables/new
  def new
    authorize Table
    @table = Table.new
  end

  # GET /tables/1/edit
  def edit; end

  # POST /tables
  # POST /tables.json
  def create
    authorize Table
    @table = Table.new(table_params)
    @user = current_user
    @table.account = @user.account

    respond_to do |format|
      if @table.save
        format.html { redirect_to table_path(@table), notice: 'Table ajoutée.' }
        format.json { render :show, status: :created, location: @table }
      else
        format.html { render :new }
        format.json { render json: @table.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tables/1
  # PATCH/PUT /tables/1.json
  def update
    respond_to do |format|
      if @table.update(table_params)
        format.html { redirect_to table_path(@table, attrs: 1), notice: 'Table modifiée.' }
        format.json { render :show, status: :ok, location: @table }
      else
        format.html { render :edit }
        format.json { render json: @table.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tables/1
  # DELETE /tables/1.json
  def destroy
    @table.destroy
    respond_to do |format|
      format.html { redirect_to tables_url, notice: 'Table supprimée.' }
      format.json { head :no_content }
    end
  end

  def link
    @projects = current_user.account.projects.where(table_id: nil)
  end

  def link_do
    @table.projects << Project.find(params[:project_id])
    redirect_to tables_path, notice: 'Projet ajouté'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_table
    @table = Table.find_by(slug: params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def table_params
    params.require(:table).permit(:name, :record_index)
  end

  def user_authorized?
    authorize @table
  end
end
