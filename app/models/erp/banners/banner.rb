module Erp::Banners
  class Banner < ApplicationRecord
    belongs_to :creator, class_name: 'Erp::User'
    belongs_to :category

    mount_uploader :image_url, Erp::Banners::BannerImageUploader

    validates :image_url, presence: true
		validates :image_url, allow_blank: true, format: {
			with: %r{\.(gif|jpg|png)\Z}i,
			message: 'URL hình ảnh phải có định dạng: GIF, JPG hoặc PNG.'
		}
		validates :name, :category_id, presence: true

		after_save :recreate_thumbs

		def recreate_thumbs
			self.image_url.recreate_versions!
		end

    # get categories active
    def self.get_active
			self.where(archived: false).order("created_at DESC")
		end

    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      and_conds = []

      # show archived items condition - default: false
			show_archived = false

			#filters
			if params["filters"].present?
				params["filters"].each do |ft|
					or_conds = []
					ft[1].each do |cond|
						# in case filter is show archived
						if cond[1]["name"] == 'show_archived'
							# show archived items
							show_archived = true
						else
							or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
						end
					end
					and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
				end
			end

      #keywords
      if params["keywords"].present?
        params["keywords"].each do |kw|
          or_conds = []
          kw[1].each do |cond|
            or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          end
          and_conds << '('+or_conds.join(' OR ')+')'
        end
      end

      # join with categories table for search with category
      query = query.joins(:category)

      # join with users table for search creator
      query = query.joins(:creator)

      # showing archived items if show_archived is not true
			query = query.where(archived: false) if show_archived == false

      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?

      return query
    end

    def self.search(params)
      query = self.all
      query = self.filter(query, params)

      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?

        query = query.order(order)
      end

      return query
    end

    # data for dataselect ajax
    def self.dataselect(keyword='')
      query = self.all

      if keyword.present?
        keyword = keyword.strip.downcase
        query = query.where('LOWER(name) LIKE ?', "%#{keyword}%")
      end

      query = query.limit(8).map{|banner| {value: banner.id, text: banner.name} }
    end

    def archive
			update_columns(archived: true)
		end

		def unarchive
			update_columns(archived: false)
		end

    def self.archive_all
			update_all(archived: true)
		end

    def self.unarchive_all
			update_all(archived: false)
		end

    def category_name
      category.present? ? category.name : ''
    end

    # get banner with position
    def self.get_home_sliders
			self.get_active.joins(:category).where(erp_banners_categories: {position: Erp::Banners::Category::POSITION_HOME_SLIDESHOW})
		end

    def self.get_home_block_banners
			self.get_active.joins(:category).where(erp_banners_categories: {position: Erp::Banners::Category::POSITION_HOME_BLOCK_BANNER})
		end

    def self.get_home_service_banners
			self.get_active.joins(:category).where(erp_banners_categories: {position: Erp::Banners::Category::POSITION_HOME_SERVICE})
		end

    def self.get_home_long_banners
			self.get_active.joins(:category).where(erp_banners_categories: {position: Erp::Banners::Category::POSITION_HOME_LONG_BANNER})
		end

    def self.get_category_banners
			self.get_active.joins(:category).where(erp_banners_categories: {position: Erp::Banners::Category::POSITION_CATEGORY_BANNER})
		end
  end
end
