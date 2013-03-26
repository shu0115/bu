# coding: utf-8
class UserGroup < ActiveRecord::Base
  attr_accessible :user_id, :group_id, :state, :role, :attendance

  belongs_to :user
  belongs_to :group
  validates_uniqueness_of :user_id, :scope => [:group_id]
  validates :role, :length => { :maximum => 16 }

  # 直近参加数
  def recent_entry_count
    # ユーザのイベント参加数をカウント
    UserEvent.attendance_event_count(user_id, group.events.closed.in_recent_times.pluck(:id))
  end

  private

  # グループ内イベント総参加数
  def self.entry_count(user, group)
    UserEvent.attendance_event_count(user.id, Event.closed.where(group_id: group.id).pluck(:id))
  end
end
