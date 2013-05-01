require 'net/http'
require "json"
require "hyperpdf/exceptions"
require 'httparty'

class HyperPDF

  # Initializes new HyperPDF object
  #
  # @param content [String] HTML document or URL
  # @param options [Hash] Authorization and PDF options
  # @option options [String] :user If provided, sets user name (by default uses ENV['HYPERPDF_USER'] variable)
  # @option options [String] :password If provided, sets user password (by default uses ENV['HYPERPDF_PASSWORD'] variable)
  #
  # Full list of PDF options see on {http://docs.heroku.com HyperPDF page}
  def initialize(content, options = {})
    raise HyperPDF::ContentRequired if content.nil? || content.empty?
    @content = content

    @options = options
    @user = @options.delete(:user) || ENV["HYPERPDF_USER"]
    @password = @options.delete(:password) || ENV["HYPERPDF_PASSWORD"]

    @request_body = { user: @user, password: @password, content: @content, options: @options }
  end

  # Generates PDF
  #
  # @return [String] Binary string containing the generated document or id of asynchronous job
  def get
    make_request.body
  end

  # Generates PDF and uploads it to AWS S3
  #
  # @param bucket [String] Your S3 bucket name
  # @param key [String] Name for generated file
  # @param public [Boolean] Sets public read access
  # @return [String] Url to generated document or id of asynchronous job
  def upload_to_s3(bucket, key, public = false)
    @request_body.merge!(bucket: bucket, key: key, public: public)
    resp = JSON.parse make_request.body
    resp["url"] || resp["id"]
  end

  private

  def make_request(options={})
    resp = HTTParty.post('https://api.hyper-pdf.com/pdf', options.merge(body: @request_body))
    case resp.code
    when 200 then resp
    when 400 then raise HyperPDF::ContentRequired
    when 401 then raise HyperPDF::AuthorizationRequired
    when 402 then raise HyperPDF::PaymentRequired
    when 404 then raise HyperPDF::NoSuchBucket
    when 500 then raise HyperPDF::InternalServerError
    end
  end

end
