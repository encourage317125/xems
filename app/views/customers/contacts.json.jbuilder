json.array! @users do |user|
  json.id user.id
  json.name user.name
  json.email user.email
  json.address user.address
  json.phone user.phone
  json.thumb user.photo.url(:thumb)
  json.role_id user.role_id
  json.role user.role.name
end