class ApplicationController < ActionController::Base
  include Authentication
  helper_method :current_user

  protect_from_forgery

  rescue_from Authentication::Unauthenticated do
    flash[:notice] = 'Login failed' #TODO: i18n
    redirect_to login_url
  end

  def find_current_user
    User.where(id: current_user_id).first
  end

  def require_current_user
    raise Authentication::Unauthenticated unless logged_in?
  end

  rescue_from User::NotAdministrator, :with => -> { redirect_to root_url }
  rescue_from Group::NotGroupOwner, :with => -> { render :text => 'not group owner' }
  rescue_from Group::NotGroupManager, :with => -> { render :text => 'not group manager' }
  rescue_from Group::NotGroupMember, :with => -> { render :text => 'not group member' }
  rescue_from Event::NotEventManager, :with => -> { render :text => 'not event manager' }

  private
  before_filter { @subtitle = ': beta' }

  before_filter {
    if controller_name != 'users' and controller_name != 'events' and controller_name != 'sessions'
      session.delete(:redirect_path_after_event_show)
    end
  }

  def only_group_owner(group = nil)
    require_current_user
    group ||= Group.find(params[:id])
    group.owner?(current_user) or raise(Group::NotGroupOwner)
  end

  def only_group_manager(group = nil)
    require_current_user
    group ||= Group.find(params[:id])
    group.manager?(current_user) or raise(Group::NotGroupManager)
  end

  def only_group_member(group = nil)
    require_current_user
    group ||= Group.find(params[:id])
    group.member?(current_user) or raise(Group::NotGroupMember)
  end

  def only_event_manager(event)
    require_current_user
    event.manager?(current_user) or raise(Event::NotEventManager)
  end
end
