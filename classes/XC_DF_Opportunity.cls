/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 06/05/2019
* @description XC_DF_Opportunity – Data Factory for Opportunity
*/
@isTest
public class XC_DF_Opportunity {
     /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to create N Opportunity
     * @param  conList List<Contact> 
     * @param  address XC_Address__c 
     * @return List<Opportunity> to insert 
    */ 
      public static List<Opportunity> createOpportunityWithVisit(List<Contact> conList, XC_Address__c address) {
        XC_ProductCategoryOfInterest__c prodCat =  XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        insert prodCat;
        List<Opportunity> listOpportunity = new List<Opportunity>();
        for(Integer i = 0; i < conList.size(); i++) {
                Opportunity opportunityToInsert = new Opportunity();
                opportunityToInsert.Name = 'OP0000'+ i;
                opportunityToInsert.XC_Contact__c = conList[0].Id;
                opportunityToInsert.AccountId = conList[0].AccountId;
                opportunityToInsert.XC_ProductCategoryOfInterest__c = prodCat.Name;
                opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
                opportunityToInsert.StageName = 'Draft';
                opportunityToInsert.XC_Source__c = 'BLOG';
                opportunityToInsert.XC_ReceivingChannel__c = 'Web';
                opportunityToInsert.XC_Address__c = address.Id;
                opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
                opportunityToInsert.XC_PipelineStatus__c = 'Qualified potential opportunity';
                listOpportunity.add(opportunityToInsert);
        }
        return listOpportunity;
    }
      /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to create N Opportunity
     * @param  n  Integer
     * @param  visit Boolean 
     * @return List<Opportunity> to insert 
    */ 
      public static List<Opportunity> createOpportunity(Integer n, Boolean visit) {
        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(n);
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        insert contList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        insert address;
        if (visit){
            return createOpportunityWithVisit(contList, address[0]);
        }
        return createOpportunityWithoutVisit(contList, address[0]);
    }
     /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to create N Opportunity
     * @param  conList List<Contact> 
     * @param  address XC_Address__c 
     * @return List<Opportunity> to insert
    */
      public static List<Opportunity> createOpportunityWithoutVisit(List<Contact> conList, XC_Address__c address) {
        XC_ProductCategoryOfInterest__c prodCat =  XC_DF_ProductCategoryOfInterest.prodCatWithoutVisitRecord();
        insert prodCat;
        List<Opportunity> listOpportunity = new List<Opportunity>();
        for(Integer i = 0; i < conList.size(); i++) {
                Opportunity opportunityToInsert = new Opportunity();
                opportunityToInsert.Name = 'OP0000'+ i;
                opportunityToInsert.XC_Contact__c = conList[0].Id;
                opportunityToInsert.AccountId = conList[0].AccountId;
                opportunityToInsert.XC_ProductCategoryOfInterest__c = prodCat.Name;
                opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
                opportunityToInsert.StageName = 'Draft';
                opportunityToInsert.XC_Source__c = 'BLOG';
                opportunityToInsert.XC_ReceivingChannel__c = 'Web';
                opportunityToInsert.XC_Address__c = address.Id;
                opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
                listOpportunity.add(opportunityToInsert);
        }
        return listOpportunity;
    }
    
     /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description Method to create an Opportunity with assigned service resources
     * @param  n Integer
     * @return List<Opportunity> to insert
    */
    public static List<Opportunity> createOpportunitiesWithAssignedResource(Integer n) {
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Opportunity> listOpportunity = createOpportunity(n, false);
        List<ServiceResource> serviceResList = XC_DF_ServiceResource.createServiceResources(n);
        for(Integer i = 0; i<n ; i++){
            Opportunity opp = listOpportunity[i];
            opp.XC_CommercialVisitAssignedResource__c = serviceResList[i].Id;
            opportunities.add(opp);
        }
        return opportunities;
    }
}