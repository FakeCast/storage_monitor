require_relative 'vnxgetter.rb'
require_relative 'influxdb_connection.rb'
collect_vnx = VnxGetter.new

collect_vnx.username =
collect_vnx.password = 
collect_vnx.scope = 0
collect_vnx.ip = ARGV[0]
collect_vnx.nav_path = '/opt/Navisphere/bin'

@end_date =  Time.now.to_i * 1000
@start_date = (@end_date - 600000)
@host = ARGV[0]
@array_id = collect_vnx.get_array_name

def insert_metrics(measurement_name, metrics, additional_tags = {})
  metrics.each do |key, value|
    tags = { 'S/N': @array_id }
    tags.merge!(additional_tags)
    time = metrics['timestamp'].nil? ? Time.now.to_i * 1000 : metrics['timestamp']
    values = { key.to_s => value, 'time': time }
    InfluxDatabase.insert(measurement_name, tags, values)
  end
end

collect_vnx.get_ip_list.each do |key, ip|
 collect_vnx.ip = ip
 metrics = collect_vnx.get_sp_metrics
 insert_metrics('Array', metrics, {storage_processor: key})
   metrics = collect_vnx.get_sp_metrics
   insert_metrics('StorageProcessor', metrics, {storage_processor: key})
   metrics = collect_vnx.get_cache_metrics
   insert_metrics('Cache', metrics, {storage_processor: key.to_s})
end

metrics = collect_vnx.get_fastcache_metrics
insert_metrics('FastCache', metrics)

collect_vnx.get_port_metrics.each do |key, metric|
 insert_metrics('VNX Port', metric, {storage_processor: metric[:storage_processor].to_s, port_id: metric[:port_id].to_s })
end

collect_vnx.get_pool_metrics.each do |key, metric|
  insert_metrics('Pool', metric, {pool_id: metric[:pool_id]})
end
