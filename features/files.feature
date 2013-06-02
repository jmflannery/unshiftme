@files
@javascript
Feature: Files
  As a GTM user
  I need to see the files that I sent,
  and files that were sent to me or my workstation,
  in a seperate view from the messages
  So I can still find them later

  Scenario: Visit the Files page and see the files that I sent and were sent to me
    Given the following user records
      | user_name | id |
      | bill      | 1  |
      | jack      | 2  |
    And the following workstation records
      | name      | abrev | job_type | user_id |
      | CUS North | CUSN  | td       | 1       |
      | CUS South | CUSS  | td       | 2       |
    Given I am in bill's browser
    And I am logged in as "bill" with password "secret" at "CUSN"
    When I click link "Files"
    Then I should see the files page
    And I should not see any files

    When I go to bill's messaging page
    And I send "test_file.txt" to "CUSS"
    Then I should see sent message link "test_file.txt" from workstation "CUSN" user "bill" one time

    Given I am in jack's browser
    And I am logged in as "jack" with password "secret" at "CUSS"
    When I send "another_test_file.dat" to "CUSN"
    Then I should see sent message link "another_test_file.dat" from workstation "CUSS" user "jack" one time
    
    Given I am in bill's browser
    When I click link "Files"
    Then I should see a link to "test_file.txt"
    And I should see a link to "another_test_file.dat"

  @files2
  Scenario: Visit the Files page and see the files that were sent to my
    workstation while I was not working at that workstation
    Given the following user records
      | user_name | id |
      | bill      | 1  |
      | jack      | 2  |
      | mike      | 3  |
    And the following workstation records
      | name      | abrev | job_type |
      | CUS North | CUSN  | td       |
      | CUS South | CUSS  | td       |
    Given I am in bill's browser
    And I am logged in as "bill" with password "secret" at "CUSN"
    Then I should see that I have no messages

    Given I am in mike's browser
    And I am logged in as "mike" with password "secret" at "CUSS"
    Then I should see that I have no messages

    Given I am in bill's browser
    When I send "test_file.txt" to "CUSS"
    Then I should see sent message link "test_file.txt" from workstation "CUSN" user "bill" one time

    Given I am in mike's browser
    Then I should see recieved message link "test_file.txt" from workstation "CUSN" user "bill" one time

    Given I am in jack's browser
    And I am logged in as "jack" with password "secret" at "CUSS"
    When I click link "Files"
    Then I should see a link to "test_file.txt"
