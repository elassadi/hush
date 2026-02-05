module SupplierArticles
  class ImportAction < ::ApplicationBaseAction
    include Concerns::BaseResourceHelper
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/download"
    self.standalone = true

    self.visible = lambda do
      current_user.can?(:import, SupplierArticle.new)
    end

    docs_link(path: '/import-into-catalogue.html', i18n_key: :help_message)

    field :import_file, as: :file, required: true
    field :supplier, as: :select,
                     options: lambda { |_args|
                                Supplier.by_account.all.pluck(:company_name, :id)
                              }, display_with_value: true

    def handle(**args)
      file = args[:fields][:import_file]
      supplier_id = args[:fields][:supplier]
      authorize_and_run(:import, SupplierArticle.new) do
        document = save_document(file)

        if document.valid?
          Event.broadcast(:supplier_article_import_requested, document_id: document.id, supplier_id:)
          next Success(document)
        end

        Failure(document.errors.full_messages)
      end
    end

    def save_document(file)
      document = Document.new
      document.send(:generate_uuid)
      document.file = file
      document.key = document.uuid
      document.documentable = current_user.account
      document.save
      document
    end
  end
end
