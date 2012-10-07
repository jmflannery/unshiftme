@files
@javascript
Feature: Files
  As a GTM user
  I need to see my files in a seperate view from the messages
  So I can still find them later
  
  @files1
  Scenario: Visit the Files page and view a file
    Given the following user records
      | user_name | id |
      | jack      | 1  |
      | bill      | 2  |
    And the following workstation records
      | name      | abrev | job_type | user_id |
      | CUS North | CUSN  | td       | 1       |
      | CUS South | CUSS  | td       | 2       |
    And I am in jack's browser
    And I am logged in as "jack" with password "secret" at "CUSN"
    When I send "test_file.txt" to "CUSS"
    Then I should see sent message link "test_file.txt" from workstation "CUSN" user "jack" one time
    
    Given I am in bill's browser
    And I am logged in as "bill" with password "secret" at "CUSS"
    When I click link "Files"
    Then I should see the files page
    And I should see "test_file.txt"

