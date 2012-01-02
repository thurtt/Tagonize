class User < ActiveRecord::Base
	has_many :emails
	belongs_to :email
	
	validates_presence_of :name, :location
	
	def authenticate(passtest)
		return false if passtest == nil
		return false if passtest == ""
		return false if self.password != User.find_by_sql("select password('#{passtest}') as passhash")[0].passhash
		return true
	end
	
	def projects
		@projects = []
		for em in emails
			#DAMAGE CONTROL
			for project in em.projects
				if !is_participating_in(project)
					part = Participation.new
					part.email_id = em.id
					part.project_id = project.id
					part.save
				end
			end
			
			if em.participations.length > 0
				for part in em.participations
					@projects << part.project if part.project != nil #suggests a deleted project or email
				end
			end
		end
		@projects.sort!{ |x, y| y.efforts.length <=> x.efforts.length }
		return @projects.uniq
	end
	
	def is_participating_in(project)
		emails.each{|e|e.participations.each{|p| return true if p.project_id == project.id }}
		return false
	end
	
	def email_for_project(project)
		emails.each{|e|e.participations.each{|p| return p.email if p.project_id == project.id}}
		return Email.find(email_id)
	end
	
	def has_email(email)
		emails.each{|e| return true if e == email}
		return false
	end
end
