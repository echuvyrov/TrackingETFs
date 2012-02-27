class Fund < ActiveRecord::Base
  has_and_belongs_to_many:trackable_items
  has_many:etf_prices
end
