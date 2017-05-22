module Erp
  module Banners
    class BannerImageUploader < CarrierWave::Uploader::Base
    
      # Include RMagick or MiniMagick support:
      # include CarrierWave::RMagick
      include CarrierWave::MiniMagick
    
      # Choose what kind of storage to use for this uploader:
      storage :file
      # storage :fog
    
      # Override the directory where uploaded files will be stored.
      # This is a sensible default for uploaders that are meant to be mounted:
      def store_dir
        "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end
    
      # Provide a default URL as a default if there hasn't been a file uploaded:
      # def default_url
      #   # For Rails 3.1+ asset pipeline compatibility:
      #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
      #
      #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
      # end
    
      # Process files as they are uploaded:
      # process scale: [200, 300]
      #
      # def scale(width, height)
      #   # do something
      # end
    
      # Create different versions of your uploaded files:
      # version :thumb do
      #   process resize_to_fit: [50, 50]
      # end
      
      # Used for backend
      version :system do
        process resize_to_fill: [150, 150]
      end
      version :system_logo do
        process resize_to_fill: [0, 25]
      end
      version :smaller do
				process :resize_to_fill => [0, 50]
			end
      version :banner_img do
				process :resize_to_fill => [100, 0]
			end
      version :small do
				process :resize_to_fill => [0, 75]
			end
      
      # Used for frontend
#      version :slider do
#				process :resize_to_fill => [904, 449]
#			end
#      version :block_banner do
#				process :resize_to_fill => [292, 180]
#			end
#      version :long_banner do
#				process :resize_to_fill => [1170, 100]
#			end
#      version :service_banner do
#				process :resize_to_fill => [364, 164]
#			end
      
      # Thumb size
			version :thumb do
				process :banner_resize
			end 
			
			# Thumb size
			def banner_resize
				if model.category.present? 
					if model.category.image_scale == "fill"
						resize_to_fill(model.category.width, model.category.height)
					elsif model.category.image_scale == "fit"
						resize_to_fit(model.category.width, model.category.height)
					else
						resize_to_fill(904, 449)
					end
				else
					resize_to_fill(904, 449)
				end
			end
    
      # Add a white list of extensions which are allowed to be uploaded.
      # For images you might use something like this:
      # def extension_whitelist
      #   %w(jpg jpeg gif png)
      # end
    
      # Override the filename of the uploaded files:
      # Avoid using model.id or version_name here, see uploader/store.rb for details.
      # def filename
      #   "something.jpg" if original_filename
      # end
    end
  end
end
