class AddUserEventsCountToUsers < ActiveRecord::Migration
  def change
    add_column :user_groups, :attendance, :integer, null: false, default: 0
  end
end
