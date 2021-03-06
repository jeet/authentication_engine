Feature: Password Reset
  As a user who forgot my password
  I want to reset my password
  So that I can continue using the site

  Scenario: Display a reset password form
    Given I am an anonymous user
    When I go to the login page
    Then I should see "Forgot password"
    When I follow "Forgot password"
    Then I should see a reset password form

  Scenario: Send a reset instructions email if given a valid email
    Given I am a confirmed user with email "bob@example.com"
    When I go to the reset password page
    And I fill in "Your Email Address" with "bob@example.com"
    And I press "Reset my password"
    Then "bob@example.com" should receive an email
    When I open the email
    And I should see "reset your password" in the email body
  
  Scenario: Do not send a reset instructions email if given an invalid email
    Given I am a confirmed user with email "bob@example.com"
    When I go to the reset password page
    And I fill in "Your Email Address" with "unknown@example.com"
    And I press "Reset my password"
    Then "bob@example.com" should receive no emails
    And "unknown@example.com" should receive no emails
    And I should see "No user was found with that email address"
  
  Scenario: Display change password form with valid token
    Given I am a user who opened my reset password email
    When I follow "reset your password" in the email
    Then I should see a password modification form
  
  Scenario: Not display change password form with invalid token
    Given I am a user who opened my reset password email
    When I go to the change password form with bad token
    Then I should not see a password modification form
  
  Scenario: Update password and log in user with valid input
    Given I am a user who opened my reset password email
    When I follow "reset your password" in the email
    Then I should see a password modification form
    When I fill in "New password" with "new secret"
    And I fill in "Password confirmation" with "new secret"
    And I press "Update my password and log me in"
    And I should see "Password successfully updated"
    Then I should see my account page
    When I follow "Logout"
    Then I should be logged out
  
  Scenario Outline: Don't update password and log in user with invalid input
    Given I am a user who opened my reset password email
    When I follow "reset your password" in the email
    Then I should see a password modification form
    When I fill in "Password" with "<password>"
    And I fill in "Password confirmation" with "<confirmation>"
    And I press "Update my password and log me in"
    Then I should see a password modification form
    And I should not see my account page
    And I should have <count> errors
    And I should see "<error_message>"
    And I should not see "Password successfully updated"
  
    Examples:
      | password   | confirmation | count | error_message                                                |
      |            |              | 2     | Password is too short (minimum is 4 characters)              |
      |            | new secret   | 2     | Password is too short (minimum is 4 characters)              |
      | new secret |              | 2     | Password confirmation is too short (minimum is 4 characters) |
      | new secret | secret       | 2     | Password doesn't match confirmation                          |
