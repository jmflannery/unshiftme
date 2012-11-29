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
    And I fill in "Old password" with "secret"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I press "Update password"
    Then I should see "Password updated!"

