include ApplicationHelper

# RSpec custom matchers (as opposed to Cucumber), see 8.3.3 at 
# http://ruby.railstutorial.org/chapters/sign-in-sign-out#sec-rspec_custom_matchers
def valid_signin(user)
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def valid_signup
  fill_in "Name",           with: "Example User"
  fill_in "Email",          with: "user@example.com"
  fill_in "Password",       with: "foobar"
  fill_in "Confirmation",   with: "foobar"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-success', text: message)
  end
end

RSpec::Matchers.define :have_header do |header|
  match do |page|
    page.should have_selector('h1', text: header)
  end
end

RSpec::Matchers.define :have_title do |title|
  match do |page|
    page.should have_selector('title', text: title)
  end
end

RSpec::Matchers.define :have_header_and_title do |header, title|
  match do |page|
    page.should have_selector('h1', text: header)
    page.should have_selector('title', text: title)
  end
end