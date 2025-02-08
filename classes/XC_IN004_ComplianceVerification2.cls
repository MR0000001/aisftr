/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 07/01/2019
* @date Modification dd/mm/yyyy
* @description  – public class with invocable method. It is invoked by a Flow to start the complience 2
*/ 

public without sharing class XC_IN004_ComplianceVerification2 {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN004_ComplianceVerification2');
     /**
     * @description InputWrapper the input wrapper
     */ 
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;      
    }
    
    /**
     * @description Compliance verification 2.  
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod
    public static void complianceVerification2(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### enter in XC_IN004_ComplianceVerification2');
        if(inputWrapperList.isEmpty()){
            return;
        }
        executeVerification(inputWrapperList);
    }

    /**
     * @description executeVerification  
     * @param inputWrapperList the input wrapper list
     */
    private static void executeVerification(List<InputWrapper> inputWrapperList){
        List<Id> confItemListId = new List<Id>();            
        List<String> listStepIds = new List<String>(); 
        Map<Id,XC_Provisioning_Step__c> mapStepConfItemId = new Map<Id,XC_Provisioning_Step__c>();
        List<XC_Provisioning_Step__c> listProvisiongStepToUpdate = new List<XC_Provisioning_Step__c>();
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
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN004 - mapSteps---> '+mapSteps); 
   
        //List<Id> configurationItemList = new List<Id>(configurationItemMap.keyset());

        Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> wrapperConfItemMap = XC_UTIL_ComplianceMaster.getComplianceMaster(Label.XC_CL_Compliance_C2, confItemListId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN004 - wrapperConfItemMap---->' + wrapperConfItemMap); 
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        for(Id confItemId : mapStepConfItemId.keyset()){
            XC_UTIL_ComplianceMaster.ComplianceWrapperResult wr = wrapperConfItemMap.get(confItemId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN004 - wrapper ---->' + wrapperConfItemMap);

            if(wr != null){
                if(wr.check){
                    NE__OrderItem__c confItem = new NE__OrderItem__c(Id = confItemId);
                    orderItemList.add(confItem);
                    //orderItemList.add(configurationItemMap.get(confItemId));    
                } else {
                    XC_Provisioning_Step__c step = mapStepConfItemId.get(confItemId);
                    step.XC_Status__c = Label.XC_CL_Step_Skipped;
                    listProvisiongStepToUpdate.add(step);
                }
            }
        }
        //UPDATE RECORDS
        List<XC_UTIL_Sobject.WrapperResult> dmlResultList = XC_UTIL_SObject.updateListRecords(listProvisiongStepToUpdate);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN004 - dmlResult ---->' + dmlResultList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN004 - orderItemList ---->' + orderItemList);


        if(XC_UTIL_Sobject.checkDMLResults(dmlResultList) && !orderItemList.isEmpty()){
            Map<Id, List<String>> documentIdMap = XC_UTIL_DocumentComplianceMaster.getDocumentComplianceMaster(Label.XC_CL_Compliance_C2, orderItemList); 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ documentIdMap ---> ' + documentIdMap);
            //CALL THE METHOD TO CREATE XC_ComplianceVerificationStatus__c AND Case
            if(!documentIdMap.isEmpty()){
                XC_LCC069_ComplianceVerification1.cvsWrapper cvs = new XC_LCC069_ComplianceVerification1.cvsWrapper();
                cvs.mapOrderitemDocument = documentIdMap;
                cvs.complianceType = Label.XC_CL_Compliance_C2;
                cvs.orderId = mapSteps.get(listStepIds[0]).XC_Configuration_Item__r.NE__OrderId__c;
                cvs.mapOrderitemCompliance = wrapperConfItemMap;
                XC_LCC069_ComplianceVerification1.createComplianceVerificationStatus(cvs);
            }
        }
    }  
}