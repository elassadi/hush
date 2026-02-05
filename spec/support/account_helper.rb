module AccountHelper
  extend ActiveSupport::Concern
  included do
    include_context "setup system user"
    include_context "setup demo account and user"
  end
end
