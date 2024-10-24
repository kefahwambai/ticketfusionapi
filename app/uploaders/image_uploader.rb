class ImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  protected

  def secure_token
    @secure_token ||= SecureRandom.uuid
  end
end

