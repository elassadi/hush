module Stocks
  module StockMovements
    module CreatedEvent
      class StockInOut < BaseEvent
        subscribe_to :stock_movement_created, prio: 10
        attributes :stock_movement_id
        delegate :qty, :article, :account, :stock_area, to: :stock_movement

        def call
          stock_in if stock_movement.action_stock_in?
          stock_out if stock_movement.action_stock_out?
          yield sync_stock_reservations if article.stockable?

          # check if we need this call
          # StockReservations::SyncTransaction.call(article_id: article.id)

          Success(true)
        end

        private

        def sync_stock_reservations
          StockReservations::SyncOperation.call(article:)
        end

        def stock_in
          article.stock.add_to_stock_quantity(qty)
          stock_item.add_to_stock_quantity(qty)
          Success(true)
        end

        def stock_out
          article.stock.substract_from_stock_quantity(qty)
          stock_item.substract_from_stock_quantity(qty)
          Success(true)
        end

        def stock_item
          @stock_item ||= find_stock_item || create_stock_item
        end

        def find_stock_item
          StockItem.find_by(
            account:,
            article:,
            stock_area:
          )
        end

        def create_stock_item
          stock_item = StockItem.create!(
            account:,
            article:,
            stock_area:
          )
          stock_movement.update(stock_item:)
          stock_item
        end

        def stock_movement
          @stock_movement ||= StockMovement.find(stock_movement_id)
        end
      end
    end
  end
end
