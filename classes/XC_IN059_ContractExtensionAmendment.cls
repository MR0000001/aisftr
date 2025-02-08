/**
 * @author Andrea Di Cicco
 * @date Creation 10/08/2020
 * @description This class is used to create an amendment for contract extension
 */ 
public with sharing class XC_IN059_ContractExtensionAmendment {
	/** 
    * @description InputWrapper the input wrapper.
    */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }
    
   /** 
    * @description Invocable method to launch the creation of an amendment for contract extension
    * @param inputWrapperList
    */
    @InvocableMethod 
    public static void createAmendmentContract(List<InputWrapper> inputWrapperList) {       
        XC_REST_UpdateSubscription.WrapperRequest wrapperReq = new XC_REST_UpdateSubscription.WrapperRequest();
        XC_REST_UpdateSubscription.WrapperResponse wrapperRes = new XC_REST_UpdateSubscription.WrapperResponse();
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
        String subscriptionId = '';
        
        if(inputWrapperList.isEmpty()){
            return;
        }
        step = retrieveConfigurationInfo( inputWrapperList.get(0).stepId);
        subscriptionId = retrivesubscriptionId( step.XC_Configuration_Item__c);
        wrapperReq =  populateWrapperReq( step);
        wrapperRes = XC_REST_UpdateSubscription.updateSubscription(subscriptionId, wrapperReq);
        System.debug(wrapperRes);
        if(!wrapperRes.success){
            manageStatus(step, Label.XC_CL_Step_CompletedKO);
        }
        manageStatus(step, Label.XC_CL_Completed_Ok); 
    }
    
    private static void manageStatus(XC_Provisioning_Step__c step, String status){
        step.XC_Status__c = status;
        XC_UTIL_Sobject.updateRecord(step);
    }

    private static XC_Provisioning_Step__c retrieveConfigurationInfo(String stepId){
        List<XC_Provisioning_Step__c> provisioningInformation = new List<XC_Provisioning_Step__c>();
        if(!Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            return null;
        }

        provisioningInformation = [SELECT  XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c,
                                            XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c,
                                            XC_Configuration_Item__r.NE__OrderId__r.XC_ExtensionMonths__c, 
                                            XC_Configuration_Item__c
                                    FROM  XC_Provisioning_Step__c 
                                    WHERE Id = : stepId ];

        return provisioningInformation.get(0);
    }   

    private static String retrivesubscriptionId(String configurationItemId){
        List<Asset> relatedAsset = new List<Asset>();
        if(Schema.sObjectType.Asset.isAccessible()){
            relatedAsset = [Select XC_SubscriptionName__c, XC_Configuration_Item__c  from Asset where XC_Configuration_Item__c = : configurationItemId];
        }
        System.debug('related Asset Name' + relatedAsset.get(0).XC_SubscriptionName__c);
        if(relatedAsset.get(0) == null || relatedAsset.get(0).XC_SubscriptionName__c == null){
            return '';
        }
        return relatedAsset.get(0).XC_SubscriptionName__c;
    }

    private static XC_REST_UpdateSubscription.WrapperRequest populateWrapperReq(XC_Provisioning_Step__c step){
        XC_REST_UpdateSubscription.WrapperRequest populateWrapperReq = new XC_REST_UpdateSubscription.WrapperRequest();
        populateWrapperReq.legalEntity = step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
        populateWrapperReq.stream = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
        //populateWrapperReq.applyCreditBalance= false;
        //populateWrapperReq.collectX=false;
        //populateWrapperReq.runBilling= false;
        populateWrapperReq.renewalTerm = Integer.valueOf(step.XC_Configuration_Item__r.NE__OrderId__r.XC_ExtensionMonths__c);
        populateWrapperReq.renewalTermPeriodType = 'Month';
        populateWrapperReq.autoRenew = false;

        return populateWrapperReq;
    }
    
}