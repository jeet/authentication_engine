Given /^I am an anonymous user$/ do
  visit '/logout'
end

Given /^I am a confirmed user "([^\"]*)" with password "([^\"]*)"$/ do |name, password|
  u = User.new
  u.signup_without_credentials!({:name => name, :email => "#{name}@example.com"}) {}
  u.activate!({:login => name, :password => password, :password_confirmation => password}, false) {}
end

Given /^I am a confirmed user with email "([^\"]*)"$/ do |email|
  u = User.new
  u.signup_without_credentials!({:name => "Foo Bar", :email => email }) {}
  u.activate!({:login => 'foobar', :password => 'secret', :password_confirmation => 'secret'}, false) {}
end

Given /^I am an un-confirmed user with email "([^\"]*)"$/ do |email|
  u = User.new
  u.signup_without_credentials!({:name => "Foo Bar", :email => email }) {}
end

Given /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  unless login.blank?
    visit login_path
    fill_in "Login", :with => login
    fill_in "Password", :with => password
    click_button "Login"
    # save_and_open_page 
  end
end

Given /^I am logged in as "([^\"]*)" with email "([^\"]*)"$/ do |name, email|
  u = User.new
  u.signup_without_credentials!({:name => name, :email => email}) {}
  u.activate!({:login => name, :password => 'secret', :password_confirmation => 'secret'}, false) {}
  visit login_path
  fill_in "Login", :with => name
  fill_in "Password", :with => 'secret'
  click_button "Login"
  save_and_open_page 

end



Given /^I should see a login form$/ do
  response.should contain("Login")
  response.should contain("Password")
  response.should contain("Remember me")
  response.should contain("Open ID")
end

When /^I open the homepage in a new window$/ do
  new_window = ::Webrat.session_class.new(self)
  new_window.visit root_path
end


# http://wiki.github.com/aslakhellesoy/cucumber/multiline-step-arguments
# http://wiki.github.com/aslakhellesoy/cucumber/background
Given /^the following user records$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |hash|
    # ex: hash = {'login' => 'bob', 'password' => 'secret'}
    u = User.new
    u.signup_without_credentials!({:name => hash['login'], :email => "#{hash['login']}@example.com"}) {}
    u.activate!({:login => hash['login'], :password => hash['password'], :password_confirmation => hash['password']}, false) {}
    ## please don't use signup! method, this will invoke an authlogic_oid method 'openid_complete?'
    ## since we don't have a good openid testing environment yet.
    #u.signup!(:login => hash['login'], :email => "#{hash['login']}@example.com")
    #u.activate!(:password => hash['password'], :password_confirmation => hash['password'])
  end
end

Factory.define :user do |f|
  f.sequence(:name) { |n| "name#{n}" }
  f.sequence(:login) { |n| "foo#{n}" }
  f.password "foobar"
  f.password_confirmation { |u| u.password }
  f.sequence(:email) { |n| "foo#{n}@example.com" }
end


