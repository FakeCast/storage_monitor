class TriPar
  require 'net/ssh'
  attr_accessor :ip, :username, :remote

  def pre_command(cmd)
    unless @remote.nil?
      cmd = "ssh 3paradm@#{@remote} #{cmd}"
      @username = 'root'
    end
    Net::SSH.start(@ip, @username).exec!(cmd)
  end

  def get_array_name
    pre_command('showsys').split("\n")[2].split(" ")[4].to_s
  end

  def get_port_list
    pre_command('showport -nohdtot').split("\n").select {|x| x.include? 'FC'}.map! {|x| x.split(' ')[0]}
  end

  def get_volume_metrics
    metrics = Hash.new
    i = 0
    pre_command('statvlun -nohdtot -iter 1').each_line do |line|
      line_array = line.split(' ')
      lun_id = line_array[0]
      metrics[:"#{i}"] = {
        lun_name: line_array[1],
        host: line_array[2],
        io_per_second: line_array[5].to_i,
        kb_per_second: line_array[8].to_i,
        svt_ms: line_array[11].to_f,
        io_size: line_array[13].to_f
      }
      i += 1
    end

    metrics
  end

  def get_port_metrics(port)
    metrics = Hash.new
    data = pre_command("srstatport #{port} -port_type host -attime -nohdtot").split("\n").last.split(' ')
    if data.count > 5
      metrics[:io_read] = data[1].to_f
      metrics[:io_write] = data[2].to_f
      metrics[:kb_read] = data[4].to_f
      metrics[:kb_write] = data[5].to_f
      metrics[:busy] = data.last.to_f
    else
      metrics = {}
    end

    metrics
  end

  def get_array_capacity(disktype)
    metrics = Hash.new
    pre_command("showsys -space -devtype #{disktype}").each_line do |line|
      metrics[:total_usable_cap_gb] = line.split(':').last.strip.to_i / 1024 if line.include? 'Total Capacity'
      metrics[:total_allocated_cap_gb] = line.split(':').last.strip.to_i / 1024 if line.include? 'Allocated'
      metrics[:total_subscribed_cap_gb] = line.split(':').last.strip.to_i / 1024 if line.include? 'CPGs (TPVVs & TDVVs & CPVVs)'
      metrics[:compress_ratio] = line.split(':').last.strip.to_s if line.include? 'Compaction'
    end

    metrics
  end
end
