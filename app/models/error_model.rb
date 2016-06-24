class ErrorModel
  include Swagger::Blocks

  swagger_schema :ErrorModel do #collapse_start
    property :errors do
      key :type, :array
      key :required, true
      items do
        property :title do
          key :description, 'The error title, brief'
          key :required, true
          key :type, :string
        end
        property :detail do
          key :description, 'A longer description of the error'
          key :required, false
          key :type, :string
        end
        property :status do
          key :description, 'The HTTP status code'
          key :required, false
          key :type, :integer
        end
      end
    end
  end #collapse_end
end