# coding: utf-8
require 'spec_helper'

describe "My" do
  include_context "twitter_login"

  describe "GET /my" do
    before { visit my_path }
    it { page.status_code.should eq 200 }

    context 'event exists' do
      include_context 'visit_event_page'
      before { visit my_path }
      it { page.should have_content(event.title) }
    end

    context 'group exists' do
      include_context 'visit_group_page'
      before { visit my_path }
      it { page.should have_content(group.name) }
    end
  end

  describe "GET /my/edit" do
    let(:new_user) do
      FactoryGirl.attributes_for(:user, name: Forgery::Basic.text, mail: Forgery::Email.address)
    end

    context 'すべての領域に値を入力' do
      before do
        visit edit_my_path
        fill_in 'user[name]', with: new_user[:name]
        fill_in 'user[mail]', with: new_user[:mail]
        click_on 'Save'
      end

      it { page.should have_content('User was successfully updated.') }
      it { page.should_not have_content('Please input your mail address') }
    end

    context 'name領域だけ入力されているとき' do
      before do
        visit edit_my_path
        fill_in 'user[name]', with: new_user[:name]
        fill_in 'user[mail]', with: ''
        click_on 'Save'
      end

      it 'Userの更新は失敗する？' do
        pending '仕様が不明なのですが、現状ではアップデートが成功します。これで良い？'
        page.should_not have_content('User was successfully updated.')
      end
      it { page.should have_content('Please input your mail address') }
    end
  end
end
