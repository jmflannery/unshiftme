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
    When I click on the upload attachment icon
    Then I should see the attachement upload section

    When I attach file "test_file.txt"
    And I press "Upload"
    Then I should see "test_file.txt"

