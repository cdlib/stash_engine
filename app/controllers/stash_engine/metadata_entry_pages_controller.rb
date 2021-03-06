require_dependency 'stash_engine/application_controller'

module StashEngine
  class MetadataEntryPagesController < ApplicationController
    before_action :require_login
    before_action :resource_exist, except: [:metadata_callback]
    before_action :require_resource_owner, except: [:metadata_callback]

    # GET/POST/PUT  /generals/find_or_create
    def find_or_create
      @resource = Resource.find(params[:resource_id])
      if @resource.current_resource_state == 'published'
        redirect_to metadata_entry_pages_new_version_path(resource_id: params[:resource_id]) and return
      end
    end

    #create a new version of this resource before editing with find or create
    def new_version
      #create new version deep copy of most items
      @resource = Resource.find(params[:resource_id])
      if @resource.identifier.has_in_progress?
        id = @resource.identifier.in_progress_version.id
        redirect_to metadata_entry_pages_find_or_create_path(resource_id: id) and return
      end
      @new_res = @resource.amoeba_dup
      @new_res.save!
      copy_files(@new_res, @resource)
      res_state = ResourceState.create(user_id: current_user.id, resource_state: 'in_progress', resource_id: @new_res.id)
      @new_res.current_resource_state_id = res_state.id
      @new_res.save!

      #redirect to find or create path
      redirect_to metadata_entry_pages_find_or_create_path(resource_id: @new_res.id)
    end

    def metadata_callback
      auth_hash = request.env['omniauth.auth']
      params = request.env['omniauth.params']
      path = request.env['omniauth.origin']
      creator = metadata_engine::Creator.new(resource_id: params['resource_id'],
                                             creator_first_name: auth_hash.info.first_name,
                                             creator_last_name: auth_hash.info.last_name,
                                             orcid_id: auth_hash.uid)
      creator.save
      redirect_to path
    end

    private

    def resource_exist
      @resource = Resource.find(params[:resource_id])
      if @resource.nil?
        redirect_to root_path, notice: "The dataset you are looking for does not exist."
      end
    end

    def require_resource_owner
      if current_user.id != @resource.user_id
        flash[:alert] = 'You do not have permission to modify this dataset.'
        redirect_to stash_engine.dashboard_path
      end
    end

    def copy_files(new_resource, resource)
      new_resource.file_uploads << resource.current_file_uploads.collect { |file| file.dup }
      if new_resource.file_uploads.any?
        new_resource.file_uploads.each do |file|
          file.resource_id = new_resource.id
          file.file_state = 'copied'
          file.save!
        end
      end
    end

  end
end
