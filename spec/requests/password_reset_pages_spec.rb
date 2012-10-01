require 'spec_helper'

describe "PasswordResetPages" do

  subject { page }

  describe "Reset password page" do
    before { visit new_password_reset_path }
    it { should have_header_and_title('Reset password', 'Reset password') }

    describe "for existing user" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email", with: user.email
        click_button "Reset Password"
      end

      it { should have_header_and_title('Sample App','') }
      it { should have_success_message('Email sent') }
    end

    describe "for non-existing user" do
      before do
        fill_in "Email", with: "random@random.com"
        click_button "Reset Password"
      end

      it { should have_header_and_title('Sample App','') }
      it { should have_success_message('Email sent') }
    end
  end
end
