/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com 
* @date Creation 05/09/2019
* @date Modification 
* @description XC_LCC142_ChangeOfOwnershipParam_TEST 
*/  
@isTest
public class XC_LCC142_ChangeOfOwnershipParam_TEST {  
    
    /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com 
* @description  Method to test setTypeAndReason
*/
static testMethod void setTypeAndReasonTest(){

    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    NE__Order__c ord = new NE__Order__c();
        insert ord;
        NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__OrderId__c=ord.id, NE__Qty__c=2, XC_BillingModel__c='One Shot', XC_IsAProduct__c=true);
        insert ordItem;
        NE__OrderItem__c ordItem2 = new NE__OrderItem__c(NE__OrderId__c=ord.id, NE__Qty__c=1, XC_IsAProduct__c=true);
        insert ordItem2;
    XC_LCC142_ChangeOfOwnershipParam.setTypeAndReason(ord.id);
    Test.stopTest();

}
        /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com 
* @description  Method to test setTypeAndReason
*/
static testMethod void setTypeAndReasonTest2(){

    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    NE__Order__c ord = new NE__Order__c();
    ord.NE__Type__c = 'ChangeOrder';
    ord.XC_Subtype__c = 'Change of ownership';
        insert ord;
        NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__OrderId__c=ord.id, NE__Qty__c=2, XC_BillingModel__c='One Shot', XC_IsAProduct__c=true);
        insert ordItem;
        NE__OrderItem__c ordItem2 = new NE__OrderItem__c(NE__OrderId__c=ord.id, NE__Qty__c=1, XC_IsAProduct__c=true);
        insert ordItem2;
    XC_LCC142_ChangeOfOwnershipParam.setTypeAndReason(ord.id);
    Test.stopTest();

}
    
    
    
       /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com 
* @description  Method to test changeOwnerOnOrder
*/
static testMethod void changeOwnerOnOrderTest(){

    insert XC_DF_OneOrg.createOneOrg('Spain');
     
       
    List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
    insert accList;
    List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);

    Contact c = contactList[0];
    c.XC_PrimaryContact__c = true;
    insert contactList;

    Account a = accList[0];
    XC_Address__c ad = new XC_Address__c(XC_Account__c=a.id, XC_BillingAddress__c=true);
    insert ad;
    NE__Order__c ord = new NE__Order__c(NE__AccountId__c = a.id, XC_DeliveryAddress__c = ad.Id);
    insert ord;
    NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__OrderId__c=ord.id, NE__Qty__c=2, XC_BillingModel__c='One Shot', XC_IsAProduct__c=true);
    insert ordItem;
    NE__OrderItem__c ordItem2 = new NE__OrderItem__c(NE__OrderId__c=ord.id, NE__Qty__c=1, XC_IsAProduct__c=true);
    insert ordItem2;

    List<Account> accList2 = XC_DF_Account.createResidentialAccounts(1);
    insert accList2;

    List<Contact> contactList2 = XC_DF_Contact.createResidentialContacts(accList2);
    Contact con = contactList2[0];
    con.XC_PrimaryContact__c = true;
    insert contactList2;

    Test.startTest();
    	XC_LCC142_ChangeOfOwnershipParam.changeOwnerOnOrder(ord.id,accList2[0].id,'Contract migration','With Subrogation');
    Test.stopTest();

}
    static testMethod void getContactLists(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);
        insert contactList;
        Test.startTest();
        XC_LCC142_ChangeOfOwnershipParam.getContactLists(accList[0].id);
        Test.stopTest();
    }
    
    static testMethod void changeOwnerAndContactOnOrder(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);
        insert contactList;
        List<XC_Address__c> add = XC_DF_Address.createAddress(accList);
        insert add;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunityWithoutVisit(contactList, add[0]);
        insert oppList;
        NE__Order__c ord = XC_DF_Order.createOrderWithAddress('Order', add[0].id, accList[0].id, oppList[0].id);
        ord.XC_Segment__c = 'B2B';
        update ord;
        NE__OrderItem__c ordItem = XC_DF_OrderItem.createOrderItem(ord);
        ordItem.XC_Installation_Address__c = add[0].id;
        ordItem.NE__Account__c = accList[0].id;
        
        insert ordItem;
        List<Asset> ass = XC_DF_Asset.createAssets(accList);
        ass[0].XC_Configuration_Item__c = ordItem.id;
        ass[0].NE__Order_Config__c = ord.id;
        ass[0].XC_Original_Configuration_Item__c = ordItem.id;
        insert ass;
        List<Contract> contr = XC_DF_Contract.createContracts(1);
        contr[0].XC_Configurations__c = ord.id;
        insert contr;
        
        Test.startTest();
        	XC_LCC142_ChangeOfOwnershipParam.changeOwnerAndContactOnOrder(ord.id,accList[0].id, '', '', contactList[0].id );
        Test.stopTest();
    }
}