require 'spec_helper'
require 'environment' if File.exists?(File.expand_path('../environment.rb', __FILE__)) # sets HYPDF_USER and HYPDF_PASSWORD environment variables

describe HyPDF do
  it 'should have a version number' do
    expect(HyPDF::VERSION).to_not be_nil
  end

  let(:html) { '<!DOCTYPE html><html><head></head><body>This is some text</body></html>' }
  let(:hypdf) { HyPDF.htmltopdf(html, test: true) }

  it 'should create pdf from html' do
    expect(hypdf).to include(pages: 1)
  end

  let(:pdf) { hypdf[:pdf].force_encoding('UTF-8') }

  it 'should concatenate two pdfs' do
    expect(HyPDF.pdfunite(pdf, pdf, test: true)).to have_key(:pdf)
  end
end
