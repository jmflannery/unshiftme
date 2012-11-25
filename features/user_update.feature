@user_update
Feature: User update
  As a GTM user
  I need to update my user properties
  So I can make change my user name, password, and normal workstations

  @user_name_update
  Scenario: Update user name
    Given I am registered user "jack" logged in with password "secret"
    Then I should see "jack@"
    When I click link "Profile"
    And I enter "jmflannery" for "User name"
    And I enter "secret" for "Password"
    And I enter "secret" for "Password confirmation"
    And I press "Update"
    Then I should see "Profile updated!"
    And I should see "jmflannery@"

  @normal_workstation_update
  Scenario: Update normal workstations
    Given the following workstation records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
    And I am registered user "jack@CUSN" logged in to "CUSN" in with password "secret"
    Then I should see "jack@CUSN"
    When I click link "Profile"
    Then I should see that workstation "CUSN" is checked
    And I should see that workstation "CUSS" is not checked
    When I check workstation "CUS South"
    And I uncheck workstation "CUS North"
    And I enter "secret" for "user[password]"
    And I enter "secret" for "user[password_confirmation]"
    And I press "Update"
    Then I should see "Profile updated!"
    When I click link "Profile"
    Then I should see that workstation "CUSS" is checked
    And I should see that workstation "CUSN" is not checked

