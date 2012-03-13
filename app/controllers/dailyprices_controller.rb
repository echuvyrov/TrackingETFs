class DailypricesController < ApplicationController
  require 'yahoofinance-typhoeus'
  include CommonHelper
  
  def index
    logger.debug '<<<---Initializing--->>>'

    #this service should be invoked on a regular basis to pull the daily prices from Yahoo
    first_of_the_year = business_day(Date.new(Date.today.year, 1,1))
    today = Date.today
    
    #by default, start date will be 7 days back from today's date, that should accommodate any weekends/holidays/bugs invoking this service
    start_date = first_of_the_year
    
    logger.debug "<<<---Start date #{start_date.inspect}--->>>"
    if start_date > today
      return
    end

    logger.debug '<<<---Getting MSFT--->>>'

    #for all the funds in the system, get prices from the start date up until today
    all_funds = Fund.all
    all_funds.each { 
      |fund|
   	  yf = YahooFinance.new
      #queue the calls to yahoo to fill in tall of the price points for dates from start date until today        
      yf.add_query(fund.tickersymbol, start_date, today) {
        |response|
        #prices for all dates come back as one big response payload; parse it appropriately
        prices = response.split("\n")
        
        prices.each {
          |priceline|
          pricedate = priceline.split(",")[0]
          yahooprice = priceline.split(",")[6]
  
          logger.debug "<<<---Response #{pricedate.inspect} - #{yahooprice.inspect}--->>>"     
          #does the price for a given date already exist?
          if fund.etf_prices.find_by_pricedate(pricedate)
            #yes, it does exist, skip adding it to the database
          else
            #skip empty and 0 elements
            if is_a_number?(yahooprice)
	            price = fund.etf_prices.new(:pricedate => pricedate, :price=>yahooprice) 
	            logger.debug ">>>>>>#{price.inspect}<<<<<<"
	            price.save 
	          end          
          end
        }
      }
      
      begin
        yf.run
      rescue Exception => exc
        logger.error("Error retrieving Yahoo quotes #{exc.message}")
        #flash[:notice] = "There was an error trying to get quotes from Yahoo service"
        price = fund.etf_prices.new(:pricedate => start_date, :price=> nil)
        price.save
        next
      end
    }    
  end
end
