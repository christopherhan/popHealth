class ReportsController < ApplicationController
  skip_authorization_check
  before_filter :authenticate_user!
  def index
  
  end

end
