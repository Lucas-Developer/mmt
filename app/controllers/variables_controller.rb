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

    fetch_references(schema_file)
  end

  def fetch_references(schema_file)
    puts schema_file.to_s.scan(/(?=\$ref)/).count

    referenced_properties = schema_file.fetch('properties', {}).select { |key, property| property.key?('$ref') }

    referenced_properties.each do |key, property|
      referenced_property = fetch_property_reference(property, schema_file)

      # Merge the property into the reference incase we've overridden anything
      schema_file['properties'][key] = referenced_property.merge(schema_file['properties'][key])
      schema_file['properties'][key].delete('$ref')

      if referenced_property.fetch('properties', {}).key?('$ref') || referenced_property.fetch('properties', {}).map { |key, property| property.fetch('items', {}).key?('$ref') }.any?
        # fetch_references(schema_file)
      end
    end

    referenced_items = schema_file.fetch('properties', {}).select { |key, property| property.fetch('items', {}).key?('$ref') }
    referenced_items.each do |key, property|
      referenced_property = fetch_items_reference(property, schema_file)

      # Merge the property into the reference incase we've overridden anything
      schema_file['properties'][key]['items'] = referenced_property.merge(schema_file['properties'][key]['items'])
      schema_file['properties'][key]['items'].delete('$ref')

      if referenced_property.fetch('properties', {}).key?('$ref') || referenced_property.fetch('properties', {}).map { |key, property| property.fetch('items', {}).key?('$ref') }.any?
        # fetch_references(schema_file)
      end
    end

    schema_file
  end

  def fetch_property_reference(property, current_schema)
    file, path = property['$ref'].split('#')

    referenced_property = unless file.blank?
      # If the reference in a different file -- parse it
      # referenced_schema = JSON.parse(File.read(File.join(Rails.root, 'lib', 'assets', 'schemas', file)))
      referenced_schema = parse_schema(file)
      referenced_schema['definitions'][path.split('/').last]
    else
      current_schema['definitions'][path.split('/').last]
    end

    fetch_items_reference(referenced_property, current_schema) if property.fetch('items', {}).key?('$ref')

    referenced_property
  end

  def fetch_items_reference(property, current_schema)
    file, path = property['items']['$ref'].split('#')

    referenced_items = unless file.blank?
      # If the reference in a different file -- parse it
      # referenced_schema = JSON.parse(File.read(File.join(Rails.root, 'lib', 'assets', 'schemas', file)))
      referenced_schema = parse_schema(file)
      referenced_schema['definitions'][path.split('/').last]
    else
      current_schema['definitions'][path.split('/').last]
    end

    referenced_items
  end
end
