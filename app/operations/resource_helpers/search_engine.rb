module ResourceHelpers
  class SearchEngine < ::RecloudCore::DryBase
    attributes :search_query, :scope, :model, :global
    optional_attributes :fetch_recent
    MIN_CHARS = 4
    MIN_DIGIT = 4

    SEARCH_REGEX = {
      issue: [
        { weight: 1000, regex_pool: [/^REP[-_]?(\d+)$/i], search_by: :sequence_id },
        { weight: 900, regex_pool: [/^(\d+)$/], search_by: :sequence_id },
        { weight: 500, regex_pool: [/(^\d+)$/], search_by: :id },
        { weight: 400, regex_pool: [/(^\d{6,#{Device::IMEI_LENGTH}})$/], search_by: :imei },
        { weight: 400, regex_pool: [/^(.*[@.].*)$/i], search_by: :customer_email },
        { weight: 400, regex_pool: [/^([#{Constants::CHAR_REGEX}]{#{MIN_CHARS},})$/],
          search_by: :customer_name },
        { weight: 400, regex_pool: [/^([#{Constants::COMPANY_REGEX}]{#{MIN_CHARS},})$/],
          search_by: :customer_company_name },
        { weight: 400, regex_pool: [/^[0+](\d{#{MIN_DIGIT},})$/i], search_by: :customer_mobile_number }
      ],
      customer: [
        { weight: 990, regex_pool: [/^[0+](\d+)$/i], search_by: :mobile_number },
        { weight: 980, regex_pool: [/^CUS[-_]?([#{Constants::UUID_REGEX}]+)$/i], search_by: :sequence_id },
        { weight: 900, regex_pool: [/^(\d+)$/], search_by: :sequence_id },
        { weight: 900, regex_pool: [/^(.*[@.].*)$/i], search_by: :email },
        { weight: 500, regex_pool: [/^([#{Constants::CHAR_REGEX}]{#{MIN_CHARS},})$/], search_by: :name },
        { weight: 500, regex_pool: [/^([#{Constants::COMPANY_CHAR_REGEX}]{#{MIN_CHARS},})$/],
          search_by: :company_name },
        { weight: 490, regex_pool: [/^(\d+)$/], search_by: :id }
      ],
      repair_set: [
        { weight: 1000, regex_pool: [/^SET[-_]?(\d+)$/i], search_by: :id },
        { weight: 400, regex_pool: [/^\s*(.{3,})$/], search_by: :set_name }

      ],
      device: [
        { weight: 1000, regex_pool: [/^DEV[-_]?(\d+)$/i], search_by: :uuid },
        { weight: 600, regex_pool: [/(^\d{6,#{Device::IMEI_LENGTH}})$/], search_by: :imei },
        { weight: 500, regex_pool: [/(^\d{3,#{Device::SERIAL_NUMBER_MAX_LENGTH}})$/], search_by: :serial_number },
        { weight: 400, regex_pool: [/^\s*(.{3,})$/], search_by: :model_name }
      ],
      article: [
        { weight: 1000, regex_pool: [/^ART[-_]?(\d+)$/i], search_by: :uuid },
        { weight: 400, regex_pool: [/^\s*(.{3,})$/], search_by: :sku },
        { weight: 300, regex_pool: [/^\s*(.{3,})$/], search_by: :name }

      ],
      document: [
        { weight: 1000, regex_pool: [/^[a-zA-Z]*[-_]?(\d+)$/i], search_by: :sequence_id }
      ]

    }.freeze

    def call
      proccess_search
    end

    private

    def search_class
      "ResourceHelpers::#{model.to_s.classify}Search".constantize
    end

    # rubocop:todo Metrics/PerceivedComplexity
    # rubocop:todo Metrics/AbcSize
    def proccess_search # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
      regex_definitions = SEARCH_REGEX[model.to_sym]

      regex_definitions.each do |definition|
        definition[:regex_pool].each do |regex|
          next unless (match = search_query.match(regex))

          result = search_class.call(search_query: match[1], scope:, model:,
                                     search_by: definition[:search_by],
                                     global:).success
          return Success(result) if result.count > 0
        end
      end
      if global || search_query.present?
        return Success(scope.none) if search_query.present?

        fetch_recent ? recent_search_hits(scope) : Success(scope.none)
      else
        Success(scope)
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/PerceivedComplexity

    def recent_search_hits(scope)
      list = RecentSearchItems::ReadOperation.call(class_name: model.to_s).success
      ids = Array(list).pluck("id")
      if ids.present?
        query = scope.where(id: ids).reorder(Arel.sql("FIELD(id, #{ids.join(',')})"))
        return Success(query)
      end

      Success(scope.none)
    end
  end
end
