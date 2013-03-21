class MembersController < ApplicationController
  before_filter :find_group, only: [:destroy, :join, :leave, :request_to_join, :delete_request]
  before_filter :member_only, only: [:leave]

  def leave
    @group.users.delete(current_user)
    redirect_to @group, notice: 'Left.'
  end

  def join
    unless @group.public?
      redirect_to group_url(@group.id), notice: 'Not joined.'
      return
    end

    if @group.member?(current_user)
      redirect_to group_url(@group.id), notice: 'You already are a member of this group.'
    else
      @group.users << current_user
      redirect_to group_url(@group.id), notice: 'Joined.'
    end
  end

  def request_to_join
    if @group.public?
      redirect_to @group, notice: 'Not requested.'
      return
    end

    if @group.member?(current_user)
      redirect_to @group, notice: 'You already are a member of this group.'
    elsif @group.requesting_user?(current_user)
      redirect_to @group, notice: 'You already requested to join this group.'
    else
      @group.requesting_users << current_user
      redirect_to @group, notice: 'Requested.'
    end
  end

  def delete_request
    if @group.requesting_user?(current_user)
      @group.requesting_users.delete current_user
      redirect_to @group, notice: 'Deleted request.'
    else
      redirect_to @group, notice: 'Not deleted request.'
    end
  end

  private
  def member_only
    only_group_member(@group)
  end

  def find_group
    @group = Group.find(params[:group_id])
  end
end
