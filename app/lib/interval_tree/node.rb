module IntervalTree
  class Node
    attr_accessor :start_at, :end_at, :left, :right, :max_end, :node_data

    def initialize(start_at, end_at, node_data = nil)
      @start_at = start_at
      @end_at = end_at
      @max_end = end_at
      @node_data = node_data
    end
  end
end
