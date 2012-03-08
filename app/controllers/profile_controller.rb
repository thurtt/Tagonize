class ProfileController < ApplicationController
	before_filter :test_authentication, :except=>:verify_email
	
	in_place_edit_for :user, :name
	in_place_edit_for :user, :location
	
	def index
		@email = Email.new() #front load for form_for
		@dg = Digest::MD5.hexdigest("test2")
	end
	
	def save
		if params[:user][:id] == ""
			user = User.new(params[:user])
			user.created = Time.now()
			user.created_at = Time.now()
			user.updated_at = Time.now()
			user.user = @user
			flash[:notice] = "User Created." if user.save
		else
			user = User.find(params[:user][:id])
			user.updated_at = Time.now()
			flash[:notice] = "User Updated." if user.update_attributes(params[:user])
		end
		redirect_to :action=>"index"
	end
	
	def mini_profile
		render :partial=>"mini_profile"
	end
	
	def set_default_email
		if params[:id] != ""
			if Email.exists? params[:id]
				@user.email = Email.find(params[:id])
				@user.save
			end
		end
		
		respond_to do |format|
			format.html { render :partial=>".js", :locals=>{:partial=>partial} }
			format.js { render :partial=>"user_login.js", :locals=>{:partial=>partial} }
		end
		render :partial=>"mini_profile"
	end
	
	def link_email
		if params[:email][:id] == ""
			#we actually have a thing.
			if Email.find_by_address(params[:email][:address]) != nil
				#already exists.
				#send verification email.
				email = Email.find_by_address(params[:email][:address])
				notify = Notify.create_verification_request(email)
				Notify.deliver(notify)
			else
				#it doesn't exist. create it.
				email = Email.new(params[:email])
				email.created_at = Time.now()
				email.updated_at = Time.now()
				email.generate_verification()
				email.user = @user
				email.save
				if @user.email == nil
					@user.email = email
					@user.save
					@new_email = true;
				end
				notify = Notify.create_verification_request(email)
				Notify.deliver(notify)
			end
		end
		render :partial=>"email_list"
	end
	
	def unlink_email
		if Email.find(:all, :conditions=>[ "id = ? and user_id = ?", params[:id], @user.id]) != nil
			@user.email_id = nil
			@user.save
			@new_email = true;
			Email.destroy(params[:id])
		end
		render :partial=>"email_list"
	end
	
	def verify_email
		#hacked up version of login
		if session[:authenticated] != true
			#not authenticated
			flash[:notice] = "This action requires you to be logged in."
			session[:landing] = request.request_uri
		else
			#set up whatever you need
			@user = User.find(session[:user])
		
			if params[:c] != ""
				email = Email.find_by_verification(params[:c],:conditions=>"verified <> 1")
				if email != nil
					email.verified = 1
					email.user = @user
					flash[:notice] = "#{email.address} has been verified." if email.save
				else
					flash[:notice] = "Unable to verify the requested email. It could be in use, or not found."
				end
				render :text=>"<script>window.location='/';</script>" and return
			end
		end
		
		redirect_to :controller=>"landing", :action=>"index"
	end
	
	def invite_participant
		if params[:email][:address] != ""
			notify = Notify.create_participation_request(params[:email][:address], params[:project_id])
			Notify.deliver(notify)
		end
		render :text=>"Invitation sent!"
	end
		
	def accept_participation
		#hacked up version of login
		if session[:authenticated] != true
			#not authenticated
			flash[:notice] = "This action requires you to be logged in."
			session[:landing] = request.request_uri
		else
			#set up whatever you need
			@user = User.find(session[:user])
		
			if params[:project_id] != "" && params[:email] != ""
				email = Email.find_by_address(params[:email], :conditions=>["user_id = ?",@user.id])
				if email == nil
					#we don't have the email address requested. Add it, verified.
					email = Email.new()
					email.address = params[:email]
					email.user = @user
					email.verified = 1
					email.save
				end
				
				if email != nil
					#the existing one might not be verified. do so now.
					email.verified
					email.save
					
					participation = Participation.new()
					participation.project = Project.find(params[:project_id].to_i())
					participation.email = email
					flash[:notice] = "<i>#{participation.project.name}</i> has been added to your list." if participation.save
				else
					flash[:notice] = "Unable to find the requested email."
				end
				render :text=>"<script>window.location='/';</script>" and return
			end
		end
		
		redirect_to :controller=>"landing", :action=>"index"
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
end
