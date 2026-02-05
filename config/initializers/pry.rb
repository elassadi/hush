unless Rails.env.development?
  env = Pry::Helpers::Text.red("PROD[#{Rails.application.class.module_parent.name}]")
else
  env = Pry::Helpers::Text.green("DEV[#{Rails.application.class.module_parent.name}]")
end

Pry.config.prompt = Pry::Prompt.new(
  'custom',
  'my custom prompt',
  [
    proc { |*_args| "#{env} > " },
    proc { |*_args| "#{env} > " }
  ]
)