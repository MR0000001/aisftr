/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 04/03/2020
* @date Modification 
* @description XC_TR_Configuration_U_ExternalFinancing - Class to createExternal Financing Case . 
*/ 
public without sharing class XC_TR_Configuration_U_ExternalFinancing {

     /**
     * @author Domenico Del Prete - domenico.delprete@nttdata.com
     * @date 04/03/2020
     * @description Method to create External Financing Case
     * @param orderItemList - List<NE__OrderItem__c>
     */
    public static void checkExternalFinancingPayment(List<NE__Order__c> confList, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'RecordTypeId'}, mapOld, mapNew);
        String rtOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        if(listChanged.isEmpty()){
                return;
        }
        List<String> orderIds = (List<String>) XC_UTIL_Sobject.getIds(listChanged);
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_ExternalFinancing});
        XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_ExternalFinancing);
        Map<Id, NE__Order__c> mapExternalFinancingCase = XC_TR_ConfigurationItem_U_BillingModel.getExternalFinancingCase(orderIds, caseMDT);
        if(caseMDT == null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_ExternalFinancing}));
        }
        Map<String,Case> caseMapToInsert = new Map<String,Case>();
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c, XC_BillingProfileLineItem__c, XC_PaymentMethod__c FROM NE__OrderItem__c WHERE NE__OrderId__c IN:confList]);
        for(NE__OrderItem__c orderIt : orderItemList){
            if(orderIt.XC_PaymentMethod__c == 'External Financing' && 
                mapExternalFinancingCase.get(orderIt.NE__OrderId__c).XC_Cases__r.isEmpty() &&
                orderIt.XC_BillingProfileLineItem__c != null && 
                mapExternalFinancingCase.get(orderIt.NE__OrderId__c).RecordTypeId == rtOrder 
            ) {
                Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
                c.AccountId = mapExternalFinancingCase.get(orderIt.NE__OrderId__c).NE__AccountId__c;
                c.ContactId = mapExternalFinancingCase.get(orderIt.NE__OrderId__c).NE__OptyId__r.XC_Contact__c;
                //c.Origin = Label.XC_CL_CaseOriginCAN002;
                c.XC_Order__c = orderIt.NE__OrderId__c;
                caseMapToInsert.put(c.XC_Order__c, c); 
            }
        }
        XC_UTIL_Sobject.insertListRecords(caseMapToInsert.values());
        XC_UTIL_Sobject.runAssignmentRules(caseMapToInsert.values(),'Case');
    }
}