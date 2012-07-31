module UsersHelper

  def parse_params_for_workstations(params)
    workstations = []
    params.each_pair do |key, val|
      if val == "1"
        workstation = Workstation.find_by_abrev(key) 
        workstations << workstation.abrev if workstation
      end
    end
    workstations
  end
end
