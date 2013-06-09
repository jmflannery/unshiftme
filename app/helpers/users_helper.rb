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
  
  def remove_current_password_key_from_hash(hash)
    hash.delete(:current_password) if hash[:current_password]
    hash
  end

  def merge_workstation_parameters
    workstations = each_workstation_in(params)
    params[:user][:normal_workstations] = workstations if params.has_key?(:user)
    params
  end
end
