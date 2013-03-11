# coding: utf-8
require 'spec_helper'

describe UsersController do
  describe "GET 'show'" do
    let(:user) { FactoryGirl.create(:user) }
    before { get :show, id: user.id }
    it { assigns(:current_user).id.should eq user.id }
  end
end
