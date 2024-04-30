# frozen_string_literal: true

require_relative 'iproute2'

module K8sRoutingMesh
  class Interface
    attr_reader :name, :attached, :flags, :state, :link, :mtu

    def initialize(name, flags: nil)
      @name = name
      @name, @attached = @name.split('@') if @name.include? '@'

      @flags = flags&.downcase&.split(',')&.map(&:to_sym) || []
    end

    def to_s
      name
    end

    def up?
      @flags.include? :up
    end

    def lower_up?
      @flags.include? :lower_up
    end

    def routes
      IPRoute2.routes(name, family: :ipv4) + IPRoute2.routes(name, family: :ipv6)
    end

    # rubocop:disable Metrics/MethodLength
    def parse(line)
      components = line.split
      while components.any?
        component = components.shift.to_sym
        data = components.first

        case component
        when %r{/}
          @link = component.to_s.split('/').last.to_sym
          @mac = data
        when :mtu
          @mtu = data.to_i
        when :state
          @state = data.downcase.to_sym
        end
        components.shift
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
