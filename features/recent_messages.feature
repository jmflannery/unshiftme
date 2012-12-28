@messages
@javascript
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
      | id | content    | user | to_workstation | read | created_at        |
      | 1  | Hi Jeff!   | bob  | AML            | t    | 1441.minutes.ago  |
      | 2  | Hello, Bob | jeff | CUSS           | t    | 1430.minutes.ago  |
      | 3  | Whats up?  | bob  | AML            | t    | 1439.minutes.ago  |
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
      | user_name | id  |
      | sam       | 33  |
      | jeff      | 11  |
      | bob       | 22  |
    And the following workstation records
      | name      | abrev | user_id  |
      | CUS South | CUSS  | 22       |
      | AML / NOL | AML   | 11       |
    And the following messages
      | id  | content    | user | to_workstation | to_user | created_at     |
      | 24  | Bye Sam    | bob  | AML            | sam     | 10.minutes.ago |
      | 25  | Anyone??   | bob  | AML            |         | 2.minutes.ago  |

    And I am logged in as "jeff" with password "secret" at "AML"
    When I go to the messaging page
    Then I should not see message 24 "Bye Sam"
    And I should see unread received message 25 "Anyone??" from "bob@CUSS" one time
    
    Given I click on message 25
    Then I should see that received message 25 was read

