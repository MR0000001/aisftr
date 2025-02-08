@istest
public class XC_TR_ConfiItem_U_FillAddress_TEST {
    static testMethod void populateAddressFromConf(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
    	User u = XC_DF_User.createUserAdmin();
    	insert u;
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        List<XC_Address__c> add=XC_DF_Address.createAddress(acc);
       	List<Contact> cont= XC_DF_Contact.createResidentialContacts(acc);
        List<Opportunity> opp =XC_DF_Opportunity.createOpportunityWithoutVisit(cont,add[0]);
        NE__Order__c order =XC_DF_Order.createOrderWithAddress('InOrder',add[0].id,acc[0].id,opp[0].id);
        NE__OrderItem__c ori = XC_DF_OrderItem.createOrderItem(order);        
        ori.NE__OrderId__c= order.id;
        List<NE__OrderItem__c> oiList = new List<NE__OrderItem__c>();
        oiList.add(ori);
        insert oiList;
        XC_TR_ConfiItem_U_FillAddress.populateAddressFromConf(oiList);
        test.stopTest();
        
    }
}