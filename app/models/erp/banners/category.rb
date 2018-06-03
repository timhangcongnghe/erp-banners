module Erp::Banners
  class Category < ApplicationRecord
    belongs_to :creator, class_name: 'Erp::User'
    has_many :banners
    validates :name, :width, :height, :image_scale, :presence => true
    
    # class const
    SCALE_FILL = 'fill'
    SCALE_FIT = 'fit'
    POSITION_HOME_SLIDESHOW = 'home_slideshow'
    POSITION_HOME_BLOCK_BANNER = 'home_block_banner'
    POSITION_HOME_SERVICE = 'home_service_banner'
    POSITION_HOME_LONG_BANNER	= 'home_long_banner'
    POSITION_CATEGORY_BANNER = 'category_banner'
    POSITION_BRAND_IDENTITY = 'brand_identity'
    
    # get image scale
    def self.get_image_scale_options
      [
        {text: I18n.t('.fill'),value: self::SCALE_FILL},
        {text: I18n.t('.fit'),value: self::SCALE_FIT}
      ]
    end
    
    # get position for banner type
    def self.get_position_options()
      [
        {text: 'home_slideshow',value: self::POSITION_HOME_SLIDESHOW},
        {text: 'home_block_banner',value: self::POSITION_HOME_BLOCK_BANNER},
        {text: 'home_service_banner',value: self::POSITION_HOME_SERVICE},
        {text: 'home_long_banner',value: self::POSITION_HOME_LONG_BANNER},
        {text: 'category_banner',value: self::POSITION_CATEGORY_BANNER}
      ]
    end
    
    after_save :recreate_thumbs
    
    def recreate_thumbs
			banners.each do |s|
				s.recreate_thumbs
			end
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
      
      query = query.limit(8).map{|category| {value: category.id, text: category.name} }
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
  end
end
