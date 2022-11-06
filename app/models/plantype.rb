class Plantype < ActiveRecord::Base
  default_scope order('id ASC')
  belongs_to :plancategory

  validates :name,  presence: true, length: { maximum: 150 }
end
