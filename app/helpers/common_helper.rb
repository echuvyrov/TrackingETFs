module CommonHelper
	
	def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
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
