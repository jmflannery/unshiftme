@javascript
Feature: Messaging
  As a registered user
  I want to send and recieve messages
  So I can do my job

  Scenario: Send and recieve messages
    Given the following desk records
      | name      | abrev | job_type | user_id |
      | CUS North | CUSN  | td       | 0       |
      | CUS South | CUSS  | td       | 0       |
    Given the following user records
      | user_name |
      | Bill      |
      | Bob       |
    And I am in Bill's browser
    And I am logged in as "Bill" with password "secret" at "CUSN"
    When I go to the messaging page
    Then I should not see recieved message "Hi Bill!"

    Given I am in Bob's browser
    And I am logged in as "Bob" with password "secret" at "CUSS"
    When I go to the messaging page
    And I click "CUSN"
    And I fill in "message_content" with "Hi Bill!"
    And I press the "enter" key
    Then I should see my message "Hi Bill!"
    And I should nothing in the "message_content" text field

    Given I am in Bill's browser
    When I wait 1 second
    Then I should see recieved message "Hi Bill!"

    Given I click on the recieved message

    Given I am in Bob's browser
    When I wait 1 second
    Then I should see "Bill" read this
