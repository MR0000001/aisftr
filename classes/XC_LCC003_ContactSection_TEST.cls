/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 03/05/2019 
* @description XC_LCC003_ContactSection_TEST – Test class for XC_LCC003_ContactSection
*/ 
@isTest 
public class XC_LCC003_ContactSection_TEST {
    
    /**
	 * @author Roberta Porrega - roberta.porrega@nttdata.com  
     * @description test retrieveLanguagePicklist
     */
    static testMethod void retrieveLanguagePicklist() {
        String res = XC_LCC003_ContactSection.retrieveLanguagePicklist();
        System.assertNotEquals(null, res, 'Error');
    }

    @isTest
    static void retrieveDefaultDocumentTypeTest() {
        Test.startTest();
            String res = XC_LCC003_ContactSection.retrieveDefaultDocumentType('Spain');
        Test.stopTest();
    }

    
 
}