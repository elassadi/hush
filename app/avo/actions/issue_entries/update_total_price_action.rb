module IssueEntries
  class UpdateTotalPriceAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)

    self.visible = lambda do
      return false
    end

    # field :price, as: :price, default: -> { resource.model.price }, input_mode: :brutto
    field :price, as: :price, default: -> { resource.model.issue.price }, input_mode: :brutto
    field :issue_entry_id, as: :html do |_resource|
      %{
        <input id="issue_entry_id" type="hidden"
        value="{{resource_model_id}}" id="fields_issue_entry_id" name="fields[issue_entry_id]">
      }
    end

    def handle(**args)
      price = args[:fields][:price].to_f
      entry = args[:fields][:issue_entry_id].to_f

      issue = IssueEntry.by_account.find(entry).issue

      authorize_and_run(:create, issue) do |_issue|
        update_price.call(issue_id: issue.id, issue_entry_ids: [], user_given_set_price: price)
      end

      close_frame
    end

    private

    def update_price = IssueEntries::UpdatePriceTransaction
  end
end
