require 'spec_helper'

describe HyPDF do
  it 'should have a version number' do
    HyPDF::VERSION.should_not be_nil
  end
end
