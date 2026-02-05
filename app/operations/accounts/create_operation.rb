# Roles::CreateCustomerRolesOperation.call(account: Account.recloud)
module Accounts
  class CreateOperation < BaseOperation
    attributes :name, :email, :account_type, :legal_form, :first_name, :last_name, :password, :plan

    def call
      result = create_account
      account = result.success
      if result.success?
        Event.broadcast(:account_created, account_id: account.id)

        return Success(account)
      end
      Failure(result.failure)
    end

    private

    def create_account
      yield validate_statuses

      account = Account.create(name:, email:,
                               legal_form:, account_type:, first_name:, last_name:, plan:)

      if account.valid?
        yield create_related_entities(account)

        return Success(account)
      end

      Failure(account)
    end

    def create_related_entities(account)
      yield create_master_merchant(account)
      yield create_account_settings(account)
      yield Roles::CreateCustomerRolesOperation.call(account:)
      yield Users::CreateOperation.call(account:, email:, role_name: :on_boarding, password:, master: true)
      yield Accounts::CreateDummyDataOperation.call(account:)
      yield create_templates(account)
      yield create_device_model_categories(account)
      yield create_notification_settings(account)
      yield create_default_application_settings(account)
      yield create_public_api_user(account)

      Success(account)
    end

    def validate_statuses
      # unless account.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved account_id: #{account.id} ")
      # end
      Success(true)
    end

    def create_master_merchant(account)
      merchant = yield Merchants::CreateOperation.call(
        company_name: account.name,
        account_id: account.id,
        first_name: first_name || 'Keine Angaben',
        last_name: last_name || 'Keine Angaben',
        master: true,
        email: account.email
      )

      Success(merchant)
    end

    def create_templates(account)
      Dir[Rails.root.join("config/templates/*.yaml")].each do |f|
        template_data = YAML.load_file(f).with_indifferent_access

        Template.create!(name: template_data[:name], account:) do |template|
          template.body = template_data[:body]
          template.template_type = template_data[:type]
          template.tags = template_data[:tags]
          template.subject = template_data[:subject]
          template.protected = template_data[:protected].present? ? true : false
        end
      end
      Success(true)
    end

    def create_device_model_categories(account)
      I18n.with_locale(:de) do
        I18n.t("model_categories").each do |category|
          DeviceModelCategory.create!(name: category[:name], description: category[:description], account:)
        end
      end
      Success(true)
    end

    def create_default_application_settings(account)
      account.application_settings.document_footer = 'Powered by ReCloud www.hush-haarentfernung.de'
      account.application_settings.save!
      Success(true)
    end

    def create_notification_settings(account)
      CustomerNotificationRule.create!(
        account:,
        setting: account.application_settings,
        template: Template.find_by(name: 'default-sms-template', account:),
        trigger_events: %w[issue_repairing_successfull],
        channel: 'sms'
      )

      CustomerNotificationRule.create!(
        account:,
        setting: account.application_settings,
        template: Template.find_by(name: 'default-mail-template', account:),
        trigger_events: %w[issue_order_printed],
        channel: 'mail'
      )

      Success(true)
    end

    def create_account_settings(account)
      Setting.categories.each do |category, _value|
        Setting.create!(
          metadata: {},
          account:,
          category:
        )
      end
      Success(true)
    end

    def create_public_api_user(account)
      Users::CreatePublicApiUserOperation.call(account:)
    end
  end
end
