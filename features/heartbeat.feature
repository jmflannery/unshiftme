@javascript
@heartbeat
@ignore
Feature: Heartbeat
  Every 60 seconds each signed in client will send a heartbeat
  via ajax request and update the user's heartbeat timestamp

  @heartbeat1
  Scenario: Heartbeat
  Given the following desk records
     | name         | abrev  | job_type | user_id |
     | CUS North    | CUSN   | td       | 0       |
   And I am registered user "fred" with password "secret"
   And I am logged in as "fred" with password "secret" at "CUSN"
   When I go to the messaging page
   Then my heartbeat should be less than or equal to the current time
   And I should be signed in

