/**
 * @description The Class XC_TR_CustomerInteractionRelationship.
 */
public without sharing class XC_TR_CustomerInteractionRelationship {
    
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Sets the interaction id on the case.
     * @param listNew the new cases
     */
    public static void setInteractionId(list<Case> listNew){
        List<id> caseIds = XC_UTIL_Sobject.getIds(listNew);
        String currentUser = UserInfo.getUserId();
        List<Case> caseToUpdate = new List<Case>();
        List<XC_CTI_Interaction__c> ciList = queryOnCustomerInteraction(currentUser);
        if(ciList.isEmpty()){
            return;
        }
        for (Case caso : listNew){
            //if(caso.CreatedById == currentUser){
                caso.XC_CTI_Interaction__c = ciList[0].id;
            //}
        }
    }

    /**
     * @description Sets the case data on the CTIinteraction.
     * @param listNew the new cases
     */
    public static void setCTIinteraction(list<Case> listNew){
        System.debug('@@@ List Case ' +listNew);
       
        List<id> caseIds = XC_UTIL_Sobject.getIds(listNew);
        String currentUser = UserInfo.getUserId();
        List<Case> caseList = queryOnCase(caseIds);
        List<XC_CTI_Interaction__c> customerToUpdate = new List<XC_CTI_Interaction__c>();
        List<XC_CTI_Interaction__c> ciList = queryOnCustomerInteraction(currentUser);
        
        if(ciList.isEmpty()){
            return;
        }
        for (Case caso : caseList){
            caso.XC_CTI_Interaction__c = ciList[0].id; //caseList[0]
            ciList[0].XC_ContactId__c = caseList[0].ContactId;
            ciList[0].XC_AccountId__c = caseList[0].AccountId;
            ciList[0].XC_CaseId__c = caseList[0].Id;
            customerToUpdate.add(ciList[0]);
        }
        XC_UTIL_Sobject.updateListRecords(customerToUpdate);
    }

    /**
    * @description Sets the interaction id on opportunity.
    * @param listNew the new interaction id on opportunity
     */
    public static void setInteractionIdOnOpportunity(list<Opportunity> listNew){
       
        List<id> oppIds = XC_UTIL_Sobject.getIds(listNew);
        String currentUser = UserInfo.getUserId();
        List<Opportunity> oppList = new List<Opportunity>();
        if(Schema.sObjectType.Opportunity.isAccessible() && Schema.sObjectType.Opportunity.fields.Id.isAccessible() && Schema.sObjectType.Opportunity.fields.XC_CTI_Interaction__c.isAccessible() && Schema.sObjectType.Opportunity.fields.XC_Contact__c.isAccessible() && Schema.sObjectType.Opportunity.fields.AccountId.isAccessible()){     
            oppList = [SELECT id, XC_CTI_Interaction__c, XC_Contact__c, AccountId FROM Opportunity WHERE Id IN: oppIds];
        } 
        List<XC_CTI_Interaction__c> customerToUpdate = new List<XC_CTI_Interaction__c>();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        
        List<XC_CTI_Interaction__c> ciList = queryOnCustomerInteraction(currentUser);
        
        for (Opportunity o : oppList){
           if(!ciList.isEmpty()){
                oppList[0].XC_CTI_Interaction__c = ciList[0].id;
                ciList[0].XC_ContactId__c = oppList[0].XC_Contact__c;
                ciList[0].XC_AccountId__c = oppList[0].AccountId;
                customerToUpdate.add(ciList[0]);
                oppToUpdate.add(oppList[0]);
            }
        }
        
        XC_UTIL_Sobject.updateListRecords(oppToUpdate);
        XC_UTIL_Sobject.updateListRecords(customerToUpdate);

    }
    
       /**
    * @description Sets the interaction id on lead.
    * @param listNew the new interaction id on lead
     */
    public static void setInteractionIdOnLead(list<Lead> listNew){
       
        List<id> oppIds = XC_UTIL_Sobject.getIds(listNew);
        String currentUser = UserInfo.getUserId();
        List<Lead> leadList = new List<Lead>();
        if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.fields.Id.isAccessible() && Schema.sObjectType.Lead.fields.XC_CTI_Interaction__c.isAccessible() ){     
            leadList = [SELECT id, XC_CTI_Interaction__c, Contact__c  FROM Lead WHERE Id IN: oppIds];
        } 
        List<XC_CTI_Interaction__c> customerToUpdate = new List<XC_CTI_Interaction__c>();
        List<Lead> oppToUpdate = new List<Lead>();
        
        List<XC_CTI_Interaction__c> ciList = queryOnCustomerInteraction(currentUser);
        
        for (Lead o : leadList){
           if(!ciList.isEmpty()){
                leadList[0].XC_CTI_Interaction__c = ciList[0].id;
                ciList[0].XC_ContactId__c = null;
                ciList[0].XC_AccountId__c = null;
                ciList[0].XC_LeadId__c = leadList[0].Id;
                ciList[0].XC_HasMultipleMatch__c = false;
                customerToUpdate.add(ciList[0]);
                oppToUpdate.add(leadList[0]);
            }
        }
        
        XC_UTIL_Sobject.updateListRecords(oppToUpdate);
        XC_UTIL_Sobject.updateListRecords(customerToUpdate);

    }
    /**
    * @description query from Case
    * @param caseIds
    * @return caseList
     */
    public static List<Case> queryOnCase(List<id> caseIds) {
        List<Case> caseList = new List<Case>(); 
        if(Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Case.fields.Id.isAccessible() && Schema.sObjectType.Case.fields.XC_CTI_Interaction__c.isAccessible() && Schema.sObjectType.Case.fields.ContactId.isAccessible() && Schema.sObjectType.Case.fields.AccountId.isAccessible()){
            caseList = [SELECT id, XC_CTI_Interaction__c, ContactId, AccountId,RecordTypeId FROM Case WHERE Id IN: caseIds]; 
        }
        return caseList;
    }

    /**
    * @description query on XC_CTI_Interaction__c
    * @param currentUser
    * @return ciList
     */
    
    public static List<XC_CTI_Interaction__c> queryOnCustomerInteraction(String currentUser) {
        List<XC_CTI_Interaction__c> ciList = new List<XC_CTI_Interaction__c>();
        if(Schema.sObjectType.XC_CTI_Interaction__c.isAccessible() && Schema.sObjectType.XC_CTI_Interaction__c.fields.Id.isAccessible() && Schema.sObjectType.XC_CTI_Interaction__c.fields.XC_ContactId__c.isAccessible() && Schema.sObjectType.XC_CTI_Interaction__c.fields.XC_AccountId__c.isAccessible()){
            ciList = [SELECT id, XC_ContactId__c,XC_AccountId__c,XC_CaseId__c FROM XC_CTI_Interaction__c 
       	                WHERE XC_InteractionStatus__c ='Open' AND CreatedById=:currentUser ORDER BY CreatedDate DESC limit 1]; // AND XC_Communication_Type__c='Inbound Call' [MC,FI 20191107]
        }
        System.debug(ciList);
        return ciList;
    }
}