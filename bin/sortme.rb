require 'yaml'

# Function to recursively sort the keys alphabetically at each level
def deep_sort_hash(hash)
  hash.keys.sort.each_with_object({}) do |key, sorted_hash|
    value = hash[key]
    next if key.start_with?('#collision_de.')
    sorted_hash[key] = value.is_a?(Hash) ? deep_sort_hash(value) : value
  end
end

# Read YAML file into memory
input_file = './config/locales/de.yml'  # Replace with your input file path
output_file = 'output.yaml' # Replace with your output file path

yaml_content = YAML.load_file(input_file)

# Deep sort the YAML content
sorted_yaml_content = deep_sort_hash(yaml_content)

# Save the sorted YAML back to a file
File.open(output_file, 'w') do |file|
  file.write(sorted_yaml_content.to_yaml)
end

puts "YAML file has been sorted and saved to #{output_file}."