@sign_in
Feature: Sign in
  As a registered user
  I want to sign in to Unshift.me
  So I can send and recieve messages

  Scenario: Login Failure
    Given I am not a registered user
    And I am on the sign in page
    When I fill in "User name" with "fred"
    And I fill in "Password" with "secret"
    And I press "Sign In"
    Then I should see the sign in page

  Scenario: Successful login
    Given I am a registered user
    And I am on the sign in page
    When I fill in "User name" with "fred"
    And I fill in "Password" with "secret"
    And I press "Sign In"
    Then I should see my user home page
