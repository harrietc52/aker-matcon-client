require "spec_helper"

describe MatconClient::Slot do
	context "when initialised with just an address" do
		let (:slot) { MatconClient::Slot.new(address: 'A:1')}

		it "has an address" do
			expect(slot.address).to eq 'A:1'
		end

		it "sets material_id to nil" do
			expect(slot.material_id).to be nil
		end

		it "sets material to nil" do
			expect(slot.material).to be nil
		end

		it "should be empty" do
			expect(slot.empty?).to be true
		end
	end

	context "when initialised with an address and material is a string" do
		let (:slot) {MatconClient::Slot.new(address: 'A:1', material: '123')}

		it "has an address" do
			expect(slot.address).to eq 'A:1'
		end

		it "sets the correct material_id" do
			expect(slot.material_id).to eq '123'
		end

		it "should not be empty" do
			expect(slot.empty?).to be false
		end
	end

	context "when initialised with an address and material as a hash" do
		let (:material) do
			{
				"_updated": "Mon, 23 Jan 2017 09:53:00 GMT",
                "gender": "male",
                "donor_id": "asdf",
                "phenotype": "asdf",
                "supplier_name": "asdf",
                "common_name": "asdf",
                "_created": "Mon, 23 Jan 2017 09:53:00 GMT",
                "_id": "123"
			}
		end

		let (:slot) {MatconClient::Slot.new(address: 'A:1', material: material)}

		it "has an address" do
			expect(slot.address).to eq 'A:1'
		end

		it "sets the correct material_id from the hash" do
			expect(slot.material_id).to eq '123'
		end

		it "creates a material object from the hash" do
			expect(slot.material).to be_instance_of(MatconClient::Material)
		end

		it "should not be empty" do
			expect(slot.empty?).to be false
		end
	end
end







