class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user

  private
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    
    def login_required
      if !current_user
        flash[:warning] = "You must be logged in to do that."
        redirect_to root_url
      end
    end
    
    def not_a_pubby_required
      if !current_user || current_user.pubby?
        flash[:warning] = "You must be logged in and not a pubby to do that."
        redirect_to root_url
      end
    end
end
