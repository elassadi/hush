# frozen_string_literal: true

class SeedInitData < ActiveRecord::Migration[7.0]

  def up
    account = Account.recloud
    seed_device_failure_categories(account)
    seed_suppliers(account)

    # # will be imported
    # account = Account.find_by!(name:"hush")
    # seed_device_failure_categories(account)
  end

  def seed_device_failure_categories(account)
    categories = [
      {name: "Display-Schaden", description: "Beschädigung von Display, Touch-Funktionalität beeinträchtigt"},
      {name: "Akku", description: "Schneller Akkuverbrauch, kein Laden des Akkus"},
      {name: "Kamera", description: "Unscharfe Aufnahmen, keine Funktion der Kamera"},
      {name: "Ladeanschluss", description: "Schlechter Kontakt, keine Ladefunktion"},
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
      DeviceFailureCategory.create(account: ,protected: true, **category)
    end

  end


  def seed_suppliers(account)
    suppliers = [
      {company_name: "Faroline"}
    ]

    suppliers.each do |supplier|
      Supplier.create(account:, **supplier)
    end

  end




  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
