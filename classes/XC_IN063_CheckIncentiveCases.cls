/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 10-06-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   10-06-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_IN063_CheckIncentiveCases {

    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }


    /**
    * @description check if steps have to be considered in this flow or have to be skipped
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param inputs 
    **/
    @InvocableMethod 
    public static void checkClosedCases(List<InputWrapper> inputs){


        if(!inputs.isEmpty()){

            Map<Id,XC_Provisioning_Step__c> stepsMap = getStepsMap(inputs);
            List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();

            Map<String,XC_Provisioning_Step__c> confItemStepMap = new Map<String,XC_Provisioning_Step__c>();


            for(XC_Provisioning_Step__c step : stepsMap.values()){
                if(step.XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c){
                    confItemStepMap.put(step.XC_Configuration_Item__c,step);
                }else{
                  step.XC_Status__c = Label.XC_CL_Step_Skipped;
                  stepsToUpdate.add(step);
                }
            }

            if(!confItemStepMap.isEmpty()){
                stepsToUpdate.addAll(checkIfCasesAreClosed(confItemStepMap));
            }

            XC_UTIL_Sobject.updateListRecords(stepsToUpdate);

        }




    }


    /**
    * @description retrieve provisioning steps infos
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param inputs 
    * @return Map<Id, XC_Provisioning_Step__c> 
    **/
    private static Map<Id,XC_Provisioning_Step__c> getStepsMap(List<InputWrapper> inputs){

        Set<String> stepIds = new Set<String>();
        for(InputWrapper iw : inputs){
            stepIds.add(iw.stepId);
        }

        return new Map<Id,XC_Provisioning_Step__c>([SELECT ID,XC_Status__c, XC_Configuration_Item__c,XC_Configuration_Item__r.Name,
        XC_Configuration_Item__r.XC_PaymentMethod__c,XC_Configuration_Item__r.NE__OrderId__c, 
        XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c,
        XC_Configuration_item__r.NE__Bundle_Configuration__r.Name,XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c,
        XC_Configuration_item__r.NE__OrderId__r.NE__AccountId__c,XC_Configuration_item__r.NE__OrderId__r.NE__OptyId__r.XC_Contact__c
        FROM XC_Provisioning_Step__c WHERE Id IN :stepIds]);



    }


    /**
    * @description check if each orderitem has 2 closed cases and unlock the steps
    * @author Francesco Imperioli - fimperioli@deloitte.it | 10-06-2020 
    * @param confItemStepMap 
    * @return List<XC_Provisioning_Step__c> 
    **/
    private static List<XC_Provisioning_Step__c> checkIfCasesAreClosed(Map<String,XC_Provisioning_Step__c> confItemStepMap){

        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_CreditTransfer,Label.XC_CL_CMD_AdministrativeTask});
        XC_CM_Case_Type_Setting__mdt creditTransferCaseSetting = mapCaseSetting.get(Label.XC_CL_CMD_CreditTransfer);
        XC_CM_Case_Type_Setting__mdt incentiveCaseSetting = mapCaseSetting.get(Label.XC_CL_CMD_AdministrativeTask);
        Set<String> stepLabels = new Set<String>{'Documental Check','Credit Transfer Case'};
        Map<String,List<Case>> confItemCasesMap = new Map<String,List<Case>>();
        List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();

        List<Case> cases = [SELECT Id,
        XC_OrderItem__c,XC_ProvisioningStep__c,
        XC_ProvisioningStep__r.XC_StepLabel__c,
        Status 
        FROM Case
        WHERE XC_OrderItem__c IN :confItemStepMap.keySet() AND 
        XC_ProvisioningStep__r.XC_StepLabel__c IN :stepLabels AND
        ((Reason = :creditTransferCaseSetting.XC_Case_Reason__c	 AND SubCause__c = :creditTransferCaseSetting.XC_Sub_Cause__c) 
            OR (Reason = :incentiveCaseSetting.XC_Case_Reason__c AND Subcause__c = :incentiveCaseSetting.XC_Sub_Cause__c))
        ];

        //mapping cases and orderItems

        for(Case c : cases){
            if(!confItemCasesMap.containsKey(c.XC_OrderItem__c)){
                confItemCasesMap.put(c.XC_OrderItem__c,new List<Case>{c});
            }else{
                confItemCasesMap.get(c.XC_OrderItem__c).add(c);
            }
        }

        //checking if cases are closed
        for(String oiId : confItemCasesMap.keySet()){

            List<Case> casesListForOi = confItemCasesMap.get(oiId);
            if(casesListForOi.size() == 2){

                Boolean casesClosed = true;

                for(Case c : casesListForOi){
                    if(!c.Status.equalsIgnoreCase(Label.XC_CL_Case_Status007)){
                        casesClosed = false;
                    }
                }

                if(casesClosed){
                    XC_Provisioning_Step__c currentStep = confItemStepMap.get(oiId);
                    currentStep.XC_Status__c = Label.XC_CL_Completed_Ok;
                    stepsToUpdate.add(currentStep);
                }

            }
        }

        return stepsToUpdate;

    }


}