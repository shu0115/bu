# coding: utf-8
namespace :users do
  # rake users:events_count
  desc 'イベント参加数カウント更新'
  task events_count: :environment do
    groups = Group.includes(:users).all

    groups.each { |group|
      group.users.each { |user|
        attendance = UserEvent.attendance_event_count(user.id, Event.closed.where(group_id: group.id).pluck(:id))
        UserGroup.where(user_id: user.id, group_id: group.id).first.update_attributes( attendance: attendance )
      }
    }
  end
end
