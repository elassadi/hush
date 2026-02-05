module Articles
  class PromoteSupplierOperation < BaseOperation
    attributes :article

    def call
      result = promote_supplier_article
      article = result.success
      if result.success?
        # Event.broadcast(:article_activated, article_id: article.id) if article.status_active?
        return Success(article)
      end

      Failure(result.failure)
    end

    private

    def promote_supplier_article
      yield validate_statuses
      supplier = yield find_best_supplier_from_sources

      article.update!(supplier:)

      Success(article)
    end

    def find_best_supplier_from_sources
      source = SupplierSource.where(article_id: article.id).order(*SupplierSource.supplier_sorting_criteria).first
      Success(source&.supplier)
    end

    def validate_statuses
      # unless article.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved article_id: #{article.id} ")
      # end

      Success(true)
    end
  end
end
