namespace :db do
  namespace :desk do
    desc "Populate Desks table with static data"
    task populate: :environment do
      Desk.delete_all
      Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td")
      Desk.create!(name: "CUS South", abrev: "CUSS", job_type: "td")
      Desk.create!(name: "AML / NOL", abrev: "AML", job_type: "td")
      Desk.create!(name: "Yard Control", abrev: "YDCTL", job_type: "ops")
      Desk.create!(name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
      Desk.create!(name: "Glasshouse", abrev: "GLHSE", job_type: "ops")
    end
  end
end
