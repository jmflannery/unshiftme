@update_password
Feature: Update password
  As a GTM user
  I need to change my password
  To maintain security

  @javascript
  Scenario: User changes password
    Given I am registered user "jack" logged in with password "secret"
    When I click link "Profile"
    And I click link "Change password"
    And I fill in "Current password" with "secret"
    And I fill in "New password" with "secret"
    And I fill in "Confirm new password" with "secret"
    And I press "Update password"
    Then I should see "Password updated!"

