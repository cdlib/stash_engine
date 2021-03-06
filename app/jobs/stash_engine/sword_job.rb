require 'stash/sword'

module StashEngine
  class SwordJob
    include Concurrent::Async

    def self.submit_async(title:, doi:, zipfile:, resource_id:, sword_params:, request_host:, request_port:)
      result = SwordJob.new(
          title: title,
          doi: doi,
          zipfile: zipfile,
          resource_id: resource_id,
          sword_params: sword_params,
          request_host: request_host,
          request_port: request_port
      ).async.submit

      result.add_observer(ResultLoggingObserver.new(title: title, doi: doi))
    end

    def initialize(title:, doi:, zipfile:, resource_id:, sword_params:, request_host:, request_port:)
      super()
      @title = title
      @doi = doi
      @zipfile = zipfile
      @resource_id = resource_id
      @sword_params = sword_params
      @request_host = request_host
      @request_port = request_port
    end

    def submit
      log.debug("#{self.class}.submit() at #{Time.now}: title: '#{title}', doi: #{doi}, zipfile: #{zipfile}, resource_id: #{resource_id}, sword_params: #{sword_params}")
      request_msg = "Submitting #{zipfile} for '#{title}' (#{doi}) at #{Time.now}: #{(sword_params.map { |k, v| "#{k}: #{v}" }).join(', ')}"

      resource = nil
      begin
        resource = Resource.find(resource_id)
        resource.update_uri ? update(resource) : create(resource)
        resource.set_state('published')
        resource.update_version(zipfile)
        update_submission_log(resource_id: resource_id, request_msg: request_msg, response_msg: 'Success')
      rescue => e
        log.error(e)
        log.debug(e.backtrace.join("\n")) if e.backtrace

        update_submission_log(resource_id: resource_id, request_msg: request_msg, response_msg: "Failed: #{e}")

        if resource
          resource.set_state('error')
          if resource.update_uri
            UserMailer.update_failed(resource, title, request_host, request_port, e).deliver_now
          else
            UserMailer.create_failed(resource, title, request_host, request_port, e).deliver_now
          end
        end

        # TODO: Enable this (and don't raise) once we have ExceptionNotifier configured
        # ExceptionNotifier.notify_exception(e, data: {title: title, doi: doi, zipfile: zipfile, resource_id: resource_id, sword_params: sword_params})
        raise
      end
    end

    private

    attr_reader :title
    attr_reader :doi
    attr_reader :zipfile
    attr_reader :resource_id
    attr_reader :sword_params
    attr_reader :request_host
    attr_reader :request_port

    def log
      Rails.logger
    end

    def client
      @client ||= Stash::Sword::Client.new(logger: log, **sword_params)
    end

    def create(resource)
      log.debug("invoking create(doi: #{doi}, zipfile: #{zipfile}) for resource #{resource.id} (title: '#{title}')")
      receipt = client.create(doi: doi, zipfile: zipfile)
      log.debug("create(doi: #{doi}, zipfile: #{zipfile}) for resource #{resource.id} completed with em_iri #{receipt.em_iri}, edit_iri #{receipt.edit_iri}")
      resource.download_uri = receipt.em_iri
      resource.update_uri = receipt.edit_iri
      resource.save # save download and update URLs for this resource
      log.debug("resource #{resource.id} saved")
      UserMailer.create_succeeded(resource, title, request_host, request_port).deliver_now
    end

    def update(resource)
      update_uri = resource.update_uri
      log.debug("invoking update(edit_iri: #{update_uri}, zipfile: #{zipfile}) for resource #{resource.id} (title: '#{title}')")
      status = client.update(edit_iri: update_uri, zipfile: zipfile)
      log.debug("update(edit_iri: #{update_uri}, zipfile: #{zipfile}) for resource #{resource.id} completed with status #{status}")
      UserMailer.update_succeeded(resource, title, request_host, request_port).deliver_now
    end

    def update_submission_log(resource_id:, request_msg:, response_msg:)
      SubmissionLog.create(resource_id: resource_id, archive_submission_request: request_msg, archive_response: response_msg)
    end

  end

  class ResultLoggingObserver
    def log
      Rails.logger
    end

    attr_reader :title
    attr_reader :doi

    def initialize(title:, doi:)
      @doi = doi
      @title = title
    end

    def update(time, value, reason)
      reason ? log_failure(time, reason) : log_success(time, value)
    end

    def log_failure(time, reason)
      log.warn("SwordJob for '#{title}' (#{doi}) failed at #{time}: #{reason}")
    end

    def log_success(time, value)
      msg = value ? value.archive_response : 'nil'
      log.info("SwordJob for '#{title}' (#{doi}) completed at #{time}: #{msg}")
    end
  end
end
