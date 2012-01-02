class Timeentry < ActiveRecord::Base
	has_one :effort
	belongs_to :email
	has_one :deliverable
	
	# These named scopes need to be set to utc to ensure a time zone agnostic query.
	named_scope :created_between, lambda{ |a, b| { :conditions => ["created_at >= ? and created_at <= ?", a.utc, b.utc] } }
	named_scope :efforts_created_between, lambda{ |a, b, c| { :conditions => ["effort_id = ? and created_at >= ? and created_at <= ?", a, b.utc, c.utc] } }
	named_scope :efforts_created_between_for_email, lambda{ |a, b, c, d| { :conditions => ["effort_id = ? and created_at >= ? and created_at <= ? and email_id = ?", a, b.utc, c.utc, d] } }

end
