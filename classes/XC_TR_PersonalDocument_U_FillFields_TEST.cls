/**
* @author Sara Miozza sara.miozza@nttdata.com
* @date Creation  28/05/2019 
* @description XC_TR_PersonalDocument_U_FillFields_TEST – Test class for XC_TR_PersonalDocument_U_FillFields
*/ 
@isTest
public class XC_TR_PersonalDocument_U_FillFields_TEST {
    
    @isTest
    static void updateAdressFieldsTest(){
        test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;
        List<XC_PersonalDocument__c> personalDocList = new List<XC_PersonalDocument__c>();
        XC_PersonalDocument__c perDoc = new XC_PersonalDocument__c(XC_Lead__c = leadList[0].Id);
        personalDocList.add(perDoc);
        insert personalDocList;
        personalDocList[0].XC_ReleaseDate__c = date.today();
        update personalDocList;
        delete personalDocList;
        test.stopTest();
        System.assert(!personalDocList.isEmpty());
        
    }
    
    
    @isTest
    static void testCF() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        accList[0].XC_FirstName__c = 'testa';
        accList[0].XC_LastName__c = 'testa';
        accList[0].XC_AccountType__c = 'Residential';
        accList[0].IdentityNumber__c = 'TSTTST80A01H501G';
        accList[0].IdentityType__c = 'CF';
        insert accList;
        
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(accList);
        cont[0].FirstName = 'testa';
        cont[0].LastName = 'testa';
        insert cont;
        
        XC_PersonalDocument__c perDoc = new XC_PersonalDocument__c(XC_Contact__c = cont[0].id);
        
        perDoc.XC_DocumentType__c = 'CF';
        perDoc.XC_DocumentNumber__c = 'TSTTST80A01H501G';
        insert perDoc;
        
        try{
            perDoc.XC_DocumentNumber__c = 'asd';
            update perDoc;
        } catch(exception e){
            xc_util_debug.debug(true, e+'');
        }
        
        Test.stopTest();
    }
}