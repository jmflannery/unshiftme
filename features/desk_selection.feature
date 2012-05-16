@javascript
@focus
Feature: Desk Selection
  As a signed in user
  I want to toggle the desks that I am currently messaging
  So I can message specific desks
  
  Scenario: 
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
      | Bill      |

     And I am logged in as "Bill" with password "secret" at "CUSN"
     When I go to the messaging page
     Then I should see a button for each desk indicating that I am not messaging that desk
     
     When I click on each button
     Then I should see each button indicate that I am messaging that desk
     When I click on each button
     Then I should see each button indicate that I am not messaging that desk
