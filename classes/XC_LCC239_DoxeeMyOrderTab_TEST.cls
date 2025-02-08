/**
 * The Class XC_LCC239_DoxeeMyOrderTab_TEST.
 *
 * @author Simone Trenta - strenta@deloitte.it
 * @date Creation  18/01/2020
* @description Test Class for XC_LCC239_DoxeeMyOrderTab / Canvas / Doxee 

*/
@isTest
public class XC_LCC239_DoxeeMyOrderTab_TEST {
    
    static testMethod void getUserInformationOrder() {

        User automotiveUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and IsActive=true and XC_LegalEntity__c='EnelXItalia' LIMIT 1];
     
        System.runAs(automotiveUser){
            OneOrg__c org = new OneOrg__c(); 
            org.Name = 'OneOrg (User)';
            org.XC_Spain_Triggers__c = true;
            insert org;
            NE__Order__c o=XC_DF_Order.createOrder('Opty');
            test.startTest();
            XC_LCC239_DoxeeMyOrderTab.fetchUser(o.id);
            test.stopTest();
        }
    }
    

    
}