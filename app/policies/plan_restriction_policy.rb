# frozen_string_literal: true

class PlanRestrictionPolicy < RecloudCore::DryBase
  attributes :resource_class, :account
  def call
    result = check_plan_restriction

    return Success(true) if result.success?

    Event.broadcast(:plan_exhausted, account_id: account.id)
    Failure(false)
  end

  private

  def check_plan_restriction
    return Success(true) if account.plan_advanced? || account.plan_unlimited? || plan_restriction_passes?

    Failure(false)
  end

  def plan_restriction_passes?
    return true unless PLAN_RESTRICTIONS_CONFIG[resource_class.to_s]

    limit = PLAN_RESTRICTIONS_CONFIG[resource_class.to_s][account.plan]

    return true if resource_class.by_account.count < limit

    false
  end
end
