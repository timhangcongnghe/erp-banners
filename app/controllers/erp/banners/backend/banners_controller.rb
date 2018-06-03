module Erp
  module Banners
    module Backend
      class BannersController < Erp::Backend::BackendController
        before_action :set_banner, only: [:move_up, :move_down, :archive, :unarchive, :show, :edit, :update, :destroy]
        before_action :set_banners, only: [:delete_all, :archive_all, :unarchive_all]

        # GET /banners
        def list
          @banners = Banner.search(params).paginate(:page => params[:page], :per_page => 10)

          render layout: nil
        end

        # GET /banners/1
        def show
        end

        # GET /banners/new
        def new
          @banner = Banner.new

          if request.xhr?
            render '_form', layout: nil, locals: {banner: @banner}
          end
        end

        # GET /banners/1/edit
        def edit
        end

        # POST /banners
        def create
          @banner = Banner.new(banner_params)
          @banner.creator = current_user

          if @banner.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @banner.name,
                value: @banner.id
              }
            else
              redirect_to erp_banners.edit_backend_banner_path(@banner), notice: t('.success')
            end
          else
            if params.to_unsafe_hash['format'] == 'json'
              render '_form', layout: nil, locals: {banner: @banner}
            else
              render :new
            end
          end
        end

        # PATCH/PUT /banners/1
        def update
          if @banner.update(banner_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @banner.name,
                value: @banner.id
              }
            else
              redirect_to erp_banners.edit_backend_banner_path(@banner), notice: t('.success')
            end
          else
            render :edit
          end
        end

        # DELETE /banners/1
        def destroy
          @banner.destroy

          respond_to do |format|
            format.html { redirect_to erp_banners.backend_banners_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # Archive /banners/archive?id=1
        def archive
          @banner.archive

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # Unarchive /banners/unarchive?id=1
        def unarchive
          @banner.unarchive

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # DELETE /banners/delete_all?ids=1,2,3
        def delete_all
          @banners.destroy_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # Archive /banners/archive_all?ids=1,2,3
        def archive_all
          @banners.archive_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # Unarchive /banners/unarchive_all?ids=1,2,3
        def unarchive_all
          @banners.unarchive_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        def dataselect
          respond_to do |format|
            format.json {
              render json: Banner.dataselect(params[:keyword])
            }
          end
        end

        # Move up /banners/up?id=1
        def move_up
          @banner.move_up

          respond_to do |format|
          format.json {
            render json: {
            #'message': t('.success'),
            #'type': 'success'
            }
          }
          end
        end

        # Move down /banners/up?id=1
        def move_down
          @banner.move_down

          respond_to do |format|
          format.json {
            render json: {
            #'message': t('.success'),
            #'type': 'success'
            }
          }
          end
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_banner
            @banner = Banner.find(params[:id])
          end

          def set_banners
            @banners = Banner.where(id: params[:ids])
          end

          # Only allow a trusted parameter "white list" through.
          def banner_params
            params.fetch(:banner, {}).permit(:image_url, :name, :category_id, :link_url, :note)
          end
      end
    end
  end
end
