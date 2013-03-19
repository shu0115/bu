# coding: utf-8
require 'spec_helper'

describe "Comments" do
  include_context "twitter_login"
  include_context 'visit_event_page'

  describe 'POST /comments' do
    let(:comment) { FactoryGirl.attributes_for(:comment) }
    before do
      fill_in 'comment[text]', with: comment[:text]
      click_on 'Save'
    end

    it { page.should have_content(comment[:text]) }
  end

  describe 'GET /comment/:id' do
    let(:comment) { FactoryGirl.create(:comment, user: you, event_id: event.id) }
    before { visit group_event_comment_path(id: comment.id, event_id: event.id, group_id: group.id) }
    it { page.should have_content(comment[:text]) }
  end

  describe 'DELETE /comment/:id' do
    let(:comment) { FactoryGirl.create(:comment, user: you, event_id: event.id) }
    before do
      visit group_event_comment_path(id: comment.id, event_id: event.id, group_id: group.id)
      click_link '削除'
    end

    pending 'コメントの表示ページに削除リンクが未実装' do
      page.should have_content('Comment was successfully deleted.')
    end
  end
end
