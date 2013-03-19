# coding: utf-8
class MyController < ApplicationController
  before_filter :find_user

  def show
    @groups = @user.groups
    @events = @groups.map(&:events).flatten.sort_by(&:started_at).reverse
  end

  # GET /users/edit
  def edit
    @user.locale = session[:language] #TODO 仕様を決める
  end

  # PUT /users/1
  def update(user)
    if @user.update_attributes(user)
      session[:language] = @user.locale #TODO 仕様を決める
      current_user.reload
      redirect_to my_url, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  private
  def find_user
    @user = User.find(current_user_id)
  end
end
