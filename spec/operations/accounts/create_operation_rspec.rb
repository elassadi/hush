require 'rails_helper'

RSpec.describe Accounts::CreateOperation do
  let(:demo_operation_instance) { instance_double(Accounts::CreateDummyDataOperation) }
  let(:success_result) { Dry::Monads::Success(true) }

  describe '#call' do
    let(:name) { Faker::Company.name }
    let(:email) { Faker::Internet.email }
    let(:legal_form) { Account.legal_forms.keys.sample }
    let(:account_type) { Account.account_types.keys.sample }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:password) { Faker::Internet.password }
    let(:plan) { :basic }

    subject(:call) do
      described_class.call(
        name:,
        email:,
        legal_form:,
        account_type:,
        first_name:,
        last_name:,
        password:,
        plan:
      )
    end

    it 'creates a new account with the correct attributes and create a master merchant and user' do
      expect(Accounts::CreateDummyDataOperation).to receive(:new).and_return(demo_operation_instance)
      expect(demo_operation_instance).to receive(:call).and_return(success_result)
      expect do
        expect(Event).to receive(:broadcast).with(:api_token_created, any_args)
        expect(Event).to receive(:broadcast).with(:public_api_user_created, any_args)
        expect(Event).to receive(:broadcast).with(:merchant_created, any_args)
        expect(Event).to receive(:broadcast).with(:user_created, any_args).twice
        expect(Event).to receive(:broadcast).with(:account_created, any_args)
        expect(call).to(be_success)
      end.to(
        change(Account, :count).by(1)
        .and(change(Merchant, :count).by(1))
        .and(change(User, :count).by(2))
      )
      expect(Account.last.public_token).to be_present
    end
  end
end
