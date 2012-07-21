@messages
Feature: Messages
  As a messenger user
  I want to see recent messages when I load the messaging page
  So I can review current and recent information

  @messages1
  Scenario: Recent messages: When a user loads the messaging page,
    messages sent and recieved durring the last 8 hours should be visible
    Given the following user records
      | user_name | id |
      | jeff      | 1  |
      | bob       | 2  |
    And the following desk records
      | name      | abrev | user_id |
      | CUS South | CUSS  | 2       |
      | AML / NOL | AML   | 1       |
    And the following messages
      | id | content    | user | from | to_user | to_desk | read | created_at       |
      | 1  | Hi Jeff!   | bob  | CUSS | jeff    | AML     | t    | 1440.minutes.ago |
      | 2  | Hello, Bob | jeff | AML  | bob     | CUSS    | t    | 1439.minutes.ago |
      | 3  | Whats up?  | bob  | CUSS | jeff    | AML     | t    | 1438.minutes.ago |
    And I am logged in as "jeff" with password "secret" at "AML"
    When I go to the messaging page
    Then I should not see recieved message 1 "Hi Jeff!"
    And I should see sent message 2 "Hello, Bob" from desk "AML" user "jeff" one time
    And I should see desk "CUSS" user "bob" read message 2
    And I should see recieved message 3 "Whats up?" from desk "CUSS" user "bob" one time
    And I should not see desk "AML" user "jeff" read message 3

