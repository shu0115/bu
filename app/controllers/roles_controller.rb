class RolesController < ApplicationController
  before_filter :find_group, only: [:index, :show, :update, :destroy]
  before_filter :group_member_only, only: [:index, :show]
  before_filter :find_user_group, only: [:update, :destroy]
  before_filter :manager_only, only: [:update, :destroy]
  before_filter :owner_only, only: :destroy

  def index #TODO: members#indexに移動する?
    @events = @group.events
  end

  def show #TODO: members#showに移動する?
    @user = @group.users.find(params[:id])
    @user_group = @user.user_group(@group)

    time = @user_group.created_at
    if oldst = @user.user_events.minimum(:created_at)
      time = oldst if oldst < time
    end
    @events = @group.events.where('created_at >= ?', time)
  end

  def update #TODO: viewが整理されないとリファクタリング辛い
    if @user_group.update_attributes(user_group_params)
      redirect_to group_roles_url(group_id: @group.id), notice: 'Role was successfully updateed.'
    else
      redirect_to group_roles_url(group_id: @group.id)
    end
  end

  def destroy
    @user_group.destroy
    redirect_to group_roles_url(@group.id), notice: 'Remeved member.'
  end

  private
  def group_member_only
     only_group_member(@group) if @group.secret?
  end

  def find_group
    @group = Group.find(params[:group_id])
  end

  def user_group_params
    { role: params[:user_group].try(:[], :role) }
  end

  def user_group_params
    { role: params[:user_group].try(:[], :role) }
  end

  def find_user_group
    @user_group = UserGroup.find(params[:id])
  end

  def manager_only
    only_group_manager(@group)
  end

  def owner_only
    raise Group::NotGroupOwner if @group.owner?(@user_group.user)
  end
end
