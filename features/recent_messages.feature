@messages
Feature: Messages
  As a messenger user
  I want to see recent messages when I load the messaging page
  So I can review current and recent information

  @messages1
  Scenario: Recent messages: When a user loads the messaging page,
    messages sent and recieved to the current user durring the last 24
    hours should be visible
    Given the following user records
      | user_name | id |
      | jeff      | 1  |
      | bob       | 2  |
    And the following workstation records
      | name      | abrev | user_id |
      | CUS South | CUSS  | 2       |
      | AML / NOL | AML   | 1       |
    And the following messages
      | id | content    | user | from | to_user | to_workstation | read | created_at       |
      | 1  | Hi Jeff!   | bob  | CUSS | jeff    | AML     | t    | 1440.minutes.ago |
      | 2  | Hello, Bob | jeff | AML  | bob     | CUSS    | t    | 1439.minutes.ago |
      | 3  | Whats up?  | bob  | CUSS | jeff    | AML     | t    | 1438.minutes.ago |
    And I am logged in as "jeff" with password "secret" at "AML"
    When I go to the messaging page
    Then I should not see recieved message 1 "Hi Jeff!"
    And I should see sent message 2 "Hello, Bob" from workstation "AML" user "jeff" one time
    And I should see workstation "CUSS" user "bob" read message 2
    And I should see recieved message 3 "Whats up?" from workstation "CUSS" user "bob" one time
    And I should not see workstation "AML" user "jeff" read message 3

  @messages2
  Scenario: Recent messages: When the current user loads the messaging page, messages
    sent to the current user's workstations, while the workstation was vacant during the last 24 hours
    will be visible. Messages sent to the user's workstation while another user was working
    the workstation during the last 24 hours will not be visible. Visible received messages can then
    be acknowledged by clicking the message
    Given the following user records
      | user_name | id |
      | sam       | 3  |
      | jeff      | 1  |
      | bob       | 2  |
    And the following workstation records
      | name      | abrev | user_id |
      | CUS South | CUSS  | 2       |
      | AML / NOL | AML   | 1       |
    And the following messages
      | id | content    | user | from | to_user | to_workstation | read | created_at  |
      | 1  | Bye Sam    | bob  | CUSS | sam     | AML     | t    | 3.hours.ago |
      | 2  | Anyone??   | bob  | CUSS |         | AML     | f    | 2.hours.ago |

    And I am logged in as "jeff" with password "secret" at "AML"
    When I go to the messaging page
    Then I should not see unread recieved message 1 "Bye Sam"
    And I should see unread recieved message 2 "Anyone??" from workstation "CUSS" user "bob" one time

