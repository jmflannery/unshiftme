module UsersHelper
  
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
  
  def remove_old_password_key_from_hash(hash)
    hash.delete(:old_password) if hash[:old_password]
    hash
  end
end

