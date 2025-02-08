/**
 * The Class XC_TR_Configuration_ManageCompletedQuote.
 *
 * @author            : Domenico Del Prete - domenico.delprete@nttdata.com
 * @date Creation     : 15/11/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Class to manage completed quote
 **/ 
public without sharing class XC_TR_Config_U_ManageCompletedQuote {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_ManageCompletedQuote');

    /**
    * @description 
    * @author Del Prete Domenico | 18/11/2019 
    * @param listNew 
    * @param mapOld 
    * @param mapNew
    **/
    public static void manageCompletedQuote(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_Status__c'}; 
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            populateQuoteList(listChanged);
        }

    }

    private static void populateQuoteList(List <NE__Order__c> listChanged){
        List <NE__Order__c> quoteOrder = new List <NE__Order__c>();
        List<String> optyId = new List <String>();
        Id recTypeQuote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Order_RecordTypeQuote).getRecordTypeId();
        for(NE__Order__c ord : listChanged){
            if(ord.RecordTypeId.equals(recTypeQuote) && ord.XC_Status__c.equals(Label.XC_CL_Configuration_QuoteRejected)){
                quoteOrder.add(ord);
                optyId.add(ord.NE__OptyId__c);
            }  
        }
        if(!quoteOrder.isEmpty()){
            manageQuoteRejected(optyId);
        }
    }

    private static void manageQuoteRejected (List<String> optyListId){
        List<Opportunity> listOfOpp = new List<Opportunity>([SELECT Id, XC_WorkOrder__c, XC_WorkOrder__r.ParentWorkOrderId, XC_WorkOrder__r.XC_StatusReason__c
                                                              FROM Opportunity
                                                              WHERE Id IN:(optyListId) AND XC_WorkOrder__r.XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_Repair]);       
        if(listOfOpp.isEmpty()){
            return;
        }
        List<String> parentWorkOrderList = new List<String>();
        for(Opportunity opp : listOfOpp){
            parentWorkOrderList.add(opp.XC_WorkOrder__r.ParentWorkOrderId);
        }
        List<XC_DictamenItem__c> listOfDictamen = new List<XC_DictamenItem__c>([SELECT Id, XC_Precintar__c, XC_WorkOrder__c, XC_AnomalyResolvedIn__c
                                                                                FROM XC_DictamenItem__c 
                                                                                WHERE XC_WorkOrder__c IN:(parentWorkOrderList) 
                                                                                      AND XC_WorkOrder__r.XC_WorkTypeLabel__c =: Label.XC_CL_WorkTypeLabel_PlannedMaintenance]);
        if(listOfDictamen.isEmpty()){
            return;            
        }
        updateWoRepair(listOfDictamen, listOfOpp);
    }

    private static void updateWoRepair(List<XC_DictamenItem__c> listOfDictamen, List<Opportunity> listOfOpp){
        WorkOrder woToUpdate = new WorkOrder();
        for(Opportunity opp : listOfOpp){
            if(opp.XC_WorkOrder__r.ParentWorkOrderId.equals(listOfDictamen[0].XC_WorkOrder__c)){
                woToUpdate.Id = opp.XC_WorkOrder__c;
                woToUpdate.XC_StatusReason__c = opp.XC_WorkOrder__r.XC_StatusReason__c;
                break;
            }
        }
        if(listOfDictamen[0].XC_Precintar__c.equals(Label.XC_CL_DictamenPrecintar_Sealed) && woToUpdate.XC_StatusReason__c!= Label.XC_CL_WorkOrder_SATObreakdown){
            woToUpdate.Status = Label.XC_CL_Completed;
        }else if (listOfDictamen[0].XC_Precintar__c.equals(Label.XC_CL_DictamenPrecintar_NotSealed) && !listOfDictamen[0].XC_AnomalyResolvedIn__c.equals(Label.XC_CL_DictamenAnomalyResolvedIn_Immediate)){
            woToUpdate.Status = Label.XC_CL_OnHold;
            woToUpdate.XC_StatusReason__c = Label.XC_CL_WorkOrder_Anomalies;
            if(listOfDictamen[0].XC_AnomalyResolvedIn__c.equals(Label.XC_CL_DictamenAnomalyResolvedIn_15Days)){
                woToUpdate.XC_DateVerificationOfRepairCase__c = Date.today().addDays(15);  
            }else if(listOfDictamen[0].XC_AnomalyResolvedIn__c.equals(Label.XC_CL_DictamenAnomalyResolvedIn_6Months)){
                woToUpdate.XC_DateVerificationOfRepairCase__c = Date.today().addMonths(6);
            }
            woToUpdate.XC_VerificationOfRepairRequested__c = true;
        }
        XC_UTIL_Sobject.updateRecord(woToUpdate); 
    }
}