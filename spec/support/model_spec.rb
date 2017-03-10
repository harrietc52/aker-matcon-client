RSpec.shared_examples "a model" do

  let(:response_with_items) do
    instance_double("Faraday::Response", body: {
      "_items": [
          {
              "_updated": "Mon, 23 Jan 2017 09:53:00 GMT",
              "gender": "male",
              "_links": {
                  "self": {
                      "href": "materials/a341279d-7dde-472a-9b74-bb2612ee9977",
                      "title": "Material"
                  }
              },
              "donor_id": "asdf",
              "phenotype": "asdf",
              "supplier_name": "asdf",
              "common_name": "asdf",
              "_created": "Mon, 23 Jan 2017 09:53:00 GMT",
              "_id": "a341279d-7dde-472a-9b74-bb2612ee9977"
          },
          {
              "_updated": "Mon, 30 Jan 2017 15:33:12 GMT",
              "gender": "male",
              "_links": {
                  "self": {
                      "href": "materials/d2eb2d4e-c772-428c-ba64-68ec87fa9741",
                      "title": "Material"
                  }
              },
              "donor_id": "sdaf",
              "phenotype": "sadf",
              "supplier_name": "adsf",
              "common_name": "sadf",
              "_created": "Mon, 30 Jan 2017 14:21:37 GMT",
              "_id": "d2eb2d4e-c772-428c-ba64-68ec87fa9741"
          }
        ],
      "_links": {
          "self": {
              "href": "materials",
              "title": "materials"
          },
          "last": {
              "href": "materials?page=3",
              "title": "last page"
          },
          "parent": {
              "href": "/",
              "title": "home"
          },
          "next": {
              "href": "materials?page=2",
              "title": "next page"
          }
      },
      "_meta": {
          "max_results": 25,
          "total": 2,
          "page": 1
      }
    })
  end

	describe '#new' do

    it 'can be instantiated with dynamic attributes' do
      material = described_class.new(name: 'pikachu', colour: 'yellow')

      expect(material.name).to eql('pikachu')
      expect(material.colour).to eql('yellow')

      material.name = 'charizard'
      material.colour = 'red'

      expect(material.name).to eql('charizard')
      expect(material.colour).to eql('red')
    end

    it 'can be instantiated with dynamic nested attributes' do
      material = described_class.new(name: 'pikachu', meta: { 'fight_wins': 11 })

      expect(material.meta).to eq({ 'fight_wins' => 11 })
    end

  end

  describe 'deserialization' do

    it 'can be have its attributes set from json' do
      json = { name: 'pikachu', colour: 'yellow'}.to_json

      material = described_class.from_json(json)

      expect(material.name).to eql('pikachu')
      expect(material.colour).to eql('yellow')
    end

  end

  describe 'serialization' do

    it 'can serialize its attributes to json' do
      json = { name: 'pikachu', colour: 'yellow'}.to_json
      material = described_class.new(name: 'pikachu', colour: 'yellow')
      expect(material.to_json).to eql(json)
    end
  end

  describe 'querying' do

    it 'should forward the methods of query onto it' do
      expect(described_class).to respond_to(:page)
      expect(described_class).to respond_to(:limit)
      expect(described_class).to respond_to(:order)
      expect(described_class).to respond_to(:where)
      expect(described_class).to respond_to(:projection)
      expect(described_class).to respond_to(:embed)
    end

  end

  describe '#find' do
    it 'can find a model with a given id' do
      expect(described_class.connection).to receive(:run).with(:get, described_class.endpoint+'/123', {}, {}).and_return(instance_double('Faraday::Response', body: { _id: '123' }))
      m = described_class.find('123')
      expect(m).to be_instance_of(described_class)
      expect(m.id).to eq '123'
    end
  end

  describe '#create' do
    it 'can create a model (including saving it on the server)' do
      body = { gender: 'female' }
      expect(described_class.connection).to receive(:run).with(:post, described_class.endpoint, body, {}).and_return(instance_double('Faraday::Response', body: { _id: '123', gender: 'female' }))

      m = described_class.create(body)
      expect(m).to be_instance_of(described_class)
    end
  end

  describe '#persisted?' do

    context 'when model has not been saved' do
      it 'returns false' do
        model = described_class.new
        expect(model.persisted?).to be(false)
      end
    end

    context 'when model has been saved' do
      it 'returns true' do
        model = described_class.new
        model._id = '123'
        expect(model.persisted?).to be(true)
      end
    end

  end

  describe '#save' do
    context 'when model is already persisted' do
      it 'sends a PUT and updates the current model' do
        body = { _id: '123', gender: 'female' }
        expect(described_class.connection).to receive(:run)
                                                .with(:put, described_class.endpoint + '/' + body[:_id], body, {})
                                                .and_return(instance_double('Faraday::Response', body: { _id: '123', gender: 'female' }))

        model = described_class.new(_id: '123', gender: 'male')
        model.gender = 'female'
        model.save
      end
    end

    context 'when model is not persisted' do
      it 'sends a POST and updates the current model' do
        body = { gender: 'female' }
        expect(described_class.connection).to receive(:run)
                                                .with(:post, described_class.endpoint, body, {})
                                                .and_return(instance_double('Faraday::Response', body: { _id: '123', gender: 'female' }))

        model = described_class.new(gender: 'female')
        model.save
        expect(model.id).to eq('123')
        expect(model.persisted?).to be(true)
      end
    end
  end

  describe '#destroy' do
    context 'when model is already persisted' do
      it 'sends a DELETE and deletes the current model' do
        body = { _id: '123'}
        expect(described_class.connection).to receive(:run)
                                                .with(:delete, described_class.endpoint + '/' + body[:_id], {}, {})
                                                .and_return(instance_double('Faraday::Response', body: {}))
        model = described_class.new(_id: '123')
        model.destroy
        expect(model.frozen?).to be true
      end
    end

    context 'when calling as a class method' do
      it "sends a DELETE" do
        body = { _id: '123'}
        expect(described_class.connection).to receive(:run)
                                                  .with(:delete, described_class.endpoint + '/' + body[:_id], {}, {})
                                                  .and_return(instance_double('Faraday::Response', body: {}))
        described_class.destroy(body[:_id])
      end
    end
  end

  describe '#all' do
    it 'returns the first page of the described class' do
      expect(described_class.connection).to receive(:run)
                                                  .with(:get, described_class.endpoint, {}, {})
                                                  .and_return(response_with_items)
      expect(described_class.all).to be_instance_of MatconClient::ResultSet
    end
  end

  describe '#==' do
    context 'when two models of same id and same class' do
      it 'returns true' do
        model1 = described_class.new(_id: '123')
        model2 = described_class.new(_id: '123')
        expect(model1 == model2).to be true
      end
    end
    context 'when two models of different id and same class' do
      it 'returns false' do
        model1 = described_class.new(_id: '123')
        model2 = described_class.new(_id: '234')
        expect(model1 == model2).to be false
      end
    end
    context 'when two models of same id and different class' do
      it 'returns false' do
        model1 = described_class.new(_id: '123')
        model2 = double('Model', id: '123')
        expect(model1 == model2).to be false
      end
    end
  end
end