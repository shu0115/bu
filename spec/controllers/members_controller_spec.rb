# coding: utf-8
require 'spec_helper'

describe MembersController do
  let(:you) { FactoryGirl.create(:user) }

  context 'GET index' do
    let(:group) { FactoryGirl.create(:group, owner_user_id: you.id) }
    let!(:events) { FactoryGirl.create_list(:event, 10, group_id: group.id, owner_user_id: you.id) }

    before { get :index, group_id: group.to_param }

    it { assigns(:events).first.group_id.should eq group.id }
    it { assigns(:events).count.should eq events.count }
    it { assigns(:group).should eq group }
  end

  context 'GET show' do
    let(:group) { FactoryGirl.create(:group, owner_user_id: you.id) }
    let!(:events) { FactoryGirl.create_list(:event, 10, group_id: group.id, owner_user_id: you.id) }
    before { get :show, id: you.to_param, group_id: group.to_param }

    it { assigns(:events).count.should eq events.count }
    it { assigns(:group).should eq group }
    it { assigns(:current_user).should eq you }
  end

  describe "PUT 'join'" do
    let!(:group) { FactoryGirl.create(:group) }

    context 'Loginしているとき' do
      let(:you) { FactoryGirl.create(:user) }
      before do
        login_as(you)
        put :join, group_id: group.to_param
      end

      it { response.should redirect_to(group_url(group.to_param)) }
    end

    context 'Loginしていないとき' do
      before { bypass_rescue }
      it { expect { put :join, group_id: group.to_param }.to raise_error(User::UnAuthorized) }
    end
  end


  describe 'PUT #join' do
    context 'ログインしていない場合' do
      let!(:group) { FactoryGirl.create(:group, owner_user_id: you.id) }

      before { bypass_rescue }
      it { expect { put :join, group_id: group.to_param }.to raise_error(User::UnAuthorized) }
    end

    context 'ログインしている場合' do
      let!(:group) { FactoryGirl.create(:group, owner_user_id: you.id, permission: permission) }

      context 'グループがpublicである場合' do
        let(:permission) { 0 }

        context 'あなたがメンバーの場合' do
          before { login_as(you) }
          it { expect { put :join, group_id: group.to_param }.to change(UserGroup, :count).by(0) }
        end

        context 'あなたがメンバーではない場合' do
          let(:other) { FactoryGirl.create(:user) }
          before { login_as(other) }
          it { expect { put :join, group_id: group.to_param }.to change(UserGroup, :count).by(+1) }
        end
      end

      context 'グループがpublicでない場合' do
        let(:permission) { 1 }
        it { expect { put :join, group_id: group.to_param }.to change(UserGroup, :count).by(0) }
      end
    end
  end

  describe 'PUT #leave' do
    let!(:group) { FactoryGirl.create(:group, owner_user_id: you.id) }

    context 'あなたがメンバーの場合' do
      before { login_as(you) }
      it { expect { put :leave, group_id: group.to_param }.to change(UserGroup, :count).by(-1) }
    end

    context 'あなたがメンバーではない場合' do
      let(:other) { FactoryGirl.create(:user) }
      before { login_as(other) }
      it { expect { put :leave, group_id: group.to_param }.to change(UserGroup, :count).by(0) }
    end
  end

  describe 'PUT #request_to_join' do
    context 'ログインしていない場合' do
      let!(:group) { FactoryGirl.create(:group, owner_user_id: you.id) }

      before { bypass_rescue }
      it { expect { put :request_to_join, group_id: group.to_param }.to raise_error(User::UnAuthorized) }
    end

    context 'ログインしている場合' do
      let!(:group) { FactoryGirl.create(:group, owner_user_id: you.id, permission: permission) }

      context 'グループがpublicである場合' do
        let(:permission) { 0 }
        it { expect { put :request_to_join, group_id: group.to_param }.to change(MemberRequest, :count).by(0) }
      end

      context 'グループがpublicでない場合' do
        let(:permission) { 1 }

        context 'あなたがメンバーの場合' do
          before { login_as(you) }
          it { expect { put :request_to_join, group_id: group.to_param }.to change(MemberRequest, :count).by(0) }
        end

        context 'あなたがメンバーリクエスト済の場合' do
          let(:other) { FactoryGirl.create(:user) }
          before do
            login_as(other)
            group.requesting_users << other
          end
          it { expect { put :request_to_join, group_id: group.to_param }.to change(MemberRequest, :count).by(0) }
        end

        context 'あなたがメンバーではない場合' do
          let(:other) { FactoryGirl.create(:user) }
          before { login_as(other) }
          it { expect { put :request_to_join, group_id: group.to_param }.to change(MemberRequest, :count).by(+1) }
        end
      end
    end
  end

  describe 'PUT #delete_request' do
    let!(:group) { FactoryGirl.create(:group, owner_user_id: you.id) }

    context 'ログインしている場合' do
      let(:other) { FactoryGirl.create(:user) }
      before { login_as(other) }

      context 'あなたがメンバーリクエスト済の場合' do
        before { group.requesting_users << other }
        it { expect { put :delete_request, group_id: group.to_param }.to change(MemberRequest, :count).by(-1) }
      end

      context 'あなたがメンバーリクエストしていない場合' do
        it { expect { put :delete_request, group_id: group.to_param }.to change(MemberRequest, :count).by(0) }
      end
    end

    context 'ログインしていない場合' do
      it { expect { put :delete_request, group_id: group.to_param }.to change(MemberRequest, :count).by(0) }
    end
  end

  describe "PUT update" do
    #groupにおける役職名の設定
    let(:owner) { FactoryGirl.create(:user) }
    let(:target) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, owner_user_id: owner.id) }
    let(:target_user_groups_id) { target.user_groups.where(:group_id => group.id).first.to_param }
    let(:edited_user_group_params) { FactoryGirl.attributes_for(:user_group, group_id: group.id, user_id: target.id) }

    before do
      group.users << target
      login_as(operator)
    end

    shared_examples "update user_group successfully" do
      it 'update_attributesが呼ばれていること' do
        UserGroup.any_instance.should_receive(:update_attributes).with(role: 'a')
        put :update, {id: target_user_groups_id, group_id: group.id, user_group: {role: 'a'}}
      end
      it {
        put :update, { id: target_user_groups_id, group_id: group.id, user_group: edited_user_group_params }
        response.should redirect_to(group_members_url(group_id: group.id))
      }
    end

    context "with valid params" do
      context "操作者がOwnerのとき" do
        let(:operator) { owner }
        it_behaves_like 'update user_group successfully'
      end

      context "操作者がManagerのとき" do
        let(:operator) { FactoryGirl.create(:user) }
        before do
          # managerにする
          FactoryGirl.create(:user_group, user_id: operator.id, group_id: group.id, role: 'role')
        end
        it_behaves_like 'update user_group successfully'
      end

      context "操作者がOwnerでもManagerでもないとき" do
        let(:operator) { FactoryGirl.create(:user) }
        before { bypass_rescue }
        it { expect { put :update, {id: target_user_groups_id, group_id: group.id, user_group: edited_user_group_params } }.to raise_error(Group::NotGroupManager) }
      end
    end

    context "with invalid params" do
      let(:operator) { owner }
      before { put :update, {id: target_user_groups_id, group_id: group.id, user_group: {}} }
      it { response.should redirect_to(group_members_url(group_id: group.id)) }
    end
  end

  describe "DELETE destroy" do
    let(:owner) { FactoryGirl.create(:user) }
    let(:target) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, owner_user_id: owner.id) }
    let(:target_user_groups_id) { target.user_groups.where(:group_id => group.id).first.to_param }

    before do
      login_as(operator)
    end

    context '操作者がOwnerのとき' do
      let(:operator) { owner }
      before do
        group.users << target
      end
      it '対象者が削除されること' do
        expect {
          delete :destroy, {id: target_user_groups_id, group_id: group.id }
        }.to change(UserGroup, :count).by(-1)
      end
    end

    context '操作者がManagerのとき' do
      let(:operator) { FactoryGirl.create(:user) }
      before do
        # managerにする
        FactoryGirl.create(:user_group, user_id: operator.id, group_id: group.id, role: 'role')
      end
      context '対象者がOwnerのとき' do
        let(:target) { owner }
        it '対象者が削除されないこと' do
          expect {
            delete :destroy, {id: target_user_groups_id, group_id: group.id }
          }.not_to change(UserGroup, :count)
        end
      end
      context '対象者がOwnerではないとき' do
        before do
          group.users << target
        end
        it '対象者が削除されること' do
          expect {
            delete :destroy, {id: target_user_groups_id, group_id: group.id}
          }.to change(UserGroup, :count).by(-1)
        end
      end
    end

    context '操作者がOwnerでもManagerでもないとき' do
      let(:operator) { FactoryGirl.create(:user) }
      before do
        bypass_rescue
        group.users << operator
        group.users << target
      end
      it 'Group::NotGroupManagerが発生すること' do
        expect {
          delete :destroy, {id: target_user_groups_id, group_id: group.id }
        }.to raise_error(Group::NotGroupManager)
      end
    end
  end
end
