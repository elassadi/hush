require 'rails_helper'

RSpec.describe ArticleGroup, type: :model do
  subject(:model) { record }

  let(:record) { create(:device) }

  describe "#validations" do
    it { is_expected.to have_db_index :uuid }
    it { is_expected.to validate_length_of(:serial_number).is_at_most(Device::SERIAL_NUMBER_MAX_LENGTH) }
    it { is_expected.to validate_length_of(:imei).is_equal_to(Device::IMEI_LENGTH) }
    # it { should validate_uniqueness_of(:name).scoped_to(:account_id).case_insensitive }
  end
end
