class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  # Profile media
  has_one_attached :profile_image
  has_one_attached :cover_image
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :date_of_birth, presence: true

  # Friendships
  has_many :friendships, dependent: :destroy
  has_many :accepted_friendships, -> { where(status: "accepted") }, class_name: "Friendship"
  has_many :friends, through: :accepted_friendships, source: :friend

  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
  has_many :inverse_accepted_friendships, -> { where(status: "accepted") }, class_name: "Friendship", foreign_key: "friend_id"
  has_many :inverse_friends, through: :inverse_accepted_friendships, source: :user

  # Helpers for pending state
  has_many :pending_friendships, -> { where(status: "pending") }, class_name: "Friendship"
  has_many :pending_friends, through: :pending_friendships, source: :friend
  has_many :incoming_pending_friendships, -> { where(status: "pending") }, class_name: "Friendship", foreign_key: "friend_id"
  has_many :incoming_pending_friends, through: :incoming_pending_friendships, source: :user
end
