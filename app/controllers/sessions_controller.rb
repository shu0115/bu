# coding: utf-8
class SessionsController < ApplicationController
  skip_before_filter :require_current_user

  def new
  end

  def create
    user = User.find_or_create_with_omniauth(request.env['omniauth.auth'])
    login! user
    session[:language] = 'japanese' #TODO 仕様を決める
    redirect_to redirect_path, notice: 'Login successful.'
  end

  def destroy
    logout!
    redirect_to root_path
  end

  private
  def redirect_path
    session.delete(:redirect_path) || my_url #TODO: 動いてない気がする
  end
end
