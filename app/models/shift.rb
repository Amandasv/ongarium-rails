class Shift < ActiveRecord::Base
  has_and_belongs_to_many :opportunities
end
