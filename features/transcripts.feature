@transcripts
Feature: Transcripts
  A Transcript is an exact copy of a previous Messenger session

  @transcripts1
  Scenario: Transcripts page
    Given I am registered administrative user "bill" with password "secret"
    And I am logged in as "bill" with password "secret" at ""
    When I click link "Transcripts"
    Then I should see the Transcript page
    And I should see a New Transcripts button
    And I should see that I have 0 Transcripts
    
    When I click link "New Transcript"
    Then I should see the Create Transcript page

