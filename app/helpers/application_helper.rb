=begin
RailsCollab
-----------

=end

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def system_notices
	    []
	end
	
	def site_name
		html_escape AppConfig.site_name
	end
	
	def product_signature
		"Powered by <a href=\"http://rubyforge.org/projects/railscollab\">RailsCollab</a>"
	end
	
	def pagination_links(url, ids)
	 values = ids.collect do |id|
	   "<a href=\"#{url}page=#{id}\">#{id}</a>"
	 end.join ' | '
	 
	 "<div class=\"advancedPagination\"><span>Page: </span><span>(#{values})</span></div>"
	end

	def checkbox_link(link, checked=false, hint=nil, attrs={})
    	icon_url = checked ? '/images/icons/checked.gif' : '/images/icons/not-checked.gif'
    	
    	link_to "<img src='#{icon_url}' alt=\'\' />", link, attrs.merge({:post => true, :class => 'checkboxLink', :title => ( hint.nil? ? '' : (html_escape hint) )})
	end
	
	def render_icon(filename, alt, attrs={})
		attr_values = attrs.keys.collect do |a|
			"#{a}='#{attrs[a]}'"
		end.join ' '
		
		"<img src='/images/icons/#{filename}.gif' alt='#{alt}' #{attr_values}/>"
	end
	
	def action_list(actions)
		actions.collect do |action|
			if action[:cond]
				extras = {}
				extras[:confirm] = action[:confirm] if not action[:confirm].nil?
				extras[:method] = action[:method] if not action[:method].nil?
				
				link_to action[:name], action[:url], extras
			else
				nil
			end
		end.compact.join(' | ')
	end
	
	def tag_list(object)
		tags = Tag.list_by_object(object)
		
		if !tags.empty?
			tags.collect do |tag|
				"<a href=\"/project/#{object.project_id}/tags/#{tag}\">#{tag}</a>"
			end.join(', ')
		else
			"--"
		end
	end
	
	def country_code_select(object_name, method, extra_options={})
		countries = [TZInfo::Country.all.collect{|x|x.name},
		             TZInfo::Country.all_codes].transpose.sort
		select(object_name, method, countries, extra_options)
	end
	
	def format_size(value)
		kbs = value / 1024
		mbs = kbs / 1024
		
		if kbs > 0
			if mbs > 0
				"#{mbs}MB"
			else
				"#{kbs}KB"
			end
		else
			"#{value}B"
		end
	end
	
	def format_usertime(time, format, user=@logged_user)
		adjusted_time = time + ((user.timezone * 60.0 * 60.0).to_i)
		adjusted_time.strftime(format)
	end
	
	#def textilize(text)
	# "<p>#{text}</p>"
	#end
end