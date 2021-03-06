module StashEngine
  class Identifier < ActiveRecord::Base
    has_many :resources, :class_name => 'StashEngine::Resource'
    def view_count
      ResourceUsage.joins(resource: :identifier ).
          where("stash_engine_identifiers.identifier = ? AND stash_engine_identifiers.identifier_type = ?",
                identifier, identifier_type).sum(:views)
    end

    def download_count
      ResourceUsage.joins(resource: :identifier ).
          where("stash_engine_identifiers.identifier = ? AND stash_engine_identifiers.identifier_type = ?",
                identifier, identifier_type).sum(:downloads)
    end

    # this returns a resource object for the last version
    def last_submitted_version
      submitted = self.resources.submitted
      submitted.by_version_desc.first
    end

    def in_progress_version
      self.resources.in_progress.first
    end

    # returns true if there is an in progress version
    def has_in_progress?
      self.resources.in_progress.count > 0
    end

  end
end
