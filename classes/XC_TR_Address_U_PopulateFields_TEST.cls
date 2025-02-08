/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  09/05/2019 
* @description XC_TR_Address_U_PopulateFields_TEST – Test class for XC_TR_Address_U_PopulateFields
*/ 
@isTest
private class XC_TR_Address_U_PopulateFields_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
    
    static testMethod void onInsert() {
        List<XC_Address__c> addressList = XC_DF_Address.createAddress(100);

        Test.startTest();
        insert addressList;
        Test.stopTest();        
    }
    
    static testMethod void onUpdate() {
        List<XC_Address__c> addressList = XC_DF_Address.createAddress(100);
        insert addressList;
        Integer i = 0;
        List<XC_Address__c> addressToUpdate = [SELECT Id FROM XC_Address__c];
        system.debug(addressToUpdate);
        for(XC_Address__c addr : addressToUpdate){ 
            addr.XC_Address__c = 'Test on Update';
            addr.XC_City__c = 'Barcelona';
            addr.XC_Stair__c = '4';
            addr.XC_Floor__c = 'D';
        }
        Test.startTest();
        update addressToUpdate;
        Test.stopTest();        
    }

}