module CurrentUserAndAudit
  extend ActiveSupport::Concern

  included do
    before_action :setup_paper_trail_whodunnit
    before_action :setup_current_user
    before_action :setup_session
    # before_action :process_onboarding
  end

  def setup_paper_trail_whodunnit
    return unless ::PaperTrail.request.enabled?

    ::PaperTrail.request.whodunnit = current_user
    ::PaperTrail.request.controller_info = { whodunnit_type: current_user.class.name }
  end

  def setup_current_user
    Current.user = current_user
    I18n.locale = Current.user.locale || I18n.default_locale
  end

  def setup_session
    Current.session = session
  end

  def process_onboarding
    return if request.xhr?

    return if Current.account.status_active?
    return unless Current.user.account.completed_onboarding?
    return unless request.path == "/dashboards/cockpit"

    flash.now[:alert] = I18n.t("shared.messages.account_pending_activation")
  end
end
