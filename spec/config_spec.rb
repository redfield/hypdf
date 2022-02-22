require 'spec_helper'

describe HyPDF::Config do
  describe "Config#timeout" do
    it 'will default to 60' do
      expect(HyPDF.config.timeout).to eq 60
    end

    it 'can be changed to 5 seconds' do
      HyPDF.configure {|c| c.timeout = 5 }
      expect(HyPDF.config.timeout).to eq 5
    end
  end
end
