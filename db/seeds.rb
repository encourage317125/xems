# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create(email: 'admin@gmail.com', name: 'Adminitrator', password: 'password', password_confirmation: 'password')

Role.create(name: 'administrators')
Role.create(name: 'users')
Role.create(name: 'staffs')
Role.create(name: 'customer')
Role.create(name: 'supplier')