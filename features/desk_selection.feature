@javascript
@desk_selection
Feature: Desk Selection
  As a signed in user
  I want to toggle the desks that I am currently messaging
  So I can message specific desks
  
  @desk_selection1
  Scenario: Each desk button indicates whether or not I am currently messaging that desk
    Given the following desk records
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

    And I am logged in as "bill" with password "secret" at "CUSN"
    When I go to the messaging page
    Then I should see each Desk Toggle Button indicate that I am not messaging that desk, excluding my own desk "CUSN"
    And I should see that I am at "CUSN"
   
    When I click on each button
    Then I should see each Desk Toggle Button indicate that I am messaging that desk, excluding my own desk "CUSN"
    When I click on each button
    Then I should see each Desk Toggle Button indicate that I am not messaging that desk, excluding my own desk "CUSN"

  Scenario: I should see who is currently at each desk in real time
            as users are signing in and signing out
    Given the following desk records
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
    And I am logged in as "bill" with password "secret" at "CUSN"
    When I go to the messaging page
    Then I should see that "bill" is at "CUSN" desk
    And I should see that "nobody" is at "AML" desk

    Given I am in Sam's browser
    And I am logged in as "sam" with password "secret" at "AML"
    When I go to the messaging page
    Then I should see that "sam" is at "AML" desk
    And I should see that "bill" is at "CUSN" desk

    Given I am in Bill's browser
    When I go to the messaging page
    Then I should see that "sam" is at "AML" desk

    Given I log out

    Given I am in Sam's browser
    When I go to the messaging page
    Then I should see that "sam" is at "AML" desk
    And I should see that "nobody" is at "CUSN" desk

  @toggle_all
  Scenario: Each press of the 'Message all' button toggles all of the desks
            between being messaged and not being messaged" 
    Given the following desk records
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
    And I am logged in as "bill" with password "secret" at "CUSN"
    When I go to the messaging page
    And I click Message "all"
    Then I should see each Desk Toggle Button indicate that I am messaging that desk, excluding my own desk "CUSN"
    When I click Message "none" 
    Then I should see each Desk Toggle Button indicate that I am not messaging that desk, excluding my own desk "CUSN"

  @multiple_desks
  Scenario: Selecting a desk controlled by a user who is also controlling other desks,
            should toggle all of the desks controlled by that user
    Given the following desk records
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
    And I am logged in as "joe" with password "secret" at "YDCTL"
    When I go to the messaging page
    Then I should see that "bill" is at "CUSN,CUSS,AML" desk

    When I click "CUSN"
    Then I should see that I am messaging "CUSN,CUSS,AML"
    When I click "CUSS"
    Then I should see that I am not messaging "CUSN,CUSS,AML"
    When I click "AML"
    Then I should see that I am messaging "CUSN,CUSS,AML"
    When I click "CUSN"
    Then I should see that I am not messaging "CUSN,CUSS,AML"
