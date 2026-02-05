module Addresses
  class ActivateAction < ::ApplicationBaseAction
    self.name = "i18n_activate_address"

    # test
    self.visible = lambda do
      return false unless view == :show

      current_user.may?(:activate, resource.model)
    end

    def handle(**args)
      # No batch actions
      models = args[:models]
      model = models.first
      authorize_and_run(:activate, model) do |address|
        activate(address)
      end

      client = model.addressable
      redirect_to avo.send :resources_client_path, id: client.id
    end

    private

    def activate(address)
      Addresses::ActivateTransaction.call(address_id: address.id)
    end
  end
end
