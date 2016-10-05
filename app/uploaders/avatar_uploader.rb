class AvatarUploader < CarrierWave::Uploader::Base
  # storage :file
  storage :postgresql_lo
  # def store_dir
  #   "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  # end
  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   puts "FILE NAME #{filename}"
  #   # "something.jpg" if original_filename
  # end
  # version :thumb do
  #   process :resize_to_limit => [200, 200]
  # end
end