class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :admin?

  protected
  def admin?
    test = session[:password]
    logger.debug "<<<--->>>Checkpoint SESSION = #{test.inspect}<<<--->>>"
    if session != nil
      return session[:password] == "etfftw"
    else
      return false
    end
  end

  def authorize
    unless admin?
      flash[:error] = "unauthorized access"
      redirect_to home_path
      false
    end
  end  
  
end
