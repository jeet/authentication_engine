Feature: Invitations
  As a site member
  I want to be able to invite my friends
  So that I interact with them online

  Scenario: Invite a friend
    Given I am a confirmed user "bob" with password "secret"
      And I am logged in as "bob" with password "secret"
     Then I should see "Send Invitation"
      And I should have 5 invitations left
     When I follow "Send Invitation"
     Then I should see invitation form
     When I fill in "Friend's full name" with "lina"
      And I fill in "Friend's email address" with "lina@example.com"
      And I press "Invite!"
     Then I should see "Thank you, invitation sent."
      And I should have 4 invitations left
     Then "lina@example.com" should receive 1 email
     When "lina@example.com" opens the email with subject "User Invitation"
     Then "lina@example.com" should see "bob has invited you to register." in the email
  
  Scenario: Accept invitation
    Given a user with email "lina@example.com" who was invited by "bob"
     When "lina@example.com" opens the email with subject "User Invitation"
     Then "lina@example.com" should see "bob has invited you to register." in the email
     When I click the first link in the email
     Then I should see "Activate your account"
     When I fill in "Login" with "lina"
      And I fill in "Set your password" with "secret"
      And I fill in "Password confirmation" with "secret"
      And I press "Activate"
     Then I should see "Your account has been activated."
      And I should be logged in
     Then I should have 2 emails at all
     When I open the most recent email
     Then I should see "Activation Complete" in the subject
    # TODO: implement when failing mailer template is fixed
    # Then "bob@example.com" should have 1 email
    # When "bob@example.com" opens the email
    # Then "bob@example.com" should see "Invitation Activated" in the subject
  
