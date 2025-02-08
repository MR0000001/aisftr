/**
 * @author Monica Cutillo - mcutillo@deloitte.it
 * @date Creation 20/04/2020
 * @description XC_TR_Case_Handler_TEST - test class for XC_TR_Case_Handler.
 */
@isTest
public class XC_TR_Case_Handler_TEST {
    
    @TestSetup
    static void setup()
    {	
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
    
    @isTest
    static void populateAssetListDetails_EquipmenmtAssociatedOnUpdate(){
        User user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1];
        user.XC_EnabledToSkip__c = true;
        update user;
        system.runAs(user){
        List<Account> accntList = XC_DF_Account.createResidentialAccounts(1);
        accntList[0].XC_Segment__c = 'B2C';
        insert accntList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accntList);
        contList[0].XC_Segment__c = 'B2C';
        insert contList;
        
        List<RecordType> rtCaseESP = [SELECT id FROM RecordType WHERE DeveloperName='XC_ESP_Complaint_Case' AND SObjectType = 'Case' LIMIT 1];

        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Reason = 'XCMOT005';
        //caseList[0].SubCause__c = 'ATCL070';
        caseList[0].SubCause__c = 'ATCL043'; //[DeAv 20211008 - CR NR1857]
        caseList[0].XC_CompliantApplicable__c = true;
        caseList[0].AccountId = accntList[0].Id;
        caseList[0].ContactId = contList[0].Id;
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        caseList[0].XC_Segment__c = 'B2C';
        if(!rtCaseESP.isEmpty()){
            caseList[0].RecordTypeId = rtCaseESP.get(0).Id;
        }
        Test.startTest();
        	insert caseList;
        	//caseList[0].XC_Subtype__c = 'XC069';
            caseList[0].XC_Subtype__c = 'XC058'; //[DeAv 20211008 - CR NR1857]
        	update caseList;
        	Case caso = [SELECT Id, XC_Subtype__c FROM Case WHERE Id =: caseList[0].Id];
        	System.assert(String.isNotBlank(caso.XC_Subtype__c));
        Test.stopTest();
    }
}

}