require 'spec_helper'

describe "UserPages" do
  subject { page }

  describe "index" do

    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      valid_signin(user)
      visit users_path
    end

    it { should have_header_and_title('All users') }

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

    it "should list each user" do
      User.all.each do |user|
        page.should have_selector('li', text: user.name)
      end
    end

    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          valid_signin(admin)
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        # verify that admin cannot delete himself
        it { should_not have_link(('delete'), href: user_path(admin)) }
      end
    end
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_header_and_title('Sign up', 'Sign up') }
  end

  describe "profile page" do
    # make a user variable
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }

    before { visit user_path(user) }

    it { should have_header_and_title(user.name, user.name) }

    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect { click_button "Follow" }.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect { click_button "Follow" }.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_selector('input', value: 'Unfollow') }
        end
      end

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect { click_button "Unfollow" }.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect { click_button "Unfollow" }.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_selector('input', value: 'Follow') }
        end
      end

      describe "follower/following counts" do
        before { other_user.follow!(user) }

        describe "current user" do
          before { visit user_path(user) }

          it { should have_link("0 following", href: following_user_path(user)) }
          it { should have_link("1 followers", href: followers_user_path(user)) }
        end

        describe "other user" do
          before { visit user_path(other_user) }

          it { should have_link("1 following", href: following_user_path(other_user)) }
          it { should have_link("0 followers", href: followers_user_path(other_user)) }
        end
      end
    end
  end

  describe "signup" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }
        it { should have_content("Name can't be blank") }
        it { should have_content("Email can't be blank") }
        it { should have_content("Password confirmation can't be blank") }
      end
    end

    describe "with valid information" do
      before { valid_signup }

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_title(user.name) }
        it { should have_success_message('Welcome') }
        it { should have_link('Sign out') }
      end
    end

    describe "when already signed in" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }

      describe "visit sign up page" do
        before { visit signup_path }

        it { should_not have_title('Sign up') }
        it { should have_title(user.name) }
      end
      
      describe "submitting a POST request to the User#create action" do
        before { post users_path(user) }

        specify { request.should redirect_to(user_path(user)) }
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      valid_signin(user)
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_header_and_title('Update your profile', 'Edit user') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }

      before { valid_edit_user(user, new_name, new_email) }

      it { should have_title(new_name) }
      it { should have_success_message('') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe "followed users" do
      before do
        valid_signin(user)
        visit following_user_path(user)
      end

      it { should have_title('Following') }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "following users" do
      before do
        valid_signin(other_user)
        visit followers_user_path(other_user)
      end

      it { should have_title('Followers') }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end
end
