# coding: utf-8
require 'spec_helper'

describe UserGroup do
  describe "Validations" do
    before { FactoryGirl.create(:user_group) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:group_id) }
    it { should ensure_length_of(:role).is_at_most(16) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:group) }
  end

  describe "entry count" do
    before { FactoryGirl.create(:event, group_id: group.id) }
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }
    let(:user_group) { FactoryGirl.create(:user_group, user_id: user.id, group_id: group.id) }

    it '直近参加数が一致すること' do
      user_group.recent_entry_count.should eq UserEvent.where(user_id: user.id, event_id: Event.closed.in_recent_times.where(group_id: group.id).pluck(:id), state: "attendance").count
    end

    it 'グループ内イベント総参加数が一致すること' do
      UserGroup.entry_count(user, group).should eq UserEvent.where(user_id: user.id, event_id: Event.closed.where(group_id: group.id).pluck(:id), state: "attendance").count
    end
  end
end
