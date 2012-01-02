class Tag < ActiveRecord::Base
	belongs_to :effort
	belongs_to :taginfo
	
end
