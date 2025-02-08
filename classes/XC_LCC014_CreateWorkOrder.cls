/**
* @author Giulio Proia, Monica Cutillo, Francesco Bongiovanni
* @date Creation 24/09/2018
* @date Modification 25/03/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC014_CreateWorkOrder
*/

public without sharing class XC_LCC014_CreateWorkOrder {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC014_CreateWorkOrder');
    
    /**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 27/03/2019
* @description CreateWOforLeadWrapper - Wrapper for create Work Order for Lead
*/
    public class CreateWOforLeadWrapper {
        /** @description check */
        @AuraEnabled
        public Boolean check {get; set;}
        /** @description addressList */
        @AuraEnabled
        public List<XC_Address__c> addressList = new List<XC_Address__c>();
        /** @description resultMessage */
        @AuraEnabled
        public String resultMessage {get; set;} 
        /** @description resultWrapper */
        @AuraEnabled
        public XC_UTIL_ResultWrapper resultWrapper {get; set;}
    }
    
    /**
* Checks for commercial visit for opportunity.
* @description Checks for commercial visit for opportunity.
* @param recordId the record id
* @return the boolean
*/
    @AuraEnabled
    public static Boolean hasCommercialVisitForOpportunity(String recordId) {
        List<XC_ProductCategoryOfInterest__c> listProdCat = new List<XC_ProductCategoryOfInterest__c>();
                
        List<Opportunity> oppList = new List<Opportunity>( [SELECT Id, Name, XC_ProductCategoryOfInterest__c,XC_Address__c, XC_LegalEntity__c 
                                                               FROM Opportunity where Id =: recordId limit 1]);
        
        Opportunity opp = oppList[0];
        listProdCat = XC_LCC002_NewLead_D.retrieveProductCategoriesFromNames(new List<String>{opp.XC_ProductCategoryOfInterest__c});
        if(opp.XC_Address__c == null){
            return false; 
        }
        if(!listProdCat.isEmpty()) { 
            return listProdCat[0].XC_CommercialVisit__c;
        }
        return false;
    }
    
    /**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @param recordId the record id
* @return the creates the W ofor lead wrapper
* @date Creation 27/03/2019
* @description hasCommercialVisitForLead() - Check Commercial Visit and return CreateWOforLeadWrapper
*/
    @AuraEnabled
    public static CreateWOforLeadWrapper hasCommercialVisitForLead(String recordId) {
        CreateWOforLeadWrapper wrapper = new CreateWOforLeadWrapper();
        List<XC_ProductCategoryOfInterest__c> listProdCat = new List<XC_ProductCategoryOfInterest__c>();
                
        List<Lead> leadList = new List<Lead>([SELECT Id, Name, Status,MobilePhone,Email, Phone, XC_MainLegalEntity__c,  XC_ProductCategoryOfInterest__c,OwnerId 
                                                 FROM Lead where Id =: recordId limit 1]);
        Lead lead = leadList[0];
        listProdCat = XC_LCC002_NewLead_D.retrieveProductCategoriesFromNames(new List<String>{lead.XC_ProductCategoryOfInterest__c});
        Boolean isTakeCharge = false;
        Boolean hasAddress = XC_LCC014_CreateWorkOrder_U.hasAddressForLead(recordId);
        Map<String,Boolean> hasProductCategoryAddress = XC_LCC014_CreateWorkOrder_U.checkProductCategoryAddress(recordId,listProdCat);
        Boolean hasRequiredField = false;
        
        // Fix for Cyclomatic Complexity
        XC_LCC014_CreateWorkOrder_U.CheckLeadStatusWrapper checkWrapper = new XC_LCC014_CreateWorkOrder_U.CheckLeadStatusWrapper();
        checkWrapper.wrapper = wrapper;
        Boolean isPendingScheduling = XC_LCC014_CreateWorkOrder_U.checkLeadStatus(lead, checkWrapper);
        if(checkWrapper.finish) {
            return checkWrapper.wrapper;
        }
        XC_LCC014_CreateWorkOrder_U.CheckLeadPendingSchedulingWrapper checkPensingSchedulingWrapper = new XC_LCC014_CreateWorkOrder_U.CheckLeadPendingSchedulingWrapper();
        checkPensingSchedulingWrapper.hasRequiredField = hasRequiredField;
        checkPensingSchedulingWrapper.listProdCat = listProdCat;
        checkPensingSchedulingWrapper.isPendingScheduling = isPendingScheduling;
        checkPensingSchedulingWrapper.checkWrapper = checkWrapper;
        checkPensingSchedulingWrapper.lead = lead;
        XC_LCC014_CreateWorkOrder_U.checkLeadPendingScheduling(checkPensingSchedulingWrapper);
        if(checkPensingSchedulingWrapper.checkWrapper.finish) {
            return checkPensingSchedulingWrapper.checkWrapper.wrapper;
        }
        hasRequiredField = checkPensingSchedulingWrapper.hasRequiredField;
        wrapper = checkPensingSchedulingWrapper.checkWrapper.wrapper;
        
        
        if(!hasAddress ) {
            wrapper.check = false;
            wrapper.resultMessage = Label.XC_CL_InsertAddress;
            return wrapper;
        }
        
        // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
        /* 
         * @description : Check for : You cannot create a new Work Order because you are not the owner 
           @author      : Riccardo Cossu - riccardo.cossu@nttdata.com - Federico Amici - federico.amici@nttdata.com
           @date        : 25/05/2019
         */
        
        String ownerIdv = String.valueOf(lead.OwnerId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'user-GetUserId'+userInfo.getUserId()+ 'owner Id :'+ownerIdv);
        if(userInfo.getUserId() != ownerIdv ){
            wrapper.check = false;
            wrapper.resultMessage = Label.XC_CL_WorkOrder_NotSameUser;
            return wrapper; 
        }
        // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
        
        if(XC_LCC014_CreateWorkOrder_U.searchKeyInMap(hasProductCategoryAddress, 'D')) {
            wrapper.check = false;
            wrapper.resultMessage = Label.XC_CL_Address_NotDelivery;
            return wrapper;
        } else if(XC_LCC014_CreateWorkOrder_U.searchKeyInMap(hasProductCategoryAddress, 'I')){
            wrapper.check = false;
            wrapper.resultMessage = Label.XC_CL_Address_NotInstallation;
            return wrapper;
        }else{
            wrapper.check = true;
            wrapper.resultWrapper = createWorkOrderForLead(recordId);
        }
        return wrapper;
    }
    
    /**
* @description Gets the list address.
* @param recordId the record id
* @param applyIstallCondition the apply istall condition
* @return the list address
*/
    @auraEnabled
    public static CreateWOforLeadWrapper getListAddress(String recordId, Boolean applyIstallCondition) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in getListAddress con accId = '+recordId);
        CreateWOforLeadWrapper wrapper = new CreateWOforLeadWrapper();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getAccountPod - recordId:'+recordId + ', applyIstallCondition:'+applyIstallCondition);
        List<XC_UTIL_Address.AddressWrapper> listAddressWrapper = new List<XC_UTIL_Address.AddressWrapper>();
        
        if(recordId == null) {
            return null;
        }
        List<XC_Address__c> listAddress;         
        if(applyIstallCondition){
            listAddress    = new List<XC_Address__c>([SELECT Id, Name, XC_FullAddress__c, XC_Municipality__c
                                                     FROM XC_Address__c WHERE XC_Account__c =: recordId AND XC_InstallationAddress__c = true]);
        }else {            
            listAddress = new List<XC_Address__c>([SELECT Id, Name, XC_FullAddress__c, XC_Municipality__c FROM XC_Address__c 
                                                   WHERE XC_Account__c =: recordId ]);
        }
        wrapper.addressList = listAddress;   
        return wrapper;
    }
    
    /**
* @description Creates the work order.
* @param recordId the record id
* @return the x C UTI L result wrapper
*/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createWorkOrder(String recordId) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'For recordId -> ' + recordId);        
        
        List<Opportunity> oppList =  new List<Opportunity>([SELECT Id, XC_Address__c,XC_Country__c, XC_Contact__c,AccountId , XC_LegalEntity__c
                                                               FROM Opportunity WHERE Id =:recordId LIMIT 1]);
        Opportunity opp = oppList[0];
        List<XC_Address__c> listAddress = XC_UTIL_Sobject.selectAllFields(opp.XC_Address__c);
        XC_UTIL_Sobject.WrapperResult wrRes = new XC_UTIL_Sobject.WrapperResult();        
        
        String accountId = opp.AccountId;
        String contactId = opp.XC_Contact__c;
        WorkOrder wo = XC_UTIL_WorkOrder.createWorkOrder(Label.XC_CL_CommercialVisit, opp.XC_Country__c, accountId);
        wo.XC_Address__c = listAddress[0].Id;
        wo.ContactId = contactId;
        wo.XC_LegalEntity__c = opp.XC_LegalEntity__c;
        wo.XC_Opportunity__c = recordId;
        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_PendingContact;
        wo.XC_CreatedAutomaticallyBySystem__c = true;
        XC_UTIL_Address.populateAddressFieldsFromAddress(wo, listAddress[0]);
        wrRes = XC_UTIL_Sobject.insertRecord(wo); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'wrapperResult -> ' + wrRes);
        
        return new XC_UTIL_ResultWrapper(wrRes);
        //return createWrapper(wrRes.recordId, wrRes.success, wrRes.errorMessage); 
    }
    
    /**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @param recordId the record id
* @return the x C UTI L result wrapper
* @date Creation 27/03/2019
* @description createWorkOrderForLead() - Create a new Work Order for Lead
*/
    public static XC_UTIL_ResultWrapper createWorkOrderForLead(String recordId) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'For recordId -> ' + recordId); 
        XC_UTIL_Sobject.WrapperResult wrRes = new XC_UTIL_Sobject.WrapperResult();
        
        List<Lead> leadList = new List<Lead>([SELECT Id, Status, XC_LeadAddress__c, Country__c, XC_City__c, XC_ZipCode__c, XC_StreetType__c, XC_StreetTypeText__c, XC_Address__c, XC_StreetNumber__c, XC_Province__c, XC_MainLegalEntity__c
                                                 FROM Lead
                                                 WHERE Id =: recordId LIMIT 1]);
        
        Lead lead = leadList[0];
        
        WorkOrder wo = XC_UTIL_WorkOrder.createWorkOrder(Label.XC_CL_CommercialVisit, lead.Country__c, null);
        List<XC_Address__c> listAddress = XC_UTIL_Sobject.selectAllFields(lead.XC_LeadAddress__c);
        wo.XC_Lead__c = recordId;
        XC_UTIL_Address.populateAddressFieldsFromAddress(wo, listAddress[0]);
        //lead.Status = Label.XC_CL_Lead_PendingScheduling;
        wo.XC_LegalEntity__c = lead.XC_MainLegalEntity__c;
        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_PendingContact;
        wo.XC_CreatedAutomaticallyBySystem__c = true;
        wrRes = XC_UTIL_Sobject.insertRecord(wo); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'wrapperResult -> ' + wrRes);
        XC_UTIL_Sobject.updateRecord(lead);
        return new XC_UTIL_ResultWrapper(wrRes);
    }
    
    /**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @param recordId the record id
* @return the creates the W ofor ZUORA wrapper
* @date Creation 27/09/2019
* @description callZuoraForUpdate     
*/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper callZuoraForUpdate(String addressId, String lineItemId) {
		XC_BillingProfileLineItem__c bpli = [
            SELECT Id, XC_CustomerAccount__c, XC_ZuoraId__c, XC_LegalEntity__c, XC_SoldToContactId__c, XC_BillingProfile__r.XC_Segment__c 
            FROM XC_BillingProfileLineItem__c 
            WHERE Id=: lineItemId LIMIT 1
        ];
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(bpli.XC_LegalEntity__c, bpli.XC_BillingProfile__r.XC_Segment__c);
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        ZuoraWebservice.CreateZuoraAccountResponse zr = new ZuoraWebservice.CreateZuoraAccountResponse();
        
        Map<String, String> parametersMap = new Map<String, String>();
        parametersMap.put('zuoraAccountId' , bpli.XC_ZuoraId__c);        // REQUIRED
        parametersMap.put('billToId' , bpli.XC_SoldToContactId__c);                    // REQUIRED
        parametersMap.put('soldToId', bpli.XC_SoldToContactId__c);                    // REQUIRED
        parametersMap.put('billAddrId' , addressId);                // REQUIRED
        parametersMap.put('soldAddrId' , addressId);  
        parametersMap.put('legalEntity', bpli.XC_LegalEntity__c);       
        zr = zws.updateZuoraAccount(parametersMap);
        resWrapper.success = Boolean.valueOf(zr.success);
        resWrapper.resultMessage = JSON.serialize(zr.reasons);
        return resWrapper; 
    } 
	
	
}