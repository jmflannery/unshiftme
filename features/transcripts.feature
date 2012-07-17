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
      | content    | user | to_user | to_desk | read_user | read_desk | from |
      | Hello, Bob | jeff | bob     | CUSS    | bob       | CUSS      | AML  |
      | Hi Jeff!   | bob  | jeff    | AML     | jeff      | AML       | CUSS |
    And I am logged in as "bill" with password "secret" at "CUSS"
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

