/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/

@isTest
public with sharing class XC_TR_Opp_U_CheckZipBlackList_Test {
    @TestSetup
    static void setup(){
        Test.startTest();
        //OneOrg__c org            = new OneOrg__c();
        //org.Name                 = 'OneOrg (User)';
        //org.XC_Spain_Triggers__c = true;
        //insert org;
        insert XC_DF_OneOrg.createOneOrg('Spain');
        User u = XC_DF_User.createUserAdmin();
        insert u;
        //List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        //insert listLead;

        Test.stopTest();

    }
    @isTest
    static void checkBlackListOnInsert_Test() {
        Test.startTest();
        List<Contact> listc = XC_DF_Contact.createCondominiumContacts(1);
        insert listc;

        Account acc = new Account(Id = listc[0].AccountId);
        List<Account> listAccount = new List<Account>();
        listAccount.add(acc);

        List<XC_Address__c> listadd = XC_DF_Address.createAddress(listAccount);
        insert listadd;

        List<Opportunity> listopp = XC_DF_Opportunity.createOpportunityWithVisit(listc,listadd[0]);
        listopp[0].XC_ProductCategoryOfInterest__c= 'Caldera';
        listopp[0].XC_LegalEntity__c= 'EndesaX';
        listopp[0].AccountId = listAccount[0].Id;
        listopp[0].XC_PrincingRegion__c = 'Centro';
        listopp[0].XC_ClosureDateTime__c = dateTime.now();
        listopp[0].XC_Address__c = listadd[0].Id;
        try{
            insert listopp;
        }
        catch(exception e)
        {
            System.debug(e);
        }

        Map<Id,Opportunity>mapOld = new Map<Id,Opportunity>(listopp);


        listopp[0].XC_ProductCategoryOfInterest__c= 'Calentador';
        listopp[0].XC_LegalEntity__c= 'EnelXItalia';
        try{
            update listopp;
            Map<Id,Opportunity> mapNew = new Map<Id,Opportunity>(listopp);
            XC_TR_Opp_U_CheckZipBlackList.checkBlackListOnUpdate(listopp,mapOld,mapNew);
        }
        catch(exception e)
        {
            System.debug(e);
        }





    }
}