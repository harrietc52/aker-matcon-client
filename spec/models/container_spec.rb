require "spec_helper"

describe MatconClient::Container do

  it_behaves_like "a model"

  it "has the correct endpoint" do
  	expect(subject.endpoint).to eq "containers"
  end

  context "when a container is initialised with slots" do
  	let (:container) do
  		MatconClient::Container.new(
  			slots: [
  				{ address: 'A:1' },
  				{ address: 'A:2', material: 'bananas' },
  				{ address: 'A:3', material: 'meringue' },
  			]
  		)
  	end

  	it "should have the given slots" do
  		slots = container.slots
  		expect(slots.length).to eql 3
  		expect(slots).to all(be_instance_of(MatconClient::Slot))
    end

    it "should have material_ids" do
    	expect(container.material_ids).to eq ['bananas', 'meringue']
	end
  end

end
