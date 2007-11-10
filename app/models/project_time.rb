=begin
RailsCollab
-----------

=end

class ProjectTime < ActiveRecord::Base
	include ActionController::UrlWriter
	
	belongs_to :project
	
	belongs_to :company, :foreign_key => 'assigned_to_company_id'
	belongs_to :user, :foreign_key => 'assigned_to_user_id'
	
	belongs_to :project_task_list, :foreign_key => 'task_list_id'
	belongs_to :project_task, :foreign_key => 'task_id'
	
	belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
	belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
	
	has_many :project_messages, :foreign_key => 'milestone_id'
	
	has_many :tags, :as => 'rel_object', :dependent => :destroy
	
	before_create :process_params
	before_update :process_update_params
	 
	def process_params
	  write_attribute("created_on", Time.now.utc)
	  
	  if self.assigned_to_user_id.nil?
	   write_attribute("assigned_to_user_id", 0)
	  end
	  if self.assigned_to_company_id.nil?
	    write_attribute("assigned_to_company_id", 0)
	  end
	end
	
	def process_update_params
		write_attribute("updated_on", Time.now.utc)
		
		if self.assigned_to_user_id.nil?
	      write_attribute("assigned_to_user_id", 0)
	    end
	    if self.assigned_to_company_id.nil?
	      write_attribute("assigned_to_company_id", 0)
	    end
	end
	
	def object_name
		self.name
	end
	
	def object_url
		url_for :only_path => true, :controller => 'time', :action => 'view', :id => self.id, :active_project => self.project_id
	end
	
	# Responsible party assignment
	
	def open_task=(obj)
		self.project_task_list = obj.class == ProjectTaskList ? obj : nil
		self.project_task = obj.class == ProjectTask ? obj : nil
	end
	
	def open_task
		if self.project_task_list
			self.project_task_list
		elsif self.project_task
			self.project_task
		else
			nil
		end
	end
	
	def open_task_id=(val)
        # Set assigned_to accordingly
        assign_id = val.to_i
        if assign_id == 0
        	self.open_task = nil
        elsif assign_id > 1000
          self.open_task = ProjectTask.find(assign_id-1000)
        else
          self.open_task = ProjectTaskList.find(assign_id)
        end
	end
	
	def open_task_id
		if self.project_task_list
			self.project_task_list.id
		elsif self.project_task
			self.project_task.id+1000
		else
			0
		end
	end
	
	# Task list / task assignment
	
	def assigned_to=(obj)
		self.company = obj.class == Company ? obj : nil
		self.user = obj.class == User ? obj : nil
	end
	
	def assigned_to
		if self.company
			self.company
		elsif self.user
			self.user
		else
			nil
		end
	end
	
	def assigned_to_id=(val)
        # Set assigned_to accordingly
        assign_id = val.to_i
        if assign_id == 0
        	self.assigned_to = nil
        elsif assign_id > 1000
          self.assigned_to = User.find(assign_id-1000)
        else
          self.assigned_to = Company.find(assign_id)
        end
	end
	
	def assigned_to_id
		if self.company
			self.company.id
		elsif self.user
			self.user.id+1000
		else
			0
		end
	end
	
	def tags
	 return Tag.list_by_object(self).join(',')
	end
	
	def tags=(val)
	 Tag.clear_by_object(self)
	 Tag.set_to_object(self, val.split(',')) unless val.nil?
	end
	
	def is_today?
		return self.done_date.to_date == Date.today
	end
	
	def is_yesterday?
		return self.done_date.to_date == Date.today-1
	end
	
	# Core Permissions
	
	def self.can_be_created_by(user, project)
	  user.has_permission(project, :can_manage_time)
	end
	
	def can_be_edited_by(user)
	 if (!self.project.has_member(user))
	   return false
	 end
	 
	 if user.has_permission(project, :can_manage_time)
	   return true
	 end
	 
	 if self.created_by == user
	   return true
	 end
	 
	 return false
	end
	
	def can_be_deleted_by(user)
	 if !self.project.has_member(user)
	   return false
	 end
	 
	 if user.has_permission(project, :can_manage_time)
	   return true
	 end
	 
	 return false
	end
	
	def can_be_seen_by(user)
	 if !self.project.has_member(user)
	   return false
	 end
	 
	 if user.has_permission(project, :can_manage_time)
	   return true
	 end
	 
	 if self.is_private and !user.member_of_owner?
	   return false
	 end
	 
	 return true
	end
	
	# Specific Permissions

    def can_be_managed_by(user)
      return user.has_permission(self.project, :can_manage_time)
    end
	
	# Accesibility
	
	attr_accessible :name, :description, :done_date, :hours, :open_task_id, :assigned_to_id
	
	# Validation
	
	validates_presence_of :name
end
