class SessionsController < ApplicationController
  def new
    
  end

  def create
    test = params[:session][:password]
    logger.debug "+++===In Session Create #{test.inspect}"
    session[:password] = params[:session][:password]
    test2 = session[:password]
    logger.debug "+++===In Session Create #{test2.inspect}"
    flash[:notice] = 'Successfully logged in'
    redirect_to '/'
  end
  
  def destroy
    reset_session
    flash[:notice] = 'Successfully logged out'
    redirect_to login_path
  end
end