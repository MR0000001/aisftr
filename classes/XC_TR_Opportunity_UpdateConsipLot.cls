/**
* @author dpalamides
* @date 26/03/2021
* @description classes.XC_TR_Opportunity_UpdateConsipLot
*/


public without sharing class XC_TR_Opportunity_UpdateConsipLot {


    public static void checkOpportunities(Map<id,Opportunity> mapOld, Map<id,Opportunity> mapNew) {
        List<String> fieldList = new List<String>{
                'StageName' , 'XC_AdditionalAct__c'
        };
        List<Opportunity> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if (listChanged.isEmpty()) {
            return;
        }else{
            calculateAmounts(listChanged);
        }
    }

    public static void checkOrderItems(Map<id,NE__OrderItem__c> mapOld, Map<id,NE__OrderItem__c> mapNew) {
        List<String> fieldList = new List<String>{
                'NE__Qty__c','XC_RecurringDuration__c','NE__OneTimeFeeOv__c','NE__RecurringChargeOv__c'
        };
        List<NE__OrderItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if (listChanged.isEmpty()) {
            return;
        }
        List<NE__Order__c> listQuotes = [select id,NE__OptyId__c from NE__Order__c where id in :XC_UTIL_Sobject.getListFieldValues(listChanged,'NE__OrderId__c') and RecordType.developerName = 'Quote'];
        if (listQuotes.isEmpty()) {
            return;
        }
        List<Opportunity> listToProcess = (List<Opportunity>) XC_UTIL_Sobject.selectAllFields(XC_UTIL_Sobject.getListFieldValues(listQuotes,'NE__OptyId__c'),'Opportunity');
        if(listToProcess.isEmpty()) {
            return;
        }else{
            calculateAmounts(listToProcess);
        }
    }


    public static void checkOrders(Map<id,NE__Order__c> mapOld, Map<id,NE__Order__c> mapNew) {
        List<String> fieldList = new List<String>{
                'XC_SummaryQuoteAmount__c','XC_ConsipQuoteType__c'
        };
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if (listChanged.isEmpty()) {
            return;
        }

        List<Opportunity> listToProcess = (List<Opportunity>) XC_UTIL_Sobject.selectAllFields(XC_UTIL_Sobject.getListFieldValues(listChanged,'NE__OptyId__c'),'Opportunity');
        if(listToProcess.isEmpty()) {
            return;
        }else{
            calculateAmounts(listToProcess);
        }
    }

    public static void calculateAmounts(List<Opportunity> listChanged){
        if(listChanged.isEmpty()){
            return;
        }
        Map<Id,XC_ConsipLot__c> lotMap = new Map<Id,XC_ConsipLot__c>([select id,XC_ContractualExtension__c
                                                                                ,XC_IssuedProjectAmount__c
                                                                                ,XC_ProjectsNotAcceptedAmount__c
                                                                                ,XC_LotNumber__c
                                                                                ,XC_OPFAmount__c
                                                                                ,XC_ResidualAmount__c
                                                                                ,XC_SaturatedLot__c
                                                                                ,XC_SummaryQuoteAmount__c
                                                                                ,XC_TotalAmount__c from XC_ConsipLot__c where id in :XC_UTIL_Sobject.getListFieldValues(listChanged,'XC_ConsipLot__c')]);

        if(lotMap.isEmpty()){
            return;
        }
        List<Opportunity> allOpportunities = [select id,XC_ConsipLot__c,StageName,XC_AdditionalAct__c,
                                                    (select id,XC_Status__c, RecordType.DeveloperName, XC_SummaryQuoteAmount__c, XC_ConsipQuoteType__c from NE__Orders__r)
                                                from Opportunity where XC_ConsipLot__c in :lotMap.keySet()];
        Map<String,Decimal>  mapOPF = getOPFbyOpportunity(allOpportunities);

        for(XC_ConsipLot__c lot : lotMap.values()){
            lot.XC_OPFAmount__c = 0;
            lot.XC_SummaryQuoteAmount__c = 0;
            lot.XC_ProjectsNotAcceptedAmount__c = 0;
            lot.XC_ProjectsNotAcceptedAmountEST__c = 0;
            lot.XC_IssuedProjectAmount__c = 0;
            lot.XC_IssuedProjectAmountEST__c = 0;
            lot.XC_ResidualAmount__c = lot.XC_TotalAmount__c;
        }

        for(Opportunity opp : allOpportunities){
            XC_ConsipLot__c lot = lotMap.get(opp.XC_ConsipLot__c);
            NE__Order__c opty  = findOrder(opp.NE__Orders__r, 'Opty',null);
            NE__Order__c quoteSTD = findOrder(opp.NE__Orders__r, 'Quote','STD');
            NE__Order__c quoteEST = findOrder(opp.NE__Orders__r, 'Quote','EST');

            if(lot == null){
                continue;
            }

            Decimal opfAmountSTD = mapOPF.containsKey(opp.Id+'§'+'STD') ? mapOPF.get(opp.Id+'§'+'STD') : 0;
            Decimal opfAmountEST = mapOPF.containsKey(opp.Id+'§'+'EST') ? mapOPF.get(opp.Id+'§'+'EST') : 0;
            Decimal opfAmount = opfAmountSTD + opfAmountEST;

            if(opp.StageName == 'Closed Won'){
                lot.XC_OPFAmount__c += opfAmount + (opp.XC_AdditionalAct__c!=null ? opp.XC_AdditionalAct__c : 0);
                lot.XC_ResidualAmount__c = lot.XC_TotalAmount__c - lot.XC_OPFAmount__c;
            }
            if(opp.StageName == 'In Progress'){
                Decimal xSTD = (quoteSTD != null && quoteSTD.XC_SummaryQuoteAmount__c != null ? quoteSTD.XC_SummaryQuoteAmount__c : opty != null && opty.XC_SummaryQuoteAmount__c != null ? opty.XC_SummaryQuoteAmount__c : 0);
                Decimal xEST = (quoteEST != null && quoteEST.XC_SummaryQuoteAmount__c != null ? quoteEST.XC_SummaryQuoteAmount__c : opty != null && opty.XC_SummaryQuoteAmount__c != null ? opty.XC_SummaryQuoteAmount__c : 0);
                Decimal x = xSTD >= xEST ? xSTD : xEST;
                lot.XC_SummaryQuoteAmount__c += x;
            }
            else if(opp.StageName == 'Presented Proposal'){
                lot.XC_ProjectsNotAcceptedAmount__c += opfAmountSTD;
                lot.XC_ProjectsNotAcceptedAmountEST__c += opfAmountEST;
                lot.XC_IssuedProjectAmount__c += opfAmountSTD;
                lot.XC_IssuedProjectAmountEST__c += opfAmountEST;
            }
            else if(((quoteSTD!= null && quoteSTD.XC_Status__c == 'Accepted') || (quoteEST!= null && quoteEST.XC_Status__c == 'Accepted')) || opp.StageName == 'Accepted Proposal' || opp.StageName == 'Signed Contract' || opp.StageName == 'Closed Won'){
                lot.XC_IssuedProjectAmount__c += opfAmountSTD;
                lot.XC_IssuedProjectAmountEST__c += opfAmountEST;
            }

        }

        XC_UTIL_DML.updateRecords(lotMap.values());


    }


    private static NE__Order__c findOrder(List<NE__Order__c> ords, String rt, String quoteType){
        for(NE__Order__c ord : ords){
            if(rt!='Quote' && ord.RecordType.DeveloperName == rt){
                return ord;
            }
            else if(rt=='Quote' && ord.RecordType.DeveloperName == rt && ord.XC_ConsipQuoteType__c == quoteType){
                return ord;
            }
        }
        return null;
    }


    private static Map<String,Decimal> getOPFbyOpportunity(List<Opportunity> listOpp){
        Map<String,Decimal> retMap = new Map<String,Decimal>();
        Map<Id,NE__Order__c> quoteMap = new  Map<Id,NE__Order__c>([select id,NE__OptyId__c,XC_ConsipQuoteType__c,XC_OPFAmount__c, (select id, XC_RecurringDuration__c, XC_RecurringPeriodType__c, NE__Root_Order_Item__r.XC_RecurringPeriodType__c, NE__RecurringChargeOv__c,NE__OneTimeFeeOv__c,NE__Qty__c from NE__Order_Items__r
                                                                                                where recordType.developerNAme != 'Technical_Item')
                                                                    from NE__Order__c
                                                                    where RecordType.DeveloperName = 'Quote' and NE__OptyId__c = :XC_UTIL_Sobject.getIds(listOpp)]);

        for(NE__Order__c ord : quoteMap.values()){
            Decimal amountOPF = ord.XC_OPFAmount__c != null ? ord.XC_OPFAmount__c : 0;
            /*Decimal amountOPF = 0;
            for(NE__OrderItem__c oi : ord.NE__Order_Items__r){
                System.debug('oi->'+oi);
                amountOPF += (oi.NE__RecurringChargeOv__c != null && oi.XC_RecurringDuration__c != null )  ?
                             oi.NE__RecurringChargeOv__c * oi.NE__Qty__c * (oi.XC_RecurringDuration__c / getRecurringNumberOfMonths(oi.XC_RecurringPeriodType__c!=null ? oi.XC_RecurringPeriodType__c : 'Monthly')) : 0;
                amountOPF += oi.NE__OneTimeFeeOv__c != null ? oi.NE__OneTimeFeeOv__c : 0;
            }*/
            retMap.put(ord.NE__OptyId__c+'§'+ord.XC_ConsipQuoteType__c,amountOPF);
        }

        return retMap;
    }

    private static Integer getRecurringNumberOfMonths(String period){
        switch on period {
            when 'Monthly' {
                return 1;
            } when 'Annual' {
                return 12;
            } when 'Bi-Monthly' {
                return 2;
            } when 'Four-Monthly' {
                return 4;
            } when 'Biennial' {
                return 24;
            }when 'Biannual' {
                return 6;
            }when 'Quarter' {
                return 3;
            } when else{
                return 1;
            }
        }
    }


    /*public static void setConsipPicklist(Map<id,Opportunity> mapOld, Map<id,Opportunity> mapNew) {
    List<String> fieldList = new List<String>{
            'XC_ConsipLot__c'
    };
    List<Opportunity> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
    if (listChanged.isEmpty()) {
        return;
    }else{
        List<String> lots = XC_UTIL_Sobject.getListFieldValues(listChanged,'XC_ConsipLot__c');
        Map<Id,XC_ConsipLot__c> lotMap = new Map<Id,XC_ConsipLot__c>([select id, XC_LotNumber__c from XC_ConsipLot__c where id in :lots]);
        for(Opportunity opp : listChanged){

        }
    }
}*/

    public static void checkRPFVerification(Map<id,Opportunity> mapOld, Map<id,Opportunity> mapNew) {
        List<String> fieldList = new List<String>{
                'XC_RPFVerification__c'
        };
        List<Opportunity> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if (listChanged.isEmpty()) {
            return;
        }
        List<NE__Order__c> orderToUpdate = new List<NE__Order__c>();
        List<NE__Order__c> orderList = [select id, NE__OptyId__c from NE__Order__c where NE__OptyId__c in :XC_UTIL_Sobject.getIds(listChanged) and RecordType.DeveloperName = 'Opty'];
        Map<Id,NE__Order__c> optyMap = new Map<Id, NE__Order__c>();
        for(NE__Order__c ord : orderList){
            optyMap.put(ord.NE__OptyId__c, ord);
        }

        for(Opportunity opp : listChanged){
            /*if(opp.XC_RPFVerification__c == 'Documentazione non conforme' || opp.XC_RPFVerification__c == 'Lotto saturo'){
                opp.StageName = 'Closed Lost';
                opp.XC_LossReason__c = 'Other';
            }*/
            if(optyMap.containsKey(opp.Id) && opp.XC_RPFVerification__c != null){
                optyMap.get(opp.Id).XC_GenerateQuoteDocument__c = true;
                orderToUpdate.add(optyMap.get(opp.Id));
            }else if(!optyMap.containsKey(opp.Id)){
                opp.addError(Label.XC_CL_ConsipNoOptyRFP);
            }
        }

        XC_UTIL_DML.updateRecords(orderToUpdate);

    }

}