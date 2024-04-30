# frozen_string_literal: true

require 'kubeclient'

module K8sRoutingMesh
  class Client
    attr_accessor :kubeclient_options, :namespace, :auth_options, :ssl_options, :server, :api_version,
                  :interval

    def self.instance
      @instance ||= Client.new
    end

    def in_cluster?
      # FIXME: Better detection, actually look for the necessary cluster components
      Dir.exist? '/var/run/secrets/kubernetes.io'
    end

    def run
      loop do
        # Update lease
        # Get other leases
        # Build route list

        sleep interval
      end
    end

    private

    def initialize
      @interval = 5

      @kubeclient_options = {}
      @auth_options = {}
      @ssl_options = {}

      @namespace = nil
      @server = nil
      @api_version = 'v1'

      @services = {}

      return unless in_cluster?

      @server = 'https://kubernetes.default.svc'
      @namespace ||= File.read('/var/run/secrets/kubernetes.io/serviceaccount/namespace')
      if @auth_options.empty?
        @auth_options = {
          bearer_token_file: '/var/run/secrets/kubernetes.io/serviceaccount/token'
        }
      end

      return unless File.exist?('/var/run/secrets/kubernetes.io/serviceaccount/ca.crt')

      @ssl_options[:ca_file] = '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'
    end

    def logger
      @logger ||= Logging::Logger[self]
    end

    def update(service, force: false)
      service = @services[service] unless service.is_a? Service

      old_endpoints = service.endpoints.dup
      service.last_update = Time.now
      service.update
      endpoints = service.endpoints

      return true if old_endpoints == endpoints && !force

      logger.info "Active endpoints have changed for #{service.name}, updating cluster data to #{service.to_subsets.to_json}"

      kubeclient.patch_endpoint(
        service.name,
        {
          metadata: {
            annotations: {
              TIMESTAMP_ANNOTATION => Time.now.to_s
            }
          },
          subsets: service.to_subsets
        },
        service.namespace || namespace
      )
    rescue StandardError => e
      raise e
    end

    def get_service(service)
      kubeclient.get_service(service.name, service.namespace || namespace)
    rescue Kubeclient::ResourceNotFoundError
      nil
    end

    def get_endpoint(service)
      kubeclient.get_endpoint(service.name, service.namespace || namespace)
    rescue Kubeclient::ResourceNotFoundError
      nil
    end

    def kubeclient
      @kubeclient ||= Kubeclient::Client.new(
        server,
        api_version,
        auth_options: auth_options,
        ssl_options: ssl_options,
        **kubeclient_options
      )
    end
  end
end
