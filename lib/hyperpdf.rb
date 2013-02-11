require 'net/http'
require "json"

require "hyperpdf/version"
require "hyperpdf/exceptions"

class HyperPDF

  def initialize(content, options = {})
    raise HyperPDF::ContentRequired if content.nil? || content.empty?
    @content = content

    @options = options
    @user = @options.delete(:user) || ENV["HYPERPDF_USER"]
    @password = @options.delete(:password) || ENV["HYPERPDF_PASSWORD"]

    #@uri = URI('http://localhost:3000')
    @uri = URI('http://192.168.0.103:3000')
    @req = Net::HTTP::Post.new('/pdf', {'Content-Type' => 'application/json'})
    @request_body = { user: @user, password: @password, content: @content, options: @options }
  end

  def get
    make_request.body
  end

  def upload_to_s3(bucket, key, public = false)
    @request_body.merge!(bucket: bucket, key: key, public: public)
    resp = JSON.parse make_request.body
    resp["url"]
  end

  private

  def make_request
    @req.body = @request_body.to_json
    resp = Net::HTTP.new(@uri.host, @uri.port).request(@req)

    if resp.is_a? Net::HTTPOK
      resp
    else
      case resp.code
      when "400" then raise HyperPDF::ContentRequired
      when "401" then raise HyperPDF::AuthorizationRequired
      when "402" then raise HyperPDF::PaymentRequired
      when "404" then raise HyperPDF::NoSuchBucket
      when "500" then raise HyperPDF::InternalServerError
      end
    end
  end

end
