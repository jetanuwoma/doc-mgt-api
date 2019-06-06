

class DocumentSerializer < ActiveModel::Serializer
  attributes :id, :title, :access, :content

  belongs_to :user
  has_many :comments
end
