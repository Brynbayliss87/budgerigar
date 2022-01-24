# frozen_string_literal: true

describe DbpediaClient do
  describe '.get' do
    subject { described_class.get(key, value) }

    let(:key) { 'film' }
    let(:value) { 'Saving_Private_Ryan' }
    let(:status) { true }
    let(:mock_resp) { double(:mock_resp, success?: status, body: mock_body) }

    before do
      allow(Faraday).to receive(:get).and_return(mock_resp)
    end

    context 'with a film' do
      let(:mock_body) do
        {
          "head": {
            "link": [],
            "vars": ['res']
          },
          "results": {
            "distinct": false,
            "ordered": true,
            "bindings": [
              {
                "res": {
                  "type": 'uri',
                  "value": 'http://dbpedia.org/resource/Tom_Hanks'
                }
              },
              { "res": {
                "type": 'uri',
                "value": 'http://dbpedia.org/resource/Tom_Sizemore'
              } }
            ]
          }
        }.to_json
      end

      it 'sends a film query' do
        expect(described_class).to receive(:film_query).with(value).and_call_original
        subject
      end

      it 'returns a list of actors from the film' do
        expect(subject).to eq(['Tom Hanks', 'Tom Sizemore'])
      end

      context 'when the request fails' do
        let(:status) { false }

        it 'raises an error' do
          expect { subject }.to raise_error(DbpediaClient::RequestError)
        end
      end
    end

    context 'with an actor' do
      let(:key) { 'actor' }
      let(:value) { 'Tom_Hanks' }
      let(:mock_body) do
        {
          "head": {
            "link": [],
            "vars": ['res']
          },
          "results": {
            "distinct": false,
            "ordered": true,
            "bindings": [
              {
                "res": {
                  "type": 'uri',
                  "value": 'http://dbpedia.org/resource/The_Ladykillers_(2004_film)'
                }
              },
              { "res": {
                "type": 'uri',
                "value": "http://dbpedia.org/resource/You've_Got_Mail"
              } }
            ]
          }
        }.to_json
      end

      it 'sends an actor query' do
        expect(described_class).to receive(:actor_query).with(value).and_call_original
        subject
      end

      it 'returns a list of films for the actor' do
        expect(subject).to eq(['The Ladykillers (2004 film)', "You've Got Mail"])
      end

      context 'when the request fails' do
        let(:status) { false }

        it 'raises an error' do
          expect { subject }.to raise_error(DbpediaClient::RequestError)
        end
      end
    end
  end
end
