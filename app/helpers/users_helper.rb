module UsersHelper
  include WorkstationsHelper
  
  def promoting_user_admin_status?
    params["user"]["admin"] and params["user"]["admin"] == "1"
  end

  def demoting_user_admin_status?
    params["user"]["admin"] and params["user"]["admin"] == "0"
  end

  def deletion_confirmed?
    params.has_key?("commit") and params["commit"] =~ /Yes delete user/
  end

  def deletion_cancelled?
    params.has_key?("commit") and params["commit"] == "Cancel"
  end
  
  def merge_workstation_parameters
    @user_params = user_params
    workstations = each_workstation_in(params)
    @user_params[:normal_workstations] = workstations
    @user_params
  end
end
