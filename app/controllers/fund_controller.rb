class FundController < ApplicationController
  require "yahoofinance-typhoeus"
  
  def find
    searchcriteria = params[:searchcriteria].upcase
    
    funds = Fund.find_all_by_tickersymbol(searchcriteria)
    if funds.count == 0
      @funds = Fund.find_all_by_etfname(searchcriteria)
      searchedFor = "fund name " + searchcriteria
    else
      @funds = funds
      searchedFor = "ticker " + searchcriteria
    end

    execYF("AAPL")    
    @title = "Showing results for " + searchedFor
  end
  
  def execYF(ticker)
 	  yf = YahooFinance.new # or YahooFinance.new(max_number_of_concurrent_connections)
    today = Date.today - 4

 	  yf.add_query(ticker, today, today) {|response| Fund.EtfPrices.new(today, response.split(",")[12], 1)}
 	  #yf.add_query(ticker, today << 1, today << 1) {|response| puts "On #{today << 1}, Apple stock price was " + response.split(",")[12]}
 	  #yf.add_query(ticker, today << 2, today << 2) {|response| puts "On #{today << 2}, Apple stock price was " + response.split(",")[12]}
 	  #yf.add_query(ticker, today << 3, today << 3) {|response| puts "On #{today << 3}, Apple stock price was " + response.split(",")[12]}
 	  #yf.add_query(ticker, today << 4, today << 4) {|response| puts "On #{today << 4}, Apple stock price was " + response.split(",")[12]}
 	  #yf.add_query(ticker, today << 5, today << 5) {|response| puts "On #{today << 5}, Apple stock price was " + response.split(",")[12]}

 	  #yf.add_query(ticker, today << 6, today << 6) {|response| puts "On #{today << 6}, Apple stock price was " + response.split(",")[12]}
 	  #yf.add_query(ticker, today << 7, today << 7) {|response| puts "On #{today << 7}, Apple stock price was " + response.split(",")[12]}
 	  #yf.add_query(ticker, today << 8, today << 8) {|response| puts "On #{today << 8}, Apple stock price was " + response.split(",")[12]}
 	  #yf.add_query(ticker, today << 9, today << 9) {|response| puts "On #{today << 9}, Apple stock price was " + response.split(",")[12]}
 	  #yf.add_query(ticker, today << 10, today << 10) {|response| puts "On #{today << 10}, Apple stock price was " + response.split(",")[12]}
 	  #yf.add_query(ticker, today << 11, today << 11) {|response| puts "On #{today << 11}, Apple stock price was " + response.split(",")[12]}

 	  yf.run
  end

end
