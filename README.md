# EMC Vmax/EMC VNX/ HP 3PAR / Monitor Toolkit (Ruby)
EMC Vmax/VNX  and HP 3PAR Monitoring using InfluxDB and Grafana

InfluxDB Time-Series https://www.influxdata.com/

InfluxDB GEM https://github.com/influxdata/influxdb-ruby
```
gem install influxdb
```
Grafana for visualization: https://grafana.com/

## References
https://github.com/stevenctong/vmax_monitoring - Used as reference to develop the code in Ruby
https://github.com/ciarams87/PyU4V - I got many problems trying to install some python libraries on my Linux machine, so I decided to recode some functions from PyU4V in Ruby.

## ruvnx.rb
  Script that run commands via navseccli on VNX array's to get performance data

## vnx_monitoring.rb
  File that make the requests, parse data and put in InfluxDB

  You must initialize a new instance of the VnxGetter class and set the follow attributes:
  ```
  collect_vnx = VnxGetter.new
  collect_vnx.username =
  collect_vnx.password =
  collect_vnx.scope = 0
  collect_vnx.ip = ARGV[0]
  collect_vnx.nav_path = '/opt/Navisphere/bin' #Path of Navseccli in your system
  ```

  Usage:
  ```
  ruby vnx_monitoring.rb <vnxip>
  ```

## RU3PAR.rb
  Script that run commands using the CLI from 3PAR

  First you need to add your public key using the following command :
  ```
  setsshkey -add
  ```

### 3par_monitoring.rb
  This file make the requests using RU3PAR.rb to each 3Par Array and insert into InfluxDB

  It have a feature where you can collect data from a 3Par connected to another machine in yout network. To make it works you must provide the second argument on the command call and set the "remote_username" param.

  You must initiate a new instance of RU3PAR class and set the follow attributes:
  ```
  collect_3par = TriPar.new
  collect_3par.ip = ARGV[0]
  collect_3par.username = <3parusername>
  collect_3par.remote = ARGV[1]
  collect_3par.remote_username = <remotemachineusername>
  ```

  Usage:
  ```
  ruby 3par_monitoring.rb <3parip>
  ```

  Or if you are trying to get data from a 3PAR conected to other machine
  ```
   ruby 3par_monitoring.rb <remotemachineip> <3parip>
  ```

## U4V.rb
  Dell/EMC Have developed a module called PyU4V as a solution to make requests to the Unisphere API, unfortunattely Ruby don't have a gem that can realize the same, so I recoded some functions from PyU4V in Ruby

## unisphere_rest.rb (Unisphere API Requester)
  Used to request the Unisphere Api.

  Before start, you need to configure the header section that authenticate with Unisphere.
  ```
    @header = {
    'Authorization' => '%ENCODED AUTHORIZATION%',
    'Content-Type' => 'application/json',
    'Accept' => 'application/json'
  }
```
  Replace '%ENCODED AUTHORIZATION%' with your username/password encoded in Base64.

## influxdb_connection.rb (InfluxDB Configuration)
Replace the line following with  your DB name (collect), username (admin) and password (admin).
```
  influxdb = InfluxDB::Client.new 'collect', username: 'admin', password: 'admin', precision: 's'
```

## vmax_monitoring.rb
Here is the code of all the functions that collect the metrics to generate the dashboard.
The usage of the script is:
```
ruby vmax_monitoring.rb <hostname or hostip>
```

## dashboard*.json
Grafana dashboard exported in json format.


## Grafana Dashboard Screenshot
### VMAX
![alt text](https://raw.githubusercontent.com/FakeCast/vmax_monitor/master/dashboard.PNG)
![alt text](https://raw.githubusercontent.com/FakeCast/vmax_monitor/master/storagegroup.PNG)
![alt text](https://raw.githubusercontent.com/FakeCast/vmax_monitor/master/hostmetric.PNG)
![alt text](https://raw.githubusercontent.com/FakeCast/vmax_monitor/master/end.png)

### VNX
![alt text](https://raw.githubusercontent.com/FakeCast/vmax_monitor/master/vnx_dashboard.png)

### 3PAR
![alt text](https://raw.githubusercontent.com/FakeCast/vmax_monitor/master/3par_dashboard.png)

