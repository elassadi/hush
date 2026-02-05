module ResourcesAbilities
  class DefaultAbility < BaseAbility
    attributes :user, :record, :args

    def call
      apply
    end

    private

    def apply
      # args.all? do |condition|
      #   #condition.all? { |key, value|  Array(value).include?(record.send(key)) }
      #   condition.all? { |key, value|  Array(value).map(&:to_s).include?(record.send(key)&.to_s) }
      # end
      args.all? do |key, value|
        Array(value).map(&:to_s).include?(record.send(key)&.to_s)
      end
    end
  end
end
