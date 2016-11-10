class User < ActiveRecord::Base

  enum sex: {
    male: 0,
    female: 1,
    secret: 2
  }

  #hoishow
  def sign_in_api
    return if self.api_token.present? && self.api_expires_in.present?

    self.api_token = SecureRandom.hex(16)
    self.api_expires_in = 1.years
    self.last_sign_in_at = DateTime.now
    save!
  end

  #danche
  def sign_in_api
    if api_expires_in.blank? && api_token.blank?
      self.api_expires_in = Time.now - 1.days
    end
    return if ( Time.now < api_expires_in )

    loop do
      temp_api_token = SecureRandom.base64(16).tr('+/=lIO0', 'pqrsxyz')
      if  User.where(api_token: temp_api_token).blank?
        self.api_token = temp_api_token
        self.api_expires_in = Time.now + EXPIRES_IN_DAYS.days
        self.save
        break
      end
    end
  end

  private
  def set_password(password)
    self.salt = SecureRandom.base64(24)
    pbkdf2 = OpenSSL::PKCS5::pbkdf2_hmac_sha1(password, self.salt, 1000, 24)
    self.encrypted_password = ["sha1", Base64.encode64(pbkdf2)].join(':')
    self.save
  end

  def password_valid?(password)
    params = self.encrypted_password.split(':')
    return false if params.length != 2

    pbkdf2 = Base64.decode64(params[1])
    testHash = OpenSSL::PKCS5::pbkdf2_hmac_sha1(password, self.salt, 1000, pbkdf2.length)

    return pbkdf2 == testHash
  end
end
