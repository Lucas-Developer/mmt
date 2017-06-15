# :nodoc:
module UmmHelper
  def property_classes(property)
    classes = ['full-width']

    classes.append('textcounter') if property.key?('maxLength')

    classes.join(' ')
  end

  def validation_properties(property_name, property, required_fields: [])
    validation_properties = property.select { |key| %w(minLength maxLength).include?(key) }

    validation_properties['required'] = required_fields.include?(property_name)

    validation_properties
  end
end
