class DeviceResource < ApplicationBaseResource
  # include Concerns::ResourcesDefaultSetting
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  self.title = :title
  self.translation_key = "activerecord.attributes.device"
  self.includes = %i[device_model device_color account]
  self.stimulus_controllers = "device-resource patternlock read-only-patternlock"
  self.model_class = ::Device
  self.authorization_policy = GlobalDataAccessPolicy

  self.hide_from_global_search = true
  self.search_query = lambda {
    # scope.joins(:device_model).ransack(
    #   serial_number_matches: "%#{params[:q]}%",
    #   imei_matches: "%#{params[:q]}%",
    #   device_model_name_matches: "%#{params[:q]}%",
    #   m: "or"
    # ).result(distinct: false)

    ResourceHelpers::SearchEngine.call(search_query: params[:q], global: params[:global].to_boolean, scope:,
                                       model: :device).success
  }

  field :imei, as: :text, nullable: true,
               stimulus: { action: "device-resource#onImeiChange", view: %i[new edit] }
  field :serial_number, as: :text
  field :device_model_information, as: :heading

  field :device_model, as: :belongs_to, searchable: true,
                       stimulus: { action: "device-resource#onDeviceModelChange", view: %i[new edit] }

  field :device_color, as: :belongs_to, attach_scope: lambda {
    if parent && parent.device_model_id
      query.where(device_model_id: parent.device_model_id)
    else
      query.limit(0)
    end
  }, required: true
  field :technical_device_information, as: :heading

  field :unlock_pin, as: :text
  field :unlock_pattern, as: :text, only_on: %i[new edit],
                         stimulus: {
                           action: "focus->patternlock#onFocus keydown->patternlock#keydown", view: %i[new edit]
                         }

  html = %{
    <div class="flex flex-row justify-center items-center " id="lockwrapper" >
      <span class="text-sm text-gray-500 bg-white"></span>
      <div class="w-64">
        <svg class="patternlock" id="lock" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
          <g class="lock-actives"></g>
          <g class="lock-lines"></g>
          <g class="lock-dots">
              <circle cx="20" cy="20" r="2"/>
              <circle cx="50" cy="20" r="2"/>
              <circle cx="80" cy="20" r="2"/>

              <circle cx="20" cy="50" r="2"/>
              <circle cx="50" cy="50" r="2"/>
              <circle cx="80" cy="50" r="2"/>

              <circle cx="20" cy="80" r="2"/>
              <circle cx="50" cy="80" r="2"/>
              <circle cx="80" cy="80" r="2"/>
          </g>
        </svg>
      </div>
    </div>
  }

  field :unlock_pattern, stacked: true, as: :text, only_on: :show,
                         name: I18n.t("activerecord.attributes.device.unlock_pattern"),
                         visible: lambda { |resource:|
                                    resource.model.unlock_pattern.present?
                                  },
                         as_html: true do |_record, _resource, _view|
    code = resource.model.unlock_pattern.presence
    if code.present? && code.to_s.match?(/\A[1-9]+\z/)
      html + "<input type='hidden' data-read-only-patternlock-target='unlockPatternHiddenInput' " \
             "value='#{resource.model.unlock_pattern}' />"
    else
      resource.model.unlock_pattern.presence
    end
  end

  html = %{
    #{html}
  }

  field :unlock_pattern, as: :heading, only_on: :forms
  heading html, id: "simple", as_html: true, only_on: :forms
  field :customers, as: :has_many
  field :issues, as: :has_many

  filter Devices::NameFilter
end
