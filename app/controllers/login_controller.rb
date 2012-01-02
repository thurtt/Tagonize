class LoginController < ApplicationController
	
	def index
	end
	
	def login
		if authenticate() == true
			if session[:landing] == nil || session[:landing] == ""
				render :partial=>"profile/profile" and return
			else
				redirect_to session[:landing] and return
			end
		end
		render :partial=>"login" and return
		
	end
	
	def authenticate
		
		#To let the user use any email address entry to authenticate, do this:
		# 1. validate existence of email address or user name
		# 2. get the associated user object(s)
		# 3. ???
		# 4. profit
		email = Email.find_by_address(params[:email])
		if email != nil
			user = email.user
		else
			users = User.find(:all, :conditions=>["name = ?", params[:email]])
			for u in users
				user = u if u.authenticate(params[:password])
			end
		end
		if user != nil
			#email obj has a user obj. use it to auth.
			session[:authenticated] = user.authenticate(params[:password])
			if session[:authenticated] == true
				#get user
				session[:user] = user.id
				@user = User.find(session[:user])
				return true
			end
		end
		flash[:notice] = "These credentials don't match anything we have."
		return false
	end
	
	def signup
		
		# setup the timezone
		# I think this works...
		Time.zone = ( params[:tz_offset].to_i / 60 )
		#
		# GUARD: no data
		if params[:email] == "" or params[:password] == ""
			flash[:notice] = "Sign-up failed. Give us more info than that!"
			render :partial=>"login" and return
		end
		
		#
		# GUARD: logging in instead of creating. just go with it.
		if authenticate() == true
		
			if session[:landing] == nil || session[:landing] == ""
				render :partial=>"profile/profile" and return
			else
				redirect_to session[:landing] and return
			end
		end
			
		
		#
		# GUARD: trying to use an existing email as your username
		if params[:email].include?("@")
			flash[:notice] = "If you're trying to create an account, use your name. We'll ask for your email later."
			render :partial=>"login" and return
		end
		
		#
		# BUSINESS: We create the user; Redirect to verify password.
		render :partial=>"create_user" and return
		
		flash[:notice] = "Sign-up failed."
		render :partial=>"login" and return
			
	end
	
	def create_user
		#
		# GUARD: no data
		if params[:email] == "" or params[:password] == "" or params[:password_retype] == ""
			flash[:notice] = "Give us more info than that!"
			render :partial=>"login" and return
		end
		
		#
		# GUARD: mismatch
		if params[:password_retype] != params[:password]
			flash[:notice] = "Ooops! That password didn't match what you previously gave us."
			render :partial=>"create_user" and return
		end
		
		
		#
		# BIZNAZ: creation
		user = User.new()
		user.name = params[:email]
		user.location = 'Set your location.'
		user.created_at = Time.now()
		user.updated_at = Time.now()
		user.password = User.find_by_sql("select password('#{params[:password]}') as passhash")[0].passhash
		if user.save
			if authenticate() == true
				
				if session[:landing] == nil || session[:landing] == ""
					render :partial=>"profile/profile" and return
				else
					redirect_to session[:landing] and return
				end
			end
		end
		flash[:notice] = "Sign-up failed."
		render :partial=>"create_user" and return
	end

	def logout
		session[:authenticated] = false
		session[:user] = nil
		flash[:notice] = nil
		session[:landing] = ""
		redirect_to :controller=>"landing", :action=>"index"
	end

end
