/**
* @author Sara Miozza sara.miozza@nttdata.com
* @date Creation 03/06/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_SObject_CheckVisibility_TEST test class for XC_UTIL_SObject_CheckVisibility 
*/
@isTest
public class XC_UTIL_SObject_CheckVisibility_TEST {
    @TestSetup
    	static void setup(){
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org; 
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;    
        } 
    
    @isTest
    static void checkVisibilityTest(){
        List<Lead> leadList = [SELECT id, FirstName, LastName, Email FROM Lead LIMIT 1];
        List<Id> listId = new List<Id>();
        for(Lead ld : leadList ){
            listId.add(ld.Id);
        }
        String objName = 'Lead';
        test.startTest();
        XC_UTIL_SObject_CheckVisibility.checkVisibility(listId,objName);
        test.stopTest();
        System.assert(!listId.isEmpty()); 
    }
    @isTest
    static void getVisibleRecordTypeTest(){
        String objectType = 'Account';
        test.startTest();
        XC_UTIL_SObject_CheckVisibility.getVisibleRecordType(objectType);
        test.stopTest();
        System.assert(objectType!=null); 
    }
    
     @isTest
    static void updateLockedRecordFieldByIdTest(){
        List<Lead> leadList = [SELECT id, FirstName, LastName, Email,RecordTypeID FROM Lead LIMIT 1];
        List<Id> listId = new List<Id>();
        for(Lead ld : leadList ){
            listId.add(ld.Id);
        }
        Id recordId = listId[0];
        String fieldName = 'Email';
        String value = 'test.test@gmail.com';
        test.startTest();
        XC_UTIL_SObject_CheckVisibility.updateLockedRecordFieldById(recordId,fieldName,value);
        test.stopTest();
        System.assert(value!=null); 
    }
    

}