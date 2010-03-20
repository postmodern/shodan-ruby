require 'shodan/countries'

require 'spec_helper'

describe Countries do
  it "should enumerate over all Country names and ISO 3166-1993 Codes" do
    Countries.each do |name,code|
      name.should_not be_empty

      code.length.should == 2
    end
  end
end
