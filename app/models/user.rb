class User < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
        :registerable,
        :recoverable,
        :rememberable,
        :validatable,
        :trackable,
        :omniauthable, omniauth_providers: [:google_oauth2]

  has_one_attached :avatar

  belongs_to :account

  has_many :todos
  has_many :participants, dependent: :destroy
  has_many :projects, through: :participants
  has_many :logs, through: :projects
  has_many :comments, through: :projects

  validates :username, presence: true, uniqueness: true
  validates :name, presence: true

  THEMES = %w[
    light dark cupcake bumblebee emerald corporate synthwave retro
    cyberpunk valentine halloween garden forest aqua lofi pastel
    fantasy wireframe black luxury dracula cmyk autumn business
    acid lemonade night coffee winter
  ].freeze

  validates :theme, inclusion: { in: THEMES }, allow_blank: true

  enum :role, {
    utilisateur: 0,
    admin: 1
  }

  def same_account(user)
    self.account == user.account
  end

  def self.from_omniauth(auth)
    require "open-uri"

    if user = User.find_by(email: auth.info.email)
      user
    else
      find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.name = auth.info.name   # assuming the user model has a name
        user.username = auth.info.email.split('@').first
        user.role = "admin"
        user.account = Account.create(name: user.username)
        user.avatar.attach(io: URI.open(auth.info.image), filename:"photo.png") # assuming the user model has an image
        # If you are using confirmable and the provider(s) you use validate emails, 
        # uncomment the line below to skip the confirmation emails.
        # user.skip_confirmation!

        user.save

        #Création du projet de démonstration
        CreateWelcomeProject.new(user.account.id).call

        Notifier.welcome_admin(user.email).deliver_now
        Notifier.with(account: user.account).new_account_notification.deliver_now

        user
      end
    end
  end

  private

  def slug_candidates
    [SecureRandom.uuid]
  end
end
