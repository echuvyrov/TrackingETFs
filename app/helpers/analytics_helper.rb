module AnalyticsHelper
	def getTop10YTD
	  #first, get the latest date that we have prices for in the database
	  last_price = EtfPrice.find(:all, :order => "pricedate DESC", :limit => 1)
	  last_price_date = last_price[0].pricedate
	  fund_performance = Hash.new
	  
	  logger.debug "!!!---last_price_date = #{last_price_date.inspect}---!!!"
	  
	  #assumption: all of the funds we are interested in getting YTD info about have the price point in the database on the last_price_date
	  fund_prices_ytd = EtfPrice.find_all_by_pricedate(last_price_date)
	  logger.debug "!!!---fund_prices_ytd = #{fund_prices_ytd.inspect}---!!!"
	  
	  #scan through all of the funds retrieved and get the earliest price available this year
	  fund_prices_ytd.each{
	    |c|
	    beginning_price = Fund.find_by_id(c.fund_id).etf_prices.all(:conditions => "pricedate >= '" + Date.new(Date.today.year, 1,1).to_s + "'", :order => "pricedate", :limit => 1)
	    beginning_of_the_year_price = beginning_price[0].price
	    fund_id = beginning_price[0].fund_id
	    
	    logger.debug "!!!---beginning of the year price = #{beginning_of_the_year_price.inspect}---!!!"	    
	    fund_performance[fund_id] = (c.price.to_f - beginning_of_the_year_price.to_f) / beginning_of_the_year_price.to_f
	    logger.debug "!!!---performance =(#{c.price.to_f} - #{beginning_of_the_year_price.to_f}) / #{beginning_of_the_year_price.to_f}---!!!"

	  }
	  logger.debug "!!!---fund_performance_count = #{fund_performance.count}, fund_performance = #{fund_performance.inspect}---!!!"
	  
	  #assuming that now we have a hash of [Fund_id] => [% Price diff between now and beginning of the year], we can sort the hash from best to worst performers
	  fund_performance.sort_by{ |fund_id, perf| perf }.reverse
	end
	
	def getTop25Month
	  #first, get the latest date that we have prices for in the database
	  last_price = EtfPrice.find(:all, :order => "pricedate DESC", :limit => 1)
	  last_price_date = last_price[0].pricedate
	  fund_performance = Hash.new
	  	  
	  #assumption: all of the funds we are interested in getting YTD info about have the price point in the database on the last_price_date
	  fund_prices_ytd = EtfPrice.find_all_by_pricedate(last_price_date)	  
	  #scan through all of the funds retrieved and get the earliest price available this year
	  fund_prices_ytd.each{
	    |c|
	    beginning_price = Fund.find_by_id(c.fund_id).etf_prices.all(:conditions => "pricedate >= '" + Date.new(Date.today.year, Date.today.month,1).to_s + "'", :order => "pricedate", :limit => 1)
	    beginning_of_the_month_price = beginning_price[0].price
	    fund_id = beginning_price[0].fund_id	    
	    fund_performance[fund_id] = (c.price.to_f - beginning_of_the_month_price.to_f) / beginning_of_the_month_price.to_f

	  }	  
	  #assuming that now we have a hash of [Fund_id] => [% Price diff between now and beginning of the year], we can sort the hash from best to worst performers
	  fund_performance.sort_by{ |fund_id, perf| perf }.reverse
	
	end
	
	def getTop10MoversThisWeek
	  #first, get the latest date that we have prices for in the database
	  last_price = EtfPrice.find(:all, :order => "pricedate DESC", :limit => 1)
	  last_price_date = last_price[0].pricedate
	  fund_performance = Hash.new
	  @fund_performance_sign = Hash.new
	  
	  #assumption: all of the funds we are interested in getting YTD info about have the price point in the database on the last_price_date
	  fund_prices_ytd = EtfPrice.find_all_by_pricedate(last_price_date)	  
	  #scan through all of the funds retrieved and get the earliest price available this year
	  fund_prices_ytd.each{
	    |c|
	    beginning_price = Fund.find_by_id(c.fund_id).etf_prices.all(:conditions => "pricedate >= '" + (Date.today - 7).to_s + "'", :order => "pricedate", :limit => 1)
	    beginning_of_the_week_price = beginning_price[0].price
	    fund_id = beginning_price[0].fund_id	    
	    fund_performance[fund_id] = ((c.price.to_f - beginning_of_the_week_price.to_f) / beginning_of_the_week_price.to_f).abs
      @fund_performance_sign[fund_id] = c.price.to_f > beginning_of_the_week_price.to_f ? "" : "-"
	  }	  
	  #assuming that now we have a hash of [Fund_id] => [% Price diff between now and beginning of the year], we can sort the hash from best to worst performers
	  fund_performance.sort_by{ |fund_id, perf| perf }.reverse.take(10)
	end
	
end