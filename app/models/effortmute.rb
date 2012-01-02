class Effortmute < ActiveRecord::Base
	belongs_to :email
	belongs_to :effort
end
