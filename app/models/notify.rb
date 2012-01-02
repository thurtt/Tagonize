class Notify < ActionMailer::Base
	def participation_request(email, project_id)
		@email = email
		@project_id = project_id
		@subject    = "You've been invited to a project on Tagonize.com."
		@body       = {}
		@recipients = @email
		@from       = 'bvrn007@gmail.com'
		@sent_on    = Time.now
		@headers    = {}
		@body["email"] = ''
	end
	
	def verification_request(email)
		@email = email
		@subject    = "Verify this email on Tagonize.com."
		@body       = {}
		@recipients = @email.address
		@from       = 'bvrn007@gmail.com'
		@sent_on    = Time.now
		@headers    = {}
		@body["email"] = ''
	end

end
