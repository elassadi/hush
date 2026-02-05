# frozen_string_literal: true

class HushController < ApplicationController
  before_action :set_locale
  before_action :set_meta_tags

  def wellness
    # If locale is in URL path (e.g., /en/wellness or /de/wellness), use it
    # If no locale in params (e.g., / or /wellness), use default language (German) without redirect
    # Content will be rendered based on locale set in before_action

    # Fetch articles from database for women and men (for pricing section)
    merchant = Merchant.find_by(id: 2)

    if merchant&.account
      account = merchant.account

      @women_articles = Article.where(account: account)
                               .joins(:article_group)
                               .where(article_groups: { name: 'Dienstleistungen Frauen' })
                               .where(status: 'active')
                               .order(:sku)

      @men_articles = Article.where(account: account)
                             .joins(:article_group)
                             .where(article_groups: { name: 'Dienstleistungen Männer' })
                             .where(status: 'active')
                             .order(:sku)
    else
      @women_articles = Article.none
      @men_articles = Article.none
    end
  end

  def waxing_appointment
    # If locale is in URL path, use it; otherwise use default language (German)
    # Content will be rendered based on locale set in before_action
    @page_title = t('hush.wellness.appointment.page_title')
    @page_description = t('hush.wellness.appointment.page_description')

    # Get the account's public token for API authorization
    # Merchant ID 2 is used for waxing appointments
    merchant = Merchant.find_by(id: 2)
    @booking_token = merchant.account.public_token

    # Fetch articles from database for women and men
    account = merchant.account

    @women_articles = Article.where(account: account)
                             .joins(:article_group)
                             .where(article_groups: { name: 'Dienstleistungen Frauen' })
                             .where(status: 'active')
                             .order(:sku)

    @men_articles = Article.where(account: account)
                           .joins(:article_group)
                           .where(article_groups: { name: 'Dienstleistungen Männer' })
                           .where(status: 'active')
                           .order(:sku)
  end

  def waxing_appointment_thanks
    # Thanks page after successful appointment booking
    @page_title = t('hush.wellness.appointment.thanks_page_title', default: 'Termin erfolgreich gebucht')
    @page_description = t('hush.wellness.appointment.thanks_page_description', default: 'Vielen Dank für Ihre Buchung')
  end

  def impressum
    # Impressum page - always shows German content regardless of URL locale
    I18n.locale = :de
    @page_title = 'Impressum'
    @page_description = 'Impressum - Hush Haarentfernung'
  end

  def about
    # About page - shows information about Alena and the idea
    @page_title = t('hush.wellness.about.page_title', default: 'Über uns - Hush Haarentfernung')
    @page_description = t('hush.wellness.about.page_description', default: 'Erfahren Sie mehr über Hush Haarentfernung und Alena')
  end

  def datenschutz
    # Datenschutz page - always shows German content regardless of URL locale
    I18n.locale = :de
    @page_title = 'Datenschutzerklärung'
    @page_description = 'Datenschutzerklärung - Hush Haarentfernung'
  end

  private

  def set_locale
    # Check for locale in params first (from URL path like /en/ or /de/)
    if params[:locale].present?
      @locale = params[:locale].to_sym
      # Validate locale (only allow :de and :en)
      @locale = :de unless %i[de en].include?(@locale)
    else
      # No locale in URL - use default (German)
      @locale = :de
    end

    # Set I18n locale
    I18n.locale = @locale
  end

  def set_meta_tags
    @page_title = t('hush.wellness.meta.title', default: 'HUSH HAARENTFERNUNG | Professionelle Waxing & Haarentfernung')
    @page_description = t('hush.wellness.meta.description', default: 'Professionelle Waxing-Behandlungen, Tipps und Preise')
    @page_keywords = t('hush.wellness.meta.keywords', default: 'Waxing, Haarentfernung')
  end
end
