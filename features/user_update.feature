@user_update
Feature: User update
  As a GTM user
  I need to update my user properties
  So I can make change my user name, password, and normal workstations

  @user_update1
  Scenario: Update user name
    Given I am registered user "jack" logged in with password "secret"
    And I click link "Profile"
    When I enter "jmflannery" for "User name"
    When I enter "secret" for "user[password]"
    When I enter "secret" for "user[password_confirmation]"
    And I press "Update"
    Then I should see "Profile updated!"
    And I should see "jmflannery@"

