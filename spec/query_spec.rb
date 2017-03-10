require "spec_helper"

describe MatconClient::Query do

  before :each do
    @requestor = double("Requestor")
    @model = double("Model", requestor: @requestor)
    @query = MatconClient::Query.new(klass: @model)
  end

  describe '#to_s' do
    it 'returns an empty string if no parameters have been set' do
      expect(@query.to_s).to eql('')
    end
  end

  describe '#page' do

    let(:page) { @query.page(2) }

    it 'sets the page' do
      page
      expect(@query.to_s).to eql('page=2')
    end

    it 'returns the MatconClient::Query object' do
      expect(page).to eq(@query)
    end

  end

  describe '#limit' do

    let(:limit) { @query.limit(3) }

    it 'sets the max_results value' do
      limit
      expect(@query.to_s).to eql('max_results=3')
    end

    it 'returns the MatconClient::Query object' do
      expect(limit).to eql(@query)
    end
  end

  describe '#order' do

    context 'when a Hash is passed in' do

      it 'raises an error if value is not "asc" or "desc"' do
        expect { @query.order(city: :monkey) }.to raise_error(ArgumentError)
      end

      it 'sets the sort value' do
        @query.order(city: :asc, lastname: :desc)
        expect(@query.to_s).to eql("sort=city,-lastname")
      end

      it 'returns the MatconClient::Query object' do
        expect(@query.order(city: :asc, lastname: :desc)).to eql(@query)
      end

    end

    context 'when I pass a String' do

      it 'sets the sort value' do
        @query.order('city,-lastname')
        expect(@query.to_s).to eql('sort=city,-lastname')
      end
    end

  end

  describe '#where' do

    it 'sets the value of where' do
      @query.where(lastname: "Doe")
      expect(@query.to_s).to eql("where={\"lastname\":\"Doe\"}")
    end

    context 'when Hash has nested params' do

      it 'sets the value of "where" to a String with all its keys as Strings' do
        @query.where(born: { "$gte": "Wed, 25 Feb 1987 17:00:00 GMT"} )
        expect(@query.to_s).to eql("where={\"born\":{\"$gte\":\"Wed, 25 Feb 1987 17:00:00 GMT\"}}")
      end
    end

    it 'returns the MatconClient::Query object' do
      expect(@query.where(lastname: "Doe")).to eq(@query)
    end

  end

  describe '#projection' do

    it 'raises an error if value is an Integer and not equal to 1 or 0' do
      expect { @query.projection(firstname: 9) }.to raise_error(ArgumentError)
    end

    context 'when a Hash is passed in' do
      it 'sets the value of projection' do
        @query.projection(firstname: 1, lastname: true, born: false, address: 0)
        expect(@query.to_s).to eql("projection={\"firstname\":1,\"lastname\":1,\"born\":0,\"address\":0}")
      end
    end

    context 'when a String is passed in' do
      it 'sets the value of projection' do
        @query.projection('firstname, lastname')
        expect(@query.to_s).to eql("projection={\"firstname\":1,\"lastname\":1}")
      end
    end

    it 'returns the MatconClient::Query object' do
      expect(@query.projection(firstname: 1, lastname: true, born: false, address: 0)).to eq(@query)
    end

    it 'is aliased by #select' do
      expect(@query).to respond_to(:select)
    end

  end

  describe '#embeddable' do

    it 'raises an error if value is an Integer and not equal to 1 or 0' do
      expect { @query.embed(author: 9) }.to raise_error(ArgumentError)
    end

    context 'when a Hash is passed in' do
      it 'sets the value of embeddable' do
        @query.embed(author: 1)
        expect(@query.to_s).to eql("embeddable={\"author\":1}")
      end
    end

    context 'when a String is passed in' do
      it 'sets the value of embeddable' do
        @query.embed('author')
        expect(@query.to_s).to eql("embeddable={\"author\":1}")
      end
    end

    it 'returns the MatconClient::Query object' do
      expect(@query.embed(author: 1)).to eq(@query)
    end

    it 'is aliased by #include' do
      expect(@query).to respond_to(:include)
    end

  end

  describe 'chaining parameters' do

    it "returns a joined query string when chaining parameters" do
      @query.page(2)
            .limit(30)
            .order(city: :asc, name: :desc)
            .where(lastname: "Doe")
            .projection(firstname: true)
            .embed(author: 1)

      expect(@query.to_s).to eql("page=2&max_results=30&sort=city,-name&where={\"lastname\":\"Doe\"}&projection={\"firstname\":1}&embeddable={\"author\":1}")
    end

  end

  describe '#reset' do
    it 'sets params back to nil' do
      @query.page(2)
            .limit(30)
            .order(city: :asc, name: :desc)
            .where(lastname: "Doe")
            .projection(firstname: true)
            .embed(author: 1)

      @query.reset

      expect(@query.to_s).to eql('')
    end

    it 'returns the MatconClient::Query object' do
      expect(@query.reset).to eq(@query)
    end
  end

  describe '#each' do
    it 'should respond to the #each method call' do
      expect(@query).to respond_to(:each)
    end
  end

  describe '#result_set' do
    it 'should create a result set by calling the klass requestor with its query string' do
      expect(@requestor).to receive(:get).with(nil, { query: "page=2&max_results=30" })

      @query.page(2).limit(30).result_set
    end
  end

end
