@attachments
@javascript
Feature: Attachments
  As a GTM user
  I need to sent and receive files with other employees
  So I we can efficiently communicate operation plans
  
  @attachments1
  Scenario: Send, receive, acknowledge and download messages.
    Given the following user records
      | user_name | id |
      | bill      | 1  |
      | bob       | 2  |
    And the following workstation records
      | name      | abrev | job_type | user_id |
      | CUS North | CUSN  | td       | 1       |
      | CUS South | CUSS  | td       | 2       |
    And I am in bill's browser
    And I am logged in as "bill" with password "secret" at "CUSN"
    When I go to the messaging page
    And I wait 1 second
    And I click "CUSS"
    And I click on the upload attachment icon
    Then I should see the attachement upload section

    When I attach file "test_file.txt"
    And I wait 1 second
    #And I press "Upload"
    Then I should see sent message link "test_file.txt" from workstation "CUSN" user "bill" one time

    Given I am in bob's browser
    And I am logged in as "bob" with password "secret" at "CUSS"
    When I go to the messaging page
    Then I should see recieved message link "test_file.txt" from workstation "CUSN" user "bill" one time

    When I click link "test_file.txt"
    Then I should see "This is just a test, of the Grand Tour emergency broadcast system."

    Given I am in bill's browser
    Then I should see workstation "CUSS" user "bob" read this

