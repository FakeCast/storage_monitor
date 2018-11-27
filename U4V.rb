require_relative 'unisphere_rest.rb'
require 'json'
class U4V

  def self.get_srp_list(array_id, host)
    payload = { symmetrixId: array_id }
    target_uri = "/sloprovisioning/symmetrix/#{array_id}/srp"
    srp = JSON.parse(UnisphereRest.univmax_get(host, '/univmax/restapi'+ target_uri))["srpId"]
    srp.nil? ? srp = [] : srp
  end

  def self.get_array_list(host)
    target_uri = "/performance/Array/keys"
    JSON.parse(UnisphereRest.univmax_get(host, '/univmax/restapi'+ target_uri))["arrayInfo"]
  end

  def self.get_host_list(array_id, host)
    payload = { symmetrixId: array_id }
    target_uri = "/sloprovisioning/symmetrix/#{array_id}/host"
    hosts = JSON.parse(UnisphereRest.univmax_get(host, '/univmax/restapi'+ target_uri))["hostId"]
    hosts.nil? ? hosts = [] : hosts
  end

  def self.get_storage_group_list(array_id, host)
    payload = { symmetrixId: array_id }
    target_uri = '/performance/StorageGroup/keys'
    JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['storageGroupInfo']
  end

  def self.get_be_director_list(array_id, host)
    payload = { symmetrixId: array_id }
    target_uri = '/performance/BEDirector/keys'
    JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['beDirectorInfo']
  end

  def self.get_fe_director_list(array_id, host)
    payload = { symmetrixId: array_id }
    target_uri = '/performance/FEDirector/keys'
    JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['feDirectorInfo']
  end

  def self.get_fe_port_list(array_id, host, director_id)
    payload = { symmetrixId: array_id, directorId: director_id }
    target_uri = '/performance/FEPort/keys'
    JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['fePortInfo']
  end

  def self.get_port_group_list(array_id, host)
    payload = { symmetrixId: array_id }
    target_uri = '/performance/PortGroup/keys'
    JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['portGroupInfo']
  end

  def self.get_director_list(array_id, host)
    target_uri = "/sloprovisioning/symmetrix/#{array_id}/director"
    director_list = JSON.parse(UnisphereRest.univmax_get(host, '/univmax/restapi'+ target_uri))["directorId"]
    director_list.nil? ? director_list = [] : director_list
  end

  def self.get_srp_metrics(array_id, host, srp_id)
    target_uri = "/sloprovisioning/symmetrix/#{array_id}/srp/#{srp_id}"
    JSON.parse(UnisphereRest.univmax_get(host, '/univmax/restapi'+ target_uri))
  end

  def self.get_alert(query, host)
    target_uri = "/84/system/alert?severity=#{query}"
    JSON.parse(UnisphereRest.univmax_get(host, '/univmax/restapi'+ target_uri))["alertId"]
  end

  def self.get_array_metrics(array_id, start_date, end_date, host)
    payload = {
      startDate: start_date,
      endDate: end_date,
      symmetrixId: array_id,
      metrics: [
        'OverallCompressionRatio', 'OverallEfficiencyRatio',
        'PercentVPSaved', 'VPSharedRatio', 'VPCompressionRatio',
        'VPEfficiencyRatio', 'PercentSnapshotSaved',
        'SnapshotSharedRatio', 'SnapshotCompressionRatio',
        'SnapshotEfficiencyRatio', 'CopySlotCount', 'HostIOs',
        'HostReads', 'HostWrites', 'PercentReads', 'PercentWrites',
        'PercentHit', 'HostMBs', 'HostMBReads', 'HostMBWritten',
        'HostMBWritten', 'FEReqs', 'FEReadReqs', 'FEWriteReqs',
        'BEIOs', 'BEReqs', 'BEReadReqs', 'BEWriteReqs',
        'SystemWPEvents', 'DeviceWPEvents', 'WPCount',
        'SystemMaxWPLimit', 'PercentCacheWP', 'AvgFallThruTime',
        'FEHitReqs', 'FEReadHitReqs', 'FEWriteHitReqs',
        'PrefetchedTracks', 'FEReadMissReqs', 'FEWriteMissReqs',
        'ReadResponseTime', 'WriteResponseTime',
        'OptimizedReadMisses', 'OptimizedMBReadMisses',
        'AvgOptimizedReadMissSize', 'QueueDepthUtilization',
        'InfoAlertCount', 'WarningAlertCount', 'CriticalAlertCount',
        'RDFA_WPCount', 'AllocatedCapacity', 'FE_Balance',
        'DA_Balance', 'DX_Balance', 'RDF_Balance', 'Cache_Balance',
        'SATA_Balance', 'FC_Balance', 'EFD_Balance'
      ]
    }
    target_uri = '/performance/Array/metrics'
    JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['resultList']['result'][0]
  end

  def self.get_host_metrics(array_id, start_date, end_date, initiator_group_id, host)
    payload = {
      startDate: start_date,
      endDate: end_date,
      symmetrixId: array_id,
      hostId: initiator_group_id,
      metrics: [
        'HostIOs', 'HostMBReads', 'HostMBWrites', 'Reads',
        'ResponseTime', 'ReadResponseTime', 'Writes',
        'WriteResponseTime', 'SyscallCount', 'MBs'
      ]
    }
    target_uri = '/performance/Host/metrics'
    JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['resultList']['result'][0]
  end

  def self.get_storage_group_metrics(array_id, start_date, end_date, storage_group_id, host)
    payload = {
      symmetrixId: array_id,
      endDate: end_date,
      dataFormat: 'Average',
      storageGroupId: storage_group_id,
      startDate: start_date,
      metrics: [
       'CriticalAlertCount', 'InfoAlertCount', 'WarningAlertCount',
       'AllocatedCapacity', 'TotalTracks', 'BEDiskReadResponseTime',
       'BEReadRequestTime', 'BEReadTaskTime', 'AvgIOSize',
       'AvgReadResponseTime6', 'AvgReadResponseTime7',
       'AvgReadSize', 'AvgWritePacedDelay', 'AvgWriteResponseTime6',
       'AvgWriteResponseTime7', 'AvgWriteSize', 'BEMBReads',
       'BEMBTransferred', 'BEMBWritten', 'BEPercentReads',
       'BEPercentWrites', 'BEPrefetchedTrackss', 'BEReadReqs',
       'BEPrefetchedTrackUsed', 'BEWriteReqs', 'CompressedTracks',
       'CompressionRatio', 'BlockSize', 'HostMBs', 'IODensity',
       'HostIOs', 'MaxWPThreshold', 'HostMBReads', 'HostMBWritten',
       'AvgOptimizedReadMissSize', 'OptimizedMBReadMisss',
       'OptimizedReadMisses', 'PercentCompressedTracks',
       'PercentHit', 'PercentMisses', 'PercentRandomIO',
       'PercentRandomReads', 'PercentRandomReadHit', 'PercentRead',
       'PercentRandomReadMiss', 'PercentRandomWrites',
       'PercentRandomWriteHit', 'PercentRandomWriteMiss',
       'PercentReadMiss', 'PercentReadHit', 'PercentSeqIO',
       'PercentSeqRead', 'PercentSeqReadHit', 'PercentSeqReadMiss',
       'PercentSeqWrites', 'PercentSeqWriteHit', 'PercentWrite',
       'PercentVPSpaceSaved', 'PercentWriteHit', 'RandomIOs',
       'PercentSeqWriteMiss', 'PercentWriteMiss', 'BEPrefetchedMBs',
       'HostIOLimitPercentTimeExceeded', 'RandomReadHits',
       'RandomReadMisses', 'RandomReads', 'RandomWriteHits',
       'RandomWriteMisses', 'RandomWrites', 'RdfMBRead',
       'RdfMBWritten', 'RdfReads', 'RdfReadHits', 'RdfResponseTime',
       'RDFRewrites', 'RdfWrites', 'HostReads', 'HostReadHits',
       'HostReadMisses', 'ReadResponseTimeCount1',
       'ReadResponseTimeCount2', 'ReadResponseTimeCount3',
       'ReadResponseTimeCount4', 'ReadResponseTimeCount5',
       'ReadResponseTimeCount6', 'ReadResponseTimeCount7',
       'RDFS_WriteResponseTime', 'ReadMissResponseTime',
       'ResponseTime', 'ReadResponseTime', 'WriteMissResponseTime',
       'WriteResponseTime', 'SeqReadHits', 'SeqReadMisses',
       'SeqReads', 'SeqWriteHits', 'SeqWriteMisses', 'SeqWrites',
       'Skew', 'SRDFA_MBSent', 'SRDFA_WriteReqs', 'SRDFS_MBSent',
       'SRDFS_WriteReqs', 'BEReqs', 'HostHits', 'HostMisses',
       'SeqIOs', 'WPCount', 'HostWrites', 'HostWriteHits',
       'HostWriteMisses', 'WritePacedDelay',
       'WriteResponseTimeCount1', 'WriteResponseTimeCount2',
       'WriteResponseTimeCount3', 'WriteResponseTimeCount4',
       'WriteResponseTimeCount5', 'WriteResponseTimeCount6',
       'WriteResponseTimeCount7'
      ]
    }
    target_uri = '/performance/StorageGroup/metrics'
    JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['resultList']['result'][0]
  end

  def self.get_port_group_metrics(array_id, start_date, end_date, port_group_id, host)
    payload = {
      symmetrixId: array_id,
      endDate: end_date,
      dataFormat: 'Average',
      portGroupId: port_group_id,
      startDate: start_date,
      metrics: [
        'Reads', 'Writes', 'IOs', 'MBRead', 'MBWritten', 'MBs',
        'AvgIOSize', 'PercentBusy'
      ]
    }
    target_uri = '/performance/PortGroup/metrics'
    JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['resultList']['result'][0]
  end

  def self.get_fe_director_metrics(array_id, start_date, end_date, director_id, host)
    target_uri = '/performance/FEDirector/metrics'
    payload = {
      symmetrixId: array_id,
      directorId: director_id,
      endDate: end_date,
      dataFormat: 'Average',
      metrics: [
        'AvgRDFSWriteResponseTime', 'AvgReadMissResponseTime',
        'AvgWPDiscTime', 'AvgTimePerSyscall', 'DeviceWPEvents',
        'HostMBs', 'HitReqs', 'HostIOs', 'MissReqs',
        'AvgOptimizedReadMissSize', 'OptimizedMBReadMisses',
        'OptimizedReadMisses', 'PercentBusy', 'PercentHitReqs',
        'PercentReadReqs', 'PercentReadReqHit',
        'PercentWriteReqs', 'PercentWriteReqHit',
        'QueueDepthUtilization', 'HostIOLimitIOs',
        'HostIOLimitMBs', 'ReadReqs', 'ReadHitReqs',
        'ReadMissReqs', 'Reqs', 'ReadResponseTime',
        'WriteResponseTime', 'SlotCollisions', 'SyscallCount',
        'Syscall_RDF_DirCounts', 'SyscallRemoteDirCounts',
        'SystemWPEvents', 'TotalReadCount', 'TotalWriteCount',
        'WriteReqs', 'WriteHitReqs', 'WriteMissReqs'
      ],
      startDate: start_date,
    }
     JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['resultList']['result'][0]
  end

  def self.get_be_director_metrics(array_id, start_date, end_date, director_id, host)
    target_uri = '/performance/BEDirector/metrics'
    payload = {
      symmetrixId: array_id,
      directorId: director_id,
      endDate: end_date,
      dataFormat: 'Average',
      metrics: [
        'AvgTimePerSyscall', 'CompressedMBs', 'CompressedReadMBs',
        'CompressedWriteMBs', 'CompressedReadReqs', 'CompressedReqs',
        'CompressedWriteReqs', 'IOs', 'MBs', 'MBRead', 'MBWritten',
        'PercentBusy', 'PercentBusyLogicalCore_0',
        'PercentBusyLogicalCore_1', 'PercentNonIOBusyLogicalCore_1',
        'PercentNonIOBusyLogicalCore_0', 'PercentNonIOBusy',
        'PrefetchedTracks', 'ReadReqs', 'Reqs', 'SyscallCount',
        'Syscall_RDF_DirCount', 'SyscallRemoteDirCount', 'WriteReqs'
      ],
      startDate: start_date
    }
    JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['resultList']['result'][0]
  end

  def self.get_director_info(array_id, start_date, end_date, director_id, host)
    be_director_uri = '/performance/BEDirector/metrics'
    fe_director_uri = '/performance/FEDirector/metrics'
    rdf_director_uri = '/performance/RDFDirector/metrics'
    im_director_uri = '/performance/IMDirector/metrics'
    eds_director_uri = '/performance/EDSDirector/metrics'

    payload_base  = {
      symmetrixId: array_id,
      directorId: director_id,
      endDate: end_date,
      dataFormat: 'Average',
      startDate: start_date
    }

    be_director_metrics = {metrics: [
      'AvgTimePerSyscall', 'CompressedMBs', 'CompressedReadMBs',
      'CompressedWriteMBs', 'CompressedReadReqs', 'CompressedReqs',
      'CompressedWriteReqs', 'IOs', 'MBs', 'MBRead', 'MBWritten',
      'PercentBusy', 'PercentBusyLogicalCore_0',
      'PercentBusyLogicalCore_1', 'PercentNonIOBusyLogicalCore_1',
      'PercentNonIOBusyLogicalCore_0', 'PercentNonIOBusy',
      'PrefetchedTracks', 'ReadReqs', 'Reqs', 'SyscallCount',
      'Syscall_RDF_DirCount', 'SyscallRemoteDirCount', 'WriteReqs'
    ]}

    fe_director_metrics = {metrics: [
      'AvgRDFSWriteResponseTime', 'AvgReadMissResponseTime',
      'AvgWPDiscTime', 'AvgTimePerSyscall', 'DeviceWPEvents',
      'HostMBs', 'HitReqs', 'HostIOs', 'MissReqs',
      'AvgOptimizedReadMissSize', 'OptimizedMBReadMisses',
      'OptimizedReadMisses', 'WriteMissReqs', 'PercentHitReqs',
      'PercentReadReqs', 'PercentReadReqHit', 'PercentWriteReqs',
      'PercentWriteReqHit', 'QueueDepthUtilization', 'ReadMissReqs',
      'HostIOLimitMBs', 'ReadReqs', 'ReadHitReqs', 'Reqs',
      'ReadResponseTime', 'HostIOLimitIOs', 'WriteResponseTime',
      'SlotCollisions', 'SyscallCount', 'Syscall_RDF_DirCounts',
      'SyscallRemoteDirCounts', 'SystemWPEvents', 'TotalReadCount',
      'TotalWriteCount', 'WriteReqs', 'WriteHitReqs', 'PercentBusy',
    ]}

    rdf_director_metrics = {metrics: [
      'AvgIOServiceTime', 'AvgIOSizeReceived', 'AvgIOSizeSent',
      'AvgTimePerSyscall', 'CopyIOs', 'CopyMBs', 'IOs', 'Reqs',
      'MBSentAndReceived', 'MBRead', 'MBWritten', 'PercentBusy',
      'Rewrites', 'AsyncMBSent', 'AsyncWriteReqs', 'SyncMBSent',
      'SyncWrites', 'SyscallCount', 'Syscall_RDF_DirCounts',
      'SyscallRemoteDirCount', 'SyscallTime', 'WriteReqs',
      'TracksSentPerSec', 'TracksReceivedPerSec'
    ]}

    im_director_metrics = {metrics: ['PercentBusy']}

    eds_director_metrics = {metrics: [
      'PercentBusy', 'RandomReadMissMBs', 'RandomReadMisses',
      'RandomWriteMissMBs', 'RandomWriteMisses'
    ]}

    if ((director_id.include? 'DF') || (director_id.include? 'DX'))
      payload = payload_base.merge(be_director_metrics)
      metrics = JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ be_director_uri, payload))['resultList']['result'][0]
      response = { director_type: 'BE', metrics: metrics }

    elsif ((director_id.include? 'EF') ||( director_id.include? 'FA') || (director_id.include? 'FE') || (director_id.include? 'SE'))
      payload = payload_base.merge(be_director_metrics)
      metrics = JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ fe_director_uri, payload))['resultList']['result'][0]
      response = { director_type: 'FE', metrics: metrics }

    elsif ((director_id.include? 'RF') || (director_id.include? 'RE'))
      payload = payload_base.merge(rdf_director_metrics)
      metrics = JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ rdf_director_uri, payload))['resultList']['result'][0]
      response = { director_type: 'RDF', metrics: metrics }

    elsif director_id.include? 'IM'
      payload = payload_base.merge(im_director_metrics)
      metrics = JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ im_director_uri, payload))['resultList']['result'][0]
      response = { director_type: 'IM', metrics: metrics }

    elsif director_id.include? 'EDS'
      payload = payload_base.merge(eds_director_metrics)
      metrics = JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ eds_director_uri, payload))['resultList']['result'][0]
      response = { director_type: 'ED', metrics: metrics }

    else
      response = { director_type: 'N/A', metrics: {} }
    end
  end

  def self.get_fe_port_metrics(array_id, start_date, end_date, director_id, port_id)
    target_uri = '/performance/FEPort/metrics'
    payload = {
      symmetrixId: array_id,
      directorId: director_id,
      portId: port_id,
      endDate: end_date,
      dataFormat: 'Average',
      metrics: [
        'ReadResponseTime', 'WriteResponseTime', 'PercentBusy',
        'MBWritten', 'MBRead', 'AvgIOSize',
        'SpeedGBs', 'IOs',
      ],
      startDate: start_date
    }
    JSON.parse(UnisphereRest.univmax_post(host, '/univmax/restapi'+ target_uri, payload))['resultList']['result'][0]
  end

end
