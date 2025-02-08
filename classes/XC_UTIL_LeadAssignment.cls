/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com - Salvatore Agrillo salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_LeadAssignment – UTIL class for XC_LeadAssignmentMaster__c 
*/

public without sharing class XC_UTIL_LeadAssignment {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_LeadAssignment');

    /** @description PopulateLeadWrapper */
    public class PopulateLeadWrapper {
        public String genericQueueId;
        public String usernameOrGroupId;
        public List<Lead> listLeadWithNoMatch = new List<Lead>();
        public Map<String, String> mapNameIdGroup = new Map<String, String>();
        public List<LeadAssignmentWrapperResult> listResultWrapper = new List<LeadAssignmentWrapperResult>();
    }
    
    /** @description Wrapper for Lead Assignment */
    public class LeadAssignmentWrapper { 
        public Integer orderOfEvaluation;
        public String isEmail; 
        public String isPhone;
        public String isAddress;
        public String consentLegalEntity;
        public String receivingChannel = null;
        public String productCategoryofInterest = null; 
        public String country = null;
        public String city = null;
        public String zipCode = null;  
        public String leCountry = null;
        public String stream = null;
        public Lead lead = new Lead();  
    } 
    
    /** @description Wrapper for Lead Assignment Result */
    public class LeadAssignmentWrapperResult{
        public String status ='';
        public String product = '';
        public String assignedTo = '';
        public String assignedToQueue = '';
        public Lead lead = new Lead();
        
    }
    
    /** @description Wrapper for Check Match */
    public class CheckMatchLeadWrapper{
        public LeadAssignmentWrapperResult resultWrapper = new LeadAssignmentWrapperResult();
        public LeadAssignmentWrapper leadSkipped = new LeadAssignmentWrapper();
        public Boolean isSkipped = false;
    }
    
    /** @description Wrapper for Check Lead Assignment Master Match */
    public class CheckMatchWrapper {
        public Boolean jump = false;
        public Boolean skipped = true;
        public Lead ld;
        public CheckMatchLeadWrapper resultMatch;
        public LeadAssignmentWrapper leadWrapper;
        public XC_LeadAssignmentMaster__c lam;
        public String consentLE;
    }
    
    private class WrapperCountryLegal{
        List<String> countryLEList = new List<String>();
        List<String> leList = new List<String>();
    }

    private static List<Lead> getLeadNotPromoters(List<Lead> listLead){ 
        List<Lead> leadToBeChecked = new List<Lead>();
        for(Lead ld: listLead){
            if(ld.XC_Channel__c != Label.XC_CL_Lead_Promoters){
                leadToBeChecked.add(ld);
            }
        }
        return leadToBeChecked;
    }
    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description assignLead - assign the lead
    * @param listLead list of leads in input
    */ 
    public static void assignLead(List<Lead> listLead){ // FIX SS 070719 - Before was: assignLead(List<Lead> listLead, Map<String,List<XC_LegalEntityConsent__c>> leData)
        List<Lead> leadToProcess = getLeadNotPromoters(listLead);
        List<LeadAssignmentWrapper> listLeadWrapper = createListLeadIdWrapper(leadToProcess);
        List<XC_LeadAssignmentMaster__c> listAssignment = getLeadAssignmentMaster(listLeadWrapper);  
        List<LeadAssignmentWrapperResult> listResultWrapper = new List<LeadAssignmentWrapperResult>();
        List<Lead> listLeadWithNoMatch = new List<Lead>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listLeadWrapper ----->' + listLeadWrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listAssignment ----->' + listAssignment);
        XC_UTIL_LeadAssignment_U.AssignLeadWrapper assignWrapper = XC_UTIL_LeadAssignment_U.assignLead(listLeadWrapper, listAssignment);
        listResultWrapper = assignWrapper.listResultWrapper;
        System.debug('@@@ listResultWrapper ---> ' + listResultWrapper);
        listLeadWithNoMatch = assignWrapper.listLeadWithNoMatch;
        
        List<String> listOwnerId = new List<String>();
        for(LeadAssignmentWrapperResult wr : listResultWrapper) {
            listOwnerId.add(wr.assignedTo);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listNameGroup ---> '+ listOwnerId);
        XC_UTIL_LeadAssignment_U.AssignGroupWrapper assignGroupWrapper = XC_UTIL_LeadAssignment_U.assignGroup(listOwnerId);
        PopulateLeadWrapper populateWrapper = new PopulateLeadWrapper();
        populateWrapper.listLeadWithNoMatch = listLeadWithNoMatch;
        populateWrapper.listResultWrapper = listResultWrapper;
        populateWrapper.genericQueueId = assignGroupWrapper.genericQueueId; 
        System.debug('@@@ populateWrapper ---> ' + populateWrapper);  
        populateLead(populateWrapper);
       // }
        //checkProductCategoryOfInterest(populateWrapper);
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description Method to
    * @param listLead List lead in input
    * @return listLeadWrapper - list of LeadAssignmentWrapper
    **/    
    private static List<LeadAssignmentWrapper> createListLeadIdWrapper(List<Lead> listLead){
        List<LeadAssignmentWrapper> listLeadWrapper = new  List<LeadAssignmentWrapper>();
        List<String> consents = new List<String>();
        for(Lead ld : listLead){
            consents.add(ld.XC_MainLegalEntity__c); 
        }
        Map<String, String> mapRecTypePickValue = getMapRecordTypePickValue(consents);
        for(Lead ld : listLead){
            LeadAssignmentWrapper leadWrapper = new LeadAssignmentWrapper();
            leadWrapper.isEmail = (!String.isBlank(ld.Email)) ? 'Yes' : 'No';
            leadWrapper.isPhone = (!String.isBlank(ld.XC_LeadPhone__c)) ? 'Yes' : 'No';
            leadWrapper.isAddress = (!String.isBlank(ld.XC_Address__c)) ? 'Yes' : 'No';
            leadWrapper.receivingChannel = ld.XC_Channel__c;
            leadWrapper.productCategoryofInterest = ld.XC_ProductCategoryOfInterest__c; 
            leadWrapper.country = ld.XC_Country__c;
            leadWrapper.city = ld.XC_City__c;
            leadWrapper.lead = ld;

            leadWrapper.stream = ld.XC_Segment__c;

            leadWrapper.consentLegalEntity = ld.XC_MainLegalEntity__c ;
            if(mapRecTypePickValue.containsKey(ld.XC_MainLegalEntity__c)){            
                leadWrapper.leCountry = mapRecTypePickValue.get(ld.XC_MainLegalEntity__c);
                if(leadWrapper.leCountry == 'Italy'){
                    populateZipCodeForItaly(leadWrapper, ld);   
                } else {
                    leadWrapper.zipCode = ld.XC_ZipCode__c;
                }     
            }
            listLeadWrapper.add(leadWrapper);
        }
        return listLeadWrapper;
    }
    
    /**
    * @description util method to retrieve the correct lead zip code. Used for Italy scenario only.
    * @author salvatore.scarpato@nttdata.com | 27/3/2020 
    * @param leadWrapper 
    * @param ld 
    **/
    private static void populateZipCodeForItaly(LeadAssignmentWrapper leadWrapper, Lead ld){
        if(!String.isEmpty(ld.XC_ZipCode__c)){
            leadWrapper.zipCode = ld.XC_ZipCode__c;
        } else if(!String.isEmpty(ld.XC_GenericZipCode__c)){
            leadWrapper.zipCode = ld.XC_GenericZipCode__c;
        }
    }
    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description getLeadAssignmentMaster() - Get LeadAssignmentMaster
    * @param listLeadWrapper - List of LeadAssignmentWrapper in input
    * @return  leadAssignmentMaster - List of XC_LeadAssignmentMaster__c
    **/
    private static List<XC_LeadAssignmentMaster__c> getLeadAssignmentMaster(List<LeadAssignmentWrapper> listLeadWrapper) {
        List<Integer> orderOfEvaluationList = new List<Integer>();
        List<String> isEmailList = new List<String>(); 
        List<String> isPhoneList = new List<String>();
        List<String> isAddressList = new List<String>();
        List<String> receivingChannelList = new List<String>();
        List<String> productCategoryofInterestList = new List<String>();
        List<String> countryList = new List<String>();
        List<String> cityList = new List<String>();
        List<String> zipCodeList = new List<String>(); 
        List<String> consentsLEList = new List<String>();
        List<String> leCountries = new List<String>();
        List<String> streamList = new List<String>();
        for(LeadAssignmentWrapper wrapper : listLeadWrapper){
            isEmailList.add(wrapper.isEmail);
            isPhoneList.add(wrapper.isPhone);
            isAddressList.add(wrapper.isAddress);
            receivingChannelList.add(wrapper.receivingChannel);
            productCategoryofInterestList.add(wrapper.productCategoryofInterest);
            countryList.add(wrapper.country);
            cityList.add(wrapper.city);
            zipCodeList.add(wrapper.zipCode);
            consentsLEList.add(wrapper.consentLegalEntity);
            leCountries.add(wrapper.leCountry);
            streamList.add(wrapper.stream);
        }
        isEmailList.add(null);
        isPhoneList.add(null);
        isAddressList.add(null);
        receivingChannelList.add(null);
        productCategoryofInterestList.add(null);
        countryList.add(null);
        cityList.add(null);
        zipCodeList.add(null);
        consentsLEList.add(null);
        streamList.add(null);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ isEmailList ---> '+ isEmailList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ isPhoneList ---> '+ isPhoneList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ isAddressList ---> '+ isAddressList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ receivingChannelList ---> '+ receivingChannelList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ productCategoryofInterestList ---> '+ productCategoryofInterestList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ countryList ---> '+ countryList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ cityList ---> '+ cityList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ zipCodeList ---> '+ zipCodeList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ consentsLEList ---> '+ consentsLEList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ leCountries ---> '+ leCountries);
         XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ stream ---> '+ streamList);
        String query = String.escapeSingleQuotes('SELECT Id,XC_OrderOfEvaluation__c,XC_AssignedToUser__c,XC_AssignedToQueue__c,XC_AssignedToCreator__c, XC_Channel__c, XC_Address__c, XC_Country__c, XC_Email__c, XC_ProductCategoryOfInterest__c, XC_PrimaryPhone__c, XC_City__c, XC_ZipCode__c, XC_Status__c,  XC_LegalEntity__c, XC_RecordTypePick__c,XC_Segment__c ' +
                                                 'FROM XC_LeadAssignmentMaster__c ' +
                                                 'WHERE (XC_Email__c IN: isEmailList) ' +
                                                 'AND (XC_PrimaryPhone__c IN: isPhoneList)' +
                                                 'AND (XC_Address__c IN: isAddressList)' +
                                                 'AND (XC_Channel__c IN: receivingChannelList) ' +
                                                 'AND (XC_ProductCategoryOfInterest__c IN: productCategoryofInterestList) ' +
                                                 'AND (XC_Country__c IN: countryList) ' +
                                                 'AND (XC_City__c IN: cityList) ' +
                                                 'AND (XC_ZipCode__c IN: zipCodeList) ' +
                                                 'AND (XC_LegalEntity__c  IN: consentsLEList) ' +
                                                 'AND (XC_RecordTypePick__c IN: leCountries) ' +
                                                 'AND (XC_Segment__c IN : streamList)' +
                                                 'ORDER BY XC_OrderOfEvaluation__c ASC');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ Query Done ---> ' + query);
        List<XC_LeadAssignmentMaster__c> leadAssignmentMaster = Database.query(query);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ Query result ---> ' + leadAssignmentMaster);
        return leadAssignmentMaster; 
    }
    
    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
    * @description getRecordTypePickValue() - Get the correct country from the custom metadata XC_CM_CountryLegalEntityAssociation__mdt that
    * @param consentsLEList - List of LeadAssignmentWrapper in input
    * @return  leadAssignmentMaster - List of XC_LeadAssignmentMaster__c
    **/
    private static Map<String, String> getMapRecordTypePickValue(List<String> consentsLEList){
        Map<String, String> mapCountryRecType = new Map<String, String>();
        if(!consentsLEList.isEmpty()){
            List<XC_CM_CountryLegalEntityAssociation__mdt> countryLegalEntityList = new List<XC_CM_CountryLegalEntityAssociation__mdt>([SELECT Id, XC_Country__c,XC_LegalEntity__c  
                                                                                                                                        FROM XC_CM_CountryLegalEntityAssociation__mdt 
                                                                                                                                        WHERE XC_LegalEntity__c IN: consentsLEList]);
            for(XC_CM_CountryLegalEntityAssociation__mdt clea : countryLegalEntityList){
				mapCountryRecType.put(clea.XC_LegalEntity__c, clea.XC_Country__c);               	
            }
        }
        return mapCountryRecType;
    }
    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 08/04/2019
    * @date Modification dd/mm/yyyy
    * @param leadWrapper - LeadAssignmentWrapper
    * @param leadAssignmentMaster - List of XC_LeadAssignmentMaster__c
    * @param consentLE
    * @return  resultMatch - CheckMatchLeadWrapper
    * @description checkLeadAssignmentMasterMatch() - This method matches all the field of the Wrapper with all the fields of a XC_LeadAssignmentMaster__c
    **/
    public static CheckMatchLeadWrapper checkLeadAssignmentMasterMatch(LeadAssignmentWrapper leadWrapper, List<XC_LeadAssignmentMaster__c> leadAssignmentMaster, String consentLE) {
        CheckMatchLeadWrapper resultMatch = new CheckMatchLeadWrapper();
        Lead ld = leadWrapper.lead;
        Boolean skipped = true;
        for(XC_LeadAssignmentMaster__c lam : leadAssignmentMaster){
            // For cyclomatic complexity warning:
            CheckMatchWrapper checkWrapper = new CheckMatchWrapper();
            checkWrapper.skipped = skipped;
            checkWrapper.ld = ld;
            checkWrapper.resultMatch = resultMatch;
            checkWrapper.leadWrapper = leadWrapper;
            checkWrapper.lam = lam;
            checkWrapper.consentLE = consentLE;
            XC_UTIL_LeadAssignment_U_Check.checkExactMatch(checkWrapper);
            skipped = checkWrapper.skipped;
            resultMatch = checkWrapper.resultMatch;
            leadWrapper = checkWrapper.leadWrapper;
            if(checkWrapper.jump) {
                break;
            }
        }
        if(skipped) {
            resultMatch.isSkipped = true; // Modified by Salvatore Scarpato 05-07-2019
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LeadAssignment@ No  leadAssignmentMaster case for lead: ' + leadWrapper);
            resultMatch.leadSkipped = leadWrapper;
        }
        return resultMatch;
    }
    
    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 09/04/2019
    * @date Modification dd/mm/yyyy
    * @param leadWrapper - LeadAssignmentWrapper
    * @param leadAssignmentMaster - List of XC_LeadAssignmentMaster__c
    * @param consentLE
    * @return  resultWrapper - LeadAssignmentWrapperResult
    * @description checkLeadAssignmentMasterWildCardMatch() - This method matches all the field of the Wrapper with all the fields of a XC_LeadAssignmentMaster__c or with the wildcard '*' for certain fields
    **/
    public static CheckMatchLeadWrapper checkLeadAssignmentMasterWildCardMatch(LeadAssignmentWrapper leadWrapper, List<XC_LeadAssignmentMaster__c> leadAssignmentMaster, String consentLE) {
        CheckMatchLeadWrapper resultMatch = new CheckMatchLeadWrapper();
        Lead ld = leadWrapper.lead;
        Boolean skipped = true;
        for(XC_LeadAssignmentMaster__c lam : leadAssignmentMaster){
            // For Cyclomatic complexity warning:
            CheckMatchWrapper checkWrapper = new CheckMatchWrapper();
            checkWrapper.skipped = skipped;
            checkWrapper.ld = ld;
            checkWrapper.resultMatch = resultMatch;
            checkWrapper.leadWrapper = leadWrapper;
            checkWrapper.lam = lam;
            checkWrapper.consentLE = consentLE;
            XC_UTIL_LeadAssignment_U_Check.checkWildCardMatch(checkWrapper);
            skipped = checkWrapper.skipped;
            resultMatch = checkWrapper.resultMatch;
            leadWrapper = checkWrapper.leadWrapper;
            if(checkWrapper.jump) {
                break;
            }        
        }
        if(skipped) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'For Lead (' + ld.Name + ') -> NO match!');
            resultMatch.isSkipped = true;
            resultMatch.leadSkipped = leadWrapper;
        } 
        
        return resultMatch;
    }
    
    
    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com / Salvatore Scarpato@nttdata.com
    * @date Creation 08/04/2019
    * @description Populate ResultWrapper of ResultMatch for WildCard Match (FOR CYCLOMATIC COMPLEXITY WARNING)
    * @param checkWrapper - CheckMatchWrapper
    **/
    public static void populateResultWrapper(CheckMatchWrapper checkWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@SS 0507@@ populateResultWrapper LAM -->' + checkWrapper.lam);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@SS 0507@@ populateResultWrapper Queue -->' + checkWrapper.lam.XC_AssignedToQueue__c);
        if(checkWrapper.lam.XC_AssignedToUser__c != null) {
            LeadAssignmentWrapperResult wr = new LeadAssignmentWrapperResult();
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@Lead Assignment@@ Assigned for Lead (' + checkWrapper.ld.Name + ') -> ' + checkWrapper.lam.XC_AssignedToUser__c );
            wr.assignedTo = checkWrapper.lam.XC_AssignedToUser__c;
            wr.lead = checkWrapper.ld;
            wr.status = checkWrapper.lam.XC_Status__c; // FIX SS 090719 OLD WAS: wr.product = wr.lead.XC_ProductCategoryOfInterest__c;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@Lead Product-->' + wr.lead.XC_ProductCategoryOfInterest__c);
            checkWrapper.resultMatch.resultWrapper = wr;
            checkWrapper.jump = true;
        } else if(checkWrapper.lam.XC_AssignedToQueue__c != null){
            LeadAssignmentWrapperResult wr = new LeadAssignmentWrapperResult();
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@Lead Assignment@@ Assigned for Lead (' + checkWrapper.ld.Name + ') -> ' + checkWrapper.lam.XC_AssignedToQueue__c);
            wr.assignedToQueue = checkWrapper.lam.XC_AssignedToQueue__c; 
            wr.lead = checkWrapper.ld;
            wr.status = checkWrapper.lam.XC_Status__c; // FIX SS 090719 OLD WAS:  wr.product = wr.lead.XC_ProductCategoryOfInterest__c;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@Lead Product-->' + wr.lead.XC_ProductCategoryOfInterest__c);
            checkWrapper.resultMatch.resultWrapper = wr;
            checkWrapper.jump = true;
        } else if(checkWrapper.lam.XC_AssignedToCreator__c){
            LeadAssignmentWrapperResult wr = new LeadAssignmentWrapperResult();
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@Lead Assignment@@ Assigned for Lead (' + checkWrapper.ld.Name + ') -> To the Lead Creator'); 
            wr.lead = checkWrapper.ld;
            wr.status = checkWrapper.lam.XC_Status__c; // FIX SS 090719 OLD WAS:   wr.product  = wr.lead.XC_ProductCategoryOfInterest__c;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@Lead Product-->' + wr.lead.XC_ProductCategoryOfInterest__c);
            checkWrapper.resultMatch.resultWrapper = wr;
            checkWrapper.jump = true;
        }
    }
    
    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Assign Lead
    * @param populateWrapper - PopulateLeadWrapper
    **/   
    private static void populateLead(PopulateLeadWrapper populateWrapper) {
        List<String> queueToBeQueried = new List<String>();
        for(LeadAssignmentWrapperResult wr : populateWrapper.listResultWrapper){
            queueToBeQueried.add(wr.assignedToQueue);
        }
        Map<String,String> mapQueueNameId = XC_UTIL_LeadAssignment_U.searchForCorrectQueue(queueToBeQueried);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@SS@@ populateLead -->' + populateWrapper);
        for(LeadAssignmentWrapperResult wr : populateWrapper.listResultWrapper) {
            
            if(!String.isBlank(wr.assignedTo)){
            	wr.lead.OwnerId = wr.assignedTo;
                wr.lead.Status = wr.status;
                XC_UTIL_LeadAssignment_U.setDateTime(wr.lead);
            //} else if(!String.isBlank(wr.assignedToQueue) && !mapQueueNameId.isEmpty()){
            } else if(!String.isBlank(wr.assignedToQueue)){
                if(!mapQueueNameId.isEmpty()){
                    wr.lead.OwnerId = mapQueueNameId.get(wr.assignedToQueue);
                    wr.lead.Status = wr.status;
                    XC_UTIL_LeadAssignment_U.setDateTime(wr.lead);
                }else {
                    wr.lead.addError(Label.XC_CL_QueueNotExists);
                }   
            } else {
                wr.lead.Status = wr.status;
                XC_UTIL_LeadAssignment_U.setDateTime(wr.lead);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@SS@@ OWNER ID -->' + wr.lead.OwnerId);
        }

        XC_UTIL_LeadAssignment_U.genericQueueScenario(populateWrapper);
    }
}