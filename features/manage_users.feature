@manage_users
@javascript
Feature: Managing users
  As as a GTM admin user
  I need to manage the application's user base
  As changes occur to the team

  Scenario: Manage users page
    Given the following user records
      | user_name | admin |
      | bill      | true  |
      | bob       | false |
      | jeff      | false |
      | mike      | false |
      | vernice   | fasle |
    And the following workstation records
      | name | abrev | job_type |
      | CCC  | CCC   | ops  |
    And I am logged in as "bill" with password "secret" at "CCC"
    When I click link "Manage Users"
    Then I should see "Unshift.me Users:"
    And I should see user records for "bill,bob,jeff,mike,vernice"
    And I should see that user "bill" is an admin user
    And I should see that users "bob,jeff,mike,vernice" are not admin users

    When I click delete for User "bob"
    Then I should see a button with text "Yes delete user bob"
    And I should see a button with text "Cancel"

    When I press "Cancel"
    Then I should not see a button with text "Yes delete user bob"
    And I should see user records for "bill,bob,jeff,mike,vernice"

    When I click delete for User "bob"
    And I press "Yes delete user bob"
    Then I should see "User bob has been deleted."
    And I should not see user records for "bob"
    And I should see user records for "bill,jeff,mike,vernice"

    When I check admin for user "jeff"
    And I press Update for user "jeff"
    Then I should see "User jeff updated to administrator"
    And I should see that users "bill,jeff" are admin users

    When I uncheck admin for user "jeff"
    And I press Update for user "jeff"
    Then I should see "User jeff updated to non-administrator"
    And I should see that user "bill" is an admin user
    And I should see that users "jeff,mike,vernice" are not admin users

