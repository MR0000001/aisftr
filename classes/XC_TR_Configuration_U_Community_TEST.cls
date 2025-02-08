@isTest
public class XC_TR_Configuration_U_Community_TEST {
    static testMethod  void setPartnerAccount(){
     test.startTest();
        List<NE__Order__c> listNew = XC_DF_Order.createOrders(1, 'Order');
        insert listNew;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        List<Account> acc = XC_DF_Account.createCondominiumAccounts(1);
        insert acc;
        List <Contact> cont = XC_DF_Contact.createCondominiumContacts(acc);
       	cont[0].AccountId=acc.get(0).id;
        insert cont; 
        User u = XC_DF_User.createCommunityUser(cont.get(0));
        insert u;
             for(Opportunity opp : oppList){
                opp.XC_Segment__c ='B2B';
                opp.AccountId = acc.get(0).id;
                opp.StageName = 'Draft'; 
                opp.Name = 'TEST'; 
                opp.CloseDate =System.today(); 
            }
        insert oppList;
            for(NE__Order__c ord : listNew){
                    ord.XC_Segment__c ='B2B';
                    ord.NE__OptyId__c = oppList.get(0).id;
                }
         update listNew;
          system.runAs(u){
    	XC_TR_Configuration_U_Community.setPartnerAccount(listNew);
          }
		test.stopTest();
    }
}