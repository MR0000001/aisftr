/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 13/02/2019
* @date Modification dd/mm/yyyy
* @description 
*/

public without sharing class XC_REST_Case_Outbound_D {
    
		 
    /**
     * @description Gets the case by id.
     * @param caseId the case id
     * @return the case by id
     */
    public static Case getCaseById(ID caseId){
        return [SELECT 	Id, Type, Reason, Channel_Type__c, Country__c, Provincia__c, Origin, XC_Opportunity__c, ContactID,
                       	Priority, CreatedDate, ClosedDate, OwnerId, Status, XC_ProductCategoryOfInterest__c, CaseNumber,
                       	Description, XC_WorkOrder__c, XC_Order__c, AssetId, SubCause__c, XC_Subtype__c, ParentId, AccountID, 
                		ContactPhone__c, NotificationEmail__c, XC_Contact_Preferred_Time__c, Subject, XC_ReclamationCounter__c, 
                		Responsible__c, Type_Notification__c, XC_OrderItem__c, XC_Address__c, Asset.Name, Asset.NE__CatalogItem__r.NE__Brand__c,
                		Asset.NE__CatalogItem__r.NE__Engine_Code__c
                        FROM Case
                       	WHERE ID =: caseID][0];
    }

 
}