require "json"
require "hypdf/exceptions"
require 'httmultiparty'

class HyPDF

  HOST = 'https://www.hypdf.com'

  class << self

    def htmltopdf(content, options = {})
      raise HyPDF::ContentRequired if content.nil? || content.empty?
      options[:content] = content
      response = request('htmltopdf', options)

      result = {
        pages: response.headers['hypdf-pages'].to_i,
        page_size: response.headers['hypdf-page-size'],
        pdf_version: response.headers['hypdf-pdf-version'].to_f
      }

      if options[:callback].nil? && options[:bucket].nil?
        result.merge(pdf: response.body)
      else
        result.merge(JSON.parse(response.body, symbolize_names: true))
      end
    end

    def pdfinfo(file, options = {})
      options.merge!(file: File.new(file))
      JSON.parse(request('pdfinfo', options).body)
    end

    def pdftotext(file, options = {})
      options.merge!(file: File.new(file))
      JSON.parse(request('pdftotext', options).body, symbolize_names: true)
    end

    def pdfextract(file, options = {})
      options.merge!(file: File.new(file))
      response = request('pdfextract', options).body

      if options[:bucket].nil?
        {pdf: response}
      else
        JSON.parse(response, symbolize_names: true)
      end
    end

    def pdfunite(*params)
      options = params.last.is_a?(Hash) ? params.delete_at(-1) : {}
      params.each_with_index do |path, index|
        options.merge!("file_#{index}" => File.new(path))
      end
      response = request('pdfunite', options).body

      if options[:bucket].nil?
        {pdf: response}
      else
        JSON.parse(response, symbolize_names: true)
      end
    end

    private

    def request(method, body)
      body[:user] ||= ENV["HYPDF_USER"]
      body[:password] ||= ENV["HYPDF_PASSWORD"]

      response = HTTMultiParty.post("#{HyPDF::HOST}/#{method}", body: body)
      case response.code
      when 200 then response
      when 400 then raise HyPDF::ContentRequired
      when 401 then raise HyPDF::AuthorizationRequired
      when 402 then raise HyPDF::PaymentRequired
      when 404 then raise HyPDF::NoSuchBucket
      when 500 then raise HyPDF::InternalServerError
      end
    end

  end

  # Initializes new HyPDF object
  #
  # @param content [String] HTML document or URL
  # @param options [Hash] Authorization and PDF options
  # @option options [String] :user If provided, sets user name (by default uses ENV['HYPDF_USER'] variable)
  # @option options [String] :password If provided, sets user password (by default uses ENV['HYPDF_PASSWORD'] variable)
  #
  # Full list of PDF options see on {http://docs.heroku.com HyPDF page}
  def initialize(content, options = {})
    puts "Warning! This syntax is deprecated and will be removed in the future version, please visit https://devcenter.heroku.com/articles/hypdf for details."
    raise HyPDF::ContentRequired if content.nil? || content.empty?
    @content = content

    @options = options
    @user = @options.delete(:user) || ENV["HYPDF_USER"]
    @password = @options.delete(:password) || ENV["HYPDF_PASSWORD"]

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

  # Returns PDF meta information
  # @return [Hash] PDF meta information (nubmer of pages, page size and PDF version)
  def meta
    {
      pages: @last_headers['hypdf-pages'].to_i,
      page_size: @last_headers['hypdf-page-size'],
      pdf_version: @last_headers['hypdf-pdf-version'].to_f
    }
  end

  private

  def make_request(options={})
    resp = HTTParty.post('https://www.hypdf.com/pdf', options.merge(body: @request_body))
    @last_headers = resp.headers
    case resp.code
    when 200 then resp
    when 400 then raise HyPDF::ContentRequired
    when 401 then raise HyPDF::AuthorizationRequired
    when 402 then raise HyPDF::PaymentRequired
    when 404 then raise HyPDF::NoSuchBucket
    when 500 then raise HyPDF::InternalServerError
    end
  end

end
