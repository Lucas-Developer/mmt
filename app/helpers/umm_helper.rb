# :nodoc:
module UmmHelper
  def element_classes(property)
    # Default classes
    classes = ['full-width']

    # Add textcounter to the UI if the element has a maxLength
    classes.append('textcounter') if property.key?('maxLength')

    classes.join(' ')
  end

  def validation_properties(element, schema)
    # jQuery Validate can use html elements for validation so we'll set those elements
    # here instead of having to define these attributes on a one off basis in javascript
    validation_properties = element.select { |key| %w(minLength maxLength pattern).include?(key) }

    # JSON Schema provides the required fields in a separate array so we have to look this up
    if schema_required_fields(schema).include?(element['key'])
      validation_properties['required'] = true

      # jQuery validation supports custom messages via data attributes
      validation_properties['data'] = {
        'msg-required': "#{element['key'].titleize} is required."
      }
    end

    validation_properties
  end

  def element_properties(element, schema)
    { class: element_classes(element) }.merge(validation_properties(element, schema))
  end

  def render_form_element(element, schema, object)
    if element['type'] == 'section'
      render_section(element, schema, object)
    else
      send('render_markup', element.fetch('type', 'text'), hydrate_schema_property(schema, element['key']), schema, object)
    end
  end

  def render_markup(type, element, schema, object)
    capture do
      # Label for the form field
      concat render_label(element, schema)

      # Help Icon and Modal
      concat mmt_help_icon({ help: "properties/#{element['key']}", title: element['key'] })

      # Render the field
      concat send("render_#{type}", element, schema, object)
    end
  end

  def render_section(element, schema, object)
    content_tag(:section, class: element['htmlClass']) do
      # Display a title for the section if its provided
      concat content_tag(:h4, element['title'], class: 'space-bot') if element.key?('title')

      # Display a description of the section if its provided
      concat content_tag(:p, element['description'], class: 'form-description space-bot') if element.key?('description')

      # Continue rendering fields that appear in this section
      element.fetch('items', []).each do |child_element|
        concat render_form_element(child_element, schema, object)
      end
    end
  end

  def render_textarea(element, schema, object)
    text_area_tag(keyify_property_name(element), object[element['key']], element_properties(element, schema))
  end

  def render_text(element, schema, object)
    text_field_tag(keyify_property_name(element), object[element['key']], element_properties(element, schema))
  end

  def render_select(element, schema, object)
    select_tag(keyify_property_name(element), options_for_select(element['enum'], object[element['key']]), element_properties(element, schema))
  end

  def render_multiselect(element, schema, object)
    select_tag(keyify_property_name(element), options_for_select(element['items']['enum'], object[element['key']]), { multiple: true }.merge(element_properties(element, schema)))
  end

  def render_label(element, schema)
    label_tag(keyify_property_name(element), element.fetch('label', element['key'].split('/').last.titleize), class: ('eui-required-o' if schema_required_fields(schema).include?(element['key'])))
  end

  def schema_required_fields(schema)
    schema.fetch('required', [])
  end

  def hydrate_schema_property(schema, key)
    # Retreive the requested key from the schema
    property = key.split('/').reduce(schema['properties']) { |hsh, k| hsh.fetch(k) }

    # Set the 'key' attribute within the property has so that we have reference to it
    property['key'] = key

    property
  end

  def keyify_property_name(element)
    element['key'].split('/').map.with_index { |key, index| index == 0 ? key.underscore : "[#{key.underscore}]" }.join()
  end
end
