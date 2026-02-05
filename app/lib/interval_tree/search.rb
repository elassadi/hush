module IntervalTree
  class Search
    def overlaps(node, start_time, end_time)
      return [] if node.nil?

      overlapping_intervals = []

      overlapping_intervals << node if node.start_at < end_time && node.end_at > start_time

      if node.left && node.left.max_end > start_time
        overlapping_intervals.concat(overlaps(node.left, start_time, end_time))
      end

      overlapping_intervals.concat(overlaps(node.right, start_time, end_time))

      overlapping_intervals
    end

    class << self
      delegate :overlaps, to: :new

      def build_and_search(entries, start_time, end_time)
        root = Builder.build_tree(entries)
        overlaps(root, start_time, end_time)
      end
    end
  end
end
