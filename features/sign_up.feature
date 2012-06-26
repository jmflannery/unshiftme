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
  
  @javascript
  Scenario: Sign up success
    Given the following desk records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
    And I am not a registered user
    And I am on the sign up page
    When I fill in "User name" with "fred"
    And I check desk "CUS North"
    And I fill in "password" with "secret"
    And I fill in "conformation" with "secret"
    And I press "Sign Up"
    Then I should see the sign in page
    And I should see that registration was successful
    When I fill in "User name" with "fred"
    And I press the "tab" key from the "User name" field
    Then I should see that desk "CUSN" is checked
    And I should see that desk "CUSS" is not checked
