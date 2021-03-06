# frozen_string_literal: true
require 'puppet/util/rpm_compare'

module Puppet::Util::Package::Version
  class Rpm < Numeric
    # provides Rpm parsing and comparison
    extend Puppet::Util::RpmCompare
    include Puppet::Util::RpmCompare
    include Comparable

    class ValidationFailure < ArgumentError; end

    def self.parse(ver)
      raise ValidationFailure unless ver.is_a?(String)
      version = rpm_parse_evr(ver)
      new(version[:epoch], version[:version], version[:release], version[:arch]).freeze
    end

    def to_s
      version_found = ''
      version_found += "#{@epoch}:"   if @epoch
      version_found += @version
      version_found += "-#{@release}" if @release
      version_found
    end
    alias inspect to_s

    def initialize(epoch, version, release, arch)
      @epoch   = epoch
      @version = version
      @release = release
      @arch    = arch
    end

    attr_reader :epoch, :version, :release, :arch

    def eql?(other)
      other.is_a?(self.class) &&
        @epoch.eql?(other.epoch) &&
        @version.eql?(other.version) &&
        @release.eql?(other.release) &&
        @arch.eql?(other.arch)
    end
    alias == eql?

    def <=>(other)
      raise ArgumentError, _("Cannot compare, as %{other} is not a Rpm Version") % { other: other } unless other.is_a?(self.class)

      cmp = @epoch <=> other.epoch
      if cmp == 0
        cmp = rpm_compareEVR(rpm_parse_evr(self.to_s), rpm_parse_evr(other.to_s))
      end
      cmp
    end

  end
end
