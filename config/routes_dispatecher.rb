module ActionDispatch
  module Routing
    class Mapper
      def route_by_env
        routes_path = Rails.root.join('config', "routes.#{Rails.env}.rb")
        instance_eval(File.read(routes_path))
     end
    end
  end
end

Rails.application.routes.draw do
  route_by_env
end