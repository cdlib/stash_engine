require_dependency 'stash_engine/application_controller'

module StashEngine
  class LandingController < ApplicationController
    def show
      render('not_available') && return if params[:id].blank?
      @type, @id = params[:id].split(':', 2)
      @identifiers = Identifier.where(identifier_type: @type).where(identifier: @id)
      render('not_available') && return if @identifiers.count < 1
      @id = @identifiers.first
      @resource = @id.last_submitted_version
      render('not_available') && return if @resource.blank?
      @resource_id = @resource.id
      @resource.increment_views
    end
  end
end
