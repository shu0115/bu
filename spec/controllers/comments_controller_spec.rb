# coding: utf-8
require 'spec_helper'

describe CommentsController do
  describe "GET show" do
    let(:you) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, owner_user_id: you.id) }
    let(:event) { FactoryGirl.create(:event, group_id: group.id) }
    let!(:comment) { FactoryGirl.create(:comment, event_id: event.id) }

    before { get :show, id: comment.to_param, group_id: group.to_param, event_id: event.to_param }
    it { assigns(:comment).should eq comment }
  end

  describe "POST create" do
    let(:you) { FactoryGirl.create(:user) }

    context 'グループメンバーの場合' do
      let(:group) { FactoryGirl.create(:group, owner_user_id: you.id) }
      let(:event) { FactoryGirl.create(:event, group_id: group.id) }
      let!(:comment) { FactoryGirl.attributes_for(:comment, event_id: event.id) }

      before { login_as(you) }

      context 'valid params' do
        let(:url) { group_event_url(group_id: assigns(:comment).event.group.id, id: assigns(:comment).event.id) }
         before { post :create, {comment: comment, group_id: group.to_param, event_id: event.to_param} }
         it { response.should redirect_to(url) }
       end

      context 'invalid params' do
        before do
          Comment.any_instance.should_receive(:save) { false }
          post :create, {comment: comment, group_id: group.to_param, event_id: event.to_param}
        end

        it { response.should render_template("new") }
      end
    end

    context 'グループメンバーではない場合' do
      let(:group) { FactoryGirl.create(:group, owner_user_id: other.id) }
      let!(:event) { FactoryGirl.create(:event, group_id: group.id) }
      let(:comment) { FactoryGirl.attributes_for(:comment, event_id: event.id) }
      let(:other) { FactoryGirl.create(:user) }

      before do
        login_as(you)
        bypass_rescue
      end

      it "Group::NotGroupMemberエラーが発生すること" do
        expect {
          post :create, comment: comment, group_id: group.to_param, event_id: event.to_param
        }.to raise_error(Group::NotGroupMember)
      end
    end
  end

  describe "DELETE destroy" do
    let(:you) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, owner_user_id: you.id) }
    let(:event) { FactoryGirl.create(:event, group_id: group.id) }
    let!(:comment) { FactoryGirl.create(:comment, event_id: event.id) }

    it "1件減っていること" do
      expect {
        delete :destroy, group_id: group.to_param, event_id: event.to_param, id: comment.to_param
      }.to change(Comment, :count).by(-1)
    end
  end
end
