/**
* @author Giovanni Schioppa giovanni.schioppa@nttdata.com
* @date Creation 16/01/2019
* @date Modification dd/mm/yyyy
* @description  – public class with invocable method. It is invoked by a Flow to start the complience 3
*/ 

public without sharing class XC_IN005_ComplianceVerification3 {

    /** @description The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN005_ComplianceVerification3');

    /**
    * @description InputWrapper the input wrapper 
    **/
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;      
    }

    private class ResultListsWrapper{
        List<XC_UTIL_Sobject.WrapperResult> dmlResultList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
    }

    private class UtilWrapper {
        List<XC_Provisioning_Step__c> listProvisiongStepToUpdate = new List<XC_Provisioning_Step__c>();
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
    }

    private class ParameterWrapper {
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        XC_UTIL_ComplianceMaster.ComplianceWrapperResult wr;
        Id confItemId;
        Map<Id,XC_Provisioning_Step__c> mapStepConfItemId = new Map<Id,XC_Provisioning_Step__c>();
    }
    /**
     * @description Compliance verification 3.
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod
    public static void complianceVerification3(List<InputWrapper> inputWrapperList) {
        ResultListsWrapper wrapper = new ResultListsWrapper();
        if(!inputWrapperList.isEmpty()){
            List<String> confItemListId = new List<String>();            
            List<String> listStepIds = new List<String>(); 
            Map<Id,XC_Provisioning_Step__c> mapStepConfItemId = new Map<Id,XC_Provisioning_Step__c>();
            
            for(InputWrapper inputWr : inputWrapperList){                
                listStepIds.add(inputWr.stepId);                         
            }
            Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(     
                [SELECT ID, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c      
                FROM XC_Provisioning_Step__c              
                WHERE Id IN: listStepIds]); 
            for(Id stepId : mapSteps.keySet()){ 
                confItemListId.add(mapSteps.get(stepId).XC_Configuration_Item__c); 
                mapStepConfItemId.put(mapSteps.get(stepId).XC_Configuration_Item__c,mapSteps.get(stepId));
            } 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN005 - mapSteps---> '+mapSteps); 
            Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> wrapperConfItemMap = XC_UTIL_ComplianceMaster.getComplianceMaster(Label.XC_CL_Compliance_C3, confItemListId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN005 - wrapperConfItemMap---->' + wrapperConfItemMap); 
            List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>(); 
            wrapper = complianceVerification3Helper(orderItemList, mapStepConfItemId, wrapperConfItemMap);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN005 - dmlResult ---->' + wrapper.dmlResultList);
            
            if(XC_UTIL_Sobject.checkDMLResults(wrapper.dmlResultList) && !wrapper.orderItemList.isEmpty()){
                Map<Id, List<String>> documentIdMap = XC_UTIL_DocumentComplianceMaster.getDocumentComplianceMaster(Label.XC_CL_Compliance_C3, wrapper.orderItemList); 
                //CALL THE METHOD TO CREATE XC_ComplianceVerificationStatus__c AND Case
                createComplianceAndCase(documentIdMap, mapSteps.get(listStepIds[0]).XC_Configuration_Item__r.NE__OrderId__c, wrapperConfItemMap);
            }
        }
    }
    /**
    * @description InputWrapper the input wrapper 
    * @param documentIdMap
    * @param orderId
    * @param wrapperConfItemMap
    **/
    private static void createComplianceAndCase(Map<Id, List<String>> documentIdMap, String  orderId, Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> wrapperConfItemMap){
        if(!documentIdMap.isEmpty()){
            XC_LCC069_ComplianceVerification1.cvsWrapper cvs = new XC_LCC069_ComplianceVerification1.cvsWrapper();
            cvs.mapOrderitemDocument = documentIdMap;
            cvs.complianceType = Label.XC_CL_Compliance_C3;
            cvs.orderId = orderId;
            cvs.mapOrderitemCompliance = wrapperConfItemMap;
            XC_LCC069_ComplianceVerification1.createComplianceVerificationStatus(cvs);
        }
    }

    /**
    * @description InputWrapper the input wrapper 
    * @param orderItemList
    * @param mapStepConfItemId
    * @param wrapperConfItemMap
    * @return dmlResultList
    **/ 
    private static ResultListsWrapper complianceVerification3Helper(List<NE__OrderItem__c> orderItemList, Map<Id,XC_Provisioning_Step__c> mapStepConfItemId, Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> wrapperConfItemMap ){
        UtilWrapper utilWrapper = new UtilWrapper();
        ResultListsWrapper wrapper = new ResultListsWrapper();
        List<XC_Provisioning_Step__c> listProvisiongStepToUpdate = new List<XC_Provisioning_Step__c>();
        for(Id confItemId : mapStepConfItemId.keyset()){
            XC_UTIL_ComplianceMaster.ComplianceWrapperResult wr = wrapperConfItemMap.get(confItemId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN005 - wrapper ---->' + wrapperConfItemMap); 
            if(wr != null){
                ParameterWrapper parameters = new ParameterWrapper();
                parameters.orderItemList = orderItemList;
                parameters.wr = wr;
                parameters.confItemId = confItemId;
                parameters.mapStepConfItemId = mapStepConfItemId;
                utilWrapper = checkWrapper(parameters);
            }
        }
        //UPDATE RECORDS 
        List<XC_UTIL_Sobject.WrapperResult> dmlResultList = XC_UTIL_SObject.updateListRecords(utilWrapper.listProvisiongStepToUpdate);
        wrapper.dmlResultList = dmlResultList;
        wrapper.orderItemList = utilWrapper.orderItemList;
        return wrapper;
    }

    private static UtilWrapper checkWrapper(ParameterWrapper parameters) {
        UtilWrapper wrapper = new UtilWrapper();
        List<NE__OrderItem__c> orderItemList = parameters.orderItemList;
        XC_UTIL_ComplianceMaster.ComplianceWrapperResult wr = parameters.wr;
        Id confItemId = parameters.confItemId;
        Map<Id,XC_Provisioning_Step__c> mapStepConfItemId = parameters.mapStepConfItemId;
        List<XC_Provisioning_Step__c> listProvisiongStepToUpdate = new List<XC_Provisioning_Step__c>();
        if(wr.check){
            NE__OrderItem__c confItem = new NE__OrderItem__c(Id = confItemId);
            orderItemList.add(confItem);                        
            if(!wr.mandatory){
                XC_Provisioning_Step__c step = mapStepConfItemId.get(confItemId);
                step.XC_Status__c = Label.XC_CL_Step_Skipped;
                listProvisiongStepToUpdate.add(step);
            }
        } else {
            XC_Provisioning_Step__c step = mapStepConfItemId.get(confItemId);
            step.XC_Status__c = Label.XC_CL_Step_Skipped;
            listProvisiongStepToUpdate.add(step); 
        }
        wrapper.listProvisiongStepToUpdate = listProvisiongStepToUpdate;
        wrapper.orderItemList = orderItemList;
        return wrapper;
    }
}