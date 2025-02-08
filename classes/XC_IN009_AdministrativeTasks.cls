/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com 
* @date Creation 18/02/2019
* @date Modification dd/mm/yyyy
* @description  Invocable class to create a Administrative Task ase of type under a configuration item
*/ 
public without sharing class XC_IN009_AdministrativeTasks {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN009_AdministrativeTasks');
    
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
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
        List<NE__OrderItem__c> subsidiesInOrder = new List<NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> bundleIdIncentiveMap = new Map<Id, NE__OrderItem__c>();
        Map<Id,Asset> confItemAssetMap = new Map<Id,Asset>();
        Boolean autoComplete = false;
    }
    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @param inputWrapperList the list coming from flow
     * @description class to the the logic of administrative Task
     */
    @InvocableMethod 
    public static void administrativeTask(List<InputWrapper> inputWrapperList) {
        InputWrapper inWrapper = inputWrapperList[0];
        /*if(inWrapper.model == 'Complex'){
            complexProvisioning(inputWrapperList);
        } else if(inWrapper.model == 'Basic'){
            basicProvisioning(inputWrapperList);
        }*/
        basicProvisioning(inputWrapperList);
    }


   /* private static void complexProvisioning(List<InputWrapper> inputWrapperList){
        List<Case> caseToInsertList = new List<Case>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN009_AdministrativeTasks complexProvisioning scenario');
        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            
            List<String> listStepIds = new List<String>();
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }
            Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_AdministrativeTask});
            XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_AdministrativeTask);
            if(caseMDT == null) {
                throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_AdministrativeTask}));
            }
            MapWrapper wrapper = getInfoFromOrderItem(listStepIds);
            Map<Id, NE__OrderItem__c> configurationItemMap = wrapper.orderItemMap;
            Map<Id, XC_Provisioning_Step__c> mapSteps = wrapper.stepsMap;
            List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();
            for(InputWrapper inputWr : inputWrapperList){
                XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'step->' + step);               
                NE__OrderItem__c confItem = configurationItemMap.get(step.XC_Configuration_Item__c);
                caseToInsertList = XC_UTIL_Case.createAdministrativeCase(confItem, step,caseMDT);
                step.XC_Status__c = Label.XC_CL_Completed_Ok;
                stepsToUpdate.add(step);
            }
            XC_UTIL_Sobject.insertListRecords(caseToInsertList);
            XC_UTIL_Sobject.updateListRecords(stepsToUpdate);
        }
    }*/

    private static void basicProvisioning(List<InputWrapper> inputWrapperList){
        List<Case> caseToInsertList = new List<Case>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN009_AdministrativeTasks basicProvisioning scenario');
        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            
            List<String> listStepIds = new List<String>();
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }
            Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_AdministrativeTask});
            XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_AdministrativeTask);
            if(caseMDT == null) {
                throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_AdministrativeTask}));
            }
            MapWrapper wrapper = getInfoFromOrderItem(listStepIds);
            System.debug(LoggingLevel.FINEST, '@@NM wr: ' + wrapper);
            Map<Id, NE__OrderItem__c> configurationItemMap = wrapper.orderItemMap;
            Map<Id, XC_Provisioning_Step__c> mapSteps = wrapper.stepsMap;
            List<NE__OrderItem__c> sussidies = wrapper.subsidiesInOrder;
            List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();
            for(InputWrapper inputWr : inputWrapperList){
                XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'step->' + step);               
                NE__OrderItem__c confItem = configurationItemMap.get(step.XC_Configuration_Item__c);
                if(!sussidies.isEmpty()){
                    caseToInsertList = XC_UTIL_Case.createAdministrativeCase(confItem, step, caseMDT);
                    //step.XC_Status__c = Label.XC_CL_Completed_Ok; 
                    for(Case cas: caseToInsertList){
                        cas.XC_Order__c = wrapper.orderItemMap.get(cas.XC_OrderItem__c).NE__OrderId__c;
                        cas.XC_ConfigurationItemIncentive__c = (!wrapper.bundleIdIncentiveMap.isEmpty() && configurationItemMap.get(cas.XC_OrderItem__c) != null && String.isNotBlank(configurationItemMap.get(cas.XC_OrderItem__c).NE__Bundle_Configuration__c) && wrapper.bundleIdIncentiveMap.get(configurationItemMap.get(cas.XC_OrderItem__c).NE__Bundle_Configuration__c) != null) ? wrapper.bundleIdIncentiveMap.get(configurationItemMap.get(cas.XC_OrderItem__c).NE__Bundle_Configuration__c).Id : null;
                        cas.AssetId = String.isNotBlank(cas.XC_ConfigurationItemIncentive__c) && wrapper.confItemAssetMap.containsKey(cas.XC_OrderItem__c) ? wrapper.confItemAssetMap.get(cas.XC_OrderItem__c).Id : null;
                    }

                    //check if step has to be autocompleted
                    if(wrapper.autoComplete){
                        step.XC_Status__c = Label.XC_CL_Completed_Ok;
                    }

                } else {
                    step.XC_Status__c = Label.XC_CL_Step_Skipped;
                }
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
        Map<Id, NE__OrderItem__c> bundleIdIncentiveMap = new Map<Id, NE__OrderItem__c>();

        Map<Id, XC_Provisioning_Step__c> mapSteps = getInfoFromStep(listStepIds);
        for(Id stepId : mapSteps.keySet()){
            confItemListId.add(mapSteps.get(stepId).XC_Configuration_Item__c);
            confIds.add(mapSteps.get(stepId).XC_Configuration_Item__r.NE__OrderId__c);
        }
        
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>([
                SELECT Id, NE__Account__c,NE__Bundle_Configuration__c,NE__OrderId__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.XC_SubsidyIncluded__c, XC_LegalEntityFormula__c
                    FROM NE__OrderItem__c
                WHERE Id IN: confItemListId]);

        Map<Id, NE__Order__c> parentOrders = new Map<Id, NE__Order__c>([
                SELECT Id,
                (SELECT Id, NE__Account__c, NE__OrderId__c,XC_Product_Subtype__c,NE__Bundle_Configuration__c,NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.XC_SubsidyIncluded__c, 
                    NE__ProdId__r.XC_LIC_Product_Name__c, XC_LegalEntityFormula__c
                    FROM NE__Order_Items__r)
                FROM NE__Order__c
                WHERE Id IN: confIds]);

        List<NE__OrderItem__c> sussidies = new List<NE__OrderItem__c>();
        for(NE__Order__c ord : parentOrders.values()){
            for(NE__OrderItem__c item : parentOrders.get(ord.Id).NE__Order_Items__r){
                if(item.NE__ProdId__r.XC_LIC_Product_Name__c == 'Subvencion'){
                    sussidies.add(item);
                }
            }
        }  

        Map<Id,Asset> confItemAssetMap = new Map<Id,Asset>();
        List<Asset> asstList = [SELECT Id,XC_Configuration_Item__c FROM Asset WHERE XC_Configuration_Item__c IN : configurationItemMap.keySet()];
        for(Asset asst : asstList){
            if(!confItemAssetMap.containsKey(asst.XC_Configuration_Item__c)){
                confItemAssetMap.put(asst.XC_Configuration_Item__c,asst);
            }
        }

        //FI Added check for Italian Subsidies
        Boolean autoCompleteStep = false;
        if(sussidies.isEmpty()){
            autoCompleteStep = manageItalianIncentive(configurationItemMap,sussidies, bundleIdIncentiveMap);
        }

        wrapper.stepsMap = mapSteps;
        wrapper.subsidiesInOrder = sussidies;
        wrapper.orderItemMap = configurationItemMap;
        wrapper.autoComplete = autoCompleteStep;
        wrapper.bundleIdIncentiveMap = bundleIdIncentiveMap;
        wrapper.confItemAssetMap = confItemAssetMap;
        return wrapper;
    }

    /**
     * @author: francesco imperioli - fimperioli@deloitte.it
     * @description : manage italian incentive product to create administrative task
     * @created date: 2020/03/25
     */
    public static Boolean manageItalianIncentive(Map<Id, NE__OrderItem__c> configurationItemMap,List<NE__OrderItem__c> sussidies, Map<Id, NE__OrderItem__c> bundleIdIncentiveMap){

        Boolean result = false;

        List<String> bundleIds = new List<String>();
        //Map<Id,NE__OrderItem__c> bundleItemMap = new Map<Id,NE__OrderItem__c>();
        for(NE__OrderItem__c oi : configurationItemMap.values()){
            if(String.isNotBlank(oi.NE__Bundle_Configuration__c))
                bundleIds.add(oi.NE__Bundle_Configuration__c);
        }
        
        if(!bundleIds.isEmpty()){
            List<NE__OrderItem__c> incentiveItems = [SELECT ID,NE__Bundle_Configuration__c 
            FROM NE__OrderItem__c
            WHERE XC_Product_Subtype__c = :Label.XC_CL_ProductSubtypeIncentive 
                AND NE__Bundle_Configuration__c IN :bundleIds];

            for(NE__OrderItem__c incentiveOi : incentiveItems){
                bundleIdIncentiveMap.put(incentiveOi.NE__Bundle_Configuration__c,incentiveOi);
            }

            if(!bundleIdIncentiveMap.isEmpty()){
                for(NE__OrderItem__c oi : configurationItemMap.values()){
                    if(bundleIdIncentiveMap.containsKey(oi.NE__Bundle_Configuration__c)){
                        result = true;
                        sussidies.add(bundleIdIncentiveMap.get(oi.NE__Bundle_Configuration__c));
                    }
                }
            }
        }

        return result;
    }
}