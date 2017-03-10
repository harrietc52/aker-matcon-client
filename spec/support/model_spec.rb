RSpec.shared_examples "a model" do
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

end