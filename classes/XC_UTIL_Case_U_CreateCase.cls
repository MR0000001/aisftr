/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Case_U_CreateCase -–- Util class XC_UTIL_Case for create method
*/ 
public without sharing class XC_UTIL_Case_U_CreateCase { 

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Case_U_CreateCase');

    /**
    * @description
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 13/8/2019 
    */
    public class UtilityWrapper{
        public XC_UTIL_Case_U.AdministrativeCaseWrapper administrativeCaseWrapper;
        public Case caseToCreate;
        public Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap;
        public String ordItemId;
    }


    /**
    * @description populate Reason And SubCause
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 13/8/2019
    * @param utilityWrapper UtilityWrapper
    */
    public static void populateReasonAndSubCause(UtilityWrapper utilityWrapper){
        XC_UTIL_Case_U.AdministrativeCaseWrapper wrapper = utilityWrapper.administrativeCaseWrapper;
        Case caseToCreate = utilityWrapper.caseToCreate;
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = utilityWrapper.caseSettingsMap;
        String ordItemId = utilityWrapper.ordItemId;
        if(wrapper.mapConfItemComplianceWrapper.containsKey(ordItemId) && wrapper.mapConfItemComplianceWrapper.get(ordItemId).complianceType == Label.XC_CL_Compliance_Reason_C1){
            caseToCreate.Reason = caseSettingsMap.get(Label.XC_CL_Compliance_1).XC_Case_Reason__c;
            caseToCreate.SubCause__c = caseSettingsMap.get(Label.XC_CL_Compliance_1).XC_Sub_Cause__c;
            caseToCreate.Origin = caseSettingsMap.get(Label.XC_CL_Compliance_1).XC_Origin__c;
        } else if(wrapper.mapConfItemComplianceWrapper.containsKey(ordItemId) && wrapper.mapConfItemComplianceWrapper.get(ordItemId).complianceType == Label.XC_CL_Compliance_Reason_C2){
            caseToCreate.Reason = caseSettingsMap.get(Label.XC_CL_Compliance_2).XC_Case_Reason__c;
            caseToCreate.SubCause__c = caseSettingsMap.get(Label.XC_CL_Compliance_2).XC_Sub_Cause__c;  
            caseToCreate.Origin = caseSettingsMap.get(Label.XC_CL_Compliance_2).XC_Origin__c;                  
        } else if(wrapper.mapConfItemComplianceWrapper.containsKey(ordItemId) && wrapper.mapConfItemComplianceWrapper.get(ordItemId).complianceType == Label.XC_CL_Compliance_Reason_C3){
            caseToCreate.Reason = caseSettingsMap.get(Label.XC_CL_Compliance_3).XC_Case_Reason__c;
            caseToCreate.SubCause__c = caseSettingsMap.get(Label.XC_CL_Compliance_3).XC_Sub_Cause__c;
            caseToCreate.Origin = caseSettingsMap.get(Label.XC_CL_Compliance_3).XC_Origin__c;  
        } else {
            checkCompliance4And5(utilityWrapper);
        }
    }

    private static void checkCompliance4And5( UtilityWrapper utilityWrapper){
        XC_UTIL_Case_U.AdministrativeCaseWrapper wrapper = utilityWrapper.administrativeCaseWrapper;
        Case caseToCreate = utilityWrapper.caseToCreate;
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = utilityWrapper.caseSettingsMap;
        String ordItemId = utilityWrapper.ordItemId;
        if(wrapper.mapConfItemComplianceWrapper.containsKey(ordItemId) && wrapper.mapConfItemComplianceWrapper.get(ordItemId).complianceType == Label.XC_CL_Compliance_Reason_C4){
            caseToCreate.Reason = caseSettingsMap.get(Label.XC_CL_Compliance_4).XC_Case_Reason__c;
            caseToCreate.SubCause__c = caseSettingsMap.get(Label.XC_CL_Compliance_4).XC_Sub_Cause__c;  
            caseToCreate.Origin = caseSettingsMap.get(Label.XC_CL_Compliance_4).XC_Origin__c;
        } else if(wrapper.mapConfItemComplianceWrapper.containsKey(ordItemId) && wrapper.mapConfItemComplianceWrapper.get(ordItemId).complianceType == Label.XC_CL_Compliance_Reason_C5){
            caseToCreate.Reason = caseSettingsMap.get(Label.XC_CL_Compliance_5).XC_Case_Reason__c;
            caseToCreate.SubCause__c = caseSettingsMap.get(Label.XC_CL_Compliance_5).XC_Sub_Cause__c;
            caseToCreate.Origin = caseSettingsMap.get(Label.XC_CL_Compliance_5).XC_Origin__c;
        }
    }
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Method to create a List of Compliance Verification Cases related to Orders.
    **/
    /*public static void createComplianceVerificationCases(List<NE__Order__c> listOrders){ 
        List<Case> caseToInsert = new List<Case>();
        List<String> listCountries = XC_UTIL_Sobject.getListFieldValues(listOrders, 'XC_Country__c');
        Map<String, Id> mapCountryRecordTypeId = XC_UTIL_Case_U_Check.getRecordTypeByCountry(listCountries); 

        for(NE__Order__c ord : listOrders){
            String country = ord.XC_Country__c.toUpperCase();  
            Case c = XC_UTIL_Case_U_CreateCase.createComplianceVerificationCase(ord);
            c.recordTypeId = mapCountryRecordTypeId.get(country);
            caseToInsert.add(c);
        } 
        XC_UTIL_Sobject.insertListRecords(caseToInsert);
        XC_UTIL_Sobject.runAssignmentRules(caseToInsert, 'Case');        
    } */

    /**
    * START PAYMENT VERIFICATION
    **/
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com, Giovanni Schioppa - giovanni.schioppa@nttdata.com
     * @description Method to create a List of Compliance Verification Cases related to Orders.
     * @param listOrderItems - List<NE__OrderItem__c>
    **/
    public static void createPaymentVerificationCases(List<NE__OrderItem__c> listOrderItems){ 
        List<Case> caseToInsert = new List<Case>();
        List<String> listCountries = XC_UTIL_Sobject.getListFieldValues(listOrderItems, 'XC_CountryFormula__c');
        Map<String, Id> mapCountryRecordTypeId = XC_UTIL_Case_U_Check.getRecordTypeByCountry(listCountries); 
        for(NE__OrderItem__c ordItem : listOrderItems){
            String country = ordItem.XC_CountryFormula__c.toUpperCase();  
            Case c = createPaymentVerificationCase(ordItem);
            c.recordTypeId = mapCountryRecordTypeId.get(country);
            caseToInsert.add(c);
        }
        XC_UTIL_Sobject.insertListRecords(caseToInsert);
        XC_UTIL_Sobject.runAssignmentRules(caseToInsert, 'Case');         
    } 

    /**
     * @description Create Payment Verification Case
     * @param ordItem - NE__OrderItem__c
     * @return Case
    **/
    public static Case createPaymentVerificationCase(NE__OrderItem__c ordItem){
        Case c =  new Case();
        c.AccountId = ordItem.NE__Account__c; 
        c.ContactId = ordItem.NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
        c.Status = XC_AT_Constants.TRIGGER_STATUS_ESTA001;
        c.SubCause__c  = XC_AT_Constants.TRIGGER_SUBCAUSE_ATCL023;
        c.XC_OrderItem__c = ordItem.Id;
        c.Reason = XC_AT_Constants.TRIGGER_REASON_MOT006; 
        c.Priority = '1';
        c.Subject = Label.XC_CL_PaymentVerification;
        c.Type = Label.XC_CL_PaymentVerification;   
        return c; 
    } 

    /**
     * @description Create Reservation Case
     * @param listConfItem - List<NE__OrderItem__c>
     * @param mapConfItemrResult - Map<String, String>
    **/
    public static void createCaseReservationKO(List<NE__OrderItem__c> listConfItem, Map<String,String> mapConfItemrResult) {
        List<Case> caseToInsert = new List<Case>();
        List<String> listCountries = XC_UTIL_Sobject.getListFieldValues(listConfItem, 'XC_CountryFormula__c');
        Map<String, Id> mapCountryRecordTypeId = XC_UTIL_Case_U_Check.getRecordTypeByCountry(listCountries); 

        for(NE__OrderItem__c confItem : listConfItem){
            String country = confItem.XC_CountryFormula__c.toUpperCase();  
            Case c = createCaseReservationKO(confItem);
            c.recordTypeId = mapCountryRecordTypeId.get(country);
            c.Reason = mapConfItemrResult.get(confItem.Id);
            caseToInsert.add(c);
        }
        XC_UTIL_Sobject.insertListRecords(caseToInsert);
        XC_UTIL_Sobject.runAssignmentRules(caseToInsert, 'Case');        
    }  

    /**
     * @description Create Reservation Case
     * @param ordItem - NE__OrderItem__c
     * @return Case
    **/
    public static Case createCaseReservationKO(NE__OrderItem__c ordItem){
        Case c =  new Case();
        c.AccountId = ordItem.NE__Account__c;
        c.ContactId = ordItem.NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
        c.Status = XC_AT_Constants.TRIGGER_STATUS_ESTA001;
        c.SubCause__c  = XC_AT_Constants.TRIGGER_SUBCAUSE_ATCL024;
        c.Reason = XC_AT_Constants.TRIGGER_REASON_MOT006;
        c.Priority = '1';
        c.XC_Order__c = ordItem.NE__OrderId__c;
        c.Type = Label.XC_CL_ReservationKO; 
        return c; 
    } 

    /**
     * @author Giovanni Schioppa - giovanni.schioppa@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create a List of Compliance Cases related to Orders when a compliance document is required.
     * @param mapConfItemComplianceMaster
     * @param mapConfItemComplianceWrapper
    **/
    public static void createComplianceCases(Map<Id, List<String>> mapConfItemComplianceMaster, Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> mapConfItemComplianceWrapper){ 
        List<Case> caseToInsertList = new List<Case>();
        XC_ComplianceMaster__c complianceMaster = new XC_ComplianceMaster__c();
        Set<String> setQueueNames = new Set<String>();
        for(String ordItemId : mapConfItemComplianceWrapper.keySet()){
            if(mapConfItemComplianceWrapper.get(ordItemId).check){  
                setQueueNames.add(mapConfItemComplianceWrapper.get(ordItemId).queue);
                complianceMaster = mapConfItemComplianceWrapper.get(ordItemId).complianceMaster;
            }
        }
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            return;
        }
        Map<Id,NE__OrderItem__c> orderItemMap= new Map<Id,NE__OrderItem__c>([SELECT Id,NE__OrderId__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.XC_LegalEntity__c FROM NE__OrderItem__c WHERE Id IN: mapConfItemComplianceWrapper.keySet()]);

        if(!Schema.sObjectType.Group.isAccessible()){
            return;
        }
        List<Group> queueList = [SELECT Id,Name, DeveloperName FROM Group WHERE Type ='queue' AND Name IN :setQueueNames ];
        Map<String, Id> mapQueueId = new Map<String,Id>();
        for(Group g : queueList){
            mapQueueId.put(g.Name, g.Id);
        }
       
        XC_UTIL_Case_U.AdministrativeCaseWrapper administrativeCaseWrapper = new XC_UTIL_Case_U.AdministrativeCaseWrapper();
        administrativeCaseWrapper.mapConfItemComplianceMaster = mapConfItemComplianceMaster;
        administrativeCaseWrapper.mapQueueId = mapQueueId;
        administrativeCaseWrapper.mapConfItemComplianceWrapper = mapConfItemComplianceWrapper;
        administrativeCaseWrapper.orderItemMap = orderItemMap;
        administrativeCaseWrapper.complianceMaster = complianceMaster; 

        caseToInsertList = XC_UTIL_Case_U.createAdministrativeCase(administrativeCaseWrapper);
        XC_UTIL_Sobject.insertListRecords(caseToInsertList);
        //XC_UTIL_Sobject.runAssignmentRules(caseToInsertList, 'Case');        
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create a List of Administrative Tasks Cases from an invocable class invoked by a flow.
     * @param ordItem - NE__OrderItem__c
     * @param step
     * @param caseMDT
     * @return List<Case>
    **/
    public static List<Case> createAdministrativeCase(NE__OrderItem__c ordItem, XC_Provisioning_Step__c step, XC_CM_Case_Type_Setting__mdt caseMDT){
        List<Case> caseToInsertList = new List<Case>();
        Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
        c.AccountId = ordItem.NE__Account__c;
        c.ContactId = ordItem.NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
        c.XC_OrderItem__c = ordItem.Id;
        c.XC_ProvisioningStep__c = step.Id;
        c.XC_LegalEntity__c = orditem.XC_LegalEntityFormula__c;
        caseToInsertList.add(c);
        return caseToInsertList;
    }

   
    

    /**
    * @author Giulio Serra giserra@deloitte.it
    * @description create Wrapper from Case
    * @param c - Case
    * @param comments - List<CaseComment>
    * @return CaseRESTWrapper
    */
    public static XC_UTIL_Case.CaseRESTWrapper createWrapperFromCase(Case c, List<CaseComment> comments) {
        XC_UTIL_Case.CaseRESTWrapper wrapper = createWrapperFromCase(c);
        if(!comments.isEmpty()) {
            wrapper.LastCaseComment = comments[0].CommentBody;
        }
        return wrapper;
    }

    /**
    * @author Giulio Serra giserra@deloitte.it
    * @description create Wrapper from Case
    * @param c - Case
    * @return CaseRESTWrapper
    */
    public static XC_UTIL_Case.CaseRESTWrapper createWrapperFromCase(Case c) {
        XC_UTIL_Case.CaseRESTWrapper wrapper = new XC_UTIL_Case.CaseRESTWrapper();
        wrapper.CaseID = c.ID;
        wrapper.CaseNumber = c.CaseNumber;
        wrapper.AccountID = c.AccountID;
        wrapper.ContactID = c.ContactID;
        wrapper.CaseReason = c.Reason;
        wrapper.CaseSubCause = c.SubCause__c;
        wrapper.CaseSubType = c.XC_Subtype__c;
        wrapper.Channel = c.Origin;
        wrapper.Country = c.Country__c;
        wrapper.Priority = c.Priority;
        wrapper.CreatedDate = String.valueOf(c.CreatedDate);
        wrapper.ClosedDate = String.valueOf(c.ClosedDate);
        wrapper.Owner = c.OwnerId;
        wrapper.Status = c.Status;
        //wrapper.CaseResult = 
        wrapper.ContactPhone = c.ContactPhone__c;
        wrapper.NotificationEmail = c.NotificationEmail__c;
        wrapper.ContactPreferredTime = c.XC_Contact_Preferred_Time__c;
        wrapper.ProductCategory = c.XC_ProductCategoryOfInterest__c;
        wrapper.Subject = c.Subject;
        wrapper.Description = c.Description;
        wrapper.CounterOfInsistences = Integer.valueOf(c.XC_ReclamationCounter__c);
        wrapper.TypeOfIntermediary = c.XC_Type_Intermediary__c;
        wrapper.PresentationMedium = c.Type_Notification__c;
        wrapper.WorkOrderID = c.XC_WorkOrder__c;
        wrapper.ParentCaseID = c.ParentId;
        wrapper.OpportunityID = c.XC_Opportunity__c;
        wrapper.OrderID = c.XC_Order__c;
        wrapper.OrderItemID = c.XC_OrderItem__c;
        wrapper.AddressID = c.XC_Address__c;
        wrapper.AssetID = c.AssetId;
        wrapper.AssetName = c.Asset.Name;
        wrapper.Brand = c.Asset.NE__CatalogItem__r.NE__Brand__c;
        wrapper.EngineCode = c.Asset.NE__CatalogItem__r.NE__Engine_Code__c;
        // wrapper.ContractID = 
        return wrapper;
    }
}