class VnxGetter
  attr_accessor :username, :password, :scope, :ip, :nav_path

  def pre_command
    "#{@nav_path}/naviseccli -user #{@username} -password #{@password} -scope #{@scope} -address #{@ip}"
  end

  def get_array_name
    IO.popen("#{pre_command} arrayname") {|x| x.gets.split(" ")[2]}
  end

  def get_storage_processor_ip(sp)
    IO.popen("#{pre_command} networkadmin -get -sp #{sp}").select {|x| x if x.include? 'Storage Processor IP Address:'}.join.split(' ').last.to_s
  end

  def get_ip_list
    {
      A: get_storage_processor_ip('A'),
      B: get_storage_processor_ip('B')
    }
  end

  def get_sp_metrics
    metrics = Hash.new
    IO.popen("#{pre_command} getall -sp").each_line do |x|
      metrics[:storage_processor] = x.split(" ").last.to_s if x.include? 'Storage Processor:'
      metrics[:percent_busy] = x.split(" ").last.to_f if x.include? 'Prct Busy:'
      metrics[:read_requests] = x.split(" ").last.to_f if x.include? 'Read_requests:'
      metrics[:write_requests] = x.split(" ").last.to_f if x.include? 'Write_requests:'
      metrics[:blocks_read] = x.split(" ").last.to_f if x.include? 'Blocks_read:'
      metrics[:blocks_written] = x.split(" ").last.to_f if x.include? 'Blocks_written:'
    end

    metrics
  end

  def get_cache_metrics
    metrics = Hash.new
    IO.popen("#{pre_command} cache -sp -info -perfData").each_line do |x|
      metrics[:read_hit_ratio] = x.split(" ").last.to_f if x.include? 'Read Hit Ratio'
      metrics[:write_hit_ratio] = x.split(" ").last.to_f if x.include? 'Write Hit Ratio'
      metrics[:dirty_cache_pages] = x.split(" ").last.to_f if x.include? 'Dirty Cache Pages (MB)'
    end

    metrics
  end

  def get_fastcache_metrics
    metrics = Hash.new
    IO.popen("#{pre_command} cache -fast -info").each_line do |x|
      metrics[:percent_dirty_spa] = x.split(" ").last.to_f if x.include? 'Percentage Dirty SPA: '
      metrics[:mbs_flushed_spa] = x.split(" ").last.to_f if x.include? 'MBs Flushed SPA'
      metrics[:percent_dirty_spb] = x.split(" ").last.to_f if x.include? 'Percentage Dirty SPB'
      metrics[:mbs_flushed_spb] = x.split(" ").last.to_f if x.include? 'MBs Flushed SPB'
    end

    metrics
  end

  def get_port_metrics
    metrics = Hash.new
    port_metric = Hash.new
    i = 0
    IO.popen("#{pre_command} port -list -reads -writes -bread -bwrite -qfull").each_line do |x|
      port_metric[:storage_processor] = x.split(" ").last.to_s if x.include? 'SP Name:'
      port_metric[:port_id] = x.split(" ").last.to_i if x.include? 'SP Port ID:'
      port_metric[:reads] = x.split(" ").last.to_f if x.include? 'Reads:'
      port_metric[:writes] = x.split(" ").last.to_f if x.include? 'Writes:'
      port_metric[:block_reads] = x.split(" ").last.to_f if x.include? 'Blocks Read:'
      port_metric[:block_written] = x.split(" ").last.to_f if x.include? 'Blocks Written:'
      port_metric[:queue_full] = x.split(" ").last.to_f if x.include? 'Queue Full/Busy:'
      if x.include? 'Queue'
        metrics[i] =  port_metric
        i += 1
        port_metric = Hash.new
      end
    end

    metrics
  end

  def get_pool_metrics
    metrics = Hash.new
    pool_metric = Hash.new
    i = 0
    IO.popen("#{pre_command} storagepool -list -availableCap").each_line do |x|
      pool_metric[:pool_name] = x.split(" ").last.to_s if x.include? 'Pool Name:'
      pool_metric[:pool_id] = x.split(" ").last.to_i if x.include? 'Pool ID:'
      pool_metric[:available_capacity] = x.split(" ").last.to_f if x.include? 'Available Capacity (GBs)'
      if x.include? 'Available Capacity (GBs)'
        metrics[i] = pool_metric
        i += 1
        pool_metric = Hash.new
      end
    end

    metrics
  end
end
