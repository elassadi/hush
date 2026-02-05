namespace :init_admin_roles do
  desc "init_admin_roles and seed roles Only to use on the first seed"
  # bundle exec rake "apps:create[app_name,admin_email]"
  task :seed, %i[account_name confirm] => :environment do |_task, args|
    Rails.logger = Logger.new($stdout)

    class BaseRoleAbility
      attr_accessor :role, :account_name

      def role_type = :customer

      def account
        @account ||= Account.find_by(name: account_name)
      end

      def initialize(account_name:)
        @account_name = account_name
        return unless role_name

        @role = Role.find_or_create_by(name: role_name, account:, type: role_type, protected: true)
      end

      def call
        abilities.each do |ability|
          find_or_create_abilities(ability)
        end
        role
      end

      def find_or_create_abilities(ability)
        role.abilities.create(account:, **ability) unless Ability.available?(role, **ability)
      end

      class << self
        def call(account_name:)
          new(account_name:).call
        end
      end
    end

    class AdminRoleAbility < BaseRoleAbility
      def role_name = :admin
      def role_type = :system

      def abilities
        []
      end
    end

    class CreateUser < BaseRoleAbility
      def role_name; end

      def domain
        if account_name == "recloud"
          "hush-haarentfernung.de"
        else
          "#{account_name}.hush-haarentfernung.de"
        end
      end

      def admin_role
        Role.find_by(name: "admin", account:)
      end

      def technician_role
        Role.find_by(name: "technician", account:)
      end

      def supervisor_role
        Role.find_by(name: "supervisor", account:)
      end

      def account_admin_role
        Role.find_by(name: :account_admin, account:)
      end

      def merchant
        @merchant ||= begin
          # Reload account to ensure merchant association is available
          account.reload
          account.merchant || Merchant.find_by(account_id: account.id, master: true)
        end
      end

      def call
        # Ensure merchant exists before creating users
        unless merchant
          raise "Merchant not found for account #{account.name}. Please ensure merchant is created first."
        end

        if account_name == "recloud"
          User.create!(email: "system@#{domain}",
                       name: "system@#{domain}", role_id: admin_role.id,
                       password: "NoLogin123", password_confirmation: "NoLogin123",
                       account:,
                       merchant:, confirmed_at: Time.zone.now,
                       access_level: :account,
                       agb: true)

          User.create!(email: "admin@#{domain}", name: "Admin", role_id: admin_role.id,
                       access_level: :account,
                       agb: true,
                       account:,
                       master: true,
                       merchant:, confirmed_at: Time.zone.now,
                       password: "Passw0rd", password_confirmation: "Passw0rd")
        end

        # Only create technician user if the role exists (customer accounts only)
        if technician_role.present?
        User.create!(email: "alena@#{domain}", name: "alena", role_id: technician_role.id,
                     access_level: :account,
                     agb: true,
                     account:,
                       merchant:, confirmed_at: Time.zone.now,
                     password: "Passw0rd", password_confirmation: "Passw0rd")
        end

        # Only create account_admin user if the role exists
        if account_admin_role.present?
        User.create!(email: "account_admin@#{domain}", name: "account_admin", role: account_admin_role,
                     access_level: :account,
                     agb: true,
                     master: account_name == "recloud" ? nil : true,
                     account:,
                       merchant:, confirmed_at: Time.zone.now,
                     password: "Passw0rd", password_confirmation: "Passw0rd")
        end
      end
    end

    account_name = args[:account_name]
    confirm = args[:confirm]

    if Rails.env.production?
      puts "Confirmation needed [hanswurst, true]"
      puts "Warning all abilities will be deleted "
      next unless confirm
    end

    account = Account.find_by(name: account_name)

    ::PaperTrail.enabled = false

    AdminRoleAbility.call(account_name:) if account.recloud?
    Roles::CreateCustomerRolesOperation.call(account:)

    CreateUser.call(account_name:)

    # Create dummy data for the account
    Accounts::CreateDummyDataOperation.call(account: account)

    ::PaperTrail.enabled = true
  end
end
