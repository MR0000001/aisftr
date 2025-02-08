/**
* @author: Marco Ottaviano - mottaviano@deloitte.it 
* @fileName XC_LCC194_ChangeComOff_TEST
* @date Creation Date: 16/06/2020
* @description TEST CLASS FOR XC_LCC194_ChangeCommercialOffer
**/

@IsTest
public without sharing class XC_LCC194_ChangeComOff_TEST {

    @TestSetup
    static void makeData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
    }

    @isTest
    static void changeCommercialOfferOnOrder() {

            List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
            insert accountList;
            List<Contact> conList = XC_DF_Contact.createResidentialContacts(accountList);
            conList[0].XC_PrimaryContact__c = true;
            insert conList;
            List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
            insert address;
        Test.startTest();
      

            /* This method creates also the account and the related address */
            Opportunity opportunityToInsert = new Opportunity();
            opportunityToInsert.Name = 'OP00001';
            opportunityToInsert.XC_Contact__c = conList[0].Id;
            opportunityToInsert.AccountId = conList[0].AccountId;
            opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Caldera';
            opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
            opportunityToInsert.StageName = 'Draft';
            opportunityToInsert.XC_Source__c = 'BLOG';
            opportunityToInsert.XC_ReceivingChannel__c = 'Web';
            opportunityToInsert.XC_Address__c = address[0].Id;
            opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
            insert opportunityToInsert;

            NE__Order__c order = new NE__Order__c();
            order.NE__Type__c = 'Order';
            order.NE__OptyId__c = opportunityToInsert.Id;
            order.NE__AccountId__c = opportunityToInsert.AccountId;
            order.XC_Country__c = 'Spain';
            order.XC_Segment__c = 'B2C';
            order.XC_LegalEntity__c ='EndesaX';
            insert order;
            NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
            item.NE__Account__c = opportunityToInsert.AccountId;
            insert item;
            update order;

            XC_LCC194_ChangeCommercialOffer.changeCommercialOfferOnOrder(order.Id,false);
            XC_LCC194_ChangeCommercialOffer.getOrderInfo(order.Id);

        Test.stopTest();
    }


    @isTest
    static void testcheckResultofAllDML() {
        Test.startTest();
            List<XC_UTIL_Sobject.WrapperResult> wResList = new List<XC_UTIL_Sobject.WrapperResult>();
            XC_UTIL_Sobject.WrapperResult resSuccFalse = new XC_UTIL_Sobject.WrapperResult();
            resSuccFalse.success=false;
            resSuccFalse.errorMessage= 'Error';
            resSuccFalse.recordId ='aa';
            wResList.add(resSuccFalse);
            
            SavePoint sp = DataBase.setSavePoint();
            XC_UTIL_ResultWrapper rew = new XC_UTIL_ResultWrapper();

            XC_LCC194_ChangeCommercialOffer.checkResultofAllDML(wResList,sp,rew);
        Test.stopTest();
    }
}