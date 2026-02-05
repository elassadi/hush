class ApplicationBaseAction < Avo::BaseAction
  include Concerns::BaseResourceHelper
  include Dry::Monads[:result, :do]

  def authorize_and_run(action, model)
    current_user.authorize!(action, model)
    result = yield(model)

    fail result.failure if result.is_a?(Dry::Monads::Result) && !result.success

    result
  rescue CanCan::AccessDenied
    fail I18n.t('shared.messages.no_access', action:, model: model.class.model_name.human)
    # Failure(false)
  end

  def authorize_and_run_all(action, models, &)
    authorize_and_run_result = nil
    models.each do |model|
      authorize_and_run_result = authorize_and_run(action, model, &)

      # If authorization fails or the result is unsuccessful, stop the loop
      break unless authorize_and_run_result.success?
    end
    authorize_and_run_result
  end

  def authorize_by_class_and_run(action, model)
    current_user.authorize!(action, model.class)
    result = yield(model)

    fail result.failure if result.is_a?(Dry::Monads::Result) && !result.success

    result
  rescue CanCan::AccessDenied
    fail I18n.t('shared.messages.no_access', action:, model: model.class.model_name.human)
  end

  def t(key, **args)
    self.class.t(key, **args)
  end

  class << self
    def t(key, **args)
      I18n.t(key, scope: "actions.#{to_s.underscore.tr('/', '.')}", **args)
    end

    def preview_button_html(document_type)
      %{
        <div class="ml-6">
          <a data-turbo-frame="preview_document"
            id="preview_document_button"
            data-action="click->issue-resource#startLoadingPreviewDocument"
            class="button-component inline-flex flex-grow-0 items-center font-semibold leading-6
              fill-current whitespace-nowrap
                   transition duration-100 transform cursor-pointer disabled:cursor-not-allowed
                   disabled:opacity-70 border justify-center
                   active:outline active:outline-1 rounded bg-primary-500 text-white border-primary-500
                    hover:bg-primary-600
                   hover:border-primary-600 active:border-primary-600 active:outline-primary-600
                    active:bg-primary-600 px-3 py-1.5 text-sm"
href="/resources/issues/{{resource_model_id}}/preview_document?format=turbo_stream&document_type=#{document_type}">
            <div class="preview-icon">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
              stroke="currentColor"
                   aria-hidden="true" class="mr-1 h-4 my-1">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M12 3c-4.97 0-9 3.589-9 8s4.03 8 9 8 9-3.589 9-8-4.03-8-9-8zm0 13.5c-2.485
                      0-4.5-1.57-4.5-3.5s2.015-3.5
                         4.5-3.5 4.5 1.57 4.5 3.5-2.015 3.5-4.5 3.5zm0-6c-.83 0-1.5.672-1.5 1.5s.67
                         1.5 1.5 1.5 1.5-.672 1.5-1.5-.67-1.5-1.5-1.5z">
                </path>
              </svg>
            </div>
            <span class="preview-text">#{I18n.t('shared.actions.load_preview')}</span>
          </a>

          <turbo-frame id="preview_document" class="w-full rounded mt-4"></turbo-frame>
        </div>
      }
    end
  end
end
