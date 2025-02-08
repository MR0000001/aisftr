/**
* @author Monica Cutillo - mcutillo@deloitte.it
* @date Creation  17/03/2020 
* @description XC_UTIL_ViewDefinitionsReadAccount_TEST – Test class for XC_UTIL_ViewDefinitionsReadAccount
*/
@isTest
public class XC_UTIL_ViewDefinitionsReadAccount_TEST {

    @isTest
    static void getReadAccountViewDefinitions(){
        Test.startTest();
        Map<String,XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition> viewData = XC_UTIL_ViewDefinitionsReadAccount.getReadAccountViewDefinitions();
        System.assert(!viewData.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    static void getCommodityViewDefinitions(){
        Test.startTest();
        Map<String,XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition> viewData = XC_UTIL_ViewDefinitionsReadAccount.getCommodityViewDefinitions();
        System.assert(!viewData.isEmpty());
        Test.stopTest();
    }
    
}