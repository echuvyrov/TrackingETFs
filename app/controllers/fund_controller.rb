class FundController < ApplicationController
  require "yahoofinance-typhoeus"
  require 'date'
  require 'will_paginate/array'
  
  def show
    @fund = Fund.find(params[:id])
    @title = 'Edit ' + @fund.etfname
  end
  
  def index
    funds = Fund.find_all_by_tickersymbol(searchcriteria)
    funds = getFundDetails(funds)
    @funds = funds
  end
  
  def find
    if params[:searchcriteria] != nil
      searchcriteria = params[:searchcriteria].upcase

      logger.info ">>>>>>SEARCHCRITERIA IS NOT NULL<<<<<<"
    
      funds = Fund.find_all_by_tickersymbol(searchcriteria)
      if funds.count == 0
        funds = Fund.find_all_by_etfname(searchcriteria)
        searchedFor = "fund name " + searchcriteria
      else
        searchedFor = "ticker " + searchcriteria
      end
      
    else
      #if no search criteria passed in, show all funds
      logger.info ">>>>>>SEARCHCRITERIA NULL NULL NULL<<<<<<"
      funds = Fund.all.paginate(:per_page => 2, :page => params[:page])
      searchcriteria =  ''
    end
        
    funds = getFundDetails(funds)
    @funds = funds
  end

  def category
    category = params[:name]
    funds = Fund.find_all_by_etftype(category)
    @funds = getFundDetails(funds).paginate(:per_page => 2, :page => params[:page])
    @title = 'Showing ' + category + ' funds'
  end

  def new
    @fund  = Fund.new
    @title = "Create new ETF"
  end
  
  def create
    @fund = User.new(params[:fund])
    if @fund.save
      redirect_to @user, :flash => { :success => "Successfully created the new fund." }
    else
      @title = "Create new ETF"
      render 'new'
    end
  end
  
  def edit
    @title = "Edit ETF"
  end
  
  def update
    if @fund.update_attributes(params[:fund])
      redirect_to @fund, :flash => { :success => "ETF updated." }
    else
      @title = "Edit ETF"
      render 'edit'
    end
  end

  def destroy
    fund = Fund.find( params[:id])
    fund.destroy
    redirect_to :back, :flash => { :success => "Fund deleted." }
  end
  
  protected
  
    def getFundDetails(funds)
  
      #push prices into the database
      getPrices(funds)
  
      funds.each {
        |fund|
        prices = Fund.find_by_tickersymbol(fund.tickersymbol).etf_prices.sort_by{|pd| pd[:pricedate]}
        fund.prices_last12months = Array.new
        fund.pricelabels_last12months = Array.new      
    
        prices.each { 
          |p|
          fund.prices_last12months << p.price.to_f
          fund.pricelabels_last12months << p.pricedate.strftime("%b")
        }      
      }
  
      funds
    end

    def getPrices(funds)
      funds.each { 
        |fund|
     	  yf = YahooFinance.new # or YahooFinance.new(max_number_of_concurrent_connections)
        today = Date.today
        lastpricedate = today << 12      
        fundprices = fund.etf_prices

        #do we have any price points for this fund in the database?
        if fundprices.count > 0        
          #yes, we do - get the date we got the last price on
          lastpricedate = fundprices.find(:first, :order => "pricedate DESC").pricedate
        #no, we don't have any price points for the fund - queue 12 calls to yahoo stock service (1 for each month) to get the prices for the fund           
        else
          #intentionally blank - lastpricedate has already been assigned
        end
    
        if lastpricedate > today << 1
          #yes, the last price point is within 30 days, all done, no need to call yahoo finance service -  we are done
            
        else    
          while lastpricedate < today
            logger.debug ">>>>>>#{lastpricedate.to_s}<<<<<<"
            #queue the calls to yahoo to fill in the prices from the last price point date until today in 1 month increments          
    	      yf.add_query(fund.tickersymbol, lastpricedate, lastpricedate) { 
    	        |response| 
    	        price = fund.etf_prices.new(:pricedate =>response.split(",")[6], :price=>response.split(",")[12])
    	        logger.debug ">>>>>>#{price.inspect}<<<<<<"
    	        price.save
    	      }
	        
            lastpricedate = business_day(lastpricedate >> 1)
          end

          begin
            yf.run
          rescue Exception => exc
            #logger.error("Error retrieving Yahoo quotes #{exc.message}")
            #flash[:notice] = "There was an error trying to get quotes from Yahoo service"
            price = fund.etf_prices.new(:pricedate => lastpricedate, :price=> nil)
            price.save
            next
          end               	          
      
        end
      }
    end
    
    def business_day(date)
      businessday = skip_weekends(date)
      skip_holidays(businessday)
    end

    def skip_weekends(date)
      while (date.wday % 7 == 0) or (date.wday % 7 == 6) do
        date += 1
      end
      date
    end

    def skip_holidays(date)
      #hard code the following stock market holidays and skip them (pull prior dates)
      #new Years's Eve- January 1st
      if date.month == 1 and date.day == 1
        date = date - 3
      end
      #Martin Luther King, Jr. Day is always observed on the third Monday in January, make our date the previous Friday
      if date.month == 1 and date.wday == 1 and date == Date.commercial(date.year, 3, 1) and date.day >= 14
        date = date - 3
      end
      #President's Day is always observed on the third Monday in February, make our date the previous Friday
      if date.month == 2 and date.wday == 1 and date == Date.commercial(date.year, 3, 2) and date.day >= 14
        date = date - 3
      end
      #Memorial Day is always observed on the last Monday in May, make our date the previous Friday
      if date.month == 5 and date.wday == 1 and (date + 7).month > date.month
        date = date - 3
      end
      #Independence Day - July 4
      if date.month == 7 and date.day == 4
        date = date - 4
      end
      #Labor Day - September 2
      if date.month == 9 and date.day == 2
        date = date - 4
      end
      #Thanksgiving
      if date.month == 11 and date.wday == 4 and date == Date.commercial(date.year, 4, 4) and date.day >= 21
        date = date - 1
      end
      #Christmas
      if date.month == 12 and date.wday == 24
        date = date - 3
      end
    
      #make sure to skip weekends
      while (date.wday % 7 == 0) or (date.wday % 7 == 6) do
        date += 1
      end
      date
    end
  
end
