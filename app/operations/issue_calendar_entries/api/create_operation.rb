module IssueCalendarEntries
  module Api
    class CreateOperation < BaseOperation
      # attributes  *%i[entry_type start_at end_at customer_first_name customer_last_name
      #   customer_email customer_mobile_number repair_set_id]
      # optional_attributes *%i[notes]

      attributes :params

      attr_reader :issue_calendar_entry

      DEFAULT_EVENT_COLOR = "#d1edbc".freeze # light blue

      def call
        result = validate_and_create_issue_calendar_entry
        calendar_entry = result.success
        if result.success?
          # calendar_entry.broadcast_refresh
          return Success(calendar_entry)
        end

        Failure(result.failure)
      end

      private

      def validate_and_create_issue_calendar_entry
        yield validate_schema
        yield validate_statuses

        calendar_entry = yield create_issue_calendar_entry

        Success(calendar_entry)
      end

      def create_issue_calendar_entry
        customer = yield find_or_create_customer
        calendar_entry = yield create_calendar_entry(customer)

        # Reload calendar entry to ensure we have the latest association (issue is created in create_issue)
        calendar_entry.reload

        # Add articles to issue if article_skus are provided
        if params[:article_skus].present? && calendar_entry.calendarable.is_a?(Issue)
          yield add_articles_to_issue(calendar_entry.calendarable)
        end

        Success(calendar_entry)
      end

      def add_articles_to_issue(issue)
        # Ensure article_skus is an array
        article_skus = Array(params[:article_skus]).compact
        return Success(true) if article_skus.empty?



        article_skus.each do |sku|
          # Skip if sku is blank
          next if sku.blank?


          article = Article.by_account.find_by(sku: sku.to_s)
          unless article
            Rails.logger.warn("Article with SKU #{sku} not found for account #{account.id}")
            next
          end

          # Use default_retail_price (netto) for the issue entry
          # Issue entries store netto prices, and brutto is calculated when needed
          price = article.default_retail_price

          result = IssueEntries::AddArticleOperation.call(
            issue_id: issue.id,
            article_id: article.id,
            qty: 1,
            price: price
          )

          unless result.success?
            Rails.logger.error("Failed to add article #{article.id} to issue #{issue.id}: #{result.failure}")
            return result
          end
        end

        Success(true)
      end

      def create_calendar_entry(customer)
        IssueCalendarEntries::CreateOperation.call(
          entry_type: :repair,
          start_at: params[:start_at],
          end_at: params[:end_at],
          calendarable_id: customer.id,
          calendarable_type: "Customer",
          category: "repair",
          notes: params[:notes],
          selected_repair_set_id: params[:repair_set_id],
          event_color: DEFAULT_EVENT_COLOR,
          merchant_id: params[:merchant_id],
          notify_customer: true,
          source: "api"
        )
      end

      def find_or_create_customer
        customer = Customer.find_by(merchant_id: params[:merchant_id], email: customer_params[:email],
                                    mobile_number: customer_params[:mobile_number])

        return Success(customer) if customer

        # we shoiuld update the customer here if needed
        # update_customer(customer)

        create_customer
      end

      def update_customer(customer)
        Customers::UpdateOperation.call(attributes: customer_params, skip_address: true, customer:)
      end

      def create_customer
        Customers::CreateOperation.call(attributes: customer_params, skip_address: true)
      end

      def customer_params
        customer_params = params[:customer]
        salutation = customer_params[:salutation] || 'female'
        salutation = salutation.to_s if salutation.is_a?(Symbol)

        attrs = {
          salutation: salutation,
          first_name: customer_params[:first_name],
          last_name: customer_params[:last_name],
          email: customer_params[:email],
          mobile_number: customer_params[:mobile_number],
          merchant_id: params[:merchant_id]
        }

        # Generate dummy email if not provided and mobile_number is present
        if attrs[:email].blank? && attrs[:mobile_number].present?
          clean_mobile = attrs[:mobile_number].to_s.gsub(/\D/, '')
          attrs[:email] = "#{clean_mobile}@hush-haarentfernung.de"
        end

        attrs
      end

      def validate_schema
        customer_data = {
          first_name: params.dig(:customer, :first_name),
          last_name: params.dig(:customer, :last_name),
          email: params.dig(:customer, :email),
          mobile_number: params.dig(:customer, :mobile_number)
        }
        # Include salutation if provided
        customer_data[:salutation] = params.dig(:customer, :salutation) if params.dig(:customer, :salutation).present?

        data = {
          customer: customer_data,
          start_at: params[:start_at],
          end_at: params[:end_at],
          merchant_id: params[:merchant_id]
        }
        data[:repair_set_id] = params[:repair_set_id] if params[:repair_set_id].present?
        data[:notes] = params[:notes] if params[:notes].present?

        schema_klass.call(**data)
      end

      def schema_klass
        ::Api::Schemas::IssueCalendarEntrySchema
      end

      def validate_statuses
        # unless quote.status_approved?
        #   return Failure("#{self.class} invalid_status Must be approved quote_id: #{quote.id} ")
        # end

        Success(true)
      end
    end
  end
end
