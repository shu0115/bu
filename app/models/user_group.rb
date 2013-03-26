# coding: utf-8
class UserGroup < ActiveRecord::Base
  attr_accessible :user_id, :group_id, :state, :role

  belongs_to :user
  belongs_to :group
  validates_uniqueness_of :user_id, :scope => [:group_id]
  validates :role, :length => { :maximum => 16 }

  # 過去参加数
  def entry_count
    # キャンセルされていない終了しているイベントのidを取得
    active_event_ids = Event.where(group_id: self.group_id, canceled: false).where("ended_at < ?", Time.now).pluck(:id)

    # ユーザのイベント参加数をカウント
    UserEvent.attendance_event_count(self.user_id, active_event_ids)
  end

  # 直近参加数
  def recent_entry_count(recent=10)
    # キャンセルされていない終了しているイベントのidを取得
    active_event_ids = Event.where(group_id: self.group_id, canceled: false).where("ended_at < ?", Time.now).order( "started_at DESC" ).limit(recent).pluck(:id)

    # ユーザのイベント参加数をカウント
    UserEvent.attendance_event_count(self.user_id, active_event_ids)
  end
end
