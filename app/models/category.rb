class Category < ActiveRecord::Base
  default_scope order('id ASC')
  validates :title,  presence: true, length: { maximum: 250 }

  has_many :projects, :dependent => :delete_all
end
