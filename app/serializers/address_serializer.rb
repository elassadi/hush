class AddressSerializer < ActiveModel::Serializer
  attributes :uuid, :status, :street, :house_number, :post_code, :city, :country
end
