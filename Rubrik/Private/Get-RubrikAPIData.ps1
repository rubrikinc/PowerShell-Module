﻿<#
    Helper function to retrieve API data from Rubrik
#>
function GetRubrikAPIData($endpoint)
{
  $api = @{
    Login                     = @{
      v1 = @{
        URI         = '/api/v1/login'
        Body        = @('username', 'password')
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = '{"userId": "11111111-2222-3333-4444-555555555555","token": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"}'
        FailureCode = '422'
        FailureMock = '{"errorType":"user_error","message":"Incorrect Username/Password","cause":null}'
      }
      v0 = @{
        URI         = '/login'
        Body        = @('userId', 'password')
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = '{"status":"Success","description":"Successfully logged in","userId":"11111111-2222-3333-4444-555555555555","token":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"}'
        FailureCode = '200'
        FailureMock = '{"status": "Failure","description": "Incorrect Username/Password"}'
      }
    }
    VMwareVMGet               = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm'
        Body        = ''
        Params      = @{
          Filter = 'archive_status'
          Search = 'search_value'
        }
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
	"hasMore": true,
	"data": [{
		"id": "11111111-2222-3333-4444-555555555555-vm-666666",
		"name": "TEST1",
		"configuredSlaDomainId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"configuredSlaDomainName": "Gold",
		"effectiveSlaDomainId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"effectiveSlaDomainName": "Gold",
		"isArchived": false,
		"inheritedSlaName": "Gold",
		"slaId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"isRelic": false
	}, {
		"id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffff",
		"name": "TEST2",
		"configuredSlaDomainId": "INHERIT",
		"configuredSlaDomainName": "Inherit",
		"effectiveSlaDomainId": "UNPROTECTED",
		"effectiveSlaDomainName": "Unprotected",
		"isArchived": true,
		"inheritedSlaName": "Unprotected",
		"slaId": "INHERIT",
		"isRelic": true
	}]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/vm'
        Body        = ''
        Params      = @{
          Filter = 'archiveStatusFilterOpt'
          Search = ''
        }
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
[{
		"id": "11111111-2222-3333-4444-555555555555-vm-666666",
		"name": "TEST1",
		"configuredSlaDomainId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"configuredSlaDomainName": "Gold",
		"effectiveSlaDomainId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"effectiveSlaDomainName": "Gold",
		"isArchived": false,
		"inheritedSlaName": "Gold",
		"slaId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
		"isRelic": false
	}, {
		"id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-ffffff",
		"name": "TEST2",
		"configuredSlaDomainId": "INHERIT",
		"configuredSlaDomainName": "Inherit",
		"effectiveSlaDomainId": "UNPROTECTED",
		"effectiveSlaDomainName": "Unprotected",
		"isArchived": true,
		"inheritedSlaName": "Unprotected",
		"slaId": "INHERIT",
		"isRelic": true
	}]
"@
        FailureCode = '500'
        FailureMock = '{"status": "Failure"}'
      }
    }
       UnmanagedObject               = @{
      v1 = @{
        URI         = '/api/internal/unmanaged_object'
        Body        = ''
        Params      = @{
          Search = 'search_value'
          Filter = 'object_type'
        }
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
  "hasMore": true,
  "data": [
    {
      "id": "209a93f5-bf4e-4228-965e-8e6e684cbaa2-vm-94",
      "name": "VUM1",
      "objectType": "VirtualMachine",
      "physicalLocation": [
        {
          "managedId": "vCenter:::209a93f5-bf4e-4228-965e-8e6e684cbaa2",
          "name": "vcsa1.rubrik.demo"
        },
        {
          "managedId": "DataCenter:::209a93f5-bf4e-4228-965e-8e6e684cbaa2-datacenter-2",
          "name": "Santa Clara"
        },
        {
          "managedId": "ComputeCluster:::209a93f5-bf4e-4228-965e-8e6e684cbaa2-domain-c44",
          "name": "Old Mgmt"
        },
        {
          "managedId": "VmwareHost:::209a93f5-bf4e-4228-965e-8e6e684cbaa2-host-10347",
          "name": "esxm03.rubrik.demo"
        }
      ],
      "unmanagedStatus": "Relic",
      "unmanagedSnapshotCount": 48,
      "localStorage": 1928366779,
      "archiveStorage": 1404044423
    },
    {
      "id": "f6a2122c-584b-4048-9cfb-030ab3cfdc34-vm-118",
      "name": "SE-CCHOW-WIN",
      "objectType": "VirtualMachine",
      "physicalLocation": [
        {
          "managedId": "vCenter:::f6a2122c-584b-4048-9cfb-030ab3cfdc34",
          "name": "demovcsa.rubrik.demo"
        },
        {
          "managedId": "DataCenter:::f6a2122c-584b-4048-9cfb-030ab3cfdc34-datacenter-21",
          "name": "Santa Clara"
        },
        {
          "managedId": "ComputeCluster:::f6a2122c-584b-4048-9cfb-030ab3cfdc34-domain-c26",
          "name": "Demo"
        },
        {
          "managedId": "VmwareHost:::f6a2122c-584b-4048-9cfb-030ab3cfdc34-host-70449",
          "name": "esx14.rubrik.demo"
        }
      ],
      "unmanagedStatus": "Relic",
      "unmanagedSnapshotCount": 51,
      "localStorage": 2247130648,
      "archiveStorage": 1056496800
    }
}]
"@
        FailureCode = ''
        FailureMock = ''
      }
  }

    VMwareVMSnapshotGet       = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/{id}/snapshot'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
  "hasMore": false,
  "data": [
    {
      "date": "2016-12-05T17:10:17Z",
      "virtualMachineName": "TEST1",
      "id": "11111111-2222-3333-4444-555555555555",
      "consistencyLevel": "CRASH_CONSISTENT"
    },
    {
      "date": "2016-12-05T13:06:35Z",
      "virtualMachineName": "TEST1",
      "id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "consistencyLevel": "CRASH_CONSISTENT"
    }
  ],
  "total": 2
}
"@        
        FailureCode = '404'
        FailureMock = '{"message":"Could not find VirtualMachine with id=11111111-2222-3333-4444-555555555555-vm-6666"}'
      }
      v0 = @{
        URI         = '/snapshot?vm={id}'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
[
    {
      "date": "2016-12-05T17:10:17Z",
      "virtualMachineName": "TEST1",
      "id": "11111111-2222-3333-4444-555555555555",
      "consistencyLevel": "CRASH_CONSISTENT"
    },
    {
      "date": "2016-12-05T13:06:35Z",
      "virtualMachineName": "TEST1",
      "id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "consistencyLevel": "CRASH_CONSISTENT"
    }
]
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMMountPost         = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/mount'
        Body        = @{
          snapshotId           = 'snapshotId'
          hostId               = 'hostId'
          vmName               = 'vmName'
          disableNetwork       = 'disableNetwork'
          removeNetworkDevices = 'removeNetworkDevices'
          powerOn              = 'powerOn'
        }
        Method      = 'Post'
        SuccessCode = '202'
        SuccessMock = @"
{
  "requestId": "MOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
  "status": "QUEUED",
  "links": [
    {
      "href": "https://RVM1111111111/api/v1/vmware/vm/request/MOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
      "rel": "self",
      "method": "GET"
    }
  ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/job/type/mount'
        Body        = @{
          snapshotId           = 'snapshotId'
          hostId               = 'hostId'
          vmName               = 'vmName'
          disableNetwork       = 'disableNetwork'
          removeNetworkDevices = 'removeNetworkDevices'
          powerOn              = 'powerOn'
        }
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = @"
{
  "requestId": "MOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
  "status": "QUEUED",
  "links": [
    {
      "href": "https://RVM1111111111/api/v1/vmware/vm/request/MOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
      "rel": "self",
      "method": "GET"
    }
  ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMMountGet          = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/mount'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
  "hasMore": false,
  "data": [
    {
      "id": "11111111-2222-3333-4444-555555555555",
      "snapshotDate": "2016-12-01T23:26:49+0000",
      "sourceVirtualMachineId": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-fff",
      "sourceVirtualMachineName": "TEST1",
      "isReady": 1
    },
    {
      "id": "aaaaaaaa-2222-3333-4444-555555555555",
      "snapshotDate": "2016-12-01T23:26:49+0000",
      "sourceVirtualMachineId": "11111111-bbbb-cccc-dddd-eeeeeeeeeeee-vm-fff",
      "sourceVirtualMachineName": "TEST2",
      "isReady": 1
    }
  ],
  "total": 2
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/mount'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
[
  {
      "id": "11111111-2222-3333-4444-555555555555",
      "snapshotDate": "2016-12-01T23:26:49+0000",
      "sourceVirtualMachineId": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-fff",
      "sourceVirtualMachineName": "TEST1",
      "isReady": 1
    },
    {
      "id": "aaaaaaaa-2222-3333-4444-555555555555",
      "snapshotDate": "2016-12-01T23:26:49+0000",
      "sourceVirtualMachineId": "11111111-bbbb-cccc-dddd-eeeeeeeeeeee-vm-fff",
      "sourceVirtualMachineName": "TEST2",
      "isReady": 1
    }
]
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMMountDelete       = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/mount'
        Params      = @{
          MountID = 'mount_id'
          Force   = 'force'
        }
        Method      = 'Delete'
        SuccessCode = '202'
        SuccessMock = @"
{
  "requestId": "UNMOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
  "status": "QUEUED",
  "links": [
    {
      "href": "https://RVM1111111111/api/v1/vmware/vm/request/UNMOUNT_SNAPSHOT_11111111-2222-3333-4444-555555555555_66666666-7777-8888-9999-000000000000:::0",
      "rel": "self",
      "method": "GET"
    }
  ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/job/type/unmount'
        Params      = @{
          MountID = 'mountId'
          Force   = 'force'
        }        
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    ClusterVersionGet         = @{
      v1 = @{
        URI         = '/api/v1/cluster/{id}/version'
        Params      = @{
          id = 'id'
        }
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = '"9.9.9~DA9-99"'
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/system/version'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = '"1.1.1~DA1-11"'
        FailureCode = ''
        FailureMock = ''
      }
    }
    SLADomainGet              = @{
      v1 = @{
        URI         = '/api/v1/sla_domain'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
  "hasMore": false,
  "data": [
    {
      "id": "11111111-2222-3333-4444-555555555555",
      "name": "TEST1",
      "numDbs": 11,
      "numFilesets": 11,
      "numLinuxHosts": 11,
      "numVms": 11
    },
    {
      "id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "name": "TEST2",
      "numDbs": 22,
      "numFilesets": 22,
      "numLinuxHosts": 22,
      "numVms": 22
    }
  ],
  "total": 2
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/slaDomain'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
[
  {
    "id": "11111111-2222-3333-4444-555555555555",
    "name": "TEST1",
    "numVms": 11,
    "numSnapshots": 11
  },
  {
    "id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "name": "TEST2",
    "numVms": 22,
    "numSnapshots": 22
  }
]
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    SLADomainAssignPost       = @{
      v1 = @{
        URI         = '/api/v1/sla_domain/{id}/assign'
        Body        = @{
          managedIds = 'managedIds'
        }
        Method      = 'Post'
        SuccessCode = '202'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/slaDomainAssign/{id}'
        Body        = @{
          managedIds = 'managedIds'
        }
        Method      = 'Patch'
        SuccessCode = '200'
        SuccessMock = @"
{
    "statuses":  [
                     {
                         "id":  "VirtualMachine:::11111111-2222-3333-4444-555555555555-vm-66",
                         "status":  "@{status=Success}"
                     },
                     {
                         "id":  "VirtualMachine:::11111111-2222-3333-4444-555555555555-vm-77",
                         "status":  "@{status=Success}"
                     }
                 ],
    "jobs":  [
                 "CALCULATE_EFFECTIVE_SLA_aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee_ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj:::0"
             ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    SLADomainDelete           = @{
      v1 = @{
        URI         = '/api/v1/sla_domain/{id}'
        Method      = 'Delete'
        SuccessCode = '204'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/slaDomain/{id}'
        Method      = 'Delete'
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    JobGet                    = @{
      v1 = @{
        URI         = '/api/internal/job/{id}'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
    "id":  "CREATE_SNAPSHOT_123456-vm-123:::11",
    "status":  "SUCCEEDED",
    "result":  "abcdef",
    "startTime":  "2016-12-27T06:17:54+0000",
    "endTime":  "2016-12-27T06:25:42+0000",
    "jobType":  "CREATE_SNAPSHOT",
    "nodeId":  "cluster:::RVM151S001111",
    "isDisabled":  false
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/job/instance/{id}'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
    "id":  "CREATE_SNAPSHOT_123456-vm-123:::11",
    "status":  "SUCCEEDED",
    "result":  "abcdef",
    "startTime":  "2016-12-27T06:17:54+0000",
    "endTime":  "2016-12-27T06:25:42+0000",
    "jobType":  "CREATE_SNAPSHOT",
    "nodeId":  "cluster:::RVM151S001111",
    "isDisabled":  false
}
"@
        FailureCode = ''
        FailureMock = ''
      }
    }
    ReportBackupJobsDetailGet = @{
      v1 = @{
        URI         = '/api/v1/report/backup_jobs/detail?report_type={id}'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
   "hasMore":false,
   "data":[
      {
         "objectType":"Mssql",
         "slaDomainId":"123456",
         "durationInMillis":120000,
         "slaDomainName":"Gold",
         "location":"TEST1\\MSSQLSERVER",
         "endTime":"2016-12-26T17:41:51Z",
         "failureDescription":"Rubrik backup service at \u0027TEST1\u0027 returned error: Failed to take database snapshot, Error = VSS_E_BAD_STATE(0x80042301)",
         "scheduledTime":"2016-12-26T17:34:01Z",
         "objectId":"abcdef",
         "status":"Failed",
         "objectName":"DB1",
         "jobType":"Backup",
         "jobId":"MSSQL_DB_BACKUP_123456:::11",
         "startTime":"2016-12-26T17:39:51Z"
      }
   ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/report/backupJobs/detail'
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }
    VMwareVMBackupPost = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/{id}/backup'
        Method      = 'Post'
        SuccessCode = '202'
        SuccessMock = @"
{
    "requestId":  "CREATE_VMWARE_SNAPSHOT_123456:::0",
    "status":  "QUEUED",
    "links":  [
                  {
                      "href":  "https://RVM15BS011111/api/v1/vmware/vm/request/CREATE_VMWARE_SNAPSHOT_123456:::0",
                      "rel":  "self",
                      "method":  "GET"
                  }
              ]
}
"@
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/job/type/backup'
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }    
    VMwareVMMountPowerPost = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/mount/{id}/power'
        Method      = 'Post'
        Params      = @{
          vmId = $null
          powerStatus = 'powerStatus'
          }
        SuccessCode = '204'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/vm/power'
        Method      = 'Post'
        Params      = @{
          vmId = 'vmId'
          powerStatus = 'powerState'
          }        
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }                
    VMwareVMPatch = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/{id}'
        Method      = 'Patch'
        Params      = @{
          snapshotConsistencyMandate = 'snapshotConsistencyMandate'
          maxNestedVsphereSnapshots = 'maxNestedVsphereSnapshots'
          isVmPaused = 'isVmPaused'
          preBackupScript = @{
            scriptPath = 'scriptPath'
            timeoutMs = 'timeoutMs'
            failureHandling = 'failureHandling'
            }
          postSnapScript = @{
            scriptPath = 'scriptPath'
            timeoutMs = 'timeoutMs'
            failureHandling = 'failureHandling'
            }
          postBackupScript = @{
            scriptPath = 'scriptPath'
            timeoutMs = 'timeoutMs'
            failureHandling = 'failureHandling'
            }
          }
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
      v0 = @{
        URI         = '/vm/{id}'
        Method      = 'Patch'
        Params      = @{
          snapshotConsistencyMandate = 'snapshotConsistencyMandate'
          maxNestedVsphereSnapshots = 'maxNestedVsphereSnapshots'
          }      
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }  
    SLADomainPost = @{
      v1 = @{
        URI         = '/api/v1/sla_domain'
        Method      = 'Post'
        Params      = @{
          name = 'name'
          frequencies = @{
            timeUnit = 'timeUnit'
            frequency = 'frequency'
            retention = 'retention'
            }
          }
        SuccessCode = '201'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    }      
    VMwareVMRequestGet = @{
      v1 = @{
        URI         = '/api/v1/vmware/vm/request/{id}'
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = ''
        FailureCode = ''
        FailureMock = ''
      }
    } 
       MSSQLDBGet               = @{
      v1 = @{
        URI         = '/api/v1/mssql/db'
        Body        = ''
        Params      = @{
          Filter = 'instance_id','sla_domain_id','primary_cluster_id','archive_status'
        }
        Method      = 'Get'
        SuccessCode = '200'
        SuccessMock = @"
{
  "hasMore": false,
  "data": [
    {
      "databaseUuid": "1ac0a705-d045-4373-adc1-af2da2ee0868",
      "hostId": "f149d394-2127-476d-85a4-2acc04bd5536",
      "hostname": "SE-JBAILLEY-WIN",
      "id": "1ac0a705-d045-4373-adc1-af2da2ee0868@a25e9ca0-aab0-49ee-ac06-c868090e950c",
      "instanceId": "a25e9ca0-aab0-49ee-ac06-c868090e950c",
      "instanceName": "SQLRUBRIK",
      "isRelic": false,
      "managedId": "MssqlDatabase:::1ac0a705-d045-4373-adc1-af2da2ee0868",
      "primaryClusterId": "5fca952e-d332-4419-bb96-8339d9beb3ac",
      "isArchived": false,
      "localStorage": 1430762,
      "archiveStorage": 2017481,
      "copyOnly": false,
      "logBackupFrequencyInSeconds": 600,
      "logBackupRetentionHours": 168,
      "name": "model",
      "recoveryModel": "FULL",
      "slaDomainId": "d8a8430c-40de-4cb7-b834-bd0e7de40ed1",
      "slaDomainName": "Gold",
      "snappableId": "763fe225-c5d3-46b9-8942-fe57fef85529",
      "snapshotCount": 46,
      "state": "ONLINE",
      "hasPermissions": true
    }
"@
        FailureCode = ''
        FailureMock = ''
      }
    } 
             
  } # End of API
  
  return $api.$endpoint
} # End of function
