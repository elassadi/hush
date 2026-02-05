module Concerns
  module BaseFields
    def proc(caller, method)
      caller.method(method).to_proc
    end

    def show_field(field, args)
      add_field(field, args, :show)
    end

    def index_field(field, args)
      add_field(field, args, :index)
    end

    def new_field(field, args)
      add_field(field, args, :new)
    end

    def edit_field(field, args)
      add_field(field, args, :edit)
    end

    private

    def add_field(field, args, only_on)
      base = args[:base]
      args[:only_on] = only_on
      base.field field, **args.except(:base)
    end

    def show_sidebar(base:, &block)
      base.sidebar(&block)
    end
  end
end
