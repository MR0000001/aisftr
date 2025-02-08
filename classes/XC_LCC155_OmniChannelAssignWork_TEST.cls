/**
*@author: francesco imperioli - fimperioli@deloitte.it
*@description : TC for XC_LCC155
*@createddate : 30-01-2020
 */
@IsTest
public  class XC_LCC155_OmniChannelAssignWork_TEST {

    @TestSetup
    static void setup(){
        User u = XC_DF_User.createUserAdmin();
        insert u;
        Case c = XC_DF_Case.createCases(1)[0];
        c.ownerId = u.Id;
        insert c;  

    }

    @IsTest
    static void testupdateParentCaseStatus(){
        Test.startTest();
            Case c = [SELECT ID FROM Case LIMIT 1];
            XC_LCC155_OmniChannelAssignWork.updateParentCaseStatus(c.Id);
        Test.stopTest();
    }

    @IsTest
    static void testupdateParentCaseStatusBlank(){
        Test.startTest();
            XC_LCC155_OmniChannelAssignWork.updateParentCaseStatus('');
        Test.stopTest();
    }


}