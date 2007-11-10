=begin
RailsCollab
-----------

=end

class ProjectUser < ActiveRecord::Base
	belongs_to :user
	belongs_to :project
	
	after_create :ensure_permissions
	
	def ensure_permissions(set_val=true)
	 self.can_manage_messages ||= set_val
	 self.can_manage_tasks ||= set_val
	 self.can_manage_milestones ||= set_val
	 self.can_manage_time ||= set_val
	 self.can_upload_files ||= set_val
	 self.can_manage_files ||= set_val
	 self.can_assign_to_owners ||= set_val
	 self.can_assign_to_other ||= set_val
	end
	
	def self.update_str(vals={})
	 mvals = {:can_manage_messages => false,
	         :can_manage_tasks => false,
	         :can_manage_milestones => false,
	         :can_manage_time => false,
	         :can_upload_files => false,
	         :can_manage_files => false,
	         :can_assign_to_owners => false,
	         :can_assign_to_other=> false,
	 }
	 
	 vals.each do |val|
	   intern_val = val.intern
	   mvals[intern_val] = true if !mvals[intern_val].nil?
	 end
	 
	 return (mvals.keys.collect do |key|
	   "#{key} = #{mvals[key]}"
	 end.join ', ')
	end
	
	def reset_permissions
	 self.can_manage_messages = false
	 self.can_manage_tasks = false
	 self.can_manage_milestones = false
	 self.can_manage_time = false
	 self.can_upload_files = false
	 self.can_manage_files = false
	 self.can_assign_to_owners = false
	 self.can_assign_to_other = false
    end
	
	def has_all_permissions?
		return (self.can_manage_messages and self.can_manage_tasks and self.can_manage_milestones and self.can_manage_time and self.can_upload_files and self.can_manage_files and self.can_assign_to_owners and self.can_assign_to_other)
	end
	
	def self.permission_names()
	 {:can_manage_messages => "Manage messages",
	         :can_manage_tasks => "Manage tasks",
	         :can_manage_milestones => "Manage milestones",
	         :can_manage_time => "Manage time",
	         :can_upload_files => "Upload files",
	         :can_manage_files => "Manage files",
	         :can_assign_to_owners => "Assign tasks to members of owner company",
	         :can_assign_to_other=> "Assign tasks to members of other clients",
	 }
	end
	
	def self.check_permission(user, project, permission)
	 return ProjectUser.find(:first, :conditions => "project_id = #{project.id} AND user_id = #{user.id} AND #{permission} = 1", :select => :user_id)
	end
end