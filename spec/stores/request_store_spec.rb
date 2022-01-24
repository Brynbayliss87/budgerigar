# frozen_string_literal: true

describe RequestStore do
  describe '#set' do
    context 'when the key does not exist' do
      it 'sets the key on the store' do
        described_class.instance.set('film', { 'Jumanji' => 'Robin_Williams' })
        expect(described_class.instance.store['film'].keys).to eq(['Jumanji'])
      end
    end

    context 'when the key does exist' do
      it 'merges the value hash into the parent key' do
        described_class.instance.set('film', { 'Jumanji' => 'Robin_Williams' })
        described_class.instance.set('film', { 'Toy_Story' => 'Tom_Hanks' })
        expect(described_class.instance.store['film'].keys).to eq(%w[Jumanji Toy_Story])
      end
    end
  end

  describe '#get' do
    context 'when the key exists' do
      it 'returns the result' do
        described_class.instance.set('film', { 'Jumanji' => 'Robin_Williams' })
        expect(described_class.instance.get('film', 'Jumanji')).to eq('Robin_Williams')
      end
    end

    context 'when the key does not exist' do
      it 'returns nil' do
        expect(described_class.instance.get('film', 'Cast_Away')).to be_nil
      end
    end
  end
end
