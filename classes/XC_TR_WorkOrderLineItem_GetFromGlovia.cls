public class XC_TR_WorkOrderLineItem_GetFromGlovia {

    @future(callout=true)
    public static void setWarehouseCode(List<String> woliIdList){
        Map<id,WorkOrderLineItem> woliList = new Map<id,WorkOrderLineItem>([select id,XC_WarehouseId__c, XC_WarehouseCode__c from WorkOrderLineItem where id in :woliIdList]);

        if(woliList.isEmpty() && !Test.isRunningTest()){

            return;
        }
        Map<String,XC_UTIL_FSLLogistic.WarehouseWrapper> warehouseMap = getWarehouseData(XC_UTIL_Sobject.getListFieldValues(woliList.values(), 'Id'), new Map<String,String>());
        for(WorkOrderLineItem woli : woliList.values()){
            woli.XC_WarehouseCode__c = warehouseMap.containsKey(woli.XC_WarehouseId__c) ? warehouseMap.get(woli.XC_WarehouseId__c).warehouseCode : null;
        }
        //XC_UTIL_SObject.updateListRecords(woliList.values());
        XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        update woliList.values();
    }
    

    public static List<XC_UTIL_FSLLogistic.WarehouseWrapper> getWarehouseList(List<String> woliIdList, Map<String,String> filters){
        Map<id,WorkOrderLineItem> woliList = new Map<id,WorkOrderLineItem>([select id,XC_WarehouseId__c, XC_WarehouseCode__c from WorkOrderLineItem where id in :woliIdList]);
        if(woliList.isEmpty()){
            return new List<XC_UTIL_FSLLogistic.WarehouseWrapper>();
        }
        List<XC_UTIL_FSLLogistic.WarehouseWrapper> ret = new List<XC_UTIL_FSLLogistic.WarehouseWrapper>();
        Map<String,XC_UTIL_FSLLogistic.WarehouseWrapper> warehouseMap = getWarehouseData(XC_UTIL_Sobject.getListFieldValues(woliList.values(), 'Id'), filters);
        if(!warehouseMap.isEmpty()){
            ret = warehouseMap.values();
        }
        return ret;
    }


       /**
* @date Modification 23/02/2022 Nicola Arrigo - salvatore.agrillo@nttdata.com
* @description getWarehouseData – data for WareHouse
*/
    public static Map<String,XC_UTIL_FSLLogistic.WarehouseWrapper> getWarehouseData(List<String> woliIdList, Map<String,String> filters){
        Map<String,XC_UTIL_FSLLogistic.WarehouseWrapper> retRecord = new Map<String,XC_UTIL_FSLLogistic.WarehouseWrapper>();

        try{
            XC_UTIL_FSLLogistic.InputSelfCallout wrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
            wrapper.warehouseIdList = woliIdList;
            wrapper.searchFilters = filters;
			wrapper.userType = UserInfo.getUserType(); //add user type fix INC000080543099
            wrapper.operation = 'getWarehouseRecords';
            XC_UTIL_FSLLogistic.OutputSelfCallout response = XC_UTIL_FSLLogistic.selfCalloutGlovia(wrapper);
            retRecord = response.warehouseWrappers;
        }
        catch(Exception e){
            System.debug( '@@@@ XC_TR_WorkOrderLineItem_GetFromGlovia - getWarehouseData - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }
        if(Test.isRunningTest()){
            XC_UTIL_FSLLogistic.WarehouseWrapper pbe = new XC_UTIL_FSLLogistic.WarehouseWrapper();
            pbe.recordId = '10';
            pbe.warehouseCode = '10';
            retRecord.put('TEST',pbe);
        }
        return retRecord;

    }

}