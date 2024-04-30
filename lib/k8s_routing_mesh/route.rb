# frozen_string_literal: true

require 'ipaddr'

module K8sRoutingMesh
  class Route
    attr_accessor :target, :interface, :nexthop, :metric

    def initialize(target, interface: nil, nexthop: nil, metric: nil)
      @target = target
      @interface = interface
      @nexthop = nexthop
      @metric = metric
    end

    def ==(other)
      return false unless self.class == other.class

      interface == other.interface && target == other.target
    end

    # rubocop:disable Metrics/AbcSize
    def to_s
      components = []
      components << target unless target.is_a? IPAddr
      components << "#{target}/#{target.prefix}" if target.is_a? IPAddr
      components += ['via', nexthop] if nexthop
      components += ['dev', interface] if interface
      components += ['metric', metric] if metric
      components.join ' '
    end
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def self.parse(line)
      components = line.split
      target = components.shift
      target = IPAddr.new(target) unless target == 'default'

      args = {}
      while components.any?
        component = components.shift.to_sym
        data = components.first

        case component
        when :dev
          args[:interface] = data
        when :via
          args[:nexthop] = IPAddr.new(data)
        when :metric
          args[:metric] = data.to_i
        # Route components without args
        when :linkdown
          next
        end
        components.shift
      end

      new(target, **args)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
