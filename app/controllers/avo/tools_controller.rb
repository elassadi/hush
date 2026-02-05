module Avo
  class ToolsController < Avo::ApplicationController
    def calendar_tool
      @page_title = "Calendar tool"
      add_breadcrumb "Calendar tool"
      @calendar_entry_id = params[:calendar_entry_id]
      return if @calendar_entry_id.blank?

      calendar_entry = CalendarEntry.by_account.find(@calendar_entry_id)
      @calendar_entry_start = calendar_entry.start_at.iso8601
    end

    def error_page
      @page_title = "Error page"
      add_breadcrumb "errror"
    end
  end
end
