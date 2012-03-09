class LoginController < ApplicationController

	def index
	end

	def login
		profile = login
		if authenticate() == true
			if session[:landing] == nil || session[:landing] == ""

				parital = "profile/profile"
			else
				redirect_to session[:landing] and return
			end
		end
		respond_to do |format|
			format.html { render :partial=>"user_login.js", :locals=>{:partial=>partial} }
			format.js { render :partial=>"user_login.js", :locals=>{:partial=>partial} }
		end

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

		flash[:notice] = "Sign-up failed."
		partial = "login"
		# setup the timezone
		# I think this works...
		Time.zone = ( params[:tz_offset].to_i / 60 )
		#
		# GUARD: no data
		if params[:email] == "" or params[:password] == ""
			flash[:notice] = "Sign-up failed. Give us more info than that!"

		#
		# GUARD: logging in instead of creating. just go with it.
		elsif authenticate() == true

			if session[:landing] == nil || session[:landing] == ""
				partial = "profile/profile"
			else
				respond_to{ |format| format.html{ redirect_to session[:landing]}}
			end

		#
		# GUARD: trying to use an existing email as your username
		elsif params[:email].include?("@")
			flash[:notice] = "If you're trying to create an account, use your name. We'll ask for your email later."
			partial = "login"
		#
		# BUSINESS: We create the user; Redirect to verify password.
		else

			partial = "create_user"
		end

		# Now it's business time, work through the render routine
		respond_to do |format|
			format.js { render :partial=>"signup.js", :locals=>{:partial=>partial} }
		end

	end

	def create_user

		flash[:notice] = "Sign-up failed."
		partial = "create_user"

		#
		# GUARD: no data
		if params[:email] == "" or params[:password] == "" or params[:password_retype] == ""
			flash[:notice] = "Give us more info than that!"
			partial = "login"
		#
		# GUARD: mismatch
		elsif params[:password_retype] != params[:password]
			flash[:notice] = "Ooops! That password didn't match what you previously gave us."
			partial = "create_user"
		else
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
						partial = "profile/profile"
					else
						respond_to{ |format| format.html{ redirect_to session[:landing] } }
					end
				end
			end
		end
		respond_to do |format|
			format.html { render :partial=>"user_login.js", :locals=>{:partial=>partial} }
			format.js { render :partial=>"user_login.js", :locals=>{:partial=>partial} }
		end

	end

	def logout
		session[:authenticated] = false
		session[:user] = nil
		flash[:notice] = nil
		session[:landing] = ""
		redirect_to :controller=>"landing", :action=>"index"
	end

end
