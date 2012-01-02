class Taginfo < ActiveRecord::Base
	has_many :tags
	validates_presence_of :name
	
	named_scope :tag_based_on_project, lambda{ |a, b| { :conditions => ["name = ? and project_id = ?", a, b]}}
end
