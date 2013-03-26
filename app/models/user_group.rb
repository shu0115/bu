# coding: utf-8
class UserGroup < ActiveRecord::Base
  attr_accessible :user_id, :group_id, :state, :role, :attendance

  belongs_to :user
  belongs_to :group
  validates_uniqueness_of :user_id, :scope => [:group_id]
  validates :role, :length => { :maximum => 16 }

  # 直近参加数
  def recent_entry_count
    # キャンセルされていない終了しているイベントのidを取得
    active_event_ids = Event.closed.where(group_id: self.group_id).order("started_at DESC").limit(configatron.recent_entry_coun).pluck(:id)

    # ユーザのイベント参加数をカウント
    UserEvent.attendance_event_count(self.user_id, active_event_ids)
  end

  private

  # グループ内イベント総参加数
  def self.entry_count(user, group)
    UserEvent.attendance_event_count(user.id, Event.closed.where(group_id: group.id).pluck(:id))
  end
end
