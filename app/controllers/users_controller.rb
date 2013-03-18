class UsersController < ApplicationController
  before_filter :login_required, :only => [:edit, :update]
  # GET /users/1
  def show
    @current_user = User.find(params[:id])
  end
end
