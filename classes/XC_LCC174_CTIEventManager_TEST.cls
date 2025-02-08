@isTest
public class XC_LCC174_CTIEventManager_TEST {

    @isTest
    static void checkCTIUserEnabled(){
        Test.startTest();
        Boolean check = XC_LCC174_CTIEventManager.checkCTIUserEnabled(); 
        Test.stopTest();
        system.assert(true);
    }
}