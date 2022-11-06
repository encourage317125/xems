class User < ActiveRecord::Base
  default_scope order('id ASC')
  attr_accessor :password, :password_confirmation

  if Rails.env.development?
    has_attached_file :photo,
                      :styles => {:original => "80x80#", :thumb=>"30x30#" },
                      :path => ":rails_root/public/:attachment/:id/:style/:filename",
                      :url => "/:attachment/:id/:style/:filename",
                      :default_url => "/assets/photos/:style/missing.png"
  else
    has_attached_file :photo,
                      :styles => {:original => "80x80#", :thumb=>"30x30#" },
                      :default_url => "/assets/photos/:style/missing.png"
  end

  validates :name,  presence: true, length: { maximum: 50 }
  validates :email,  presence: true, length: { maximum: 150 }, uniqueness: true

  before_save {email.downcase!}
  before_create :create_oauth_token
  before_save :encrypt_password

  belongs_to :role
  belongs_to :customer
  belongs_to :supplier
  has_many :project_users
  has_many :projects, through: :project_users

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash ==  BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  private
    def encrypt_password
      if password.present?
        self.password_salt = BCrypt::Engine.generate_salt
        self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
      end
    end
    def create_oauth_token
      self.oauth_token = SecureRandom.urlsafe_base64
    end
end
