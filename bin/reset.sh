#!/bin/bash

set -e

# Define the global constant for the limit


#bundle exec rake db:drop db:create
# bundle exec rake db:migrate:with_data
rails db:drop && rails db:prepare && rails db:migrate:with_data
bundle exec rake "init_admin_roles:seed[recloud, true]"
bundle exec rake "init_admin_roles:seed[hush, true]"
bundle exec rake "templates:update[true]"
# bundle exec rake "accounts:create[demo]"
# bundle exec rake "utils:update_article_price_strategy[2]"
# bundle exec rake "utils:correct_issue_uuids[2]"
