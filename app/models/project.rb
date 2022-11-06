class Project < ActiveRecord::Base
  default_scope order('id ASC')
  validates :name,  presence: true, length: { maximum: 255 }

  belongs_to :category
  has_many :project_customers
  has_many :customers, through: :project_customers
  has_many :project_users
  has_many :users, through: :project_users
  has_many :project_tasks, :dependent => :delete_all
  has_many :project_files, :dependent => :delete_all

  before_save :set_status
  private
    def set_status
      self.status = 0
      if self.startdate <= Date.today
        self.status = 1
      end
      if self.enddate < Date.today
        self.status = 2
      end
    end
end
