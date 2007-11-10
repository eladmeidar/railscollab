=begin
RailsCollab
-----------

=end

class CompanySweeper < ActionController::Caching::Sweeper

  observe Company
  
  def after_create(data)
  	expire_company(data)
  end
  
  def after_save(data)
  	expire_company(data)
  end
  
  def after_destroy(data)
  	expire_company(data)
  end
  
  def expire_company(data)
  	expire_page(:controller => 'company', :action => 'logo', :id => data.id, :format => 'png')
  end
end