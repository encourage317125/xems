class Supplier < ActiveRecord::Base
  default_scope order('id ASC')
  has_many :users, :dependent => :delete_all

  validates :name,  presence: true, length: { maximum: 150 }
end
