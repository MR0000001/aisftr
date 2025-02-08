/**
 * Created by dolombardi on 30/03/2021.
 */

public with sharing class XC_LCC250_CreditCheckVerify {

    public class resultWrapper{
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String resultMessage = '';
    }

    /**
   * @author: Donato Lombardi 
   * @date Creation Date 09/09/2019
   * @description method calculate WBE
   * @param recordId Id
   * @return errorMsg String
   */
    @AuraEnabled
    public static resultWrapper submit(Id recordId) {
        resultWrapper rw = new resultWrapper();
        List<NE__OrderItem__c> listItems = retriveConfItem(recordId);
 /*GS*/ updatePaymentMethod(listItems);
        
        if(checkBillingModelIsFilled(listItems)){
            system.debug('checkBillingModelIsFilled');
            return populateWrapperFailedStopExecution(rw,Label.XC_CL_PaymentMethodsRequiredMess);
        }
/*
        if(checkContractIsSigned(listItems[0].NE__OrderId__r.NE__OptyId__c, listItems)){
            return populateWrapperFailedStopExecution(rw,Label.XC_CL_VerifyContractIsSigned);
        }
           */


        if(checkRecurringDuration(listItems)){
            system.debug('checkRecurringDuration');
            return populateWrapperFailedStopExecution(rw,Label.XC_CL_DurationField_Is_Filled);
        }

        if (checkInstallmentPlan(listItems)){
            system.debug('checkInstallmentPlan');
            return populateWrapperFailedStopExecution(rw,Label.XC_CL_CreditCheckInstallmentPlan);
        }


        if(checkMilestoneTotal(listItems[0].NE__OrderId__c)){
            system.debug('checkMilestoneTotal');
            return populateWrapperFailedStopExecution(rw,Label.XC_CL_MilestoneTotalRateErr);
        }
        if(checkSkipCreditCheck(listItems)){
            system.debug('checkSkipCreditCheck');
            return populateWrapperSuccess(rw,Label.XC_CL_CreditCheckNotRequired);

        }

        List<XC_CM_ThresholdCreditCheck__mdt> listCM = new List<XC_CM_ThresholdCreditCheck__mdt>();
        listCM = retrieveThresholdCreditCheckCM(listItems);

        // //[START,gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187]
        // if(listItems!=null && listItems.size()>0 && listItems[0].NE__OrderId__r!=null && 
        // 'B2B'.equalsIgnoreCase(listItems[0].XC_Segment__c) 
        // && 'Italy'.equalsIgnoreCase(listItems[0].NE__OrderId__r.XC_Country__c))
        // {
        // system.debug('checkBillingModelofOrder');
        // checkBillingModelofOrder(listItems); 
        // return populateWrapperSuccess(rw,'OK');
        // }
        // //[END,gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187]


         //[START,gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187]
         if(listItems!=null && !listItems.isEmpty() && listItems[0].NE__OrderId__r!=null &&
            'B2B'.equalsIgnoreCase(listItems[0].XC_Segment__c) && 'Installment Plan'.equalsIgnoreCase(listItems[0].XC_BillingModel__c) &&
            'eMobility'.equalsIgnoreCase(listItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessLine__c) &&
            'Italy'.equalsIgnoreCase(listItems[0].NE__OrderId__r.XC_Country__c))
        {
            system.debug('checkBillingModelofOrder');
            if(checkBillingModelofOrder(listItems)){
                return populateWrapperSuccess(rw,'OK');
            }
        }
     //[END,gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187]

        if(checkIsNotPresentInBlackList(listItems,listCM)){
            system.debug('checkIsNotPresentInBlackList1');
            return populateWrapperSuccess(rw,Label.XC_CL_CreditCheckNotEvaluated);
        }

        if(checkIsPresentInBlackList(listItems,listCM)){
            system.debug('checkIsNotPresentInBlackList2');
            return populateWrapperSuccess(rw,Label.XC_CL_CreditCheckNeedEvaluated);
        }

        if(checkGovernanceFirstLevel(listItems, listCM)){
            system.debug('checkGovernanceFirstLevel');
            return populateWrapperSuccess(rw,Label.XC_CL_CreditCheckNeedEvaluated);
        }

        if(checkGovernanceSecondLevel(listItems,listCM)){
            system.debug('checkGovernanceSecondLevel');
            return populateWrapperSuccess(rw,Label.XC_CL_CreditCheckNeedEvaluated);
        }
        /*if(checkGovernanceGreaterSecondLevel(listItems,listCM)){
            return populateWrapperSuccess(rw,Label.XC_CL_CreditCheckNeedEvaluated);
        }*/

        return populateWrapperSuccess(rw,'OK');
    }

    /**
* @author: Donato Lombardi
* @date Creation Date 09/09/2019
* @description method calculate WBE
* @param recordId Id
* @return errorMsg String
*/
    public static List<NE__OrderItem__c> retriveConfItem(Id recordId) {
        List<NE__OrderItem__c> listItems = new List<NE__OrderItem__c>();
        if (Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            listItems = [select Id, NE__Item_Code__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__CatalogItem__r.XC_ProductLine__c, NE__CatalogItem__r.XC_ProductServiceType__c,
                    NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c, NE__ProdName__c,NE__OrderId__r.Name, RecordType.DeveloperName,NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c,
                    NE__OrderId__r.XC_Subtype__c, RecordType.name,XC_Product_Subtype__c,NE__Parent_Order_Item__c, XC_BillingModel__c, NE__OrderId__r.XC_Segment__c,
                    NE__OrderId__r.NE__OptyId__r.XC_ContractStartDate__c,
                    NE__OrderId__r.NE__OptyId__r.XC_ContractEndDate__c,
                    NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c,
                    NE__OrderId__r.NE__OptyId__r.XC_CapexFullLife__c, 
                    NE__OrderId__r.NE__OptyId__r.XC_GrossMarginFullLife__c,
                    NE__OrderId__r.NE__OptyId__r.Contract.XC_ContractType__c,
                    NE__OrderId__r.NE__AccountId__r.IdentityType__c,
                    NE__OrderId__r.NE__AccountId__r.IdentityNumber__c,
                    NE__OrderId__r.NE__AccountId__r.Name,
                    NE__OrderId__r.NE__AccountId__c,
                    NE__OrderId__r.RecordType.DeveloperName,
                    NE__OrderId__r.NE__AccountId__r.XC_CheckBlacklist__c,
                    XC_Installation_Address__r.XC_PostalCode__c,
                    NE__OrderId__r.NE__OptyId__r.XC_ModeOfEngagement__c,
                    NE__OrderId__r.NE__OptyId__r.XC_LOT__c,
                    XC_Segment__c,
                    XC_LegalEntity__c,
                    InstallmentDivisionTax__c,
                    XC_InstallmentFrequency__c,
                    XC_InstallmentPlanType__c,
                    XC_InstallmentRate__c,
                    XC_InstallmentsNumber__c,
                    XC_BlockWBE_User__c,
                    XC_PaymentMethod__c,
                    NE__OrderId__r.XC_PlantOwnership__c,
                    NE__OrderId__r.XC_UpdateWBE_FromButton__c,
                    XC_WBE_Status__c,
                    NE__OrderId__r.NE__OptyId__r.XC_CreditCheck_GB__c, //gaurav.tejpal@accenture.com, 26/05/2022,Enel X - NR2187
                    XC_BillingProfileLineItem__c,
                    NE__OrderId__r.NE__OptyId__r.XC_Contact__c,
                    NE__OrderId__r.NE__OptyId__r.XC_ProductCategoryOfInterest__c,
                    NE__OrderId__r.NE__OptyId__r.XC_BusinessLine__c,
                    NE__OrderId__r.NE__OptyId__r.XC_Segment__c, NE__RecurringChargeOv__c, NE__OneTimeFeeOv__c, XC_EstimatedRevenue__c, XC_RecurringDuration__c,
                    NE__OrderId__r.NE__OptyId__r.XC_ContractType__c,NE__CatalogItem__c, NE__CatalogItem__r.NE__ProductId__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c,
                    NE__OrderId__r.XC_Country__c  //gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187
            from NE__OrderItem__c
            //  where NE__OrderId__c = :recordId
            where NE__OrderId__c = :recordId  AND RecordType.DeveloperName != 'Technical_Item' AND NE__Parent_Order_Item__c = null/* AND NE__ProdName__c != :Constants.B2B_PROJECT AND NE__ProdName__c != :Constants.B2G_PROJECT AND RecordType.DeveloperName != :Constants.B2W_RECORDTYPE_TECHNICALITEM*/
            ];
        }
        return listItems;
    }
    private static Boolean checkBillingModelIsFilled(List<NE__OrderItem__c> listItems){
        Boolean check = false;
        for(NE__OrderItem__c ne: listItems){
            if(ne.XC_BillingModel__c != 'Capex' && ne.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c !='OpenCharge B2B') {
                if (String.isBlank(ne.XC_BillingModel__c) || String.isBlank(ne.XC_PaymentMethod__c) || String.isBlank(ne.XC_BillingProfileLineItem__c)) {
                    return true;
                }
            }

        }
        return check;
    }

    private static Boolean checkMilestoneTotal(String recordId){
        Boolean check = False;

        AggregateResult[] groupedResults
                = [select sum(XC_Rate__c) tot, XC_OrderItem__c
        from XC_milestone__c
        where XC_OrderItem__r.NE__OrderId__c = :recordId
        and XC_OrderItem__r.XC_BillingModel__c = 'Milestone'
        group by XC_OrderItem__c];
        if(groupedResults.isEmpty()){
            return False;
        }

        for(AggregateResult res : groupedResults) {
            Double sumAmount = Double.valueOf(res.get('tot'));
            if(sumAmount!=100.0){
                return True;
            }
        }

        return check;
    }





/*
    private static Boolean checkContractIsSigned(String optyId, List<NE__OrderItem__c> listOrderItems) {
        if(listOrderItems[0].NE__OrderId__r.RecordType.DeveloperName =='Quote'){
            return false;
        }
        Boolean check = false;
        Map<Id, Contract> mapIdContractRelatedToOpportunity = new Map<Id, Contract>([select id, RecordType.DeveloperName, XC_Signed__c from Contract where Opportunity__c = :optyId]);
        if (mapIdContractRelatedToOpportunity.isEmpty()) {
            return false;
        }
        for (Contract c : mapIdContractRelatedToOpportunity.values()) {
            if (!c.XC_Signed__c) {
                check = true;
                return check;
            }
        }
        return check;
    }*/
    private static Boolean checkRecurringDuration(List<NE__OrderItem__c> listOrderItems){
        Boolean check = false;
        for(NE__OrderItem__c ne : listOrderItems){
            if(ne.XC_BillingModel__c == 'Recurring' && ne.XC_RecurringDuration__c == null){
               return true;
            }
        }
        return check;
    }

    public static Boolean checkInstallmentPlan(List<NE__OrderItem__c> listOrderItems){
        Boolean check = false;
        for(NE__OrderItem__c ne :listOrderItems){
            if(ne.RecordType.DeveloperName != 'Technical_Item' && ne.NE__Parent_Order_Item__c == null){
                if(ne.XC_BillingModel__c == 'Installment plan' || ne.XC_BillingModel__c == 'Billing Plan'){
                    if(checkIsNull(ne.InstallmentDivisionTax__c)
                       || checkIsNull(ne.XC_InstallmentFrequency__c)
                        || checkIsNull(ne.XC_InstallmentPlanType__c)
                        ||checkIsNull(ne.XC_InstallmentRate__c)
                        ||checkIsNull(ne.XC_InstallmentsNumber__c)) {
                                return true;
                        }
                    }
                }
        }
        return check;
    }
       /*New method for Open Charge B2B - 18/10/2021 -  Giulia Sciammarella */
        public static void updatePaymentMethod(List<NE__OrderItem__c> listOrderItems){
            for (NE__OrderItem__c oItem :listOrderItems){
                if (oItem.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c =='OpenCharge B2B' && oItem.XC_PaymentMethod__c != 'Commodity Bill'){
                    oItem.XC_PaymentMethod__c = 'Commodity Bill';
                }
            }
              XC_UTIL_Sobject.updateListRecords(listOrderItems);  
         }  
       /*New method for Open Charge B2B - 18/10/2021 -  Giulia Sciammarella */

    private static List<XC_CM_ThresholdCreditCheck__mdt> retrieveThresholdCreditCheckCM(List<NE__OrderItem__c>listOrderItems){

        List<XC_CM_ThresholdCreditCheck__mdt> listCM = new List<XC_CM_ThresholdCreditCheck__mdt>();
        listCM = [select id,XC_LegalEntity__c, XC_Country__c,
                XC_Productcategoryofinterest__c, XC_Segment__c,XC_GovernancelevelIIthreshold__c,
                XC_GovernancelevelIthreshold__c,XC_Materialitythreshold__c
        from XC_CM_ThresholdCreditCheck__mdt where XC_LegalEntity__c = :listOrderItems[0].XC_LegalEntity__c
        AND XC_Segment__c = :listOrderItems[0].XC_Segment__c
        /*AND XC_Productcategoryofinterest__c = :listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_ProductCategoryOfInterest__c*/] ;
        return listCM;

    }
    private static Boolean checkIsNotPresentInBlackList(List<NE__OrderItem__c> listOrderItems, List<XC_CM_ThresholdCreditCheck__mdt> listCM){
        Boolean check = false;
        Decimal amount = listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c == 'Capex Intensive'? listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_CapexFullLife__c : listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c;
        //System.debug('CM-->' + listCM[0].XC_Materialitythreshold__c);
        if((amount <= listCM[0].XC_Materialitythreshold__c || listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c == 'Capex Intensive' )
                && listOrderItems[0].NE__OrderId__r.NE__AccountId__r.XC_CheckBlacklist__c =='Customer not present in the blacklist')
        {
            check = true;
            listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_CreditCheck_GB__c = 'OK';
            XC_UTIL_Sobject.updateRecord(listOrderItems[0].NE__OrderId__r.NE__OptyId__r);
        }
        return check;

    }
    private static Boolean checkIsPresentInBlackList(List<NE__OrderItem__c> listOrderItems, List<XC_CM_ThresholdCreditCheck__mdt> listCM){
        Boolean check = false;
        Decimal amount = listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c == 'Capex Intensive'? listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_CapexFullLife__c : listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c;
        if((amount <= listCM[0].XC_Materialitythreshold__c || listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c == 'Capex Intensive')
                && listOrderItems[0].NE__OrderId__r.NE__AccountId__r.XC_CheckBlacklist__c =='KO - Customer present in the blacklist')
        {
            check = true;
            listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_CreditCheck_GB__c = 'TBR';
            XC_UTIL_Sobject.updateRecord(listOrderItems[0].NE__OrderId__r.NE__OptyId__r);
            createCase(listOrderItems);
        }
        return check;



    }
    private static Boolean checkGovernanceFirstLevel(List<NE__OrderItem__c> listOrderItems, List<XC_CM_ThresholdCreditCheck__mdt> listCM){
        Boolean check = false;
        Decimal amount = listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c == 'Capex Intensive'? listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_CapexFullLife__c : listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c;
        if((listCM[0].XC_Materialitythreshold__c >= amount
                && amount <= listCM[0].XC_GovernancelevelIthreshold__c) && listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c != 'Capex Intensive')
        {
            check = true;
            listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_CreditCheck_GB__c = 'TBR';
            XC_UTIL_Sobject.updateRecord(listOrderItems[0].NE__OrderId__r.NE__OptyId__r);
            createCase(listOrderItems);
        }
        return check;

    }
    private static Boolean checkGovernanceSecondLevel(List<NE__OrderItem__c> listOrderItems, List<XC_CM_ThresholdCreditCheck__mdt> listCM){
        Boolean check = false;
        Decimal amount = listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c == 'Capex Intensive'? listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_CapexFullLife__c : listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c;
        if(listCM[0].XC_GovernancelevelIthreshold__c <= amount && listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c != 'Capex Intensive')
        {
            check = true;
            listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_CreditCheck_GB__c = 'TBR';
            XC_UTIL_Sobject.updateRecord(listOrderItems[0].NE__OrderId__r.NE__OptyId__r);
            createCase(listOrderItems);
        }
        return check;

    }
    /*private static Boolean checkGovernanceGreaterSecondLevel(List<NE__OrderItem__c> listOrderItems, List<XC_CM_ThresholdCreditCheck__mdt> listCM){
        Boolean check = false;
        Decimal amount = listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c == 'Capex Intensive'? listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_CapexFullLife__c : listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c;
        if(amount > listCM[0].XC_GovernancelevelIIthreshold__c)
        {
            check = true;
            listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_CreditCheck_GB__c = 'TBR';
            XC_UTIL_Sobject.updateRecord(listOrderItems[0].NE__OrderId__r.NE__OptyId__r);
            createCase(listOrderItems);
        }
        return check;

    }

     */





    private static void createCase(List<NE__OrderItem__c> listOrderItems){
        string name='XC_Credit_CheckV2';
        List<String> caseSettingNames = new List<String>{name};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        if(caseSettingsMap.isEmpty() || caseSettingsMap.get(name)==null){
            system.debug('CaseTypeSetting not found');
            return;
        }
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(name);
        List<case>  newCases=new List<case>();
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
        dmlOpts.EmailHeader.TriggerUserEmail = true;

            if( caseSettingsMap.get(name)!=null){
                Case newValidationCase;
                newValidationCase =XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
                newValidationCase.XC_Opportunity__c = listOrderItems[0].NE__OrderId__r.NE__OptyId__c;
                newValidationCase.AccountId = listOrderItems[0].NE__OrderId__r.NE__AccountId__c;
                newValidationCase.ContactId= listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
                newValidationCase.XC_BusinessLine__c=listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessLine__c;
                newValidationCase.XC_LegalEntity__c=listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
                newValidationCase.setOptions(dmlOpts);
                newCases.add(newValidationCase);
            }
            XC_UTIL_Sobject.insertListRecords(newCases);

    }
    /**
     * @description Method to populare Result Wrapper for Error
     * @param rw - XC_UTIL_ResultWrapper
     * @param resultMessage - String
     * @return XC_UTIL_ResultWrapper
     */
    private static resultWrapper populateWrapperFailedStopExecution(resultWrapper rw, String resultMessage){
        rw.success = false;
        rw.resultMessage = resultMessage;
        return rw;
    }

    private static resultWrapper populateWrapperSuccess(resultWrapper rw, String resultMessage){
        rw.success = true;
        rw.resultMessage = resultMessage;
        return rw;

    }

    private static Boolean checkIsNull(String value){
        Boolean check = false;
        if(String.isBlank(value)){
            check = true;
            return check;
        }
        return check;

    }

    private static Boolean checkSkipCreditCheck(List<NE__OrderItem__c> listOrderItems){
        Boolean check = false;
        String businessModel = listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c;
        String modeOfEngagement = listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_ModeOfEngagement__c;
        String contractType = listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_ContractType__c;
        List<XC_CM_Skip_Credit_Check__mdt> listCMSkipCreditCheck = new List<XC_CM_Skip_Credit_Check__mdt>();
        listCMSkipCreditCheck = [select Id, DeveloperName, XC_Contract_Type__c, XC_BusinessModel__c, XC_ModeOfEngagement__c  from XC_CM_Skip_Credit_Check__mdt
        where XC_Contract_Type__c IN (:contractType,'*') AND XC_BusinessModel__c IN (:businessModel,'*') AND XC_ModeOfEngagement__c IN (:modeOfEngagement,'*')];
        if(!listCMSkipCreditCheck.isEmpty()){
            check = true;
            listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_CreditCheck_GB__c = 'OK';
            XC_UTIL_Sobject.updateRecord(listOrderItems[0].NE__OrderId__r.NE__OptyId__r);
        }
        return check;

    }

    /**
   * @author: Gaurav Tejpal
   * @date Creation Date 05/05/2022
   * @description Create case if billing model is installment Plan and business line is emobility and installment related fields are present
   * @param listOrderItems List<NE__OrderItem__c>
   * @return Boolean
   */
    private static Boolean checkBillingModelofOrder(List<NE__OrderItem__c> listOrderItems){
        Boolean caseCreated = false;
        List<Opportunity> listOpp = new List<Opportunity>();
        if(null != listOrderItems && !listOrderItems.isEmpty()){
            for(NE__OrderItem__c oi :  listOrderItems){
                if(oi.NE__OrderId__r!=null && 
                    'Installment plan'.equalsIgnoreCase(oi.XC_BillingModel__c) 
                    && 'eMobility'.equalsIgnoreCase(oi.NE__OrderId__r.NE__OptyId__r.XC_BusinessLine__c)
                    && !String.isBlank(oi.XC_InstallmentsNumber__c)
                    && !String.isBlank(oi.XC_InstallmentFrequency__c)
                    && !String.isBlank(oi.XC_InstallmentPlanType__c))
                {
                    Opportunity opp = new Opportunity(Id = oi.NE__OrderId__r.NE__OptyId__c, XC_CreditCheck_GB__c = 'TBR');
                    listOpp.add(opp);
                }
            
            }
            if(!listOpp.isEmpty()){
                XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                update listOpp;   
                XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);  
                createCase(listOrderItems); 
                caseCreated = true;                     
            } 
        }
        return caseCreated;
    }
}