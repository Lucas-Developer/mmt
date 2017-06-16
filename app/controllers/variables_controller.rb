# :nodoc:
class VariablesController < ApplicationController
  def index
    set_schema
    set_form
    set_object
  end

  private

  def set_schema
    @schema = JSON.parse(File.read(File.join(Rails.root, 'lib', 'assets', 'schemas', 'umm-var-json-schema.json')))
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
end
