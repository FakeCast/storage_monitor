class InfluxDatabase
  require "influxdb"

  def self.insert(measurement, tags, values)
    influxdb = InfluxDB::Client.new 'collect', username: 'admin', password: 'admin', precision: 's'
    influxdb.write_point(measurement,
      tags:  tags,
      values: values)
  end
end
