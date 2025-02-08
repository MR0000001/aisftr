/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Modification 25/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC053_RedirectOpportunity_TEST 
*/  

@isTest
public class XC_LCC053_RedirectOpportunity_TEST {

    /**
    * @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
    * @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
    * @description - Method to test retriveReceivingChannel
    */
    @isTest
    static void onRedirectOpp(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        User u = XC_DF_User.createUserAdmin(); 
        insert u;
        
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert wo;
        XC_LCC053_RedirectOpportunity.RedirectWrapper wrapper = XC_LCC053_RedirectOpportunity.retrieveInfoForRedirect(u.id, wo[0].Id);
     	List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        listAccount[0].XC_DocumentCountry__c = 'Spain';
        listAccount[0].IdentityType__c = 'Passport';
        listAccount[0].IdentityNumber__c = '1234444'; 
        insert listAccount; 
        wo[0].AccountId = listAccount[0].Id;
        update wo;
        XC_LCC053_RedirectOpportunity.RedirectWrapper wrapper2 = XC_LCC053_RedirectOpportunity.retrieveInfoForRedirect(u.id, wo[0].Id);
        System.assert(wrapper.channelUser != null);
        Test.stopTest(); 
    }

}