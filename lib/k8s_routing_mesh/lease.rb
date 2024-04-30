# frozen_string_literal: true

module K8sRoutingMesh
  class Lease
    attr_accessor :holder, :duration, :renewed_at

    def initialize(holder:, duration:, renewed_at:)
      @holder = holder
      @duration = duration
      @renewed_at = renewed_at
    end

    def valid?
      renewed_at + duration < Time.now
    end

    def to_json(*params)
      {
        holderIdentity: holder,
        leaseDuratinoSeconds: duration,
        renewTime: renewed_at.to_i * 1_000_000 + renewed_at.usec
      }.compact.to_json(*params)
    end
  end
end
