class Contact < ContactRecord
  MODEL_PREFIX = "con".freeze
  include AccountOwnable

  string_enum :status, %w[disabled active deleted], _default: :active
  validates :email, presence: true
  validates :email, format: { with: Constants::EMAIL_REGEX }
  validates :first_name, :last_name, presence: true

  has_many :comments, as: :commentable, dependent: :delete_all
  has_many :addresses, as: :addressable, dependent: :delete_all

  has_one :primary_address, -> { status_active }, as: :addressable, inverse_of: :addressable,
                                                  class_name: "Address"

  def name
    [first_name, last_name].join " "
  end
end
