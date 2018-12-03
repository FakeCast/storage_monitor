require_relative 'RU3PAR.rb'
require_relative 'influxdb_connection.rb'

collect_3par = TriPar.new
collect_3par.ip = ARGV[0]
collect_3par.username = '3paradm'

@end_date =  Time.now.to_i * 1000
@start_date = (@end_date - 600000)
@array_id = collect_3par.get_array_name

def insert_metrics(measurement_name, metrics, additional_tags = {})
  metrics.each do |key, value|
    next if value.nil?
    tags = { 'S/N': @array_id }
    tags.merge!(additional_tags)
    time = Time.now.to_i * 1000
    values = { key.to_s => value, 'time': time }
    InfluxDatabase.insert(measurement_name, tags, values)
    puts values
  end
end

collect_3par.get_volume_metrics.each do |key, metric|
 insert_metrics('Volume', metric, {hostname: metric[:host].to_s, lun_name: metric[:lun_name].to_s} )
end

collect_3par.get_port_list.each do |port|
 metric = collect_3par.get_port_metrics(port)
 insert_metrics('Port', metric, {port: port})
end

['NL', 'FC', 'SSD'].each do |disktype|
  metrics = collect_3par.get_array_capacity(disktype)
  insert_metrics('Array', metrics, {disktype: disktype})
end
