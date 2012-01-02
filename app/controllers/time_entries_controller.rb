class TimeEntriesController < ApplicationController
	before_filter :test_authentication
	auto_complete_for :taginfo, :name
	auto_complete_for :email, :address
	
	def index
		render :partial=>"time_entries"
	end
	
	def update_time_entry
                if params[:effort_id] == "" || params[:minutes] == ""
                      render :partial=>"time_entries" and return
                end
                
                # find the effort based on the date range
                workingDate = session[:workingDate]
                
                # this should always be one...right?
                entries = Timeentry.efforts_created_between( params[:effort_id], workingDate.beginning_of_day, workingDate.end_of_day )
                effort = Effort.find( params[:effort_id] )
                
                if entries.length == 1
                	entry = entries[0]
                	entry.minutes = params[:minutes]
                	entry.save
                else
                        entry = Timeentry.new
                        entry.minutes = params[:minutes]
                        entry.effort_id = params[:effort_id]
                        entry.email_id = @user.email_for_project(effort.project).id
                        entry.created_at = session[:workingDate]
                        entry.save
                end
                #a.join('')
                if params[:comment] != ""
			if entry.deliverable != nil
				delivery = entry.deliverable
			else
				delivery = Deliverable.new
				delivery.timeentry_id = entry.id
			end
			delivery.comment = params[:comment]
			delivery.save
		end
                
                render :partial=>"project_overview"
	end
	
	def tag_create
                
                #GUARD: a sanity check
                if params[:project_id] == "" || params[:taginfo][:name] == ""
                      render :partial=>"time_entries" and return
                end

                # don't create a taginfo if it already exists for this project
                taginfos = Taginfo.tag_based_on_project( params[:taginfo][:name], params[:project_id] )

                
                if taginfos.length == 0
                      # create a new taginfo
                      taginfo = Taginfo.new
                      taginfo.name = params[:taginfo][:name]
                      taginfo.project_id = params[:project_id]
                      taginfo.save
                else
                      taginfo = taginfos[0]
                end
                
                # create a new effort
                effort = Effort.new
                effort.project_id = params[:project_id]
                effort.save
                
                # if we have an effort_id parameter, clone the existing tag references
                if params[:effort_id] != ""
                  cloneTags = Effort.find( params[:effort_id] ).tags
                  cloneTags.each do |cloneTag|
                    newTag = Tag.new
                    newTag.taginfo_id = cloneTag.taginfo_id
                    newTag.effort_id =  effort.id
                    newTag.save
                  end
                end
                
                # create a new tag
                tag = Tag.new
                tag.taginfo_id = taginfo.id
                tag.effort_id = effort.id
                tag.save
                
                render :partial=>"time_entries"
	end
	
  	def tag_update
              newTagName = params[:taginfo][:name]
              
              # See if our tag is already defined
              foundTaginfos = Taginfo.tag_based_on_project( newTagName, params[:project_id] )
              newTaginfo = nil
              if foundTaginfos.length > 0
                newTaginfo = foundTaginfos[0]
              else
                # create a new tag
                newTaginfo = Taginfo.new
                newTaginfo.name = newTagName
                newTaginfo.project_id = params[:project_id]
                newTaginfo.save
              end
              
              tag = Tag.find( params[:tag_id] )
              tag.taginfo_id = newTaginfo.id
              tag.save
              
              render :partial=>"time_entries"
  	end
  	
	def project_create
		#GUARD: no email, no data
		if params[:name] == "" || @user.email == nil
			flash[:notice] = "You can't add a project until you have a default email. Add an email to continue!"
			render :partial=>"time_entries" and return
		end
		
		if params[:name] != "" and Project.find(:all, :conditions=>["email_id = ? and name = ?",@user.email.id, params[:name]]).length < 1
			project = Project.new
			project.name = params[:name]
			project.email = @user.email
			project.save
			
			participation = Participation.new
			participation.email_id = @user.email_id
			participation.project_id = project.id
			participation.save
		end
		render :partial=>"time_entries"
	end
	
	def toggle_project_mute
		project = Project.find(params[:id])
		if @user.has_email(project.email)
			project.muted = !project.muted
			project.save
		else
			@email_list = []
			@user.emails.each{|e|@email_list << e.id}
			pm_list = Projectmute.find(:all, :conditions=>["email_id in (?) and project_id = ?",@email_list.join(','), project.id])
			if pm_list.length <= 0
				mute = Projectmute.new
				mute.project_id = project.id
				mute.email_id = @user.email_id
				mute.muted = false
			else
				mute = pm_list[0]
			end
			mute.muted = !mute.muted
			mute.save
		end
		
		render :partial=>"project_mute", :locals=>{:project=>project}
	end
	
		
	def toggle_effort_mute
		effort = Effort.find(params[:id])
		if @user.has_email(effort.email)
			effort.muted = !effort.muted
			effort.save
		else
			@email_list = []
			@user.emails.each{|e|@email_list << e.id}
			em_list = Effortmute.find(:all, :conditions=>["email_id in (?) and effort_id = ?",@email_list.join(','), effort.id])
			if em_list.length <= 0
				mute = Effortmute.new
				mute.effort_id = effort.id
				mute.email_id = @user.email_id
				mute.muted = false
			else
				mute = em_list[0]
			end
			mute.muted = !mute.muted
			mute.save
		end
		
		render :partial=>"effort_mute", :locals=>{:effort=>effort}
	end
	
	
	def test_authentication
		#session[:landing] = request.request_uri
		if session[:authenticated] != true
			#not authenticated
			redirect_to :controller=>"login", :action=>"index"
			return false
		else
			#set up whatever you need
			@user = User.find(session[:user])
		end
	end
	
  	def set_date
          session[:workingDate] = Time.parse( params[:date] )
          render :partial=>"time_entries" and return
  	end
  	
  	def hide_project
          
  	end
end
