@javascript
@workstation_selection
Feature: Workstation Selection
  As a signed in user
  I want to toggle the workstations that I am currently messaging
  So I can message specific workstations
  
  @workstation_selection1
  Scenario: Each workstation button indicates whether or not I am currently messaging that workstation
    Given the following workstation records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
      | AML / NOL    | AML    | td       | 0       |
      | Yard Control | YDCTL  | ops      | 0       |
      | Yard Master  | YDMSTR | ops      | 0       |
      | Glasshouse   | GLHSE  | ops      | 0       |
    And the following user records
      | user_name |
      | bill      |

    When I log in as "bill" with password "secret" at "CUSN"
    Then I should see each Workstation Toggle Button indicate that I am not messaging that workstation, excluding my own workstation "CUSN"
    And I should see that I am at "CUSN"
   
    When I click on each button
    Then I should see each Workstation Toggle Button indicate that I am messaging that workstation, excluding my own workstation "CUSN"
    When I click on each button
    Then I should see each Workstation Toggle Button indicate that I am not messaging that workstation, excluding my own workstation "CUSN"

  Scenario: I should see who is currently at each workstation in real time
            as users are signing in and signing out
    Given the following workstation records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
      | AML / NOL    | AML    | td       | 0       |
      | Yard Control | YDCTL  | ops      | 0       |
      | Yard Master  | YDMSTR | ops      | 0       |
      | Glasshouse   | GLHSE  | ops      | 0       |
    And the following user records
      | user_name |
      | bill      |
      | sam       |

    And I am in Bill's browser
    When I log in as "bill" with password "secret" at "CUSN"
    Then I should see that "bill" is at "CUSN" workstation
    And I should see that "nobody" is at "AML" workstation

    Given I am in Sam's browser
    When I log in as "sam" with password "secret" at "AML"
    Then I should see that "sam" is at "AML" workstation
    And I should see that "bill" is at "CUSN" workstation

    Given I am in Bill's browser
    Then I should see that "sam" is at "AML" workstation

    Given I log out

    Given I am in Sam's browser
    Then I should see that "sam" is at "AML" workstation
    And I should see that "nobody" is at "CUSN" workstation

  @toggle_all
  Scenario: Each press of the 'Message all' button toggles all of the workstations
            between being messaged and not being messaged" 
    Given the following workstation records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
      | AML / NOL    | AML    | td       | 0       |
      | Yard Control | YDCTL  | ops      | 0       |
      | Yard Master  | YDMSTR | ops      | 0       |
      | Glasshouse   | GLHSE  | ops      | 0       |
    And the following user records
      | user_name |
      | bill      |
    When I log in as "bill" with password "secret" at "CUSN"
    And I click Message "all"
    Then I should see each Workstation Toggle Button indicate that I am messaging that workstation, excluding my own workstation "CUSN"
    When I click Message "none" 
    Then I should see each Workstation Toggle Button indicate that I am not messaging that workstation, excluding my own workstation "CUSN"

  @multiple_workstations
  Scenario: Selecting a workstation controlled by a user who is also controlling other workstations,
            should toggle all of the workstations controlled by that user
    Given the following workstation records
      | name         | abrev  | job_type | user_id |
      | CUS North    | CUSN   | td       | 0       |
      | CUS South    | CUSS   | td       | 0       |
      | AML / NOL    | AML    | td       | 0       |
      | Yard Control | YDCTL  | ops      | 0       |
    And the following user records
      | user_name |
      | bill      |
      | joe       |
    And I am in bill's browser
    And I am logged in as "bill" with password "secret" at "CUSN,CUSS,AML"

    Given I am in joe's browser
    When I log in as "joe" with password "secret" at "YDCTL"
    Then I should see that "bill" is at "CUSN,CUSS,AML" workstation

    When I click "CUSN"
    Then I should see that I am messaging "CUSN,CUSS,AML"
    When I click "CUSS"
    Then I should see that I am not messaging "CUSN,CUSS,AML"
    When I click "AML"
    Then I should see that I am messaging "CUSN,CUSS,AML"
    When I click "CUSN"
    Then I should see that I am not messaging "CUSN,CUSS,AML"
