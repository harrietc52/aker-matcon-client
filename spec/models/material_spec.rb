require "spec_helper"

describe MatconClient::Models::Material do

  it_behaves_like "a model"

  it "has the correct endpoint" do
    expect(subject.endpoint).to eq "materials"
  end

end
