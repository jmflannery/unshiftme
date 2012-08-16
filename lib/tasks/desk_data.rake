namespace :db do
  namespace :workstation do
    desc "Populate Workstations table with static data"
    task populate: :environment do
      Workstation.delete_all
      Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td")
      Workstation.create!(name: "CUS South", abrev: "CUSS", job_type: "td")
      Workstation.create!(name: "AML / NOL", abrev: "AML", job_type: "td")
      Workstation.create!(name: "Yard Control", abrev: "YDCTL", job_type: "ops")
      Workstation.create!(name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
      Workstation.create!(name: "Glasshouse", abrev: "GLHSE", job_type: "ops")
      Workstation.create!(name: "CCC", abrev: "CCC", job_type: "ops")
    end

    desc "Truncate the workstation data"
    task truncate: :environment do
      Workstation.delete_all
    end
  end
end
