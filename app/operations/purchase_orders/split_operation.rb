module PurchaseOrders
  class SplitOperation < BaseOperation
    attributes :purchase_order, :entry_quantities
    optional_attributes :stock_immediately
    attr_reader :dup_purchase_order

    def call
      result = split_purchase_order
      return Success(dup_purchase_order) if result.success?

      Failure(result.failure)
    end

    private

    def split_purchase_order
      yield validate_statuses
      yield validate_entry_quantities
      yield duplicate_purchase_order
      yield split_purchase_order_entries
      yield stock_purchase_order if stock_immediately

      Success(true)
    end

    def duplicate_purchase_order
      @dup_purchase_order = PurchaseOrder.create(
        supplier: src_purchase_order.supplier,
        account: src_purchase_order.account,
        status: :ordered,
        status_category: :in_progress,
        linked_to_id: src_purchase_order.id
      )

      unless dup_purchase_order.valid?
        return Failure("#{self.class} failed: #{dup_purchase_order.errors.full_messages}")
      end

      Success(dup_purchase_order)
    end

    def split_purchase_order_entries
      entry_quantities.each do |entry_quantity|
        entry_id = entry_quantity[:id]
        entry_qty = entry_quantity[:qty].to_i

        next if entry_qty <= 0

        src_entry = src_purchase_order.purchase_order_entries.find_by(id: entry_id)
        return Failure("#{self.class} failed: Purchase order entry not found for ID #{entry_id}") unless src_entry

        new_entry = create_new_purchase_order_entry(src_entry, entry_qty)
        return Failure("#{self.class} failed: #{new_entry.errors.full_messages}") unless new_entry.valid?

        update_or_destroy_entry(src_entry, entry_qty)
      end

      Success(true)
    end

    def create_new_purchase_order_entry(src_entry, entry_qty)
      dup_purchase_order.purchase_order_entries.create(
        article: src_entry.article,
        originator: src_entry.stock_reservation,
        account: src_entry.account,
        price: src_entry.price,
        qty: entry_qty
      )
    end

    def update_or_destroy_entry(src_entry, entry_qty)
      remaining_qty = src_entry.qty - entry_qty
      if remaining_qty <= 0
        src_entry.destroy!
      else
        src_entry.update!(qty: remaining_qty)
      end
    end

    def src_purchase_order
      purchase_order
    end

    def stock_purchase_order
      PurchaseOrders::TransitionToOperation.call(
        purchase_order: dup_purchase_order, event: "order_delivered", comment: "Order Split", owner: Current.user
      )
    end

    def validate_statuses
      if purchase_order.status != 'ordered'
        return Failure("#{self.class} invalid_status Must be ordered purchase_order_id: #{purchase_order.id} ")
      end

      Success(true)
    end

    def validate_entry_quantities
      entries = src_purchase_order.purchase_order_entries

      @entry_quantities = entry_quantities.reject { |e| e[:qty].to_i <= 0 }

      yield validate_not_all_empty(entries)
      yield validate_min_max_qty(entries)
      yield validate_not_all_selected(entries)

      Success(true)
    end

    def validate_min_max_qty(entries)
      result = entries.all? do |entry|
        input_entry = entry_quantities.find { |e| e[:id].to_s == entry.id.to_s }
        input_entry.blank? || (input_entry[:qty].to_i <= entry.qty && input_entry[:qty].to_i > 0)
      end

      return Success(true) if result

      Failure(I18n.t(:invalid_min_max_quantity, scope: "actions.purchase_orders.split_action.errors"))
    end

    def validate_not_all_selected(entries)
      result = entries.any? do |entry|
        input_entry = entry_quantities.find { |e| e[:id].to_s == entry.id.to_s }
        input_entry.blank? || input_entry[:qty].to_i != entry.qty
      end

      return Success(true) if result

      Failure(I18n.t(:use_workflow_order_delivered, scope: "actions.purchase_orders.split_action.errors"))
    end

    def validate_not_all_empty(_entries)
      return Success(true) if entry_quantities.present?

      Failure(I18n.t(:empty_entries, scope: "actions.purchase_orders.split_action.errors"))
    end
  end
end
