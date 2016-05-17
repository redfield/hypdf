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

    def jobstatus(job_id, options = {})
      options[:job_id] = job_id
      options[:user] ||= ENV["HYPDF_USER"]
      options[:password] ||= ENV["HYPDF_PASSWORD"]

      response = HTTMultiParty.get(
        "#{HyPDF::HOST}/jobstatus",
        query: options
      )
      case response.code
      when 200 then JSON.parse(response.body)
      when 400 then raise HyPDF::ContentRequired
      when 401 then raise HyPDF::AuthorizationRequired
      when 402 then raise HyPDF::PaymentRequired
      when 403 then raise HyPDF::S3AccessDenied
      when 404 then raise HyPDF::NoSuchBucket
      when 500 then raise HyPDF::InternalServerError
      end
    end

    def pdfinfo(file, options = {})
      options.merge!(file: File.new(file))
      JSON.parse(request('pdfinfo', options).body)
    end

    def editmeta(file, options = {})
      options.merge!(file: File.new(file))
      response = request('editmeta', options).body

      if options[:bucket].nil?
        {pdf: response}
      else
        JSON.parse(response, symbolize_names: true)
      end
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
      params.each_with_index do |param, index|
        options.merge!("file_#{index}" => file_for(param, index))
      end
      response = request('pdfunite', options).body

      if options[:bucket].nil?
        {pdf: response}
      else
        JSON.parse(response, symbolize_names: true)
      end
    end

    def readform(file, options = {})
      options.merge!(file: File.new(file))
      JSON.parse(request('readform', options).body)
    end

    def fillform(file, options = {})
      options.merge!(file: File.new(file))
      response = request('fillform', options).body

      if options[:bucket].nil?
        {pdf: response}
      else
        JSON.parse(response, symbolize_names: true)
      end
    end

    private

    def file_for(param, index)
      if pdf_header?(param)
        uploadable_file(param, "file_#{index}.pdf")
      else
        File.new(param)
      end
    end

    def pdf_header?(arg)
      arg.is_a?(String) && arg.start_with?('%PDF-')
    end

    def uploadable_file(string, filename)
      UploadIO.new(StringIO.new(string), 'application/octet-stream', filename)
    end

    def request(method, body)
      body[:user] ||= ENV["HYPDF_USER"]
      body[:password] ||= ENV["HYPDF_PASSWORD"]

      response = HTTMultiParty.post("#{HyPDF::HOST}/#{method}", body: body)
      case response.code
      when 200 then response
      when 400 then raise HyPDF::ContentRequired
      when 401 then raise HyPDF::AuthorizationRequired
      when 402 then raise HyPDF::PaymentRequired
      when 403 then raise HyPDF::S3AccessDenied
      when 404 then raise HyPDF::NoSuchBucket
      when 500 then raise HyPDF::InternalServerError
      end
    end

  end

end
