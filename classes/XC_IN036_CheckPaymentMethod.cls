/**
 * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 28/10/2019
 * @description XC_IN036_CheckPaymentMethod - Class to create a case for missing payment method 
 */ 

public without sharing class XC_IN036_CheckPaymentMethod {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN036_CheckPaymentMethod');

    /** @description CheckPaymentWrapper */
    public class CheckPaymentWrapper { 
        @Invocablevariable
        public String stepId = ''; 
        @Invocablevariable
        public Boolean isPaymentBarcodeInserted = false; 
    }

    /** 
    * @description UtilWrapper util wrapper for the class. 
    */
    public class UtilWrapper{
        public String accountId;
        public String contactId;
        public String configurationId;
        public String configurationItemId;
    }

    /**
      * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
      * @date Creation 28/10/2019
      * @description Method to check if a new Case has to be created
      * @param listInputWrapper - CheckPaymentWrapper
      */
    @InvocableMethod 
    public static void checkPaymentMethods(List<CheckPaymentWrapper> listInputWrapper) {
        System.debug('@@@ checkPaymentMethods START');
        CheckPaymentWrapper cpw = listInputWrapper[0];
        if(cpw.isPaymentBarcodeInserted) {
            // If Payment Method is Barcode but Payment is not ok
            createCase('XC_BCode_Activation_CheckPaymentMethod', cpw.stepId);
        }   
        else {
            // If Payment Method doesn't exists
            createCase('XC_SSII_Activation_CheckPaymentMethod', cpw.stepId);
            
        }     
    }

    private static void createCase(String customMetadataRecordName, String stepId){
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{customMetadataRecordName});
            XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(customMetadataRecordName);
            if(caseMDT == null) {
                throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', customMetadataRecordName}));
            }
            UtilWrapper utilWr = getParentsInfo(stepId);
            Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
            c.AccountId = utilWr.accountId;
            c.XC_Order__c = utilWr.configurationId;
            c.ContactId = utilWr.contactId;
            //c.Origin = 'CAN002';
            c.XC_ProvisioningStep__c = stepId;
            c.XC_OrderItem__c = utilWr.configurationItemId;
            XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.insertRecord(c);
            System.debug('createCase: ' + wr);
    }


    /**
    * @description Gets the info from step.
    * @param stepId the id of step
    * @return 
    **/
    private static UtilWrapper getParentsInfo(String stepId){
        
        UtilWrapper wrapper = new UtilWrapper();
        NE__OrderItem__c orderItemFather = new NE__OrderItem__c();
        List<String> configurationItemIds = new List<String>(); 
        
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id,XC_Provisioning_Step__c> ([
            SELECT XC_Configuration_Item__c
            FROM XC_Provisioning_Step__c 
            WHERE Id = :stepId
        ]);
        List<XC_Provisioning_Step__c> listSteps =  mapSteps.values();
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_Configuration_Item__c)){
                wrapper.configurationItemId = step.XC_Configuration_Item__c;
                configurationItemIds.add(step.XC_Configuration_Item__c);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'stepId -->' + stepId);
        
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>([
                SELECT id, NE__OrderId__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, (SELECT id, AccountId from Assets__r) 
                FROM NE__OrderItem__c 
                WHERE Id IN: configurationItemIds
            ]);             
        
        if(!configurationItemMap.isEmpty()){
            NE__OrderItem__c oi = configurationItemMap.values()[0];
            wrapper.configurationId = oi.NE__OrderId__c;
            wrapper.contactId = oi.NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
            if(!oi.Assets__r.isEmpty()){
                wrapper.accountId = oi.Assets__r[0].AccountId;
            }
        }
        return wrapper; 
    }
}