# coding: utf-8
shared_context "twitter_login" do
  let!(:you) { FactoryGirl.create(:user) }
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[you.provider.to_sym] = {
      "provider" => you.provider,
      "uid" => you.uid,
      'info' => {
        'email' => you.mail,
        'nickname' => you.name,
        'image' => you.image
      }
    }

    visit "/auth/twitter"
  end
end

shared_context "visit_event_page" do
  let(:group) { FactoryGirl.create(:group, owner_user_id: you.id) }
  let(:event) { FactoryGirl.create(:event, group: group, owner_user_id: you.id) }
  before { visit group_event_path(group_id: group.id, id: event.id) }
end

shared_context "visit_group_page" do
  let(:group) { FactoryGirl.create(:group, owner_user_id: you.id) }
  before { visit group_path(group) }
end
