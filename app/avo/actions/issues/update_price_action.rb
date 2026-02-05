module Issues
  class UpdatePriceAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)

    self.visible = lambda do
      return false
    end

    field :price, as: :price, default: -> { resource.model.price }, input_mode: :brutto

    def handle(**args)
      model = args[:models].first
      price = args[:fields][:price].to_f

      authorize_and_run(:create, model) do |_issue_entry|
        update_price.call(issue_id: model.id, issue_entry_ids: [], user_given_set_price: price)
      end

      close_frame
    end

    private

    def update_price = IssueEntries::UpdatePriceTransaction
  end
end
