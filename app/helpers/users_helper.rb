module UsersHelper
  
  def deletion_confirmed?
    params.has_key?("commit") and params["commit"] =~ /Yes delete user/
  end

  def deletion_cancelled?
    params.has_key?("commit") and params["commit"] == "Cancel"
  end
end
