class SuccessResponse
  include Swagger::Blocks

  swagger_schema :SuccessResponse do
    key :required, :meta
    property :meta do
      key :type, :object
      property :success do
        key :description, 'The success message'
        key :required, true
        key :type, :string
      end
    end
  end
end