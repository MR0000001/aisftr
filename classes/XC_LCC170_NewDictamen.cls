/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 06/11/2019
* @description XC_LCC170_NewDictamen - Controller to create a new Dictamen
*/

public without sharing class XC_LCC170_NewDictamen {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC170_NewDictamen');

    /** @description InfoDictamenWrapper */
    public class InfoDictamenWrapper {
        @AuraEnabled
        public List<RecordType> recordTypeList = new List<RecordType>();
        @AuraEnabled
        public WorkOrder workOrder = new WorkOrder();
        @AuraEnabled
        public Boolean existDictamenItems = false;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to get the visible record type for 
    * @param workOrderId - String
    * @return InfoDictamenWrapper
    */
    @AuraEnabled
    public static InfoDictamenWrapper getVisibleRecordType(String workOrderId) {
        InfoDictamenWrapper outputWrapper = new InfoDictamenWrapper();
        outputWrapper.recordTypeList = XC_UTIL_SObject_CheckVisibility.getVisibleRecordType('XC_DictamenItem__c');
        outputWrapper.workOrder = new List<WorkOrder>([
            SELECT Id, AssetId, XC_AffectedEquipment__c, XC_AffectedInstallation__c, Status,
                (SELECT Id FROM Dictamens_Items__r)
            FROM WorkOrder
            WHERE Id = :workOrderId
        ])[0];
        if(!(outputWrapper.workOrder.Dictamens_Items__r.isEmpty())) {
            outputWrapper.existDictamenItems = true;
        }
        return outputWrapper;
	}

}