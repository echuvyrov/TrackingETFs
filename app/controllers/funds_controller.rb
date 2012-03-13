class FundsController < ApplicationController
  require "yahoofinance-typhoeus"
  require 'date'
  require 'will_paginate/array'
  include CommonHelper
  
  PageSize = 2
  
  def show
    @fund = Fund.find(params[:id])
    @title = 'Edit ' + @fund.etfname
  end
  
  def index
    funds = Fund.all.paginate(:per_page => PageSize, :page => params[:page])
    funds = getFundDetails(funds)
    @funds = funds
    
  end
  
  def find
    if params[:searchcriteria] == nil or params[:searchcriteria] == ''
      #if no search criteria passed in, show all funds
      funds = Fund.all.paginate(:per_page => PageSize, :page => params[:page])
      searchcriteria =  ''
      
    else
      searchcriteria = params[:searchcriteria].upcase    
      funds = Fund.find_all_by_tickersymbol(searchcriteria).paginate(:per_page => PageSize, :page => params[:page])
      if funds.count == 0
        funds = Fund.find_all_by_etfname(searchcriteria).paginate(:per_page => PageSize, :page => params[:page])
        searchedFor = "fund name " + searchcriteria
      else
        searchedFor = "ticker " + searchcriteria
      end
    end
    
    funds = getFundDetails(funds)
    @funds = funds
  end
  
  def category
    category = params[:name]
    funds = Fund.find_all_by_etftype(category)
    @funds = getFundDetails(funds).paginate(:per_page => PageSize, :page => params[:page])
    @title = 'Showing ' + category + ' funds'
  end

  def new
    @fund  = Fund.new
    @title = "Create new ETF"
  end
  
  def create
    @fund = Fund.new(params[:fund])
    if @fund.save
      redirect_to @fund, :flash => { :success => "Successfully created the new fund." }
    else
      @title = "Create new ETF"
      render 'new'
    end
  end
  
  def edit
    @fund = Fund.find(params[:id])  
    @title = "Edit ETF"
  end
  
  def update
     @fund = Fund.find(params[:id]) 
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
    redirect_to funds_path, :flash => { :success => "Fund deleted." }
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
        month_label = ""
        
        logger.debug "Prices: #{prices.inspect}"
        
        prices.each_with_index { 
          |p, i|
          fund.prices_last12months << p.price.to_f
          #set the labels to be only once a month
          if month_label != p.pricedate.strftime("%b")
            fund.pricelabels_last12months << p.pricedate.strftime("%b")
            month_label = p.pricedate.strftime("%b")  
          else
            fund.pricelabels_last12months << ''
          end
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
end
