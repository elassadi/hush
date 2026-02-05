class Insurance < ContactRecord
  validates :company_name, presence: true

  validates :company_name, presence: true, uniqueness: { scope: %i[account_id] }
  attribute :salutation, default: Constants::CO
  has_many :addresses, as: :addressable, dependent: :delete_all
  has_one :primary_address, -> { status_active }, as: :addressable, inverse_of: :addressable,
                                                  class_name: "Address"

  def name
    company_name
  end
end
