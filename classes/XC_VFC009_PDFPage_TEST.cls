/**
* @author Monica Cutillo - mcutillo@deloitte.it
* @date Creation  17/03/2020 
* @description XC_UTIL_ViewDefinitionsReadAccount_TEST – Test class for XC_UTIL_ViewDefinitionsReadAccount
*/
@isTest
public class XC_VFC009_PDFPage_TEST {

    @isTest
    static void downloadPDF(){
        Test.startTest();
        XC_VFC009_PDFPage contr = new XC_VFC009_PDFPage();
        PageReference pageRef = contr.downloadPDF();
        System.assert(pageRef!=null);
        Test.stopTest();
    }
    
    
}