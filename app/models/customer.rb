class Customer < ActiveRecord::Base
  default_scope order('id ASC')
  has_many :users, :dependent => :delete_all
  has_many :project_customers
  has_many :projects, through: :project_customers
  validates :name,  presence: true, length: { maximum: 150 }
end