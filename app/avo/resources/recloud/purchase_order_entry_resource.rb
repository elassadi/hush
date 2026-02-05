class PurchaseOrderEntryResource < ApplicationBaseResource
  self.authorization_policy = GlobalDataAccessPolicy
  self.translation_key = "activerecord.attributes.purchase_order_entry"

  include Concerns::AccountField

  self.includes = [:article]
  self.title = :uuid

  field :base_data_heading, as: :heading

  field :purchase_order, as: :belongs_to
  field :article, as: :belongs_to, searchable: true, hide_on: :index,
                  attach_scope: lambda {
                                  if parent.purchase_order.supplier
                                    query.where(supplier: parent.purchase_order.supplier)
                                  else
                                    query
                                  end
                                }

  field :article, as: :text, as_html: true, only_on: :index do |model|
    shorten_value = model.article.name.length > 60 ? "#{model.article.name[0...57]}..." : model.article.name
    args = model.article.name.length > 60 ? { title: model.article.name, 'data-tippy': "tooltip" } : {}

    Avo::App.view_context.link_to shorten_value, "/resources/articles/#{model.article.id}", **args
  end

  field :sku, as: :uuid, link_to_resource: false
  field :supplier_sku, as: :uuid, link_to_resource: false
  field :qty, as: :number, default: 1
  field :price, as: :price, only_on: :index
  field :total_price, as: :price, only_on: :index
  field :issue, as: :uuid, as_html: true, link_to_resource: false do |model|
    next unless model.issue

    Avo::App.view_context.link_to "REP-#{model.issue.sequence_id}", "/resources/issues/#{model.issue.id}"
  end

  action ::PurchaseOrderEntries::SplitAction
end
