class Effort < ActiveRecord::Base
	belongs_to :project
	has_many :tags
	has_many :taginfos, :through=>:tags
	has_many :timeentries
	
	
	def email
		return project.email
	end
	
	def is_muted_for(user)
		@user_emails = []
		user.emails.each{|e|@user_emails << e.id}
		user_mute = Effortmute.find(:all, :conditions=>["email_id in (?) and effort_id = ?",@user_emails.join(','), self.id])
			
		return muted if user_mute.length <= 0
		return user_mute[0].muted
	end
	
	def has_taginfo(_info_id)
		for taginfo in taginfos
			return true if taginfo.id == _info_id
		end
		return false
	end
	
	def sort_tags_by_taginfo(tag_weight)
		ordered_tags = []
		for taginfo in tag_weight
			tags.each{|tag| ordered_tags << tag if tag.taginfo == taginfo}
		end
		return ordered_tags
	end

	def total_work( startDate, stopDate )
		startTime = startDate.beginning_of_day
		stopTime = stopDate.end_of_day
		entries = Timeentry.efforts_created_between( id, startTime, stopTime )

		total = 0
		for entry in entries
			entry.minutes ? total += entry.minutes : nil
		end
		return total
	end
	
	# This will return a hash containing an x-axis label
	# for the effort and a total for each effort
	def total_work_as_hash( startDate, stopDate )
		total = self.total_work( startDate, stopDate )
		
		tagNames = []
		taginfos.each{ |taginfo| tagNames.push( taginfo.name ) }

		effortName = tagNames.join( '/' )
		
		return { effortName=>total }
	end
	
	def timeentries_created_between(startDate, stopDate)
		startTime = startDate.beginning_of_day
		stopTime = stopDate.end_of_day
		return Timeentry.efforts_created_between( id, startTime, stopTime )
	end
	
	def timeentries_created_between_for_email(startDate, stopDate, email_id)
		startTime = startDate.beginning_of_day
		stopTime = stopDate.end_of_day
		return Timeentry.efforts_created_between_for_email(id, startTime, stopTime, email_id)
	end
end
