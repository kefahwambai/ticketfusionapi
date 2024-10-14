class ImageUploader < CarrierWave::Uploader::Base
  # Choose storage type
  storage :file

  # Define the allowed file types
  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  # Customize the storage path
  def store_dir
    "uploads/events/#{model.id}"
  end

  # Customize the filename to make it unique
  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  protected

  def secure_token
    @secure_token ||= SecureRandom.uuid
  end
end
