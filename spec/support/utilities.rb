include ApplicationHelper

# RSpec custom matchers (as opposed to Cucumber), see 8.3.3 at 
# http://ruby.railstutorial.org/chapters/sign-in-sign-out#sec-rspec_custom_matchers
def valid_signin(user)
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end