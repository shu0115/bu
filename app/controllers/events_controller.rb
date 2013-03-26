class EventsController < ApplicationController
  before_filter :require_current_user, only: [:create, :update, :destroy, :be_active, :cancel]

  rescue_from ActiveRecord::RecordInvalid, :with => -> { redirect_to :back, :notice => 'error' }

  before_filter :find_group
  before_filter :member_only, only: [:new, :edit, :show]
  before_filter :member_only_for_create, only: [:create]
  before_filter :find_event, only: [:show, :update, :destroy]
  before_filter :find_last_event, only: [:new, :edit, :create, :update]
  before_filter :find_event_from_event_id, only: [:cancel, :be_active]
  before_filter :event_manager_only, only: [:update, :destroy, :cancel, :be_active]

  after_filter(only: :show) {
    session[:redirect_path_after_event_show] = group_event_url(group_id: @group.id, id: @event.id)
  }

  # GET /events/1
  def show
    @comment = @event.comments.build
    set_subtitle
  end

  # GET /events/new
  def new
    @event = @group.events.build
    set_subtitle 'new'
  end

  # GET /events/1/edit
  def edit
    @event = @group.events.find(params[:id])
    set_subtitle
  end

  # POST /events
  def create
    @event = @group.events.new(params[:event]) do |model|
      model.owner = current_user
    end

    if @event.save
      redirect_to group_event_url(group_id: @group.to_param, id: @event.to_param), notice: 'Event was successfully created.'
    else
      render :new
    end
  end

  # PUT /events/1
  def update
    if @event.update_attributes(params[:event])
      redirect_to group_event_url(group_id: @group.to_param, id: @event.to_param), notice: 'Event was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    redirect_to group_url(@group)
  end

  def cancel
    @event.cancel #TODO 失敗のケースを追加する
    redirect_to group_event_url(id: @event.to_param, group_id: @group.to_param), notice: 'Event was successfully canceled.'
  end

  def be_active
    @event.be_active #TODO 失敗のケースを追加する
    redirect_to group_event_url(id: @event.to_param, group_id: @group.to_param), notice: 'Event is active.'
  end

  private

  def set_subtitle(title = nil)
    @subtitle = ": #{@event.group.name} #{title or @event.title}"
  end

  def find_event
    @event = @group.events.find(params[:id])
  end

  def find_last_event
    @last = @group.events.order("id desc").first
  end

  def find_group
    @group = Group.find(params[:group_id])
  end

  def member_only #TODO
    only_group_member(@group) if @group.secret?
  end

  def member_only_for_create #TODO
    only_group_member(@group)
  end

  def event_manager_only #TODO
    only_event_manager(@event)
  end

  def find_event_from_event_id #TODO
    @event = Event.find(params[:id])
  end
end
