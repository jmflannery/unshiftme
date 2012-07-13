@javascript
@auto_signout
@ignore
Feature: Periodic session clean up
  The system will regularly check the heartbeat timestamp for all signed in users.
  Those users with a heartbeat 20 or more seconds less than the current time,
  will be automatically signed out of the system

  @auto_signout1
  Scenario: Auto sign out
    Given the following desk records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
      | AML / NOL    | AML    | td       | 0       |
    And I am registered user "bill" with password "secret"
    And I am logged in as "bill" with password "secret" at "CUSN,CUSS"
    And I click "AML"
    And My last heartbeat was 22 seconds ago
    When I close the browser without signing out
    Then I should not be working any desks
    And I should have no recipients

  
