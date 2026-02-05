#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to scan German locale files and generate English translations
# Usage: ruby scripts/translate_locales.rb [--dry-run] [--file=de.yml]

require 'yaml'
require 'fileutils'
require 'optparse'

class LocaleTranslator
  LOCALES_DIR = File.join(__dir__, '..', 'config', 'locales')
  DE_FILES = ['de.yml', 'avo.de.yml', 'de.basic.yml'].freeze

  # Common German to English translations
  COMMON_TRANSLATIONS = {
    'Benutzer' => 'User',
    'Kunde' => 'Customer',
    'Kunden' => 'Customers',
    'Artikel' => 'Article',
    'Artikeln' => 'Articles',
    'Reparatur' => 'Repair',
    'Reparaturauftrag' => 'Repair order',
    'Reparaturaufträge' => 'Repair orders',
    'Kalendereintrag' => 'Calendar entry',
    'Kalendereinträge' => 'Calendar entries',
    'Bestätigen' => 'Confirm',
    'Stornieren' => 'Cancel',
    'Aktivieren' => 'Activate',
    'Deaktivieren' => 'Disable',
    'Löschen' => 'Delete',
    'Speichern' => 'Save',
    'Bearbeiten' => 'Edit',
    'Anzeigen' => 'View',
    'Erstellen' => 'Create',
    'Aktualisieren' => 'Update',
    'Exportieren' => 'Export',
    'Importieren' => 'Import',
    'Einstellungen' => 'Settings',
    'Rollen' => 'Roles',
    'Berechtigungen' => 'Permissions',
    'Händler' => 'Merchant',
    'Lieferant' => 'Supplier',
    'Lieferanten' => 'Suppliers',
    'Kontakt' => 'Contact',
    'Kontakte' => 'Contacts',
    'Versicherung' => 'Insurance',
    'Versicherungen' => 'Insurances',
    'Gerät' => 'Device',
    'Geräte' => 'Devices',
    'Lager' => 'Stock',
    'Bestand' => 'Stock',
    'Bestände' => 'Stocks',
    'Dokument' => 'Document',
    'Dokumente' => 'Documents',
    'Vorlage' => 'Template',
    'Vorlagen' => 'Templates',
    'Konto' => 'Account',
    'Konten' => 'Accounts',
    'Status' => 'Status',
    'Name' => 'Name',
    'Email' => 'Email',
    'Telefonnummer' => 'Phone number',
    'Adresse' => 'Address',
    'Adressen' => 'Addresses',
    'Stadt' => 'City',
    'Postleitzahl' => 'Postal code',
    'Land' => 'Country',
    'Straße' => 'Street',
    'Hausnummer' => 'House number',
    'Beschreibung' => 'Description',
    'Preis' => 'Price',
    'Menge' => 'Quantity',
    'Rabatt' => 'Discount',
    'Steuer' => 'Tax',
    'Erstellt am' => 'Created at',
    'Aktualisiert am' => 'Updated at',
    'Gelöscht um' => 'Deleted at',
    'Aktiviert um' => 'Activated at',
    'Fehler' => 'Error',
    'Erfolg' => 'Success',
    'Warnung' => 'Warning',
    'Information' => 'Information',
    'Hilfe' => 'Help',
    'Mehr Informationen' => 'More information',
    'Bitte warten' => 'Please wait',
    'Wird geladen' => 'Loading',
    'Nicht gefunden' => 'Not found',
    'Keine Daten verfügbar' => 'No data available',
    'Sind Sie sicher?' => 'Are you sure?',
    'Möchten Sie' => 'Do you want to',
    'wirklich' => 'really',
    'Bitte geben Sie' => 'Please enter',
    'ein' => 'a',
    'einen' => 'a',
    'eine' => 'a',
    'wurde erstellt' => 'has been created',
    'wurde aktualisiert' => 'has been updated',
    'wurde gelöscht' => 'has been deleted',
    'wurde aktiviert' => 'has been activated',
    'wurde deaktiviert' => 'has been disabled',
    'wurde bestätigt' => 'has been confirmed',
    'wurde storniert' => 'has been canceled',
    'wird benachrichtigt' => 'will be notified',
    'Kunde benachrichtigen' => 'Notify customer',
    'Fehler beim Verarbeiten' => 'Error processing',
    'Bitte versuchen Sie es später erneut' => 'Please try again later',
    'Es ist ein Fehler aufgetreten' => 'An error occurred',
    'Vorschau wird geladen' => 'Loading preview',
    'Der Auftrag ist im falschen Status' => 'The order is in the wrong status',
    'Bitte überprüfen Sie den Status' => 'Please check the status',
    'und versuchen Sie es erneut' => 'and try again',
  }.freeze

  def initialize(options = {})
    @dry_run = options[:dry_run] || false
    @specific_file = options[:file]
    @verbose = options[:verbose] || false
  end

  def call
    puts "Starting locale translation scan..."
    puts "=" * 80
    puts "Mode: #{@dry_run ? 'DRY RUN (no files will be modified)' : 'LIVE (files will be updated)'}"
    puts "=" * 80

    files_to_process = @specific_file ? [@specific_file] : DE_FILES

    files_to_process.each do |de_file|
      process_file(de_file)
    end

    puts "\n" + "=" * 80
    puts "Translation scan completed!"
  end

  private

  def process_file(de_file)
    de_path = File.join(LOCALES_DIR, de_file)
    unless File.exist?(de_path)
      puts "\n⚠ File not found: #{de_file}"
      return
    end

    puts "\nProcessing: #{de_file}"
    puts "-" * 80

    # Determine corresponding English file
    en_file = de_file.sub(/^de/, 'en')
    en_path = File.join(LOCALES_DIR, en_file)

    # Load German file
    begin
      de_data = YAML.load_file(de_path)
      de_hash = de_data['de'] || de_data
    rescue => e
      puts "❌ Error loading #{de_file}: #{e.message}"
      return
    end

    # Load English file if it exists
    en_hash = {}
    if File.exist?(en_path)
      begin
        en_data = YAML.load_file(en_path)
        en_hash = en_data['en'] || en_data
      rescue => e
        puts "⚠ Warning: Error loading #{en_file}: #{e.message}"
        puts "  Continuing with empty English hash..."
      end
    else
      puts "ℹ English file #{en_file} does not exist, will be created"
    end

    # Find missing keys and generate translations
    missing_keys = find_missing_keys(de_hash, en_hash, [])

    if missing_keys.empty?
      puts "✓ No missing translations found"
      return
    end

    puts "\nFound #{missing_keys.size} missing translation(s):"
    missing_keys.first(10).each do |key_path, de_value|
      preview = de_value.to_s[0..80]
      preview += '...' if de_value.to_s.length > 80
      puts "  - #{key_path.join('.')}: #{preview.inspect}"
    end
    puts "  ... (#{missing_keys.size - 10} more)" if missing_keys.size > 10

    # Generate translations
    translations = generate_translations(missing_keys, de_hash)

    if @dry_run
      puts "\n[DRY RUN] Would update #{en_file} with #{translations.size} new translation(s)"
      if @verbose
        puts "\nGenerated translations preview:"
        puts YAML.dump({ 'en' => translations })
      end
    else
      # Merge with existing English hash
      merged_hash = deep_merge(en_hash.dup, translations)

      # Write updated English file
      output = { 'en' => merged_hash }.to_yaml
      File.write(en_path, output)

      puts "\n✓ Updated #{en_file} with #{translations.size} new translation(s)"
    end
  end

  def find_missing_keys(de_hash, en_hash, path = [])
    missing = []

    de_hash.each do |key, de_value|
      current_path = path + [key.to_s]

      if de_value.is_a?(Hash)
        en_value = en_hash[key] || {}
        missing.concat(find_missing_keys(de_value, en_value, current_path))
      elsif de_value.is_a?(String)
        en_value = en_hash[key]

        # Check if key is missing, empty, or contains German text
        is_missing = !en_hash.key?(key) || en_value.nil? || en_value == ''

        # Also check if English value looks like German (contains common German words)
        looks_like_german = false
        if en_value.is_a?(String) && !en_value.start_with?(':')
          german_indicators = ['Benutzer', 'Kunde', 'Artikel', 'Reparatur', 'wurde', 'wird', 'Bitte', 'Möchten']
          looks_like_german = german_indicators.any? { |indicator| en_value.include?(indicator) }
        end

        if is_missing || looks_like_german
          missing << [current_path, de_value]
        end
      end
    end

    missing
  end

  def generate_translations(missing_keys, de_hash)
    translations = {}

    missing_keys.each do |key_path, de_value|
      # Skip if it's a reference (starts with :)
      next if de_value.to_s.start_with?(':')

      # Generate translation
      en_value = translate_text(de_value)

      # Build nested hash structure
      current = translations
      key_path[0..-2].each do |key|
        current[key] ||= {}
        current = current[key]
      end
      current[key_path.last] = en_value
    end

    translations
  end

  def translate_text(text)
    return text if text.nil? || !text.is_a?(String)

    # Check if it's a reference
    return text if text.start_with?(':')

    # Check common translations first (exact match)
    translated = COMMON_TRANSLATIONS[text]
    return translated if translated

    # Try to find partial matches
    translated = text.dup

    # Replace whole words from common translations
    COMMON_TRANSLATIONS.each do |de, en|
      # Replace whole words only
      translated.gsub!(/\b#{Regexp.escape(de)}\b/, en)
    end

    # If no translation found, try pattern matching
    if translated == text
      translated = translate_patterns(text)
    end

    translated
  end

  def translate_patterns(text)
    translated = text.dup

    # Common German patterns
    patterns = [
      [/Möchten Sie (.+)\?/i, 'Do you want to \1?'],
      [/wurde (.+)/i, 'has been \1'],
      [/wird (.+)/i, 'will be \1'],
      [/Bitte (.+)/i, 'Please \1'],
      [/Sind Sie sicher/i, 'Are you sure'],
      [/Es ist ein Fehler/i, 'An error'],
      [/beim Verarbeiten/i, 'processing'],
      [/Ihrer Anfrage/i, 'your request'],
      [/aufgetreten/i, 'occurred'],
      [/Bitte versuchen Sie es später erneut/i, 'Please try again later'],
      [/Vorschau wird geladen/i, 'Loading preview'],
      [/bitte warten/i, 'please wait'],
      [/Der (.+) ist im falschen Status/i, 'The \1 is in the wrong status'],
      [/Bitte überprüfen Sie (.+)/i, 'Please check \1'],
      [/und versuchen Sie es erneut/i, 'and try again'],
      [/Keine (.+) angegeben/i, 'No \1 specified'],
      [/Die (.+) ist fehlerhaft/i, 'The \1 is incorrect'],
      [/kann nicht (.+) werden/i, 'cannot be \1'],
      [/da Sie (.+) ausgewählt haben/i, 'because you have selected \1'],
      [/Mehr Informationen finden Sie hier/i, 'More information can be found here'],
      [/Die (.+) werden in (.+) verschoben/i, 'The \1 will be moved to \2'],
      [/nur dann eingelagert/i, 'only then stored'],
      [/wenn Sie die Option/i, 'if you have selected the option'],
      [/ausgewählt haben/i, 'have selected'],
      [/Der Rest bleibt/i, 'The remainder stays'],
      [/in der ursprünglichen/i, 'in the original'],
      [/Die neue (.+) wird mit (.+) verknüpft/i, 'The new \1 will be linked to \2'],
      [/Passen Sie (.+) an/i, 'Adjust \1'],
      [/der bereits gelieferten/i, 'of already delivered'],
      [/mit einer Menge größer als 0/i, 'with a quantity greater than 0'],
      [/Achtung!/i, 'Warning!'],
      [/Der gesamte (.+) wird aktualisiert/i, 'The entire \1 will be updated'],
      [/Geben Sie bitte (.+) ein/i, 'Please enter \1'],
      [/einen Grund/i, 'a reason'],
      [/warum (.+) wird/i, 'why \1 is being'],
      [/angehalten/i, 'stopped'],
      [/Wird (.+) geladen/i, 'Loading \1'],
      [/(.+) wird (.+) geladen/i, 'Loading \1 \2'],
      [/Einloggen (.+)/i, 'Login \1'],
      [/fehlgeschlagen/i, 'failed'],
      [/Sie sind jetzt als (.+) eingeloggt/i, 'You are now logged in as \1'],
      [/Sie sind schon als (.+) eingeloggt/i, 'You are already logged in as \1'],
    ]

    patterns.each do |pattern, replacement|
      translated.gsub!(pattern, replacement)
    end

    translated
  end

  def deep_merge(target, source)
    source.each do |key, value|
      if target[key].is_a?(Hash) && value.is_a?(Hash)
        target[key] = deep_merge(target[key], value)
      else
        target[key] = value
      end
    end
    target
  end
end

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby scripts/translate_locales.rb [options]"

  opts.on('--dry-run', 'Run without modifying files') do
    options[:dry_run] = true
  end

  opts.on('--file=FILE', 'Process specific file (e.g., de.yml)') do |file|
    options[:file] = file
  end

  opts.on('--verbose', 'Show verbose output') do
    options[:verbose] = true
  end

  opts.on('-h', '--help', 'Show this help') do
    puts opts
    exit
  end
end.parse!

# Run the translator
translator = LocaleTranslator.new(options)
translator.call
