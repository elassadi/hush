class ClientSerializer < ActiveModel::Serializer
  attributes :uuid, :status, :updated_at, :birthdate, :email, :first_name, :last_name,
             :phone, :remote_client_id, :addresses
  # attributes :unseen_messages_count
  # belongs_to :owner, class_name: "User"
  has_many :addresses

  def updated_at
    object.updated_at.to_i
  end

  # def unseen_messages_count
  #   object.unseen_messages_count_for(Current.user)
  # end
end
