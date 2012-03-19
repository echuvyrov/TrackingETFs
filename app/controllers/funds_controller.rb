class FundsController < ApplicationController
  require "yahoofinance-typhoeus"
  require 'date'
  require 'will_paginate/array'
  include CommonHelper
  include AnalyticsHelper
  
  PageSize = 10
  
  def show
    funds = Fund.find_all_by_id(params[:id])
    @fund = getFundDetails(funds)[0]
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
  
  def top50ytd
    funds = Array.new
    top10funds = getTop10YTD.take(50)	  
    top10funds.each{
      |fund_keys|
      logger.debug "fund_keys: #{fund_keys.inspect}"  
      perf_fund = Fund.find_by_id(fund_keys[0])
      perf_fund.performance_percentage = fund_keys[1]
      logger.debug "Monthly %: #{fund_keys[1].inspect}"
      funds.push(perf_fund)
    }
    @performance_caption = "YTD %: "
    @funds = getFundDetails(funds).paginate(:per_page => PageSize, :page => params[:page])
    render :topfunds
  end

  def top25month
    funds = Array.new
    top10funds = getTop25Month.take(25)	  
    top10funds.each{
      |fund_keys|
      logger.debug "fund_keys: #{fund_keys.inspect}"  
      perf_fund = Fund.find_by_id(fund_keys[0])
      perf_fund.performance_percentage = fund_keys[1]
      logger.debug "Monthly %: #{fund_keys[1].inspect}"
      funds.push(perf_fund)
    }
    @performance_caption = "Monthly %: "
    @funds = getFundDetails(funds).paginate(:per_page => PageSize, :page => params[:page])
    render :topfunds
  end

  def weeksbiggestmovers
    funds = Array.new
    top10funds = getTop10MoversThisWeek.take(10)	  
    top10funds.each{
      |fund_keys|
      logger.debug "fund_keys: #{fund_keys.inspect}"  
      perf_fund = Fund.find_by_id(fund_keys[0])
      perf_fund.performance_percentage = (@fund_performance_sign[fund_keys[0]]  + fund_keys[1].to_s).to_f
      logger.debug "Performance %: #{fund_keys[1].inspect}"
      funds.push(perf_fund)
    }
    @performance_caption = "Weekly %: "  
    @funds = getFundDetails(funds).paginate(:per_page => PageSize, :page => params[:page])
    render :topfunds
  end
    
  def about
  
  end  
  
  protected
  
    def getFundDetails(funds)
  
      #push prices into the database
      getPrices(funds)
  
      funds.each {
        |fund|
        prices = Fund.find_by_tickersymbol(fund.tickersymbol).etf_prices.where(:pricedate => (Date.today << 12)..Date.today).sort_by{
          |pd| 
          pd[:pricedate]
        }
        
        fund.prices_last12months = Array.new
        fund.pricelabels_last12months = Array.new      
        month_label = ""
        
        #logger.debug "Prices: #{prices.inspect}"
        
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
          #intentionally blank - lastpricedate has already been assigned to 12 months ago
        end
    
        if lastpricedate > today << 1
          #yes, the last price point is within 30 days, all done, no need to call yahoo finance service -  we are done
            
        else
          #queue the calls to yahoo to fill in tall of the price points for dates from start date until today        
          yf.add_query(fund.tickersymbol, lastpricedate, today) {
            |response|
            #prices for all dates come back as one big response payload; parse it appropriately
            prices = response.split("\n")

            prices.each {
              |priceline|
              pricedate = priceline.split(",")[0]
              yahooprice = priceline.split(",")[6]

              #does the price for a given date already exist?
              if fund.etf_prices.find_by_pricedate(pricedate)
                #yes, it does exist, skip adding it to the database
              else
                #skip empty and 0 elements
                if is_a_number?(yahooprice)
    	            price = fund.etf_prices.new(:pricedate => pricedate, :price=>yahooprice) 
    	            price.save 
    	          end          
              end
            }
          }

          #old code retrieving a single value every month 
          
          #while lastpricedate < today
          #  logger.debug ">>>>>>#{lastpricedate.to_s}<<<<<<"
          #  #queue the calls to yahoo to fill in the prices from the last price point date until today in 1 month increments          
    	    #  yf.add_query(fund.tickersymbol, lastpricedate, lastpricedate) { 
    	    #    |response| 
    	    #    price = fund.etf_prices.new(:pricedate =>response.split(",")[6], :price=>response.split(",")[12])
    	    #    logger.debug ">>>>>>#{price.inspect}<<<<<<"
    	    #    price.save
    	    #  }
	        #
          #  lastpricedate = business_day(lastpricedate >> 1)
          #end

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
