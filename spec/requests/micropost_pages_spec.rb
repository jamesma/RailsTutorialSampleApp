require 'spec_helper'

describe "MicropostPages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { valid_signin user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }

      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end

    describe "as wrong user" do
      let(:wrong_user) { FactoryGirl.create(:user) }

      describe "submitting to the destroy action on micropost created by another user" do
        before { delete micropost_path(FactoryGirl.create(:micropost, user: user)) }
        specify { response.should redirect_to(root_path) }
      end

      describe "delete link" do
        before do 
          FactoryGirl.create(:micropost, user: wrong_user)
          visit user_path(wrong_user)
        end

        it "should not be displayed" do
          page.should_not have_link("delete")
        end
      end
    end
  end

  describe "pagination" do

    describe "on home page" do
      before { visit root_path }
      before(:all) { 50.times { FactoryGirl.create(:micropost, user: user) }  }
      after(:all) { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each micropost" do
        Micropost.paginate(page: 1).each do |item|
          page.should have_selector('li', text: item.content)
        end
      end
    end

    describe "on profile page" do
      before { visit user_path(user) }
      before(:all) { 50.times { FactoryGirl.create(:micropost, user: user) }  }
      after(:all) { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each micropost" do
        Micropost.paginate(page: 1).each do |item|
          page.should have_selector('li', text: item.content)
        end
      end
    end
  end
end


=begin
describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end
=end