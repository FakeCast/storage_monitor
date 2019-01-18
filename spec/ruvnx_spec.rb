require_relative '../ruvnx.rb'

describe Vnx do
  let(:scope) { 0 }
  let(:ip) { '' }
  let(:username) { '' }
  let(:password) { '' }
  let(:nav_path) { '' }

  before do
    @collect = Vnx.new
    @collect.username = username
    @collect.password = password
    @collect.scope = scope
    @collect.ip = ip
    @collect.nav_path = nav_path
  end

  describe '.pre_command' do
    it do
      expect(@collect.pre_command).to eq("#{nav_path}/naviseccli " \
      "-user #{username} -password #{password} -scope #{scope} -address #{ip}")
    end
  end

  describe '.array_name' do
    it { expect(@collect.array_name).to include('CKM') }
  end

  describe '.storage_processor_ip' do
    it { expect(@collect.storage_processor_ip('A')).to include(ip[0..6]) }
  end

  describe '.sp_metrics' do
    it do
      expect(@collect.sp_metrics).to include(
        :blocks_read,
        :blocks_written,
        :percent_busy,
        :read_requests,
        :storage_processor,
        :write_requests
      )
    end
  end

  describe '.cache_metrics' do
    it do
      expect(@collect.cache_metrics).to include(
        :read_hit_ratio,
        :write_hit_ratio,
        :dirty_cache_pages
      )
    end
  end

  describe '.fastcache_metrics' do
    it do
      expect(@collect.fastcache_metrics).to include(
        :mbs_flushed_spa,
        :mbs_flushed_spa,
        :percent_dirty_spa,
        :percent_dirty_spb
      )
    end
  end

  describe '.port_metrics' do
    it do
      expect(@collect.port_metrics[0]).to include(
        :block_reads,
        :block_written,
        :port_id,
        :queue_full
      )
    end
  end

  describe '.pool_metrics' do
    it do
      expect(@collect.pool_metrics[0]).to include(
        :available_capacity,
        :pool_id,
        :pool_name
      )
    end
  end
end
