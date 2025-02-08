@isTest
public class XC_AMP_LCC003_RedirectOrderCreation_TEST {


    @isTest
    static void retrieveRecordTypeId(){
        
        Test.startTest();
        List<Map<String,Object>> result = XC_AMP_LCC003_RedirectOrderCreation.retrieveRecordTypeId('XC_GLO_Account_Residential'); 
        System.assert(result!=null && !result.isEmpty());
        test.stopTest();
    }
}