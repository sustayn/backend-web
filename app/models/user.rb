class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User
  include Swagger::Blocks

  swagger_schema :User do
    key :required, [:id, :email, :encrypted_password]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :first_name do
      key :type, :string
    end
    property :last_name do
      key :type, :string
    end
    property :email do
      key :type, :string
    end
    property :created_at do
      key :type, :datetime
    end
    property :updated_at do
      key :type, :datetime
    end
  end

  has_one :ecg_stream, dependent: :destroy

  def get_or_create_stream
    @ecg_stream = ecg_stream || EcgStream.create(user_id: current_user.id,
                                                 signal: [],
                                                 start_time: DateTime.now,
                                                 end_time: DateTime.now)
  end
end
