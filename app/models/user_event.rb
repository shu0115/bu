# coding: utf-8
class UserEvent < ActiveRecord::Base
  attr_accessible :state, :event_id, :user_id

  belongs_to :user
  belongs_to :event
  validates_uniqueness_of :user_id, :scope => [:event_id]

  delegate :group_id, to: :event, prefix: true

  # 参加数カウント更新
  after_save    :update_events_count
  after_destroy :update_events_count

  def update_events_count
    user_group       = UserGroup.where(user_id: self.user_id, group_id: self.event_group_id).first
    active_event_ids = Event.closed.where(group_id: user_group.group_id).pluck(:id)

    user_group.update_attributes( attendance: UserEvent.attendance_event_count(self.user_id, active_event_ids) )
  end

  private

  # ユーザ参加イベント数カウント
  def self.attendance_event_count(user_id, event_ids)
    self.where(user_id: user_id, event_id: event_ids, state: "attendance").count
  end
end
