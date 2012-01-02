class LandingController < ApplicationController
	before_filter :test_authentication, :except=> :index
	
	def index
		if session[:authenticated] != true
			session[:workingDate] = Time.now
			@top_frame = "login/login" #loging page.
		else
			@user = User.find(session[:user])
			@top_frame = "profile/profile" #random for now
		end
	end
  
  	
	def test_authentication
		session[:landing] = request.request_uri
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
