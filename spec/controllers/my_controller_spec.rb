# coding: utf-8
require 'spec_helper'

describe MyController do
  describe "GET 'edit'" do
    context 'ログインしている場合' do
      let(:you) { FactoryGirl.create(:user) }
      before do
        login_as(you)
        get :edit
      end
      it { response.should render_template("edit") }
    end

    context 'ログインしてない場合' do
      before { bypass_rescue }
      #it { expect { get :edit }.to raise_error(User::UnAuthorized) }
      it { expect { get :edit }.to raise_error(Authentication::Unauthenticated) }
    end
  end

  describe "PUT 'update'" do
    context 'ログインしている場合' do
      let(:you) { FactoryGirl.create(:user) }
      before { login_as(you) }

      context 'valid params' do
        before do
          User.any_instance.should_receive(:update_attributes).with('these' => 'params').and_return { true }
          put :update, {user: {'these' => 'params'}}
        end

        it { response.should redirect_to(my_url) }
      end

      context 'invalid params' do
        before do
          User.any_instance.should_receive(:update_attributes).with('these' => 'params').and_return { false }
          put :update, {user: {'these' => 'params'}}
        end

        it { response.should render_template("edit") }
      end
    end

    context 'ログインしてない場合' do
      before { bypass_rescue }
      it { expect { get :edit }.to raise_error(Authentication::Unauthenticated) }
    end
  end
end
