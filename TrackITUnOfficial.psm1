#Requires -Modules InvokeSQL
#Requires -Version 4

function Get-TervisTrackITUnOfficialWorkOrder {
    param(
        [switch]$IncludeNotes
    )
    $QueryToGetWorkOrders = @"
Select `*
from [TRACKIT9_DATA].[dbo].[vTASKS_BROWSE]
where Status != 'Completed'
"@

    $WorkOrders = Invoke-MSSQL -Server sql -Database TRACKIT9_DATA -SQLCommand $QueryToGetWorkOrders -ConvertFromDataRow

    if($IncludeNotes) {
        $WorkOrders | Get-TrackItUnOfficialWorkOrderNote
    }

    $WorkOrders | Add-TervisTrackITUnOfficialWorkOrderCustomProperties
}

Function Get-UnassignedTrackITs {
    $QueryToGetUnassignedWorkOrders = @"
Select Wo_num, task, request_fullname, request_email
from [TRACKIT9_DATA].[dbo].[vTASKS_BROWSE]
Where RESPONS IS Null AND
Status != 'Completed'
"@
    Invoke-SQL -dataSource sql -database TRACKIT9_DATA -sqlCommand $QueryToGetUnassignedWorkOrders
}

Function Add-TervisTrackITUnOfficialWorkOrderCustomProperties {
    param (
        [Parameter(Mandatory,ValueFromPipeline)]$WorkOrder
    )
    process {
        $WorkOrder | 
        Add-Member -MemberType ScriptProperty -Name KanbanizeBoard -Value { $This.LOOKUP1 } -PassThru |
        Add-Member -MemberType ScriptProperty -Name KanbanizeColumn -Value { $This.LOOKUP2 } -PassThru |
        Add-Member -MemberType ScriptProperty -Name KanbanizeLane -Value { $This.TaskLookup3 } -PassThru |
        Add-Member -MemberType ScriptProperty -Name KanbanizeProject -Value { $This.TaskLookup4 } -PassThru |
        Add-Member -MemberType ScriptProperty -Name KanbanizeID -Value { $This.WO_TEXT2 } -PassThru
    }
}

function Get-TrackItUnOfficialWorkOrderNote {
    param(
        [Parameter(Mandatory,ValueFromPipeline)]$WorkOrder
    )
    process{
        $QueryToGetWorkOrderNotes = @"
Select `*
  from [TRACKIT9_DATA].[dbo].[TaskNote]
  where WOID = $($WorkOrder.woid)
"@

        $WorkOrderNotes = Invoke-MSSQL -Server sql -Database TRACKIT9_DATA -SQLCommand $QueryToGetWorkOrderNotes -ConvertFromDataRow
        $WorkOrder | Add-Member -MemberType NoteProperty -Name Notes -Value {
            $WorkOrderNotes
        }
    }
}

function Get-TrackITWorkOrderDetails {
    param(
        [parameter(Mandatory = $true)]$WorkOrderNumber
    )
    $QueryToGetWorkOrders = @"
Select `*
  from [TRACKIT9_DATA].[dbo].[vTASKS_BROWSE]
  where WO_NUM = $WorkOrderNumber
"@

    $WorkOrder = Invoke-SQL -dataSource sql -database TRACKIT9_DATA -sqlCommand $QueryToGetWorkOrders
    $WorkOrder
}