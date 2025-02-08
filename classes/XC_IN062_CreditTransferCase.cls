/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 11-06-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   10-05-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_IN062_CreditTransferCase {


    
    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }


    /**
    * @description create a credit transfer case for italy management
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-05-2020 
    * @param inputs 
    **/
    @InvocableMethod 
    public static void createCreditTransferCase(List<InputWrapper> inputs){

        if(!inputs.isEmpty()){

            Map<Id,XC_Provisioning_Step__c> mapSteps = getMapSteps(inputs);
            List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();
            List<Case> caseToCreate = new List<Case>();

            //getting case settings Change Label
            Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_CreditTransfer});
            XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_CreditTransfer);
            //getting assignment rule info
            AssignmentRule ar = new AssignmentRule();
            ar = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
            Database.DMLOptions opts = new Database.DMLOptions();
            opts.AssignmentRuleHeader.AssignmentRuleId = ar.Id;

            //getting bundle Ids
            List<String> bundleIds = new List<String>();
            for(XC_Provisioning_Step__c step : mapSteps.values()){
                bundleIds.add(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c);
            }

            Map<String,Asset> assetConfItemMap = getConfigurationItemAsset(XC_UTIL_Sobject.getListFieldValues(mapSteps.values(),'XC_Configuration_Item__c'));
            Map<String,NE__OrderItem__c> bundleIncentiveItemMap = getIncentiveItem(bundleIds);

            for(XC_Provisioning_Step__c step : mapSteps.values()){
                    //check if step item has credit assignment
                if(step.XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c){
                    //manage case creation
                    Case c = createCaseFromStepAndSetting(caseMDT,step);
                    c.setOptions(opts);
                    c.AssetId = assetConfItemMap.containsKey(step.XC_Configuration_Item__c) ? assetConfItemMap.get(step.XC_Configuration_Item__c).Id : null;
                    c.XC_ConfigurationItemIncentive__c = bundleIncentiveItemMap.containsKey(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c) ? bundleIncentiveItemMap.get(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c).Id : null;
                    caseToCreate.add(c);
                    step.XC_Status__c = Label.XC_CL_Completed_Ok;
                }else{
                    step.XC_Status__c = Label.XC_CL_Step_Skipped;
                }
                stepsToUpdate.add(step);
            }
            XC_UTIL_Sobject.insertListRecords(caseToCreate);
            XC_UTIL_Sobject.updateListRecords(stepsToUpdate);

        }
    }

    /**
    * @description query for provisioning steps
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-05-2020 
    * @param inputs 
    * @return Map<Id, XC_Provisioning_Step__c> 
    **/
    private static Map<Id,XC_Provisioning_Step__c> getMapSteps(List<InputWrapper> inputs){

        Set<String> stepIds = new Set<String>();
        for(InputWrapper iw : inputs){
            stepIds.add(iw.stepId);
        }

        return new Map<Id,XC_Provisioning_Step__c>([SELECT ID,XC_Status__c, XC_Configuration_Item__c,XC_Configuration_Item__r.Name,
        XC_Configuration_Item__r.XC_PaymentMethod__c,XC_Configuration_Item__r.NE__OrderId__c, 
        XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c, XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c,
        XC_Configuration_item__r.NE__Bundle_Configuration__r.Name,XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c,
        XC_Configuration_item__r.NE__OrderId__r.NE__AccountId__c,XC_Configuration_item__r.NE__OrderId__r.NE__OptyId__r.XC_Contact__c
        FROM XC_Provisioning_Step__c WHERE Id IN :stepIds]);

    }

    /**
    * @description create a case based on the field setting 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-05-2020 
    * @param cts 
    * @param step 
    * @return Case 
    **/
    private static Case createCaseFromStepAndSetting(XC_CM_Case_Type_Setting__mdt cts,XC_Provisioning_Step__c step){

        Case creditTransferCase = XC_UTIL_Case.initCaseFromCaseSettings(cts);
        creditTransferCase.XC_OrderItem__c = step.XC_Configuration_Item__c;
        creditTransferCase.AccountId = step.XC_Configuration_item__r.NE__OrderId__r.NE__AccountId__c;
        creditTransferCase.ContactId = step.XC_Configuration_item__r.NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
        creditTransferCase.XC_ProvisioningStep__c = step.Id;
        creditTransferCase.XC_Order__c = step.XC_Configuration_item__r.NE__OrderId__c;
        creditTransferCase.XC_LegalEntity__c = step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
        creditTransferCase.XC_Segment__c = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
        return creditTransferCase;

    } 

    /**
    * @description get the asset related to the provisioning master configurationItem
    * @author Francesco Imperioli - fimperioli@deloitte.it | 11-06-2020 
    * @param confItemIds 
    * @return Map<String, Asset> 
    **/
    private static Map<String,Asset> getConfigurationItemAsset (List<String> confItemIds){
        Map<String,Asset> result = new Map<String,Asset>();
        List<Asset> assetList = [SELECT Id,XC_Configuration_Item__c FROM Asset WHERE XC_Configuration_Item__c IN : confItemIds];
        for(Asset asst : assetList){
            if(!result.containsKey(asst.XC_Configuration_Item__c)){
                result.put(asst.XC_Configuration_Item__c,asst);
            }
        }
        return result;
    }

    /**
    * @description returns the incentive item in the provisioning master order item bundle configuration
    * @author Francesco Imperioli - fimperioli@deloitte.it | 11-06-2020 
    * @param bundleIds 
    * @return Map<String, NE__OrderItem__c> 
    **/
    private static Map<String,NE__OrderItem__c> getIncentiveItem (List<String> bundleIds){

        Map<String,NE__OrderItem__c> result = new Map<String,NE__OrderItem__c>();

        List<NE__OrderItem__c> incentiveItems = [SELECT Id,NE__Bundle_Configuration__c 
        FROM NE__OrderItem__c 
        WHERE NE__Bundle_Configuration__c IN : bundleIds AND XC_Product_Subtype__c = :Label.XC_CL_ProductSubtypeIncentive];
        
        for(NE__OrderItem__c incentiveOi : incentiveItems){
            if(!result.containsKey(incentiveOi.NE__Bundle_Configuration__c)){
                result.put(incentiveOi.NE__Bundle_Configuration__c,incentiveOi);
            }
        }

        return result;

    }

}