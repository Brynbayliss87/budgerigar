# frozen_string_literal: true

describe Budgerigar do
  let(:app) { Budgerigar.new }

  context 'GET to /' do
    context 'with an invalid param' do
      let(:response) { get '/?director=Ridley_Scott' }

      it 'returns a 400' do
        expect(response.status).to eq(400)
      end
    end

    context 'with too many params' do
      let(:response) { get "/?actor=Tom_Hanks&film=The_'Burbs" }

      it 'returns a 400' do
        expect(response.status).to eq(400)
      end
    end

    context 'with an actor query' do
      let(:response) { get '/?actor=Tom_Hanks' }

      before do
        allow(DbpediaClient).to receive(:get).with('actor', 'Tom_Hanks')
                                             .and_return(["The 'Burbs", 'Toy Story'])
      end

      it 'returns a list of the actors films' do
        expect(response.body).to eq({ 'films' => ["The 'Burbs", 'Toy Story'] }.to_json)
      end

      context 'when the response is cached' do
        before do
          RequestStore.instance.set('actor', { 'Tom_Hanks' => ["The 'Burbs", 'Toy Story'] })
        end

        it 'does not make a request' do
          expect(DbpediaClient).not_to receive(:get).with('actor', 'Tom_Hanks')
        end
      end
    end

    context 'with a film query' do
      let(:response) { get "/?film=The_'Burbs" }

      before do
        allow(DbpediaClient).to receive(:get).with('film', "The_'Burbs")
                                             .and_return(['Tom Hanks'])
      end

      it 'returns a list of the films cast' do
        expect(response.body).to eq({ 'actors' => ['Tom Hanks'] }.to_json)
      end

      context 'when the response is cached' do
        before do
          RequestStore.instance.set('film', { "The_'Burbs" => ['Tom Hanks'] })
        end

        it 'does not make a request' do
          expect(DbpediaClient).not_to receive(:get).with('film', "The_'Burbs")
        end
      end

      context 'if there is an error with the dbpedia request' do
        before do
          allow(DbpediaClient).to receive(:get).and_raise(DbpediaClient::RequestError)
        end

        it 'returns a 500' do
          expect(response.status).to eq(500)
        end
      end
    end
  end
end
