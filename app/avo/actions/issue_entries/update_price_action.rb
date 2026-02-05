module IssueEntries
  class UpdatePriceAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/currency-euro"

    self.visible = lambda do
      return false unless view == :index

      return false if @parent_resource.blank?

      true

      # current_user.can?(:create, @parent_resource.model)
    end

    field :price, as: :price, default: "0.0", input_mode: :brutto, help: t(:price_help)

    def handle(**args)
      models = args[:models]
      price = args[:fields][:price].to_f

      ids = models.map(&:id)

      authorize_and_run(:create, models.first) do |issue_entry|
        update_price.call(issue_id: issue_entry.issue_id, issue_entry_ids: ids, user_given_set_price: price)
      end

      close_frame
    end

    private

    def update_price = IssueEntries::UpdatePriceTransaction
  end
end
