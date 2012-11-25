@register
Feature: Register
  As an Amtrak Chicago Control Center Employee
  I want to register a user name with GTM
  So I can sign in and send and recieve messages

  Scenario: Register failure
    Given I am not a registered user
    And I am on the register page
    When I fill in "User name" with ""
    And I fill in "Password" with ""
    And I fill in "Password confirmation" with ""
    And I press "Register"
    Then I should see the register page
  
  @javascript
  Scenario: Register success
    Given the following workstation records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
    And I am not a registered user
    And I am on the register page
    When I fill in "User name" with "fred"
    And I check workstation "CUS North"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I press "Register"
    Then I should see the sign in page
    And I should see that registration was successful
    When I fill in "User name" with "fred"
    And I tab away
    Then I should see that workstation "CUSN" is checked
    And I should see that workstation "CUSS" is not checked

