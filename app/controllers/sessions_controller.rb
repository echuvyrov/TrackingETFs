class SessionsController < ApplicationController
  def new
    
  end

  def create
    session[:password] = params[:session][:password]
    password = session[:password]
    
    if password != 'etfftw'
      flash[:notice] = 'Incorrect password, try again'    
      redirect_to '/login/failure'
    else
      flash[:notice] = 'Successfully logged in'
      redirect_to '/login/success'
    end
  end
  
  def destroy
    reset_session
    flash[:notice] = 'Successfully logged out'
    redirect_to '/'
  end
end