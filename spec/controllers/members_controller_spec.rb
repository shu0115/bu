# coding: utf-8
require 'spec_helper'

describe MembersController do
  let(:you) { FactoryGirl.create(:user) }

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
end
