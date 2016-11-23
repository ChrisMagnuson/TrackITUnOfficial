#Requires -Modules InvokeSQL
#Requires -Version 4

function get-TervisTrackITWorkOrders {
    $QueryToGetWorkOrders = @"
Select `*
  from [TRACKIT9_DATA].[dbo].[vTASKS_BROWSE]
  where WorkOrderStatusName != 'Closed'
"@

    $WorkOrders = Invoke-SQL -dataSource sql -database TRACKIT9_DATA -sqlCommand $QueryToGetWorkOrders
    $WorkOrdersArray = @()
    $WorkOrdersArray = $WorkOrders.DataSet.Tables[0] | % { $_ }
    $WorkOrdersArray
}


function get-TervisTrackITWorkOrder {
    param(
        [switch]$IncludeNotes
    )
    $QueryToGetWorkOrders = @"
Select `*
  from [TRACKIT9_DATA].[dbo].[vTASKS_BROWSE]
  where WorkOrderStatusName != 'Closed'
"@

    $WorkOrders = Invoke-SQL -dataSource sql -database TRACKIT9_DATA -sqlCommand $QueryToGetWorkOrders
    $WorkOrdersArray = @()
    $WorkOrdersArray = $WorkOrders.DataSet.Tables[0] | % { $_ }

    if($IncludeNotes) {
        foreach ($WorkOrder in $WorkOrdersArray ) {
            $WorkOrder | Get-TrackItWorkOrderNote
        }
    }

    $WorkOrdersArray | ConvertFrom-DataRow
}

function Get-TrackItWorkOrderNote {
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]$WorkOrder
    )
    process{
        $WorkOrder# | % {
        
            $QueryToGetWorkOrderNotes = @"
Select `*
  from [TRACKIT9_DATA].[dbo].[TaskNote]
  where WOID = $_.woid
"@

            $WorkOrderNotes = Invoke-SQL -dataSource sql -database TRACKIT9_DATA -sqlCommand $QueryToGetWorkOrderNotes    

            $_ | Add-Member -MemberType NoteProperty -Name Notes -Value {
                $WorkOrderNotes.DataSet.Tables[0] | % { $_ }
            }
        #}
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