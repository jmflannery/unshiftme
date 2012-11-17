module UsersHelper
  
  def updating_user_admin_status?
    params.has_key?("user") and params["user"].has_key?("admin")
  end

  def deletion_confirmed?
    params.has_key?("commit") and params["commit"] =~ /Yes delete user/
  end

  def deletion_cancelled?
    params.has_key?("commit") and params["commit"] == "Cancel"
  end
end
