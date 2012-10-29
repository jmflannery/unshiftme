module WorkstationsHelper

  def parse_params_for_workstations(params)
    workstations = []
    params.each_pair do |key, val|
      if val == "1"
        workstation = Workstation.find_by_abrev(key) 
        if workstation
          workstations << workstation.abrev 
          yield workstation if block_given?
        end
      end
    end
    workstations
  end
end
