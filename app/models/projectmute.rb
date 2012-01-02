class Projectmute < ActiveRecord::Base
	belongs_to :email
	belongs_to :project
end
