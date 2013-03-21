class UsersController < ApplicationController
  skip_before_filter :require_current_user

  before_filter :login_required, :only => [:edit, :update]
  # GET /users/1
  def show
    @user = User.find(params[:id])
  end
end
