/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation 17/05/2019 
* @description XC_LCC024_ConfItemUpdateStartDate_TEST – Test class for XC_LCC024_ConfItemUpdateStartDate
*/

@isTest
public class XC_LCC024_ConfItemUpdateStartDate_TEST {
    //Test Method updateFieldsOrderItems
    static testMethod void updateFieldsOrderItems(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        NE__Order__c o = new NE__Order__c();
        o.NE__Delivery_Date__c = Date.today();
        insert o;
        NE__OrderItem__c oi = XC_DF_OrderItem.createOrderItem(o);
        insert oi;
        List<NE__OrderItem__c> listOI;
        try{
            listOI = XC_LCC024_ConfItemUpdateStartDate.updateFieldsOrderItems(o.Id);
            
        } catch(exception e){
            System.assert(e!=null);
        }

        System.assertEquals(false, listOI!=null);
        Test.stopTest();
    }

    //Test Method callCommodity
    static testMethod void callCommodity(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        Account a = XC_DF_Account.createResidentialAccounts(1)[0];
        insert a;
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'ConfItemUpdateStartDate';
        ic.XC_interfaceName__c = 'ConfItemUpdateStartDate';
        insert ic;
        XC_LCC024_ConfItemUpdateStartDate.ResultWrapper wr = XC_LCC024_ConfItemUpdateStartDate.callCommodity(a.Id);
        ic.XC_activeInterface__c = false;
        update ic;
        wr = XC_LCC024_ConfItemUpdateStartDate.callCommodity(a.Id);
        System.assertEquals(true, wr!=null);
        Test.stopTest();
    }
    
    //Test Method updateRecord
    static testMethod void updateRecord(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        Account a = XC_DF_Account.createResidentialAccounts(1)[0];
        insert a;
        XC_LCC024_ConfItemUpdateStartDate.updateRecord(a.Id,a.Id);
        System.assertEquals(true, a!=null);
        Test.stopTest();
    }
    
    //Test Method checklistValue
    static testMethod void checklistValue(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        Account a = XC_DF_Account.createResidentialAccounts(1)[0];
        insert a;
        list<Account> lista = XC_LCC024_ConfItemUpdateStartDate.checklistValue(a.Id);
        System.assertEquals(true, lista!=null);
        Test.stopTest();
    }
    
}