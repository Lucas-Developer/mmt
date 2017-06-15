class VariablesController < ApplicationController
  def index
    set_schema
  end

  private

  def set_schema
    @schema = JSON.parse(File.read(File.join(Rails.root, 'lib', 'assets', 'schemas', 'umm-var-json-schema.json')))
  end
end
