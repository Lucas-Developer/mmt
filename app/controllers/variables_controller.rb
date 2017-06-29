# :nodoc:
class VariablesController < ApplicationController
  def index
    set_schema
    set_form
    set_object
    set_science_keywords
  end

  private

  def set_schema
    @schema = parse_schema('umm-var-json-schema.json')
  end

  def set_form
    @form = JSON.parse(File.read(File.join(Rails.root, 'lib', 'assets', 'schemas', 'umm-var-form.json')))
  end

  def set_object
    @object = {
      'Name'                 => 'Sollicitudin Vestibulum',
      'DataType'             => 'uchar8',
      'DimensionsName'       => 'Lorem Cras Pellentesque Dolor Elit',
      'FillValueDescription' => 'Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor.',
      'ServiceType'          => {
        'ServiceType' => %w(WMS OPeNDAP)
      },
      'Tagging' => [
        'Tagging 1',
        'Tagging 2'
      ],
      'ScienceKeywords' => [
        {
          'Category' => 'EARTH SCIENCE',
          'Topic' => 'ATMOSPHERE',
          'Term' => 'AEROSOLS',
        }
      ]
    }
  end

  def set_science_keywords
    @science_keywords = cmr_client.get_controlled_keywords('science_keywords')
  end

  def parse_schema(filename)
    # Load the requested schema file from the schema directory
    schema_file = JSON.parse(File.read(File.join(Rails.root, 'lib', 'assets', 'schemas', filename)))

    # Fetch all references in the schema
    fetch_references(schema_file, schema_file)
  end

  def fetch_references(schema_file, property)
    # Loop through each key in the current hash element
    property.each do |_key, element|
      # Skip this element if it's not a hash, no $ref will exist
      next unless element.is_a?(Hash)

      # If we have a reference to follow
      if element.key?('$ref')
        file, path = element['$ref'].split('#')

        # Fetch the reference from the file that it's defined to be in
        referenced_property = if file.blank?
                                # This is an internal reference (lives within the file we're parsing)
                                schema_file['definitions'][path.split('/').last]
                              else
                                # Fetch the reference from an external file
                                referenced_schema = parse_schema(file)
                                referenced_schema['definitions'][path.split('/').last]
                              end

        # Merge the retrieved reference into the schema
        element.merge!(referenced_property)

        # Remove the $ref key so we don't attempt to parse it again
        element.delete('$ref')
      end

      # Keep diggin'
      fetch_references(schema_file, element)
    end

    schema_file
  end
end
