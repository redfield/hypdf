class HyPDF
  class Config
    attr_accessor :timeout
    def initialize
      @timeout = 60
    end
  end

  class << self
    attr_writer :config
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end
end
