class TasksController < ApplicationController

  layout 'project_website'

  before_filter :process_session
  before_filter :grab_list
  after_filter  :user_track, :only => [:index, :show]
  
  # GET /list_items
  # GET /list_items.xml
  def index
    include_private = @logged_user.member_of_owner?

    respond_to do |format|
      format.html {
        @open_task_lists = @active_project.project_task_lists.open(include_private)
        @completed_task_lists = @active_project.project_task_lists.completed(include_private)
        @content_for_sidebar = 'task_lists/index_sidebar'
      }
      format.xml  {
        @tasks = @task_list.project_tasks.find(:all)
        render :xml => @tasks.to_xml(:root => 'tasks')
      }
    end
  end

  # GET /list_items/1
  # GET /list_items/1.xml
  def show
    begin
      @task = @task_list.project_tasks.find(params[:id])
    rescue
      return error_status(true, :invalid_task)
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.xml  { render :xml => @list_item }
    end
  end

  # GET /list_items/new
  # GET /list_items/new.xml
  def new
    return error_status(true, :insufficient_permissions) unless (ProjectTask.can_be_created_by(@logged_user, @task_list))
    
    @task = @task_list.project_tasks.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @list_item.to_xml(:root => 'task') }
    end
  end

  # GET /list_items/1/edit
  def edit
    begin
      @task = @task_list.project_tasks.find(params[:id])
    rescue
      return error_status(true, :invalid_task)
    end
    
    return error_status(true, :insufficient_permissions) unless (@task.can_be_edited_by(@logged_user))
  end

  # POST /list_items
  # POST /list_items.xml
  def create
    return error_status(true, :insufficient_permissions) unless (ProjectTask.can_be_created_by(@logged_user, @task_list))
    
    @task = @task_list.project_tasks.build(params[:task])
    @task.created_by = @logged_user

    respond_to do |format|
      if @task.save
        flash[:notice] = 'ListItem was successfully created.'
        format.html { redirect_to(@task) }
        format.js
        format.xml  { render :xml => @list_item.to_xml(:root => 'task'), :status => :created, :location => @task }
      else
        format.html { render :action => "new" }
        format.js
        format.xml  { render :xml => @list_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /list_items/1
  # PUT /list_items/1.xml
  def update
    begin
      @task = @task_list.project_tasks.find(params[:id])
    rescue
      return error_status(true, :invalid_task)
    end
    
    return error_status(true, :cannot_edit_listitem) unless (@task.can_be_edited_by(@logged_user))
    
    @task.updated_by = @logged_user

    respond_to do |format|
      if @task.update_attributes(params[:list_item])
        flash[:notice] = 'ListItem was successfully updated.'
        format.html { redirect_to(@list_item) }
        format.js
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js
        format.xml  { render :xml => @list_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /list_items/1
  # DELETE /list_items/1.xml
  def destroy
    begin
      @task = @task_list.project_tasks.find(params[:id])
    rescue
      return error_status(true, :invalid_task)
    end
    
    return error_status(true, :insufficient_permissions) unless (@task.can_be_deleted_by(@logged_user))
    
    @list_item.updated_by = @logged_user
    @list_item.destroy

    respond_to do |format|
      format.html { redirect_to(list_items_url) }
        format.js
      format.xml  { head :ok }
    end
  end
  
  # PUT /list_items/1
  def status
    begin
      @task = @task_list.project_tasks.find(params[:id])
    rescue
      return error_status(true, :invalid_task)
    end
  
    return error_status(true, :insufficient_permissions) unless (@task.can_be_completed_by(@logged_user))
    
    @task.set_completed(params[:task][:completed] == 'true', @logged_user)
    @task.position = @task_list.project_tasks.length
    @task.save

    respond_to do |format|
      format.html { redirect_to(list_items_url) }
      format.js
      format.xml  { head :ok }
    end

  end

protected

  def grab_list
    begin
      @task_list = @active_project.project_task_lists.find(params[:task_list_id])
      unless @task_list.can_be_seen_by(@logged_user)
        error_status(true, :insufficient_permissions)
        return false
      end
    rescue ActiveRecord::RecordNotFound
      error_status(true, :invalid_task)
      return false
    end
    
    true
  end
end
