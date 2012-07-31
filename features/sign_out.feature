@javascript
@sign_out
Feature: Sign out
  As a signed in user
  I want to sign out
  So I can go home
  
  @sign_out1
  Scenario: Sign out
    Given the following workstation records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
    And I am registered user "fred" with password "secret"
    And I am logged in at "CUSN"
    When I click link "Sign out"
    Then I should see the sign in page

  @sign_out2
  Scenario: Sign out clears my recipients
    Given the following workstation records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
      | AML / NOL    | AML    | td       | 0       |
    And I am registered user "fred" with password "secret"
    And I am logged in at "CUSN"
    When I click "CUSS,AML"
    Then I should see that I am messaging "CUSS,AML"
    When I click link "Sign out"
    Then I should see the sign in page
    
    Given I am logged in at "CUSN"
    Then I should see that I am not messaging "CUSS,AML"

  @sign_out3
  Scenario: Sign out signs me out of all workstations I am working
    Given the following workstation records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
      | AML / NOL    | AML    | td       | 0       |
    And I am registered user "bill" with password "secret"
    And I am logged in as "bill" with password "secret" at "CUSN,CUSS,AML"
    When I click link "Sign out"
    And I wait 1 second
    Then I should not be working any workstations

