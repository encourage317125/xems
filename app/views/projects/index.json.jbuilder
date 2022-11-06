json.array! @projects do |project|
  json.id project.id
  json.name project.name
  json.startdate project.startdate
  json.enddate project.enddate
  json.status project.status
  json.category_id project.category_id
  json.category project.category.title
end