# Collect information from EMC
class Vnx
  attr_accessor :username, :password, :scope, :ip, :nav_path

  def pre_command
    "#{@nav_path}/naviseccli -user #{@username} " \
    "-password #{@password} -scope #{@scope} -address #{@ip}"
  end

  def array_name
    IO.popen("#{pre_command} arrayname") { |x| x.gets.split(' ')[2] }
  end

  def storage_processor_ip(storage_processor)
    IO.popen("#{pre_command} networkadmin -get -sp #{storage_processor}")
      .select { |x| x if x.include? 'Storage Processor IP Address:' }
      .join.split(' ').last.to_s
  end

  def ip_list
    {
      A: storage_processor_ip('A'),
      B: storage_processor_ip('B')
    }
  end

  def metric_filter(metric_list, filter, metric_type)
    metric = metric_list.select { |x| x.include? filter }.join.split(' ').last
    metric_type == 'Float' ? metric.to_f : metric.to_s
  end

  def sp_metrics
    output = IO.popen("#{pre_command} getall -sp").readlines.map(&:strip)
    {
      storage_processor: metric_filter(output, 'Storage Processor:', 'String'),
      percent_busy: metric_filter(output, 'Prct Busy:', 'Float'),
      read_requests: metric_filter(output,  'Read_requests:', 'Float'),
      write_requests: metric_filter(output, 'Write_requests:', 'Float'),
      blocks_read: metric_filter(output, 'Blocks_read:', 'Float'),
      blocks_written: metric_filter(output, 'Blocks_written:', 'Float')
    }
  end

  def cache_metrics
    output = IO.popen("#{pre_command} cache -sp -info -perfData")
               .readlines.map(&:strip)
    {
      read_hit_ratio: metric_filter(output, 'Read Hit Ratio', 'Float'),
      write_hit_ratio: metric_filter(output, 'Write Hit Ratio', 'Float'),
      dirty_cache_pages: metric_filter(output, 'Dirty Cache Pages (MB', 'Float')
    }
  end

  def fastcache_metrics
    output = IO.popen("#{pre_command} cache -fast -info").readlines.map(&:strip)
    {
      percent_dirty_spa: metric_filter(output, 'Percentage Dirty SPA', 'Float'),
      mbs_flushed_spa: metric_filter(output, 'MBs Flushed SPA', 'Float'),
      percent_dirty_spb: metric_filter(output, 'Percentage Dirty SPB', 'Float'),
      mbs_flushed_spb: metric_filter(output, 'MBs Flushed SPB', 'Float')
    }
  end

  def port_metrics
    metrics = {}
    port_metric = {}
    i = 0
    IO.popen("#{pre_command} port -list -reads -writes -bread -bwrite -qfull").each_line do |x|
      port_metric[:storage_processor] = x.split(' ').last.to_s if x.include? 'SP Name:'
      port_metric[:port_id] = x.split(' ').last.to_i if x.include? 'SP Port ID:'
      port_metric[:reads] = x.split(' ').last.to_f if x.include? 'Reads:'
      port_metric[:writes] = x.split(' ').last.to_f if x.include? 'Writes:'
      port_metric[:block_reads] = x.split(' ').last.to_f if x.include? 'Blocks Read:'
      port_metric[:block_written] = x.split(' ').last.to_f if x.include? 'Blocks Written:'
      port_metric[:queue_full] = x.split(' ').last.to_f if x.include? 'Queue Full/Busy:'
      if x.include? 'Queue'
        metrics[i] = port_metric
        i += 1
        port_metric = {}
      end
    end

    metrics
  end

  def pool_metrics
    metrics = {}
    pool_metric = {}
    i = 0
    IO.popen("#{pre_command} storagepool -list -availableCap").each_line do |x|
      pool_metric[:pool_name] = x.split(' ').last.to_s if x.include? 'Pool Name:'
      pool_metric[:pool_id] = x.split(' ').last.to_i if x.include? 'Pool ID:'
      pool_metric[:available_capacity] = x.split(' ').last.to_f if x.include? 'Available Capacity (GBs)'
      if x.include? 'Available Capacity (GBs)'
        metrics[i] = pool_metric
        i += 1
        pool_metric = {}
      end
    end

    metrics
  end
end
