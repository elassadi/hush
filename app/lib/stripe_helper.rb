class StripeHelper
  class << self
    STRIPE_DASHBOARD_BASE_URL = {
      production: "https://dashboard.stripe.com",
      default: "https://dashboard.stripe.com/test"
    }.freeze

    def stripe_base_url
      STRIPE_DASHBOARD_BASE_URL[Rails.env.to_sym] ||
        STRIPE_DASHBOARD_BASE_URL[:default]
    end

    def stripe_dashboard_customer_url(id)
      "#{stripe_base_url}/customers/#{id}"
    end

    def stripe_dashboard_price_url(id)
      "#{stripe_base_url}/prices/#{id}"
    end

    def stripe_dashboard_subscription_url(id)
      "#{stripe_base_url}/subscriptions/#{id}"
    end

    def stripe_dashboard_payment_url(id)
      "#{stripe_base_url}/payments/#{id}"
    end
  end
end
