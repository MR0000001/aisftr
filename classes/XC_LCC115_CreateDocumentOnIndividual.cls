/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 20/05/2019
* @date Modification dd/mm/yyyy
* @description  – XC_LCC115_CreateDocumentOnIndividual  - controller class of XC_LCP115_CreateDocumentOnIndividual to create Conga document on Individual
*/ 
public without sharing class XC_LCC115_CreateDocumentOnIndividual {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC115_CreateDocumentOnIndividual');
    /**
	 * @description Util Wrapper
	 */
    public class UtilWrapper{
        @AuraEnabled public String leadId;
        @AuraEnabled public String contactId;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String templateId;
        @AuraEnabled public String queryName;
        @AuraEnabled public Individual indi;
    }
    /**
	 * @description create Url If Lead
     * @param wrapper
	 * @param individualId
     * @return String
	 */
    private static String createUrlIfLead(UtilWrapper wrapper, String individualId) {
        String leadId = wrapper.leadId;
        String contactId = wrapper.contactId;
        String firstName = wrapper.firstName;
        String lastName = wrapper.lastName;
        String templateId = wrapper.templateId;
        String queryName = wrapper.queryName;
        String name = firstName + ' ' + lastName;

        String dm = Url.getSalesforceBaseUrl().toExternalForm();
        // It's necessary to use a List<String> because just a String type doesn't accept a curly brace.
        List<String> subst = new List<String>();
        subst.add(dm);
        subst.add('/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl=;');
        subst.add('{');
        subst.add('!API.Partner_Server_URL_370');
        subst.add('}');
        subst.add('&Id=');
        subst.add(individualId);
        subst.add('&AttachmentParentID=');
        subst.add(leadId);
        subst.add('&TemplateId=');
        subst.add(templateId);
        subst.add('&QueryId=');
        subst.add(queryName);
        subst.add('&OFN=');
        subst.add(name);
        subst.add('&DefaultPDF=1&SC0=1&SC1=SalesforceFile&DS7=11');
        String finalUrl = String.format('{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}{11}{12}{13}{14}{15}',subst);
        system.debug('@208 LEAD finalUrl-->' + finalUrl);
        return finalUrl;
    }

    /**
	 * @description populate Conga Field
	 * @param individualId
     * @return String
	 */
    @AuraEnabled
    public static String populateCongaField(String individualId) {
        system.debug('individualId -->'+ individualId);
        UtilWrapper wrapper = getIndividualInfo(individualId);
        
        String leadId = wrapper.leadId;
        String contactId = wrapper.contactId;
        String firstName = wrapper.firstName;
        String lastName = wrapper.lastName;
        String templateId = wrapper.templateId;
        String queryName = wrapper.queryName;
        String name = firstName + ' ' + lastName;
        if(!String.isBlank(leadId)){
            String finalUrl = createUrlIfLead(wrapper, individualId);
            return finalUrl; 
            
        } else if(!String.isBlank(contactId)){
            String dm = Url.getSalesforceBaseUrl().toExternalForm();
            // It's necessary to use a List<String> because just a String type doesn't accept a curly brace.
            List<String> subst = new List<String>();
            subst.add(dm);
            subst.add('/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl=;');
            subst.add('{');
            subst.add('!API.Partner_Server_URL_370');
            subst.add('}');
            subst.add('&Id=');
            subst.add(individualId);
            subst.add('&AttachmentParentID=');
            subst.add(contactId);
            subst.add('&TemplateId=');
            subst.add(templateId);
            //WARNING: Get the queries needed for the template population of the pdf file. It's needed to change the Id if the query or the org change.
            subst.add('&QueryId=');
            subst.add(queryName);
            subst.add('&OFN=');
            subst.add(name);
            subst.add('&DefaultPDF=1&SC0=1&SC1=SalesforceFile&DS7=11');
            String finalUrl = String.format('{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}{11}{12}{13}{14}{15}',subst);
            return finalUrl;          
            
        } else {
            String finalUrl = Label.XC_CL_NoContactOrLead;
            return finalUrl ;
        }
    }
    
    private static UtilWrapper getIndividualInfo(String individualId) {
        List<String> queries = new List<String>();
        Map<Id, Individual> individualInfos = new Map<Id, Individual>([SELECT id, FirstName, LastName,XC_CongaStaticAPI__c,XC_CongaDynamicAPI__c, (SELECT id, Email, phone  FROM Leads), (SELECT id, Email, phone  FROM Contacts ) FROM Individual WHERE Id =: individualId]); 
    	
        Map<Id,APXTConga4__Conga_Template__c> mapTemplate = new Map<Id,APXTConga4__Conga_Template__c> ([SELECT id, APXTConga4__Name__c, APXTConga4__Template_Group__c 
                                                                                                        FROM APXTConga4__Conga_Template__c
                                                                                                        WHERE APXTConga4__Name__c = 'IndividualTemplate']);
        Map<Id,APXTConga4__Conga_Merge_Query__c> mapQueries = new Map<Id,APXTConga4__Conga_Merge_Query__c >([SELECT id, APXTConga4__Name__c 
                                                                                                        FROM APXTConga4__Conga_Merge_Query__c 
                                                                                                        WHERE APXTConga4__Name__c = 'QueryOnContact' OR APXTConga4__Name__c = 'QueryOnLead' OR APXTConga4__Name__c  = 'QueryOnLegalEntity']);
        String queryName = '';
        Integer i = 1;
        for(APXTConga4__Conga_Merge_Query__c query : mapQueries.values()){
            String queryId = query.Id;

            if(i< mapQueries.values().size()){
                queryName =queryName + '[' + query.APXTConga4__Name__c + ']' + queryId.substring(0, 15) + ',';
            } else{
                queryName =queryName + '[' + query.APXTConga4__Name__c + ']' + queryId.substring(0, 15);
            }
            i++;
        }
        System.debug('@208 queryName -->' + queryName); 
        String templateId = mapTemplate.values()[0].Id;  
        System.debug('@208 templateId -->' + templateId);                                                                                             
        Individual indi = individualInfos.values()[0];
        String leadId='';
        String contactId = '';
        String firstName = indi.FirstName;
        String lastName = indi.LastName;
        if(!indi.Leads.isEmpty()){
            leadId = indi.Leads[0].Id;
            system.debug('@208 LEAD -->' + leadId);
        } else if(!indi.Contacts.isEmpty()){
        	contactId = indi.Contacts[0].Id;
            system.debug('@208 CONTACT -->' + contactId);
        }
        UtilWrapper wrapper = new UtilWrapper();
        wrapper.leadId = leadId;
        wrapper.contactId = contactId;
        wrapper.firstName = firstName;
        wrapper.lastName = lastName;
        wrapper.templateId = templateId;
        wrapper.queryName = queryName;
        wrapper.indi = indi;
        return wrapper;
    }
    /**
	 * @description populate Conga Field for workflow
	 * @param individualId
     * @return String
	 */
    @AuraEnabled
    public static String startWorkflowOnIndividual(String individualId) {
        system.debug('individualId -->'+ individualId);
        UtilWrapper wrapper = getIndividualInfo(individualId);
        String leadId = wrapper.leadId;
        String contactId = wrapper.contactId;
        String firstName = wrapper.firstName;
        String lastName = wrapper.lastName;
        String templateId = wrapper.templateId;
        String queryName = wrapper.queryName;
        String name = firstName + ' ' + lastName;
        Individual indi =  wrapper.indi;
        if(!String.isBlank(leadId) && !String.isBlank(templateId)){
            String staticApi = indi.XC_CongaStaticAPI__c;
            String dynamicApi = '&Id=' + individualId+ '&AttachmentParentID=' + leadId+  '&TemplateId=' +  templateId  + '&QueryId=' +  queryName +
                        + '&OFN=' + lastName + 
                        + '&DefaultPDF=1&QMode=SalesforceFile';
            indi.XC_CongaDynamicAPI__c = staticApi + dynamicApi;

            //indi.XC_CongaDynamicAPI__c = '&sessionid=00D9E0000008pbQ!ARQAQFUKBUPoH80HPeEqcIF9BwfOAlvEu6Bz2OLjos.aa0bC7lsam25beQ.zOOhU8RUDbiFssf4MoyEJKICyGmWvVMtmWHQf&serverurl=https://enelx-ci--exdev1.my.salesforce.com/services/Soap/u/29.0/00D9E0000008pbQ&Id=0PK9E000000nMYgWAM&AttachmentParentID=00Q9E000006PqaWUAS&QueryId=[QueryOnLegalEntity]a4Z9E00000057uG,[QueryOnLead]a4Z9E00000057u6,[QueryOnContact]a4Z9E00000057uB&TemplateId=a4h9E0000006a5oQAA&OFN=TEST&DefaultPDF=1&SC0=1&SC1=SalesforceFile&DS7=11';
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@209 lead dynamicApi --->' + indi.XC_CongaDynamicAPI__c);
            XC_UTIL_Sobject.updateRecord(indi);
            return 'The call to Conga has started. The document will be attached to the connected Lead.'; 
            
        } else if(!String.isBlank(contactId) && !String.isBlank(templateId)){
            contactId = contactId.substring(0, 15);
            String staticApi = indi.XC_CongaStaticAPI__c;
            String dynamicApi = '&Id=' + individualId + '&QueryId=' +  queryName + '&TemplateId=' +  templateId 
                        + '&AttachmentParentID=' + contactId
                        + '&OFN=' + lastName + 
                        + '&DefaultPDF=1&QMode=SalesforceFile';
            indi.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@209 contact dynamicApi --->' + indi.XC_CongaDynamicAPI__c);
            XC_UTIL_Sobject.updateRecord(indi);
            return 'The call to Conga has started. The document will be attached to the connected Contact.';  
        } else {
            return 'No Lead or Contact connected to this individual record';
        }
    }
}