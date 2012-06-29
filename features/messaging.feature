@javascript
@messaging
Feature: Messaging
  As a registered user
  I want to send and recieve messages
  So I can do my job

  @messaging1
  Scenario: Send and recieve messages
    Given the following desk records
      | name      | abrev | job_type | user_id |
      | CUS North | CUSN  | td       | 0       |
      | CUS South | CUSS  | td       | 0       |
      | AML / NOL | AML   | td       | 0       |
    Given the following user records
      | user_name |
      | bill      |
      | bob       |
      | sam       |
    And I am in Bill's browser
    And I am logged in as "bill" with password "secret" at "CUSN"
    When I go to the messaging page
    Then I should not see recieved message "Hi Bill!" from desk "CUSS" user "bob"

    Given I am in Sam's browser
    And I am logged in as "sam" with password "secret" at "AML"
    When I go to the messaging page
    Then I should not see recieved message "Hi Bill!" from desk "CUSS" user "bob"

    Given I am in Bob's browser
    And I am logged in as "bob" with password "secret" at "CUSS"
    When I go to the messaging page
    And I click "CUSN"
    And I fill in "message_content" with "Hi Bill!"
    And I press the "enter" key
    Then I should see my message "Hi Bill!" from desk "CUSS" user "bob"
    And I should nothing in the "message_content" text field

    Given I am in Sam's browser
    When I wait 1 second
    Then I should not see recieved message "Hi Bill!" from desk "CUSS" user "bob"

    Given I am in Bill's browser
    When I wait 1 second
    Then I should see recieved message "Hi Bill!" from desk "CUSS" user "bob"
    And I should see that I am messaging "CUSS"

    Given I click on the recieved message

    Given I am in Bob's browser
    When I wait 1 second
    Then I should see desk "CUSN" user "bill" read this

  @messaging2
  Scenario: Users working more than one desk at once should only recieve each message once
    Given the following desk records
      | name         | abrev | job_type  | user_id |
      | CUS North    | CUSN  | td        | 0       |
      | CUS South    | CUSS  | td        | 0       |
      | AML / NOL    | AML   | td        | 0       |
      | Yard Control | YDCTL | ops       | 0       |
    And the following user records
      | user_name |
      | bill      |
      | jim       |
    And I am in bill's browser
    And I am logged in as "bill" with password "secret" at "CUSN,CUSS,AML"
    
    Given I am in jim's browser
    And I am logged in as "jim" with password "secret" at "YDCTL"
    When I click "CUSN"
    And I fill in "message_content" with "Yo Bill!"
    And I press the "enter" key
    
    Given I am in bill's browser
    When I wait 1 second
    Then I should see recieved message "Yo Bill!" from desk "YDCTL" user "jim" one time
    
  @messaging3
  Scenario: When a user recieves a message from a user working multiple desks
    Given the following desk records
      | name         | abrev | job_type  | user_id |
      | CUS North    | CUSN  | td        | 0       |
      | CUS South    | CUSS  | td        | 0       |
      | AML / NOL    | AML   | td        | 0       |
      | Yard Control | YDCTL | ops       | 0       |
    And the following user records
      | user_name |
      | bill      |
      | jim       |
    Given I am in jim's browser
    And I am logged in as "jim" with password "secret" at "YDCTL"
    
    Given I am in bill's browser
    And I am logged in as "bill" with password "secret" at "CUSN,CUSS,AML"
    When I click "YDCTL"
    And I fill in "message_content" with "Yo Jim!"
    And I press the "enter" key
    
    Given I am in jim's browser
    When I wait 1 second
    Then I should see recieved message "Yo Jim!" from desk "CUSN,CUSS,AML" user "bill" one time
    And I should see that I am messaging "CUSN,CUSS,AML"
    When I click "YDCTL"
    Then I should see that I am not messaging "CUSN,CUSS,AML"
