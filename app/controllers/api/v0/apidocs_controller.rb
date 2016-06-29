class API::V0::ApidocsController < API::V0::APIController
  include Swagger::Blocks

  before_action :cors_preflight_check
  after_action :cors_set_access_control_headers

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '0.1.0'
      key :title, 'Corvae Backend'
      key :description, 'An API to receive/deliver data from/to the mobile app and web frontend. Base URL is /api/v0'
      contact do
        key :name, 'Jake'
      end
      license do
        key :name, 'MIT'
      end
    end
    security_definition 'access-token' do
      key :type, :string
      key :name, 'access-token'
      key :in, :header
    end
    tag do
      key :name, 'Home'
      key :description, 'Root functions'
    end
    tag do
      key :name, 'Auth'
      key :description, 'User Authorization and Authentication'
    end
    tag do
      key :name, 'Current User'
      key :description, 'Actions for the current user object'
    end
    tag do
      key :name, 'Ecg Streams'
      key :description, 'Controller actions for the ecg stream models'
    end
    key :host, 'rails-corvae.us-west-2.elasticbeanstalk.com/'
    key :basePath, '/api/v0'
    key :consumes, ['application/vnd.api+json']
    key :produces, ['application/vnd.api+json']
  end

  swagger_path '/auth' do
    operation :post do
      key :description, 'Register a user'
      key :tags, ['Auth']
      parameter do
        key :name, :first_name
        key :in, :body
        key :description, 'The user first name'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :last_name
        key :in, :body
        key :description, 'The user last name'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :email
        key :in, :body
        key :description, 'The user email'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :password
        key :in, :body
        key :description, 'The user password'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :password_confirmation
        key :in, :body
        key :description, 'The user password confirmation'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'Success message'
        schema do
          property :status do
            key :type, :string
          end
          property :data do
            key :'$ref', :User
          end
        end
      end
      response 421 do
        key :description, 'Insufficient Params'
        schema do
          property :status do
            key :type, :string
          end
          property :errors do
            key :type, :array
            items do
              key :type, :string
            end
          end
        end
      end
    end
    operation :delete do
      key :description, 'Delete a user account'
      key :tags, ['Auth']
      response 200 do
        schema do
          property :success do
            key :type, :boolean
          end
        end
      end
      response 404 do
        schema do
          property :status do
            key :type, :string
          end
          property :errors do
            key :type, :array
            items do
              key :type, :string
            end
          end
        end
      end
    end
    operation :put do
      key :description, 'Update the user attributes, excluding password'
      key :tags, ['Auth']
      parameter do
        key :name, :first_name
        key :in, :body
        key :description, 'The user first name'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :last_name
        key :in, :body
        key :description, 'The user last name'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :email
        key :in, :body
        key :description, 'The user email'
        key :required, false
        key :type, :string
      end
      security do
        key 'access-token', []
      end
      response 200 do
        schema do
          property :status do
            key :type, :string
          end
          property :data do
            key :'$ref', :User
          end
        end
      end
      response :default do
        schema do
          property :status do
            key :type, :string
          end
          property :errors do
            key :type, :array
            items do
              key :type, :string
            end
          end
        end
      end
    end
  end
  swagger_path '/auth/sign_in' do
    operation :post do
      key :description, 'Sign in the user'
      key :tags, ['Auth']
      parameter do
        key :name, :email
        key :in, :body
        key :description, 'The user email'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :password
        key :in, :body
        key :description, 'The user password'
        key :required, true
        key :type, :string
      end
      response 200 do
        header 'access-token' do
          key :type, :string
        end
        header :client do
          key :type, :string
        end
        header :expiry do
          key :type, :integer
        end
        header :uid do
          key :type, :string
        end
        schema do
          property :data do
            key :'$ref', :User
          end
        end
      end
      response :default do
        schema do
          property :errors do
          key :type, :array
          items do
            key :type, :string
          end
        end
        end
      end
    end
  end
  swagger_path '/auth/sign_out' do
    operation :delete do
      key :description, 'Sign out the user'
      key :tags, ['Auth']
      response 200 do
        schema do
          property :success do
            key :type, :boolean
          end
        end
      end
    end
  end
  swagger_path '/auth/validate_token' do
    operation :get do
      key :description, 'Validate that the stored token is valid'
      key :tags, ['Auth']
      parameter do
        key :name, 'access-token'
        key :in, :query
        key :description, 'The stored auth token'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :uid
        key :in, :query
        key :description, 'The stored uid'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :client
        key :in, :query
        key :description, 'The stored client'
        key :required, true
        key :type, :string
      end
      response 200 do
        header 'access-token' do
          key :type, :string
        end
        header :client do
          key :type, :string
        end
        header :expiry do
          key :type, :integer
        end
        header :uid do
          key :type, :string
        end
        schema do
          property :data do
            key :'$ref', :User
          end
        end
      end
      response :default do
        schema do
          property :success do
            key :type, :string
          end
          property :errors do
            key :type, :array
            items do
              key :type, :string
            end
          end
        end
      end
    end
  end
  swagger_path '/auth/password' do
    operation :post do
      key :description, 'Trigger email sent to reset user password'
      key :tags, ['Auth']
      parameter do
        key :name, :email
        key :in, :body
        key :description, 'The email to send the password reset to'
        key :required, true
        key :type, :string
      end
      response 200 do
        schema do
          property :success do
            key :type, :boolean
          end
          property :message do
            key :type, :string
          end
        end
      end
      response :default do
        schema do
          property :success do
            key :type, :boolean
          end
          property :errors do
            key :type, :array
            items do
              key :type, :string
            end
          end
        end
      end
    end
    operation :put do
      key :description, 'Update user password'
      key :tags, ['Auth']
      parameter do
        key :name, :password
        key :in, :body
        key :description, 'The user password'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :password_confirmation
        key :in, :body
        key :description, 'The user password confirmation'
        key :required, true
        key :type, :string
      end
      security do
        key 'access-token', []
      end
      response 200 do
        schema do
          property :success do
            key :type, :boolean
          end
          property :message do
            key :type, :string
          end
          property :data do
            key :'$ref', :User
          end
        end
      end
      response :default do
        schema do
          property :success do
            key :type, :boolean
          end
          property :errors do
            key :type, :array
            items do
              key :type, :string
            end
          end
        end
      end
    end
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    User,
    EcgStream,
    StreamAlert,
    API::V0::HomeController,
    API::V0::UsersController,
    API::V0::EcgStreamsController,
    SuccessResponse,
    ErrorModel,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end

  private

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'

      render :text => '', :content_type => 'text/plain'
    end
  end
end
