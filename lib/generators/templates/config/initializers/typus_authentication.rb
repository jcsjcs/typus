Typus.setup do |config|

  # Define authentication: +:none+, +:http_basic+, +:session+
  config.authentication = :session

  # Define master_role.
  # config.master_role = "admin"

  # Define relationship.
  # config.relationship = "typus_users"

  # Define user_class_name.
  config.user_class_name = "<%= options[:user_class_name] %>"

  # Define user_fk.
  config.user_fk = "<%= options[:user_fk] %>"

  # Define which roles go to the admin page after login:
  # Can be "all" or a comma-separated list: "admin,editor".
  # config.post_login_to_admin = "all"
  # Define route to follow after login for roles not included in +post_login_to_admin+.
  # config.post_login_route    = "/"

end
