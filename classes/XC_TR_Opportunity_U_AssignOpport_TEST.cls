/**
 * Created by dolombardi on 09/12/2020.
 */
@isTest
public with sharing class XC_TR_Opportunity_U_AssignOpport_TEST {
    static testMethod void insertOpp(){
        List<Contact> listc = XC_DF_Contact.createCondominiumContacts(1);
        insert listc;

        Account acc = new Account(Id = listc[0].AccountId);
        List<Account> listAccount = new List<Account>();
        listAccount.add(acc);

        List<XC_Address__c> listadd = XC_DF_Address.createAddress(listAccount);
        listadd[0].XC_ElectricCUPS__c ='ok';
        listadd[0].XC_GasCUPS__c ='ok';
        insert listadd;

        List<Opportunity> listopp = XC_DF_Opportunity.createOpportunityWithVisit(listc,listadd[0]);
        listopp[0].XC_ProductCategoryOfInterest__c= 'Caldera';
        listopp[0].XC_LegalEntity__c= 'EndesaX';
        listopp[0].AccountId = listAccount[0].Id;
        listopp[0].XC_PrincingRegion__c = 'Centro';
        listopp[0].XC_ClosureDateTime__c = dateTime.now();
        listopp[0].XC_Address__c = listadd[0].Id;
        insert listopp;
        XC_TR_Opportunity_U_AssignOpportunity.rebaltCUPS(listopp);

    }

}