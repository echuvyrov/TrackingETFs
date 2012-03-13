class Fund < ActiveRecord::Base
  has_and_belongs_to_many :trackable_items
  accepts_nested_attributes_for :trackable_items
  has_many:etf_prices, :dependent => :delete_all
  
  attr_accessor :prices_last12months
  attr_accessor :pricelabels_last12months
end
