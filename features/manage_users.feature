@manage_users
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
      | name | abrev |
      | CCC  | CCC   |
    And I am logged in as "bill" with password "secret" at "CCC"
    When I click link "Manage Users"
    Then I should see "Grand Tour Messenger Users:"
    And I should see user records for "bill,bob,jeff,mike,vernice"
    And I should see that user "bill" is an admin user
    And I should see that users "bob,jeff,mike,vernice" are not admin users

    When I click delete for User "bob"
    And I confirm that I want to delete "bob"
    Then I should see "User bob has been deleted."
    And I should not see user records for "bob"
    
