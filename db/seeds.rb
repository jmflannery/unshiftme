# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

Workstation.delete_all
Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td")
Workstation.create!(name: "CUS South", abrev: "CUSS", job_type: "td")
Workstation.create!(name: "AML / NOL", abrev: "AML", job_type: "td")
Workstation.create!(name: "Yard Control", abrev: "YDCTL", job_type: "ops")
Workstation.create!(name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
Workstation.create!(name: "Glasshouse", abrev: "GLHSE", job_type: "ops")
Workstation.create!(name: "CCC", abrev: "CCC", job_type: "ops")
 
