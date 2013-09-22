@register
Feature: Register
  As an Amtrak Chicago Control Center Admin
  I need to register users with GTM
  So they can sign in and send and recieve messages

  @reg_fail
  Scenario: Registration unavailable to non-admins
    Given I am registered non-admin user "bob" logged in with password "secret"
    When I visit the messaging page
    Then I should not see a link with text "Manage Users"
  
  @reg_success
  @javascript
  Scenario: Register success
    Given the following workstation records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
    Given I am registered user "bill" logged in with password "secret"
    When I click link "Manage Users"
    Then I should should see the Manage Users Page
    When I click link "Register a new user"
    And I fill in "User name" with "fred"
    And I check workstation "CUS North"
    And I fill in "user_password" with "secret"
    And I fill in "user_password_confirmation" with "secret"
    And I press "Register"
    Then I should see that registration of "fred" was successful
    And I should see user records for "bill,fred"
