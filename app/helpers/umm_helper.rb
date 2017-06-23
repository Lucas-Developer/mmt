require 'deep_find'
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
      concat mmt_help_icon(help: "properties/#{element['key']}", title: element['key'])

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
    property = key.split('/').reduce(schema['properties']) { |a, e| a.fetch(e) }

    # Set the 'key' attribute within the property has so that we have reference to it
    property['key'] = key

    property
  end

  # We use '/' as a separator in our key names for the purposes of looking them up
  # in the schema when nested. However, we often need just the actual key, which is
  # what this method does for us.
  def fetch_key_leaf(provided_key)
    provided_key.split('/').last
  end

  # We use '/' as a separator in our key names for the purposes of looking them up
  # in the schema when nested. This method translates that into ruby syntax to retrieve
  # a nested key in a hash e.g. 'object/first_key/leaf' => 'object[first_key][leaf]'
  def keyify_property_name(element)
    element['key'].split('/').map.with_index { |key, index| index == 0 ? key.underscore : "[#{key.underscore}]" }.join
  end

  # Fetch all the 'keys' in the provided section of the schema
  def fetch_all_keys(schema, input)
    keys = []

    input['items'].each do |stuff|
      keys << stuff.deep_find('key')
    end

    # Hydrate each key with the data from the schema beacuse the origin
    # of this hash is the form layout json, so it lacks the meat of the key
    Array.wrap(keys).map { |element_key| hydrate_schema_property(schema, element_key) }
  end

  # Determines whether or not a form secion is complete and returns an
  # icon to represent the determinimation
  def umm_form_circle(schema, section, section_fields, object, _errors)
    # True until told otherwise
    valid = true

    unless object.empty? # && errors
      # page_errors = errors.select { |error| error[:page] == form_name }
      # error_fields = page_errors.map { |error| error[:top_field] }

      section_fields.each do |field|
        key_leaf = fetch_key_leaf(field['key'])

        # Ignore this field if it's not required valid
        next unless schema_required_fields(schema).include?(key_leaf) && object[key_leaf].blank?

        # Field is required and has no value
        valid = false

        # We've determined this section is incomplete, no reason to further investigate
        break
      end
    end

    form_section_circle(section.fetch('title', 'no_title'), valid)
  end

  # Generate the circle icon for a form section
  def form_section_circle(section_title, valid)
    # Default classes
    classes = %w(eui-icon icon-green)

    # Add the class that will define the final appearance of the circle
    classes << if valid
                 # Valid, displays a checkmark
                 'eui-check'
               else
                 # Invalid/Empty, displays an empty circle
                 'eui-fa-circle-o'
               end

    # Generate the actual content tag to return to the view
    content_tag(:i, class: classes.join(' ')) do
      content_tag(:span, class: 'is-invisible') do
        if valid
          "#{section_title} is valid"
        else
          "#{section_title} is incomplete"
        end
      end
    end
  end
end
