class AddUserEventsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :events_count, :integer, null: false, default: 0
  end
end
