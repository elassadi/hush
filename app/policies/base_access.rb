class BaseAccess
  PERMISSIONS_CONFIG = {
    User: {
      view_create: %i[ApiToken],
      restrictions: {}
    },
    Setting: {
      view_create: %i[CustomerNotificationRule Sequence],
      restrictions: {}
    },
    Article: {
      view_create: %i[SupplierSource RepairSet Stock StockMovement StockReservation SupplierArticle],
      restrictions: {}
    },
    Account: {
      view_create: %i[Address User],
      restrictions: {}
    },
    Address: {
      view_create: %i[],
      restrictions: {
        cannot: [
          { actions: %i[edit], conditions: { status: %i[archived] } },
          { actions: %i[destroy], conditions: { status: %i[archived active] } }
        ]
      }
    },
    CalendarEntry: {
      view_create: %i[],
      restrictions: {
        cannot: [
          { actions: %i[destroy], proc_klass: "ResourcesAbilities::CalendarEntryAbility" }
        ]
      }
    },
    Comment: {
      view_create: %i[],
      restrictions: {
        cannot: [
          {
            actions: %i[edit destroy], conditions: { protected: "true" }
          }
        ]
      }
    },
    Customer: {
      view_create: %i[Address Comment Issue Device],
      restrictions: {}
    },
    DeviceManufacturer: {
      view_create: %i[DeviceModel],
      restrictions: {}
    },
    DeviceModel: {
      view_create: %i[DeviceColor RepairSet Device],
      restrictions: {}
    },
    Device: {
      view_create: %i[Issue Customer],
      restrictions: {}
    },
    Issue: {
      view_create: %i[IssueEntry CalendarEntry Document Activity Comment],
      view_versions: true,
      version_klass: "PaperTrail::IssueVersion",
      restrictions: {
        cannot: [
          { actions: %i[create edit destroy], conditions: { status_category: %i[done] } },
          { actions: %i[destroy], conditions: { status_category: %i[done in_progress] } },
          { actions: %i[create_issue_entries], proc_klass: "ResourcesAbilities::IssueEntryAbility" }
        ]
      }
    },
    IssueEntry: {
      view_create: %i[],
      restrictions: {
        cannot: [
          { actions: %i[edit destroy], proc_klass: "ResourcesAbilities::IssueEntryAbility" }
        ]
      }
    },
    Merchant: {
      view_create: %i[Address BusinessHour],
      restrictions: {
        cannot: [
          {
            actions: %i[destroy], conditions: { master: "true" }
          },
          { actions: %i[create_business_hours], proc_klass: "ResourcesAbilities::BusinessHourAbility" }
        ]
      }
    },
    PurchaseOrder: {
      view_create: %i[Comment PurchaseOrderEntry PurchaseOrder],
      restrictions: {
        cannot: [
          { actions: %i[edit destroy], conditions: { status_category: %i[in_progress done] } },
          { actions: %i[edit], proc_klass: "ResourcesAbilities::PurchaseOrderAbility" }
        ]
      }
    },
    PurchaseOrderEntry: {
      view_create: %i[],
      restrictions: {
        cannot: [
          { actions: %i[edit create destroy], proc_klass: "ResourcesAbilities::PurchaseOrderEntryAbility" }
        ]
      }
    },
    RepairSet: {
      view_create: %i[RepairSetEntry],
      restrictions: {}
    },
    RepairSetEntry: {
      view_create: %i[],
      restrictions: {}
    },
    StockLocation: {
      view_create: %i[StockArea],
      restrictions: {}
    },
    Supplier: {
      view_create: %i[Address Document],
      restrictions: {
        cannot: [
          { actions: %i[create_addresses], proc_klass: "ResourcesAbility::SupplierAbility" }
        ]
      }
    },
    Insurance: {
      view_create: %i[Address],
      restrictions: {
        cannot: [
          { actions: %i[create_addresses], proc_klass: "ResourcesAbility::InsuranceAbility" }
        ]
      }
    },
    Template: {
      view_create: %i[CustomerNotificationRule],
      restrictions: {
        cannot: [
          {
            actions: %i[edit destroy], conditions: { protected: "true" }
          }
        ]
      }
    },
    Event: {
      view_create: %i[EventJob]
    }
  }.freeze

  def constantize(resource_klass)
    "::#{resource_klass}".constantize
  end

  def read_permission_config
    PERMISSIONS_CONFIG
  end

  def initialize(user, ability)
    @user = user
    @ability = ability
  end

  def apply_permissions
    read_permission_config.each do |resource_klass, config|
      if config[:view_create]
        grant_view_create_permissions_to(klasses: config[:view_create],
                                         resource_klass:)
      end
      if config[:view_versions]
        grant_view_versions_permissions_to(resource_klass:,
                                           version_klass: config[:version_klass])
      end
    end
  end

  def apply_restrictions
    read_permission_config.each do |resource_klass, config|
      next if config[:restrictions].blank?

      restrictions = config[:restrictions]
      restrictions[:cannot].each do |restriction|
        actions = restriction[:actions]
        if restriction[:conditions]
          cannot(actions, constantize(resource_klass), proc_klass: "ResourcesAbilities::DefaultAbility",
                                                       args: restriction[:conditions])
        elsif restriction[:proc_klass]
          cannot(actions, constantize(resource_klass), proc_klass: restriction[:proc_klass])
        else
          cannot(actions, constantize(resource_klass))
        end
      end
    end
  end

  private

  def cannot(...)
    @ability.cannot(...)
  end

  def can(...)
    @ability.can(...)
  end

  def grant_view_versions_permissions_to(resource_klass: nil, version_klass: nil)
    version_klass = (version_klass.presence || "PaperTrail::#{resource_klass}Version")

    return unless @ability.permission_granted?(:read, version_klass)

    can(:view_versions, constantize(resource_klass))
  end

  def grant_view_create_permissions_to(klasses:, resource_klass:)
    klasses.each do |klass|
      next unless @ability.any_permission_granted?(%i[read create], resource_klass)

      if @ability.permission_granted?(:create, klass)
        can("create_#{klass.to_s.underscore.pluralize}".to_sym, constantize(resource_klass))
      end

      if @ability.permission_granted?(:read, klass)
        can("view_#{klass.to_s.underscore.pluralize}".to_sym, constantize(resource_klass))
        can("view_#{klass.to_s.underscore}".to_sym, constantize(resource_klass))
      end
    end
  end
end
