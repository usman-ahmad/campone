Warden::Manager.after_set_user do |resource, auth, opts|
  scope = opts[:scope]
  auth.cookies.signed["#{scope}_id"] = resource.id
end