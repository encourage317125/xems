json.(@user[0], :id, :name, :email, :address, :phone)
json.photo @user[0].photo.url
json.thumb @user[0].photo.url(:thumb)
json.role_id @user[0].role_id
json.role @user[0].role.name
if @user[0].role_id == 4
    json.customer @user[0].customer.name
end
if @user[0].role_id == 5
    json.supplier @user[0].supplier.name
end
