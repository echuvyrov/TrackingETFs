class TrackableItem < ActiveRecord::Base
  has_and_belongs_to_many:funds
end
