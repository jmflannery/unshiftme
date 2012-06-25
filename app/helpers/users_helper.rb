module UsersHelper

  def parse_params_for_desks(params)
    desks = []
    params.each_pair do |key, val|
      if val == "1"
        desk = Desk.find_by_abrev(key) 
        desks << desk.abrev if desk
      end
    end
    desks
  end
end
