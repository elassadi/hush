module CustomerNotificationRules
  class TriggerEventFilter < Avo::Filters::MultipleSelectFilter
    self.name = I18n.t(:'filters.by_trigger_event_filter.name')

    # self.button_label = I18n.t(:'filters.by_trigger_event_filter.button_label')

    def apply(_request, query, values)
      ids = if values.is_a?(Hash)
              values.select { |_k, v| v }.keys
            else
              values
            end
      return query if ids.blank?

      query.where("JSON_CONTAINS(JSON_UNQUOTE(`metadata`), '#{ids}', '$.trigger_events')")
    end

    def options
      I18n.t('activerecord.attributes.template.trigger_events').sort_by { |_, value| value }.to_h
    end
  end
end

# TODO:  Bug with filter in application setting resource Edit view . filter button is reloading for some reason

# module CustomerNotificationRules
#   class TriggerEventFilter < Avo::Filters::BooleanFilter
#     self.name = I18n.t(:'filters.by_trigger_event_filter.name')

#     #self.button_label = I18n.t(:'filters.by_trigger_event_filter.button_label')

#     def apply(_request, query, values)
#       ids = if values.is_a?(Hash)
#                        values.select { |_k, v| v }.keys
#                      else
#                        values
#                      end
#       return query if ids.blank?

#       json_query = ""
#       ids.each do |id|
#         json_query << " OR " unless json_query.blank?
#         json_query << ( "( JSON_CONTAINS(JSON_UNQUOTE(`metadata`), '\"#{id}\"', '$.trigger_events') ) " )
#       end
#       #query.where("JSON_CONTAINS(JSON_UNQUOTE(`metadata`), '#{ids.to_s}', '$.trigger_events')")
#       query.where(json_query)
#     end

#     def options
#       sorted_hash = I18n.t('activerecord.attributes.template.trigger_events').sort_by { |_, value| value }.to_h
#     end
#   end
# end
