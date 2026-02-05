class TableField < Avo::Fields::BaseField
  def turbo_frame
    "#{id}_turbo_frame"
  end

  def scope
    nil
  end

  def frame_url
    path = avo.send :"new_resources_#{@resource.singular_route_key}_path"
    path = path.to_s.gsub(%r{/new}, "")

    url = Avo::Services::URIService.parse(path)
                                   .append_path(id.to_s)
                                   .append_query(turbo_frame: turbo_frame.to_s)
                                   .append_query(format: :turbo_stream)

    record_id = @resource.record.id if @resource.record.persisted?
    url = url.append_query(id: record_id) if record_id
    url.to_s
  end
end
