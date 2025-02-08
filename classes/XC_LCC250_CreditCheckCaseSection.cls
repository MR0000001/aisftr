/**
 * Created by dolombardi on 19/04/2021.
 */

public with sharing class XC_LCC250_CreditCheckCaseSection {
    public class resultWrapper{
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public Map<String,String> mapFieldLabel;
        @AuraEnabled
        public Map<String,String> mapFieldValue;
        @AuraEnabled
        public List<String> listBillingModel;
    }



    /**
 * @author: Donato Lombardi
 * @date Creation Date 09/09/2019
 * @description method calculate WBE
 * @param recordId Id
 * @return errorMsg String
 */
    @AuraEnabled
    public static resultWrapper retrieveInformation(Id recordId) {
        resultWrapper rw = new resultWrapper();
        rw.success = True;
        Map<String,String> mapFieldValue = new Map<String,String>();
        Map<String,String> mapFieldLabel = new Map<String,String>();
        Case c = retrieveCase(recordId);

        String objectNameCase = 'Case';
        List<Schema.DescribeSObjectResult> describeSobjectsResultCase = Schema.describeSObjects(new List<String>{objectNameCase}); // this can accept list of strings, we describe only one object here
        String objectLabelCase = describeSobjectsResultCase[0].getLabel();
        mapFieldLabel.put('XC_ResultCVP_Label',objectLabelCase+' '+ Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get('XC_ResultCVP__c').getDescribe().getLabel());
        mapFieldLabel.put('XC_ExecutionDateCVP_Label',objectLabelCase+' '+ Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get('XC_ExecutionDateCVP__c').getDescribe().getLabel());



        String objectNameCOntact = 'Contact';
        List<Schema.DescribeSObjectResult> describeSobjectsResultCOntact = Schema.describeSObjects(new List<String>{objectNameCOntact}); // this can accept list of strings, we describe only one object here
        String objectLabelContact = describeSobjectsResultCOntact[0].getLabel();
        mapFieldLabel.put('contactDocumentNumberLabel',objectLabelContact +' '+ Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('XC_ContactDocumentNumber__c').getDescribe().getLabel());

        String objectNameAccount = 'Account';
        List<Schema.DescribeSObjectResult> describeSobjectsResultAccount = Schema.describeSObjects(new List<String>{objectNameAccount}); // this can accept list of strings, we describe only one object here
        String objectLabelAccount = describeSobjectsResultAccount[0].getLabel();
        mapFieldLabel.put('IdentityNumberLabel',objectLabelAccount+' '+ Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('IdentityNumber__c').getDescribe().getLabel());

        String objectNameOpportunity = 'Opportunity';
        List<Schema.DescribeSObjectResult> describeSobjectsResultOpportunity = Schema.describeSObjects(new List<String>{objectNameOpportunity}); // this can accept list of strings, we describe only one object here
        String objectLabelOpportunityRevFulLife = describeSobjectsResultOpportunity[0].getLabel();
        mapFieldLabel.put('XC_RevenueFullLife_Label',objectLabelOpportunityRevFulLife+' '+ Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get('XC_RevenueFullLife__c').getDescribe().getLabel());
        mapFieldLabel.put('XC_CapexFullLife_Label',objectLabelOpportunityRevFulLife+' '+ Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get('XC_CapexFullLife__c').getDescribe().getLabel());
        rw.mapFieldLabel = mapFieldLabel;
        //mapFieldValue.put(Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('XC_ContactDocumentNumber__c').getDescribe().getLabel(),c.Contact.XC_ContactDocumentNumber__c);

        mapFieldValue.put('IdentityNumber__c',c.Account.IdentityNumber__c);
        mapFieldValue.put('XC_ContactDocumentNumber__c',c.Contact.XC_ContactDocumentNumber__c);
        mapFieldValue.put('XC_RevenueFullLife_Value',  userInfo.getDefaultCurrency()+ ' ' + String.valueOf(c.XC_Opportunity__r.XC_RevenueFullLife__c));
        mapFieldValue.put('XC_CapexFullLife_Value', userInfo.getDefaultCurrency()+ ' ' + String.valueOf(c.XC_Opportunity__r.XC_CapexFullLife__c));
        mapFieldValue.put('ResultCVP_Value',String.valueOf(c.XC_ResultCVP__c));
        mapFieldValue.put('DateCVP_Value',String.valueOf(c.XC_ExecutionDateCVP__c));
        rw.mapFieldValue = mapFieldValue;

        System.debug('wr-->'+rw);
        System.debug('mapFieldValue-->'+mapFieldValue);
        List<String> listBillingModel = new List<String>();
        listBillingModel = retrieveConfItem(c.XC_Opportunity__c);
        rw.listBillingModel = listBillingModel;

        return rw; 

    }

    private static Case retrieveCase(Id recordId){
        Case c = [select id, XC_ResultCVP__c, XC_ExecutionDateCVP__c, Contact.XC_ContactDocumentNumber__c, Account.IdentityNumber__c, XC_Opportunity__c, XC_Opportunity__r.XC_RevenueFullLife__c, XC_Opportunity__r.XC_CapexFullLife__c from case where id =:recordId LIMIT 1];
        return c;
    }

    private static List<String> retrieveConfItem(Id opportunityId){
        List<NE__OrderItem__c> listItems = new List<NE__OrderItem__c>();
        listItems = [select id, XC_BillingModel__c, XC_PaymentMethod__c, name, NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c, NE__OrderId__r.NE__OptyId__r.XC_CapexFullLife__c, XC_BillingProfileLineItem__r.XC_PaymentTerm__c from NE__OrderItem__c where NE__OrderId__r.NE__OptyId__c = :opportunityId AND  RecordType.DeveloperName != 'Technical_Item' AND NE__Parent_Order_Item__c = null];
        List<String> listBillingModel = new List<String>();
        for(NE__OrderItem__c ne : listItems){
          listBillingModel.add(ne.name+': '+Label.XC_CL_BillingModel+ ' '+ ne.XC_BillingModel__c + '; ' + Label.XC_CL_PaymentMethodB2B +' '+ne.XC_PaymentMethod__c+'; '+ Label.XC_CL_PaymentTerm + ' ' + ne.XC_BillingProfileLineItem__r.XC_PaymentTerm__c +';' );
        }
        return listBillingModel;
    }

}