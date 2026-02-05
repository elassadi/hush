class ImportDevices < ActiveRecord::Migration[7.0]

  class DeviceManufacturer < ApplicationRecord
  end

  class DeviceModel < ApplicationRecord
  end

  class DeviceColor < ApplicationRecord
  end

  class BaseOrder < ApplicationRecord
  end

  class TaxonomyRecord < ApplicationRecord
    self.table_name ="taxonomy_records"
    self.inheritance_column = nil
  end

  def execute(sql_queries)
    sql_queries.split("\n").each do |sql|
      puts sql
      ActiveRecord::Base.connection.execute(sql) if sql.present?
    end
  end


  def recloud_id
    @recloud_id ||= Account.find_by!(name:"recloud").id
  end

  def repair_categories_map
     {
      'Verbindungen (Bluetooth, WLAN, Datenaustausch, ...)' => '12', # Bluetooth
      'Tastatur' => '6', # Tasten
      'Stromversorgung (Akku, Ladung)' => '2', # Akku
      'Netz (Empfang, Verbindung, ...)' => '15', # SIM-Karten
      'Navigation' => '11', # GPS
      'Nachrichten, Mobiles Internet (SMS, MMS, Web, ...)' => '5', # Software-Fehler
      'Multimedia (Kamera, Bilder, Video, Anwendungen, ...)' => '3', # Kamera
      'Grundfunktionen (Ein-/ Ausschalten, Software, SIM, ...)' => '5', # Software-Fehler
      'Display/Touch, Backcover, Gehäuse' => '1', # Display-Schaden
      'Audio (Mikro, ...), Benachrichtigung (Vibration, ...)' => '9', # Mikrofon
      'Daten' => '18', # Speicherprobleme
      'Feuchtigkeitsschaden' => '8' # Wasser- oder Staubschäden
    }

  end

  def up
    ::PaperTrail.enabled = false
    device_manufacturer = {}
    device_models = {}

    create_device_failure_categories

    DeviceManufacturer.update_all(account_id: recloud_id)
    DeviceModel.update_all(account_id: recloud_id)
    DeviceColor.update_all(account_id: recloud_id)
    seed_suppliers

    remove_duplicate_devices

    # DeviceManufacturer.where.not(account_id: recloud_id).delete_all
    # DeviceModel.where.not(account_id: recloud_id).delete_all
    # DeviceColor.where.not(account_id: recloud_id).delete_all

    remove_duplicate_devices

    ::PaperTrail.enabled = true
  end

  def remove_duplicate_devices
    devices = {}
    to_be_deleted=[]
    BaseOrder.where("workflow_state <> 'canceld' AND device_id IS NOT NULL").each do |order|
      device= Device.find_by(id: order.device_id)
      next unless device
      next if device.imei.blank?

      if devices[device.imei]
        order.update(device_id: devices[device.imei])
        puts "Delete device"
        device.destroy
        return
      end
      devices[device.imei] = device.id
    end
  end


  def create_device_failure_categories
      categories = [
        {name: "Display-Schaden", description: "Beschädigung von Display, Touch-Funktionalität beeinträchtigt"},
        {name: "Akku", description: "Schneller Akkuverbrauch, kein Laden des Akkus"},
        {name: "Kamera", description: "Unscharfe Aufnahmen, keine Funktion der Kamera"},
        {name: "Ladebuchsen", description: "Schlechter Kontakt, keine Ladefunktion"},
        {name: "Software-Fehler", description: "Abstürze, Fehlermeldungen"},
        {name: "Tasten", description: "Defekte, reagierende Tasten"},
        {name: "Lautsprecher", description: "Leiser Ton, kein Ton"},
        {name: "Wasser- oder Staubschäden", description: "Schäden durch Wasser oder Staub"},
        {name: "Mikrofon", description: "Verzerrung, keine Aufnahme"},
        {name: "Fingerabdrucksensor", description: "Ungenau, nicht funktionierend"},
        {name: "GPS", description: "Ungenaue Standortbestimmung, keine Verbindung"},
        {name: "Bluetooth", description: "Verbindungsprobleme, keine Übertragung"},
        {name: "Headset", description: "Kein Ton, Verbindungsprobleme"},
        {name: "Vibrationsmotor", description: "Keine Vibration, defekter Motor"},
        {name: "SIM-Karten", description: "Keine Verbindung, SIM-Kartenfehler"},
        {name: "Overheating", description: "Überhitzung, Abstürze"},
        {name: "Home-Button", description: "Reagiert nicht, defekt"},
        {name: "Speicherprobleme", description: "Zu wenig Speicher, Datenverlust"},
        {name: "Sonstiges", description: "Alle weiteren Fehler"}
      ]

      categories.each do |category|
        DeviceFailureCategory.create(account_id: recloud_id ,protected: true, **category)
      end

  end

  def seed_suppliers
    suppliers = [
      {company_name: "Faroline"}
    ]

    suppliers.each do |supplier|
      Supplier.create(account_id: recloud_id, **supplier)
    end

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end