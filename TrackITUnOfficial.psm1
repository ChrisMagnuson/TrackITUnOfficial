function get-TrackITWorkOrders {
$QueryToGetWorkOrders = @"
Select `*
  from [TRACKIT9_DATA].[dbo].[vTASKS_BROWSE]
  where WorkOrderStatusName != 'Closed'
"@

    $WorkOrders = Invoke-SQL -dataSource sql -database TRACKIT9_DATA -sqlCommand $QueryToGetWorkOrders

    $WorkOrdersArray = @()
    #$WorkOrders | % { $WorkOrdersArray += $_.data }
    $WorkOrdersArray = $WorkOrders.DataSet.Tables[0] | % { $_ }

    <#foreach ($WorkOrder in $WorkOrdersArray ) {

$QueryToGetWorkOrderNotes = @"
Select `*
  from [TRACKIT9_DATA].[dbo].[TaskNote]
  where WOID = $WorkOrder.woid
"@

        $WorkOrder | Add-Member -MemberType NoteProperty -Name Notes -Value {
            $WorkOrderNotes = Invoke-SQL -dataSource sql -database TRAC$KIT9_DATA -sqlCommand $QueryToGetWorkOrderNotes
            
            $WorkOrderNotes.DataSet.Tables[0] | % { $_ }

        }
    }#>
    $WorkOrdersArray
}