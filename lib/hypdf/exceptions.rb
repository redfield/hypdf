class HyPDF

  class ContentRequired < ArgumentError; end

  class AuthorizationRequired < StandardError; end

  class PaymentRequired < StandardError; end

  class NoSuchBucket < StandardError; end

  class InternalServerError < StandardError; end

end
