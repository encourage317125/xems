class ProjectFile < ActiveRecord::Base
  belongs_to :project
  def self.upload(name, upload)
    directory = "public/files"
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload) }
  end
end
