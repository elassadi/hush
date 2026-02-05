module IntervalTree
  class Builder
    def build_tree(entries)
      root = nil
      entries.each do |entry|
        root = insert(root, entry[:start_at], entry[:end_at], entry)
      end
      root
    end

    def insert(node, start_at, end_at, node_data)
      return Node.new(start_at, end_at, node_data) if node.nil?

      if start_at < node.start_at
        node.left = insert(node.left, start_at, end_at, node_data)
      else
        node.right = insert(node.right, start_at, end_at, node_data)
      end
      node.max_end = [node.max_end, end_at].max
      node
    end

    class << self
      delegate :build_tree, to: :new
    end
  end
end
