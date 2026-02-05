

Dir[File.join(Rails.root, "lib", "price", "*.rb")].each {|l| require l }
Dir[File.join(Rails.root, "lib", "core_extensions", "*.rb")].each {|l| require l }
