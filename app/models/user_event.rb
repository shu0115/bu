# coding: utf-8
class UserEvent < ActiveRecord::Base
  attr_accessible :state, :event_id, :user_id

  belongs_to :user
  belongs_to :event
  validates_uniqueness_of :user_id, :scope => [:event_id]

  # 参加数カウント更新
  after_save { |user_event| user_event.user.update_attributes!( events_count: user_event.user.entry_count(user_event.event.group) ) }
  after_destroy { |user_event| user_event.user.update_attributes!( events_count: user_event.user.entry_count(user_event.event.group) ) }
end
