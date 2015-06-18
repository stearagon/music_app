class User < ActiveRecord::Base
  validates :email,
    :session_token,
    :password,
    :password_digest,
    presence: true, uniqueness: true

  validates :password, length: { minimum: 6 }, allow_nil: true

  after_initialize :ensure_session_token

  def self.generate_session_token
    SecureRandom::urlsafe_base64(16)
  end

  def reset_session_token
    self.session_token = self.generate_session_token
    self.save!
    self.session_token
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def find_by_credentials(email, password)
    user = User.find_by(email: email, password: password)
    return nil if user.nil?
    user.is_password?(password) ? user : nil
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def ensure_session_token
    self.session_token ||= self.generate_session_token
  end

end
