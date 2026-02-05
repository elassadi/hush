require 'rails_helper'

RSpec.describe AppConfig, type: :model do
  subject(:model) { record }

  let_it_be(:record) { create(:app_config, key: "test") }

  describe "#key" do
    it { is_expected.to have_db_index :key }
    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_uniqueness_of(:key).case_insensitive }
  end
end
