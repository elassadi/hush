module IssueEntries
  class UpdateRabattAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)

    self.visible = lambda do
      return false
    end

    field :rabatt, as: :price, default: -> { resource.model.price }, input_mode: :brutto, help: t(:help)

    field :hidden_rabatt_entry_id, as: :html do |_resource|
      %{
        <input id="hidden_rabatt_entry_id" type="hidden"
        value="{{resource_model_id}}" id="fields_hidden_rabatt_entry_id" name="fields[hidden_rabatt_entry_id]">
      }
    end

    def handle(**args)
      rabatt = args[:fields][:rabatt].to_f
      issue_entry_id = args[:fields][:hidden_rabatt_entry_id].to_i

      model = IssueEntry.by_account.find(issue_entry_id)
      authorize_and_run(:update, model) do |issue_entry|
        update_rabatt.call(issue_entry_id: issue_entry.id, rabatt:)
      end

      close_frame
    end

    private

    def update_rabatt = IssueEntries::UpdateRabattTransaction
  end
end
