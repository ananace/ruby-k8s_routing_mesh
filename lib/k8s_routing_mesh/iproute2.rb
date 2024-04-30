# frozen_string_literal: true

require 'open3'

require_relative 'interface'
require_relative 'route'

module K8sRoutingMesh
  class IPRoute2
    class << self
      def interfaces
        ifaces = []
        cur = nil

        ip('link', 'show').each_line do |line|
          matches = IP_IFACE_REX.match(line)
          if matches
            ifaces << cur if cur
            cur = Interface.new matches['name'], flags: matches['flags']
            cur.parse(matches['components'])
          else
            cur.parse(line)
          end
        end

        ifaces << cur if cur
        ifaces
      end

      def routes(interface = nil, family: :ipv4)
        args = %w[route list]
        args += ['dev', interface] if interface
        case family
        when :ipv4
          args.unshift '-4'
        when :ipv6
          args.unshift '-6'
        else
          raise "Unknown IP family #{family.inspect}"
        end

        ip(*args).each_line.map do |route|
          route = Route.parse(route)
          route.interface = interface if interface

          route
        end
      end

      def add_route(interface, route)
        ip('route', 'add', route, 'dev', interface)
      end

      def del_route(interface, route)
        ip('route', 'del', route, 'dev', interface)
      end

      private

      IP_IFACE_REX = /^(?<id>\d+):\s*(?<name>[^:]+):\s*<(?<flags>[^>]+)>\s*(?<components>.+)/

      def ip(*args)
        puts "> ip #{args.join " "}"
        out, err, status = Open3.capture3('ip', *args)
        raise "IPRoute2 command failed: #{err}" unless status.success?

        out
      end
    end
  end
end
