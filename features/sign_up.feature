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
    When I fill in "User name" with "fsavage"
    And I fill in "password" with "jjjjjj"
    And I fill in "conformation" with "jjjjjj"
    And I press "Sign Up"
    Then I should see my user home page 
