class WelcomeController < ApplicationController
  skip_before_filter :require_current_user

  def index
    @groups = Group.where('permission <= 1')
  end
end
