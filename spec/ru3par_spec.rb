require_relative '../ru3par.rb'

describe TriPar do
  before do
    @collect = TriPar.new
    @collect.ip = '10.165.16.101'
    @collect.username = '3paradm'
  end

  describe '.array_name' do
    it { expect(@collect.array_name).to eq('2MK6040311') }
  end

  describe '.port_list' do
    it { expect(@collect.port_list).to be_an_instance_of(Array) }
  end

  describe '.volume_metrics' do
    it { expect(@collect.volume_metrics).to have_key(:'0') }
  end

  describe '.port_metrics' do
    it { expect(@collect.port_metrics('0:2:1')).to have_key(:busy) }
  end

  describe '.array_capacity' do
    it { expect(@collect.array_capacity('FC')).to have_key(:compress_ratio) }
  end
end
