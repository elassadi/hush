# Shorthand for nested hash matching
# Example:
#   match_dig(:a, :b, :c, be_an(Integer))
# evaluates to:
#   match(
#     a: hash_including(
#       b: hash_including(
#         c: be_an(Integer)
#       )
#     )
#   )
def match_dig(*dig_args, value_condition)
  tmp = value_condition
  while dig_args.any?
    current = dig_args.pop
    tmp = hash_including(current => tmp)
  end
  match(tmp)
end
