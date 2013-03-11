class AttendeesController < ApplicationController
  before_filter :login_required, only: [:attend]
  before_filter :find_group, only: [:attend, :delete, :absent, :maybe]
  before_filter :find_event, only: [:attend, :delete, :absent, :maybe]
  before_filter :member_only, only: [:attend]
  before_filter :group_member_only, only: [:absent, :maybe]

  def delete
    if @event.users.destroy(@user)
      redirect_to :back
    else
      redirect_to :back, :notice => 'error: Not deleted.'
    end
  end

  def attend
    if @user.atnd(@event)
      notice = 'atnd already is exist.'
    else
      @user.attend(@event) #TODO 失敗のケースを追加する
    end

    redirect_to session[:redirect_path_after_event_show] || :back, notice: notice
  end

  def absent
    @user.be_absent(@event) #TODO 失敗のケースを追加する
    redirect_to :back
  end

  def maybe
    @user.be_maybe(@event) #TODO 失敗のケースを追加する
    redirect_to :back
  end

  private
  def find_event #TODO
    @event = @group.events.find(params[:event_id])
  end

  def find_group #TODO
    @group = Group.find(params[:group_id])
  end

  def member_only #TODO
    if @group.public? and !@group.member?(@user)
      @group.users << @user
    end

    only_group_member(@group)
  end

  def group_member_only
    only_group_member(@event.group)
  end
end
