Feature: Sign in
  As a registered user
  I want to sign in to Messenger
  So I can send and recieve messages

  Scenario: Login Failure
    Given I am not a registered user
    And I am on the sign in page
    When I fill in "User name" with "Fred W. Savage"
    And I fill in password with "jjjjjj"
    And I press "Sign Up"
    Then I should see the sign in page

  Scenario: Successful login
    Given I am a registered user
    And I am on the sign in page
    When I fill in "User name" with "Fred W. Savage"
    And I fill in password with "jjjjjj"
    And I press "Sign Up"
    Then I should see my user home page
