/**
 * @description       : generates virtual ibans on bank transfer order items for italy
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 08-17-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   08-17-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_IN061_ManageVirtualIBAN {


    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }

    /**
    * @description generates virtual ibans on bank transfer order items for italy
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-17-2020 
    * @param inputs 
    **/
    @InvocableMethod
    public static void manageVirtualIBAN(List<InputWrapper> inputs){

        if(!inputs.isEmpty()){

            List<String> stepIds = new List<String>();
            for(InputWrapper iw : inputs){
                stepIds.add(iw.stepId);
            }
            Map<Id, XC_Provisioning_Step__c> mapSteps = getMapSteps(stepIds);
            List<XC_Provisioning_Step__c> stepsToSkip = new List<XC_Provisioning_Step__c>();
            List<XC_Provisioning_Step__c> stepsToProcess = new List<XC_Provisioning_Step__c>();

            for(XC_Provisioning_Step__c step : mapSteps.values()){
                if(step.XC_Configuration_Item__r.XC_PaymentMethod__c == 'Bank Transfer'){
                    stepsToProcess.add(step);
                }else{
                    step.XC_Status__c = Label.XC_CL_Step_Skipped;
                    stepsToSkip.add(step);
                }
            }

            if(!stepsToSkip.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(stepsToSkip);
            }

            if(!stepsToProcess.isEmpty()){
                generateVirtualIBAN(stepsToProcess);
            }

        }

    }

    /**
    * @description generate virtual IBANs as the new bank transfer code for order items
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-17-2020 
    * @param stepsToProcess 
    **/
    @TestVisible
    private static void generateVirtualIBAN(List<XC_Provisioning_Step__c> stepsToProcess){

        List<NE__OrderItem__c> oisToUpdate = new List<NE__OrderItem__c>();
        XC_Provisioning_Step__c masterStepToProcess = stepsToProcess[0];

        XC_VirtualIBANAssociation__c vIBANass = new XC_VirtualIBANAssociation__c();
        XC_UTIL_Sobject.WrapperResult vIBANassResult = XC_UTIL_Sobject.insertRecord(vIBANAss);

        //if virtual iban insertion is ok, the virtual iban value field will be copied on the orderitem
        if(vIBANassResult.success){

            XC_VirtualIBANAssociation__c IBAN = [SELECT Id,XC_IBAN__c 
            FROM XC_VirtualIBANAssociation__c 
            WHERE ID = :vIBANassResult.recordId LIMIT 1];

            System.Debug('VIRTUAL IBAN FOUND:: ' + IBAN.XC_Iban__c);

            NE__OrderItem__c provisionedItem = new NE__OrderItem__c(
                Id=masterStepToProcess.XC_Configuration_Item__c, 
                XC_BankTransferCode__c = IBAN.XC_Iban__c);
            
            oisToUpdate.add(provisionedItem);
            
            //check if we are in bundle case
            if(String.isNotBlank(masterStepToProcess.XC_Configuration_Item__r.NE__Bundle_Configuration__c)){

                NE__OrderItem__c provisionedItemBundle = new NE__OrderItem__c(
                    Id=masterStepToProcess.XC_Configuration_Item__r.NE__Bundle_Configuration__c, 
                    XC_BankTransferCode__c = IBAN.XC_Iban__c);

                oisToUpdate.add(provisionedItemBundle);
            }

            List<XC_UTIL_Sobject.WrapperResult> oisUpdateResult = XC_UTIL_Sobject.upsertListRecords(oisToUpdate);

            if(XC_UTIL_Sobject.checkDMLResults(oisUpdateResult)){

                masterStepToProcess.XC_Status__c = 'Completed OK';
                XC_UTIL_Sobject.updateRecord(masterStepToProcess);

                return;
            }

            masterStepToProcess.XC_Status__c = 'Completed KO';
            masterStepToProcess.XC_ErrorMessage__c = oisUpdateResult[0].errorMessage;
            XC_UTIL_Sobject.updateRecord(masterStepToProcess);
            return;
        }

        masterStepToProcess.XC_ErrorMessage__c = vIBANassResult.errorMessage;
        masterStepToProcess.XC_Status__c = 'Completed KO';
        XC_UTIL_Sobject.updateRecord(masterStepToProcess);

    }


    /**
    * @description retrieves informations on the provisioning step
    * @author Francesco Imperioli - fimperioli@deloitte.it | 08-17-2020 
    * @param listStepIds 
    * @return Map<Id, XC_Provisioning_Step__c> 
    **/
    public static Map<Id, XC_Provisioning_Step__c> getMapSteps(List<Id> listStepIds) {
        if(!Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            return new Map<Id, XC_Provisioning_Step__c>();
        }
		Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT ID,XC_Status__c, XC_Configuration_Item__c,XC_Configuration_Item__r.Name,
                XC_Configuration_Item__r.XC_PaymentMethod__c,XC_Configuration_Item__r.NE__OrderId__c, 
                XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c,
                XC_Configuration_item__r.NE__Bundle_Configuration__r.Name
                 FROM XC_Provisioning_Step__c 
                 WHERE Id IN: listStepIds]);
		return mapSteps;
    }

}