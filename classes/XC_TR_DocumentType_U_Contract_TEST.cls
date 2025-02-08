/**
     * @author Dario Tramontin dtramontin@deloitte.it  
    * @date Creation 23/10/2020
    * @date Modification 
    * @description XC_TR_DocumentType_U_Contract – Manage Contract Document Type for XC_TR_DocumentType Trigger
    */  

    @isTest
public with sharing class XC_TR_DocumentType_U_Contract_TEST {

    @isTest static void updateOrder(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, Label.XC_CL_Configuration_TypeInOrder);
        insert orderList;
        List<NE__Order__c> orderListFinancial = XC_DF_Order.createOrders(1, Label.XC_CL_Configuration_TypeInOrder);
        insert orderListFinancial;
        List<XC_DocumentType__c> listOfDocumentType = new List<XC_DocumentType__c>();
        XC_DocumentType__c documentType = new XC_DocumentType__c();
        documentType.Category__c = Label.XC_CL_Document_ContractSigned;
        documentType.XC_Configuration__c =orderList[0].Id;
        documentType.XC_DoxeeUrl__c = 'Url doxee';
        listOfDocumentType.add(documentType);
        XC_DocumentType__c documentTypeFinancial = new XC_DocumentType__c();
        documentTypeFinancial.Category__c = Label.XC_CL_LoanAgreementValue;
        documentTypeFinancial.XC_Configuration__c =orderListFinancial[0].Id;
        documentTypeFinancial.XC_DoxeeUrl__c = 'Url doxee';
        listOfDocumentType.add(documentTypeFinancial);
        insert listOfDocumentType;
    
        System.assertEquals(listOfDocumentType.isEmpty(), false);
        Test.stopTest(); 
        }  
}