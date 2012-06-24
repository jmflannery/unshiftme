@sign_up
Feature: Sign up
  As an Amtrak Chicago Control Center Employee
  I want to sign up for Messenger
  So I can sign in and send and recieve messages

  Scenario: Sign up failure
    Given I am not a registered user
    And I am on the sign up page
    When I fill in "User name" with ""
    And I fill in "password" with ""
    And I fill in "conformation" with ""
    And I press "Sign Up"
    Then I should see the sign up page
    
  Scenario: Sign up success
    Given I am not a registered user
    And I am on the sign up page
    When I fill in "User name" with "fred"
    #And I check desk "CUS North"
    And I fill in "password" with "secret"
    And I fill in "conformation" with "secret"
    And I press "Sign Up"
    Then I should see the sign in page
    And I should see that registration was successful
