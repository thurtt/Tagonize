class Project < ActiveRecord::Base
	has_many :participations
	has_many :emails, :through=>:participations, :order=>"address asc"
	has_many :efforts
	belongs_to :email
	has_one :project_visibilities
	
	validates_presence_of :name
	
	def is_muted_for(user)
		@user_emails = []
		user.emails.each{|e|@user_emails << e.id}
		user_mute = Projectmute.find(:all, :conditions=>["email_id in (?) and project_id = ?",@user_emails.join(','), self.id])
			
		return muted if user_mute.length <= 0
		return user_mute[0].muted
	end

	def efforts_by_tags
		@efforts = efforts.sort{ | x, y | y.tags.length <=> x.tags.length  }
		return @efforts
	end
	
	def taginfos
		taginfos = []
		for effort in efforts
			for tag in effort.tags
				taginfos << tag.taginfo
			end
		end
		freq = taginfos.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
		taginfos = taginfos.sort_by { |v| freq[v] }
		taginfos.uniq!
		#taginfos.reverse!
		return taginfos
	end
	
	def efforts_by_taginfo
		#return efforts
		@efforts = efforts_by_tags
		#@efforts.sort!{ |x, y| y.has_taginfo(15) <=> x.has_taginfo(15) }
		#@efforts.sort!{ |x, y| y.has_taginfo(13) <=> x.has_taginfo(13) }
		#@efforts.sort!{ |x, y| y.has_taginfo(12) <=> x.has_taginfo(12) }
		#@efforts.sort!{ |x, y| y.has_taginfo(11) <=> x.has_taginfo(11) }
		#return @efforts.sort!{ |x, y| y.has_taginfo(11) <=> x.has_taginfo(11) }
		#return @efforts
		taginfos.each_index{ |index|
			
			@efforts.sort!{ |x, y| y.has_taginfo(taginfos[index].id) <=> x.has_taginfo(taginfos[index].id) }
			
		}
		return @efforts
		
	end
	
	def tag_weight_for(effort_list)
		
		taginfos = []
		for effort in effort_list
			for tag in effort.tags
				taginfos << tag.taginfo
			end
		end
		freq = taginfos.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
		taginfos = taginfos.sort_by { |v| freq[v] }
		taginfos.uniq!
		taginfos.reverse!
		return taginfos
	end
	
	def sort_efforts_by_tag(effort_list, blacklist = [])
		
		#stores the final product, to pass up recursively.
		ordered_list = []
		#stores what we've done to make sure we don't add our effort to a bucket twice.
		processed_list = []
		#these are the master weights four our current list
		tag_weights = tag_weight_for(effort_list)
		
				
		
		logger.info "CLEANING: *#{blacklist.join(',')}*"
				
		for effort in effort_list
			has_new_tags = false
			for taginfo in effort.taginfos
				if !blacklist.include?(taginfo.id)
					has_new_tags = true
				end
			end
			if !has_new_tags
				logger.info "Processed effort(#{effort.id}) *#{blacklist.join(',')}*"
				ordered_list << effort
				processed_list << effort.id
			end
			
		end
			
		buckets = {}
		logger.info "ENTER: going in with (#{effort_list.length})"
		for taginfo in tag_weights
			#each taginfo is a bucket.
			buckets[taginfo.id] = []
			
			#each effort, will be put into a bucket if it has this list
			for effort in effort_list
				if effort.has_taginfo(taginfo.id) and !processed_list.include?(effort.id)
					if !blacklist.include?(taginfo.id)
						logger.info "INCLUDING: #{taginfo.name} (#{effort.id})"
						buckets[taginfo.id] << effort 
						processed_list << effort.id
					else
						
						logger.info "SKIPPING: #{taginfo.name} (#{effort.id}) blacklist{#{blacklist.join(',')}}"
					end
				end
			end
			
			#each bucket, must be further sorted, eventually, this will have no more sorting.
			
			if buckets[taginfo.id].length > 0
				bl = blacklist
				bl << taginfo.id
				#I just don't even...
				ordered_list += sort_efforts_by_tag(buckets[taginfo.id],Array.new(bl)).reverse
				logger.info "... returned control...."
			end
		end
		logger.info "EXITING."
		return ordered_list
	end

	def total_work( startDate, stopDate )
		startTime = startDate.beginning_of_day
		stopTime = stopDate.end_of_day
				
		entries = []
		efforts.each do |effort|
			entries += Timeentry.efforts_created_between( effort.id, startTime, stopTime )
		end
		
		total = 0
		for entry in entries
			total += entry.minutes
		end
		
		return total
	end
	
	def total_work_as_hash( startDate, stopDate )
		startTime = startDate.beginning_of_day
		stopTime = stopDate.end_of_day
				
		entries = []
		efforts.each do |effort|
			entries += Timeentry.find_by_sql( ["select t.created_at, t.minutes from timeentries as t where t.effort_id = ? and t.minutes > 0 and t.created_at >= ? and t.created_at <= ?", effort.id, startTime, stopTime ] )
		end
		totals = {}
		totals[startTime] = Hash.new
		for entry in entries
			createdStamp = entry.created_at.beginning_of_day
			if totals[createdStamp] == nil
				totals[createdStamp] = entry.minutes
			else
				totals[createdStamp] += entry.minutes
			end
			
		end
		
		return totals		
	end

end







