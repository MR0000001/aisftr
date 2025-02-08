/**
* @author Daniele Lico - dlico@deloitte.it 
* @date Creation 03/12/2019
* @date Modification dd/mm/yyyy
* @description  Invocable class to create a Case for internal Work Order
*/ 
public without sharing class XC_IN035_InternalWorkOrder {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN035_AdministrativeTasks');
    
    /**
    * @author Daniele Lico - dlico@deloitte.it
    * @description InputWrapper - stepId is the step Id, model can be Basic or Complex, depending from the calling flow 
    **/
    public class InputWrapper{ 
        @Invocablevariable     
        public String stepId;
        @Invocablevariable 
        public String model;
    }

    private class MapWrapper{
        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>();
        Map<Id, XC_Provisioning_Step__c> stepsMap = new Map<Id, XC_Provisioning_Step__c>();
        //List<NE__OrderItem__c> subsidiesInOrder = new List<NE__OrderItem__c>();
    }
    /**
     * @author Daniele Lico - dlico@deloitte.it
     * @param inputWrapperList the list coming from flow
     * @description class to the the logic of administrative Task
     */
   @InvocableMethod 
    public static void internalWorkOrder(List<InputWrapper> inputWrapperList) {
         InputWrapper inWrapper = inputWrapperList[0];
        basicProvisioning(inputWrapperList);
    }

    private static void basicProvisioning(List<InputWrapper> inputWrapperList){
        List<Case> caseToInsertList = new List<Case>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN035_InternalWorkOrder basicProvisioning scenario');
        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            
            List<String> listStepIds = new List<String>();
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }
            Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_InternalFieldService});
            XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_InternalFieldService);
            if(caseMDT == null) {
                throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_InternalFieldService}));
            }
            MapWrapper wrapper = getInfoFromOrderItem(listStepIds);
            Map<Id, NE__OrderItem__c> configurationItemMap = wrapper.orderItemMap;
            Map<Id, XC_Provisioning_Step__c> mapSteps = wrapper.stepsMap;
            //List<NE__OrderItem__c> sussidies = wrapper.subsidiesInOrder;
            List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();
            for(InputWrapper inputWr : inputWrapperList){
                XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'step->' + step);               
                NE__OrderItem__c confItem = configurationItemMap.get(step.XC_Configuration_Item__c);
                //if(!sussidies.isEmpty()){
                    caseToInsertList = XC_UTIL_Case.createAdministrativeCase(confItem, step, caseMDT);
                    //step.XC_Status__c = Label.XC_CL_Completed_Ok; 
                //} else {
                    //step.XC_Status__c = Label.XC_CL_Step_Skipped;
                //}
                stepsToUpdate.add(step);
            }
            XC_UTIL_Sobject.insertListRecords(caseToInsertList);
            XC_UTIL_Sobject.runAssignmentRules(caseToInsertList,'Case');
            XC_UTIL_Sobject.updateListRecords(stepsToUpdate);
        }
    }    

    private static Map<Id, XC_Provisioning_Step__c> getInfoFromStep(List<String> listStepIds){
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT ID, XC_Configuration_Item__c, XC_ConfigurationId__c, XC_Configuration_Item__r.NE__OrderId__c 
                FROM XC_Provisioning_Step__c 
                WHERE Id IN: listStepIds]); 

        return mapSteps;
    }

    private static MapWrapper getInfoFromOrderItem(List<String> listStepIds){
        MapWrapper wrapper = new MapWrapper();
        List<String> confItemListId = new List<String>();
        List<String> confIds = new List<String>();
        Map<Id, XC_Provisioning_Step__c> mapSteps = getInfoFromStep(listStepIds);
        for(Id stepId : mapSteps.keySet()){
            confItemListId.add(mapSteps.get(stepId).XC_Configuration_Item__c);
            confIds.add(mapSteps.get(stepId).XC_Configuration_Item__r.NE__OrderId__c);
        }
        //List<NE__OrderItem__c> sussidies = new List<NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>([
                SELECT Id, NE__Account__c, NE__OrderId__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.XC_SubsidyIncluded__c, XC_LegalEntityFormula__c
                    FROM NE__OrderItem__c
                WHERE Id IN: confItemListId]);
        Map<Id, NE__Order__c> parentOrders = new Map<Id, NE__Order__c>([
                SELECT Id,
                (SELECT Id, NE__Account__c, NE__OrderId__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.XC_SubsidyIncluded__c, 
                    NE__ProdId__r.XC_LIC_Product_Name__c, XC_LegalEntityFormula__c
                    FROM NE__Order_Items__r)
                FROM NE__Order__c
                WHERE Id IN: confIds]);
        //for(NE__Order__c ord : parentOrders.values()){
            //for(NE__OrderItem__c item : parentOrders.get(ord.Id).NE__Order_Items__r){
                //if(item.NE__ProdId__r.XC_LIC_Product_Name__c == 'Subvencion'){
                    //sussidies.add(item);
               // }
            //}
	//}  
        wrapper.stepsMap = mapSteps;
        //wrapper.subsidiesInOrder = sussidies;
        wrapper.orderItemMap = configurationItemMap;
        return wrapper;
    }


}