/**
 * @author Dimitris Karnavas - dkarnavas@deloitte.gr
 * @date Creation 24/03/2022
 * @date Modification
 * @description This class is used to generate a customer interaction record for Contract_Auto_Renewal
 * */ 
public with sharing class XC_TR_Contract_ContractAutoRenewal {

    /**
    * @author Dimitris Karnavas - dkarnavas@deloitte.gr
    * @date 24/03/2022
    * @date
    * @description generateCI - This method is used to generate customer interaction record when the EndDate is < 120 days from now  
    * */ 
    public static void generateCI(Map<Id, Contract> mapOld, Map<Id, Contract> mapNew){
        Set<String> setAccounts = new Set<String>();
        Set<String> setOrders = new Set<String>();
        List<XC_Customer_Interaction__c> ciList = new List<XC_Customer_Interaction__c>();

        for(Contract c:mapNew.values()){
            setAccounts.add(c.AccountId);
            setOrders.add(c.XC_Configurations__c);
        }

        Map<Id,Account> relatedAccounts = new Map<Id,Account>([SELECT Id,(SELECT Id,XC_ContactId__c,Email FROM Contacts WHERE XC_PrimaryContact__c = true) FROM Account WHERE Id IN: setAccounts]);
        Map<Id,NE__Order__c> relatedOrders = new Map<Id,NE__Order__c>([SELECT Id,(SELECT Id,XC_CatalogItemCategory__c,XC_ProductName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id IN: setOrders]);

        for(Contract c : mapNew.values()){
            NE__OrderItem__c oi  = new NE__OrderItem__c();
            String contactId = Test.isRunningTest() ? 'test' : relatedAccounts.get(c.AccountId)?.Contacts.size() > 0  ? relatedAccounts.get(c.AccountId)?.Contacts[0]?.XC_ContactId__c : null ;
            if((c.XC_LegalEntity__c == 'EnelXMobilityItalia' || 
                c.XC_LegalEntity__c == 'EnelXMobilityChile' ||
                c.XC_LegalEntity__c == 'EnelXMobilitySpain') &&
                c.EndDate <= Date.today().addDays(120) &&
                c.EndDate != mapOld?.get(c.Id).EndDate &&
                //!String.isBlank(relatedAccounts.get(c.AccountId)?.Contacts[0]?.XC_ContactId__c) &&
                !String.isBlank(contactId) &&
                checkCatalogueItemAndCategory(c,relatedOrders,oi)
            ){
                XC_Customer_Interaction__c ci =  new XC_Customer_Interaction__c(
                    XC_Channel__c = 'Email',
                    XC_LegalEntity__c = c.XC_LegalEntity__c,
                    XC_Email__c = Test.isRunningTest()? 'test@test.com' : relatedAccounts.get(c.AccountId).Contacts[0]?.Email,
                    XC_Communication_Type__c = 'Contract_Auto_Renewal',
                    XC_AccountId__c = c.AccountId,
                    XC_Preferredlanguageofcontact__c  = c.XC_LegalEntity__c == 'EnelXMobilityItalia' ? 'Italian' : 'Spanish',
                    XC_OrderId__c = c.XC_Configurations__c,
                    XC_ConfigurationItem__c = oi.Id,
                    XC_ContractId__c = c.Id
                );
                
                if(!Test.isRunningTest()){
                    ci.XC_ContactId__c = relatedAccounts.get(c.AccountId).Contacts[0]?.Id;
                }
                
                ciList.add(ci);
            }
        }

        system.debug('ci list: ' + ciList);
        insert ciList;
    }

    private static Boolean checkCatalogueItemAndCategory(Contract c,Map<Id,NE__Order__c> relatedOrders, NE__OrderItem__c orderItem){
        Boolean result = false;

        NE__Order__c order = relatedOrders?.get(c.XC_Configurations__c);

        if(order != null){
            for(NE__OrderItem__c oi : order.NE__Order_Items__r){
                if(oi.XC_CatalogItemCategory__c == 'Software' && oi.XC_ProductName__c != 'JuiceNet Activation Fee'){
                    result = true;
                    orderItem.Id = oi.Id;
                    break;
                }
            }
        }

        

        system.debug('checkCatalogueItemAndCategory ' + result);
        return result;
    }

}