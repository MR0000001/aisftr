/**
 * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
 * @date  : 10/09/2019
 * @description Util class for XC_TR_WorkOrder_U_RequiredResourcesMgmt.
**/

public class XC_TR_WorkOrder_U_RequiredResMgmt_U { 

    /**
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to populate a Map: Id -> Id
     * @param listNew
     * @param accountId preferred accountId
     * @return a Map workOrderId -> preferredAccountId
     */ 
    public static Map<Id, Id> getMapWorkOrderPreferredResourceAccount(List<WorkOrder> listNew, String accountId) {
        Map<Id, Id> mapWorkOrderPreferredResourceAccount = new Map<Id, Id>();
        if(String.isBlank(accountId)){
            mapWorkOrderPreferredResourceAccount = XC_UTIL_ResourcePreference.getMapWorkOrderPreferredResourceAccount(listNew);
        } else {
            for(WorkOrder wo : listNew){
                mapWorkOrderPreferredResourceAccount.put(wo.Id, accountId); 
            }
        }
        return mapWorkOrderPreferredResourceAccount;
    } 

    /**     
     * @author: Marco Rosa - marco.rosa@nttdata.com
     * @description Method to filter WordOrder to be applied preferences to
     *              and added a skip for multiple repair (second condition in if statement)
     * @param listNew - list Id of new records
     * @return List<WorkOrder> 
     */
    public static List<WorkOrder> getWorkOrderToApplyPreferences(List<WorkOrder> listNew){
        List<WorkOrder> workOrdersToApplyPreferences = new List<WorkOrder>();
        for(WorkOrder wo : listNew){
            Boolean isRepair = wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair;
            Boolean isDeI = wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation;
            if(((isRepair || isDeI) && wo.XC_HierarchyLevel__c > 1) || !wo.XC_isTree__c) {
                workOrdersToApplyPreferences.add(wo); 
            }
        }
        return workOrdersToApplyPreferences;
    }
}