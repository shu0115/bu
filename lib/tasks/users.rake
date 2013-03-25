# coding: utf-8
namespace :users do
  # rake users:events_count
  desc 'イベント参加数カウント更新'
  task events_count: :environment do
    groups = Group.includes(:users).all

    groups.each { |group|
      group.users.each { |user|
        user.update_attributes( events_count: user.entry_count(group) )
      }
    }
  end
end
