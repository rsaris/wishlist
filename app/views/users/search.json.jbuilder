json.users( @users ) do |user|
  json.id user.id
  json.full_name user.full_name
  json.email user.email
end