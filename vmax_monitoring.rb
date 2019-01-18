require_relative 'u4v.rb'
require_relative 'influxdb_connection.rb'

@end_date =  Time.now.to_i * 1000
@start_date = (@end_date - 600000)
@host = ARGV[0]

def insert_metrics(measurement_name, metrics, array_id, additional_tags = {})
  metrics.each do |key, value|
    tags = { 'S/N': array_id }
    tags.merge!(additional_tags)
    time = metrics['timestamp'].nil? ? Time.now.to_i * 1000 : metrics['timestamp']
    values = { key.to_s => value, 'time': time }
    InfluxDatabase.insert(measurement_name, tags, values)
  end
end

U4V.array_list(@host).each do |array|
  array_id = array["symmetrixId"]
  array_metrics = U4V.array_metrics(array_id, @start_date, @end_date, @host)
  insert_metrics('Array', array_metrics, array_id)

  U4V.storage_group_list(array_id, @host).each do |storage_group|
    sg_id = storage_group["storageGroupId"]
    storage_group_metrics = U4V.storage_group_metrics(array_id, @start_date, @end_date, sg_id, @host)
    insert_metrics('Storage Group', storage_group_metrics, array_id, {"Storage Group": sg_id})
  end

  U4V.director_list(array_id, @host).each do |director_id|
    begin
      director_metrics = U4V.director_info(array_id, @start_date, @end_date, director_id, @host)
      director_tags = {"Director ID": director_id, "Director Type": director_metrics[:director_type]}
      insert_metrics('Director', director_metrics[:metrics], array_id, director_tags)
    rescue
      director_metrics = []
      director_tags = []
    end
  end

  U4V.port_group_list(array_id, @host).each do |port_group|
    port_group_id = port_group["portGroupId"]
    port_group_metrics = U4V.port_group_metrics(array_id, @start_date, @end_date, port_group_id, @host)
    insert_metrics('Port Group', port_group_metrics, array_id, {"Port Group": port_group_id})
  end

  U4V.host_list(array_id, @host).each do |initiator_group_id|
    begin
      ig_metrics = U4V.host_metrics(array_id, @start_date, @end_date, initiator_group_id, @host)
    rescue
      ig_metrics = {}
    end
    insert_metrics('Host', ig_metrics, array_id, {"Host": initiator_group_id})
  end

  U4V.srp_list(array_id, @host).each do |srp_id|
    U4V.srp_metrics(array_id, @host, srp_id)["srp"].each do |metric|
      array_free_capacity = metric["total_usable_cap_gb"] - metric["total_allocated_cap_gb"]
      array_free_percent = array_free_capacity / metric["total_usable_cap_gb"]

      srp_metrics = {
        array_free_capacity: array_free_capacity,
        array_free_percent: array_free_percent,
        total_usable_cap_gb: metric["total_usable_cap_gb"],
        total_allocated_cap_gb: metric["total_allocated_cap_gb"],
        total_subscribed_cap_gb: metric["total_subscribed_cap_gb"]
        }
      insert_metrics('SRP', srp_metrics, array_id, {"SRP": srp_id})
    end
  end

  alerts_count = Hash.new
  alerts_count = {
    alerts_critical_fatal: U4V.alert('FATAL', @host).count + U4V.alert('CRITICAL', @host).count,
    alerts_minor_warning: U4V.alert('WARNING', @host).count + U4V.alert('MINOR', @host).count,
    alerts_information: U4V.alert('INFORMATION', @host).count
  }
  insert_metrics('Alerts', alerts_count, array_id)
end
