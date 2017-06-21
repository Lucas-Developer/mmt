# :nodoc:
class VariablesController < ApplicationController
  def index
    set_schema
    set_form
    set_object
  end

  private

  def set_schema
    # @schema = JSON.parse(File.read(File.join(Rails.root, 'lib', 'assets', 'schemas', 'umm-var-json-schema.json')))
    @schema = parse_schema('umm-var-json-schema.json')

    puts @schema
  end

  def set_form
    @form = JSON.parse(File.read(File.join(Rails.root, 'lib', 'assets', 'schemas', 'umm-var-form.json')))
  end

  def set_object
    @object = {
      'Name'                 => 'Sollicitudin Vestibulum',
      'DimensionsName'       => 'Lorem Cras Pellentesque Dolor Elit',
      'FillValueDescription' => 'Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor.'
    }
  end

  def parse_schema(filename)
    # Load the requested schema file from the schema directory
    schema_file = JSON.parse(File.read(File.join(Rails.root, 'lib', 'assets', 'schemas', filename)))

    fetch_references(schema_file, schema_file)
  end

  def fetch_references(schema_file, property)
    property.each do |_key, element|
      next unless element.is_a?(Hash)

      if element.key?('$ref')
        file, path = element['$ref'].split('#')

        referenced_property = if file.blank?
                                schema_file['definitions'][path.split('/').last]
                              else
                                # If the reference in a different file -- parse it
                                referenced_schema = parse_schema(file)
                                referenced_schema['definitions'][path.split('/').last]
                              end

        element.merge!(referenced_property)
        element.delete('$ref')
      end

      fetch_references(schema_file, element)
    end  

    schema_file
  end
end
