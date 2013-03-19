# coding: utf-8
class CommentsController < ApplicationController
  before_filter :find_group, :find_event
  before_filter :find_comment, only: [:show, :destroy]
  before_filter :login_required, :group_member_only, only: :create

  def show
  end

  # POST /comments
  def create
    @comment = @user.comments.new(params[:comment])
    if @comment.save
      redirect_to group_event_url(group_id: @group.id, id: @event.id), notice: 'Comment was successfully created.'
    else
      render :new
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
    redirect_to group_event_comments_url(group_id: @group.id, event_id: @event.id)
  end

  private
  def find_group
    @group = Group.find(params[:group_id])
  end

  def find_event
    @event = @group.events.find(params[:event_id])
  end

  def find_comment
    @comment = @event.comments.find(params[:id])
  end

  def group_member_only
    only_group_member(@group)
  end
end
