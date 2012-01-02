class Email < ActiveRecord::Base
	belongs_to :user
	has_many :projects
	has_many :timeentries
	has_many :participations
	
	validates_uniqueness_of :address
	validates_format_of :address, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
	
	def generate_verification()
		base = "#{Time.now().to_s()}#{user_id}#{address}#{Time.now().to_s()}"
		self.verification = Email.find_by_sql(["select password(?) as verify",base])[0].verify
		self.verified = 0
	end
end
