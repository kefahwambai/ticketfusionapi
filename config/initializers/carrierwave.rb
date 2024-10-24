CarrierWave.configure do |config|
  config.cache_storage = :file 
  config.cloudinary_credentials = {
    cloud_name: ENV['CLOUDINARY_CLOUD_NAME'],
    api_key:    ENV['CLOUDINARY_API_KEY'],
    api_secret: ENV['CLOUDINARY_API_SECRET']
  }
  config.storage = :cloudinary
end
