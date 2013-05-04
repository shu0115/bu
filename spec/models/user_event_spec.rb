# coding: utf-8
require 'spec_helper'

describe UserEvent do
  describe "Validations" do
    before { FactoryGirl.create(:user_event) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:event_id) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:event) }
  end

  describe "event count" do
    let(:user_event) { FactoryGirl.create(:user_event, user_id: user.id, event_id: event.id) }
    let(:user_group) { FactoryGirl.create(:user_group, user_id: user.id, group_id: group.id) }
    let(:group) { FactoryGirl.create(:group) }
    let(:user) { FactoryGirl.create(:user) }
    let(:event) { FactoryGirl.create(:event, group_id: group.id) }

    it '参加数が増加すること' do
      before_count = user_group.attendance
      user_event.update_attributes(state: "attendance")
      UserGroup.where(user_id: user.id, group_id: group.id).first.attendance.should eq (before_count + 1)
    end
  end
end
