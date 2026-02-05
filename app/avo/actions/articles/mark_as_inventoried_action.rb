module Articles
  class MarkAsInventoriedAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/check-circle"
    self.icon_class = "text-green-500"
    # self.no_confirmation = true

    self.visible = lambda do
      current_user.can?(:create, Article)
    end

    def handle(**args)
      models = args[:models]
      models.each do |model|
        authorize_and_run(:create, model) do |article|
          mark_as_inventoried(article)
        end
      end
    end

    private

    def mark_as_inventoried(article)
      Articles::MarkAsInventoriedTransaction.call(article_id: article.id)
    end
  end
end
