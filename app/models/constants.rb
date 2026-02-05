# frozen_string_literal: true

module Constants
  CITY_CODE_REGEX = /\A\d{5}\z/
  # PHONE_REGEX = /\A\+49\d{5,20}\z/
  PHONE_REGEX = /\A\+?\d{5,22}\z/
  EMAIL_REGEX = /\A[A-Z0-9._%+-]+@(\S)+\.(\S){1,63}\z/i
  CHAR_REGEX = 'a-z A-Z äöüÄÖÜ'
  COMPANY_CHAR_REGEX = 'a-z A-Z äöüÄÖÜ&/-'

  NUMBERS_REGEX = /\A[0-9]+\z/i
  LETTERS_REGEX = /\A[a-zA-ZäöüÄÖÜ]+\z/i
  HOUSE_NUMBER_REGEX = %r{^([a-zäöüß\s\d.,-]+?)\s*([\d\s]+(?:\s?[-|+/]\s?\d+)?\s*[a-z]?)?\s*$}i
  COMPANY_REGEX = "a-z A-Z äöüÄÖÜß&/-"
  UUID_REGEX = "0-9a-zA-Z"

  LOCALES = %w[de en].freeze

  AGE_GROUPS = %w[up_to_22 from_22_to_50 from_51_to_69 above_70].freeze

  RECLOUD_ACCOUNT_UUID = "acc_recloud00"
  RECLOUD_MERCHANT_UUID = "mer_recloud00"

  TABLES_WITH_ACCOUNT_AND_AGENT_COLUMNS = %i[
    clients
    contracts
  ].freeze

  TABLES_WITH_ACCOUNT_COLUMN = %i[
    agents
    clients
    contracts
    contacts
    addresses
    chatbot_sessions
    chatwoot_messages
    documents
    insurance_policies
    open_payment_items
    payment_transactions
    payments
    users
  ].freeze

  SALUTATIONS = [
    MS = "female",
    MR = "male",
    CO = "company"
  ].freeze

  UNITS = %w[piece dousaine].freeze
  SHARED_DATA_MODELS = [
    DeviceManufacturer, DeviceModel, DeviceColor, Supplier, SupplierArticle, DeviceFailureCategory
  ].freeze

  STATUS_BADGE_BACKGROUND = {
    light: 'bg-white',
    gray: 'bg-gray-500',
    info: 'bg-blue-400',
    success: 'bg-green-500',
    danger: 'bg-red-400',
    warning: 'bg-orange-400'
  }.freeze

  STATUS_BADGE_TEXT_COLOR = {
    light: 'text-black',
    gray: 'text-white',
    info: 'text-white',
    success: 'text-white',
    danger: 'text-white',
    warning: 'text-white'
  }.freeze
end
