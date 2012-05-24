@javascript
@sign_out
Feature: Sign out
  As a signed in user
  I want to sign out
  So I can go home
  
  @sign_out1
  Scenario: Sign out
    Given the following desk records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
    And I am registered user "fred" with password "secret"
    And I am logged in at "CUSN"
    When I click link "Sign out"
    Then I should see the sign in page

  @sign_out2
  Scenario: Sign out clears my recipients
    Given the following desk records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
    And I am registered user "fred" with password "secret"
    And I am logged in at "CUSN"
    When I click "CUSS"
    Then I should see that I am messaging "CUSS"
    When I click link "Sign out"
    Then I should see the sign in page
    
    Given I am logged in at "CUSN"
    Then I should see that I am not messaging "CUSS"
