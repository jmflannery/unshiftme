@transcripts
Feature: Transcripts
  A Transcript is an exact copy of a previous Messenger session

  @transcripts1
  Scenario: Transcripts page
    Given the following user records
      | user_name | admin |
      | bill      | true  |
      | jeff      | false |
      | bob       | false | 
    And the following desk records
      | name      | abrev | user_id |
      | CUS South | CUSS  | 0       |
      | AML / NOL | AML   | 0       |
    And the following messages
      | id | content    | user | from | to_user | to_desk | read | created_at         |
      | 1  | Hi Jeff!   | bob  | CUSS | jeff    | AML     | t    | "2012-06-22 17:13" |
      | 2  | Hello, Bob | jeff | AML  | bob     | CUSS    | t    | "2012-06-22 17:14" |
      | 3  | Whats up?  | bob  | CUSS | jeff    | AML     | t    | "2012-06-22 17:16" |
    And I am logged in as "bill" with password "secret" at ""
    When I click link "Transcripts"
    Then I should see the Transcript page
    And I should see a New Transcripts button
    And I should see that I have 0 Transcripts
    
    When I click link "New Transcript"
    Then I should see the Create Transcript page

    When I select "AML" for "Transcript desk"
    And I select "jeff" for "Transcript user"
    And I select date "2012-06-22 16:30" for "transcript_start_time"
    And I select date "2012-06-22 17:15" for "transcript_end_time"
    And I press "Create Transcript"
    Then I should see "Transcript for jeff"
    And I should see "Friday, June 22 2012 16:30 to Friday, June 22 2012 17:15" 
    And I should see recieved message 1 "Hi Jeff!" from desk "CUSS" user "bob" one time
    And I should see desk "AML" user "jeff" read message 1
    And I should see sent message 2 "Hello, Bob" from desk "AML" user "jeff" one time
    And I should see desk "CUSS" user "bob" read message 2
    And I should not see recieved message 3 "Whats up?" from desk "CUSS" user "bob"
 
