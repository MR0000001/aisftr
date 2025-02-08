/**
* @author CEmanuela Cacace ecacace@deloitte.it
* @date Creation  24/06/2019 
* @description XC_LCC069_ComplianceVerification1_U_TEST – Test class for XC_LCC069_ComplianceVerification1_U
*/
@isTest
public class XC_LCC069_ComplianceVerification1_U_TEST {
    //Test Method checkDocumentsComplianceVerification1
    static testMethod void complianceUtil(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_ComplianceVerificationStatus__c cvs = new XC_ComplianceVerificationStatus__c();
        cvs.Name = 'Test';
        insert cvs;
        XC_LCC069_ComplianceVerification1_U.UtilWrapper utilWr = new XC_LCC069_ComplianceVerification1_U.UtilWrapper();
        Set<String> stringSet = new Set<String>();
        stringSet.add(cvs.Name);
        utilWr.mapDocumentOrderItem.put(cvs.Name, stringSet);
        utilWr.mapIdDocument.put(cvs.Id, cvs); 
        try {
        XC_LCC069_ComplianceVerification1_U.complianceUtil(utilWr);
        } catch(Exception e){
            XC_UTIL_Debug.debug(true, e);
        }
        System.assert(utilWr!=null); 
        
        Test.stopTest();
    }
 
        //Test Method checkDocumentsComplianceVerification1
    static testMethod void populateJunctionDocumentOrderItem(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        NE__Order__c config = XC_DF_Order.createOrder('InOrder');
        XC_ComplianceVerificationStatus__c cvs = new XC_ComplianceVerificationStatus__c();
        cvs.Name = 'Test';
        cvs.XC_Order__c = config.Id; 
        insert cvs;
        XC_LCC069_ComplianceVerification1_U.UtilComplianceWrapper uWrapper = new XC_LCC069_ComplianceVerification1_U.UtilComplianceWrapper();
        List<String> listString = new List<String>();
        listString.add('Test');
        uWrapper.mapOrderitemDocument.put(config.Id,listString );
        
        XC_LCC069_ComplianceVerification1_U.populateJunctionDocumentOrderItem(uWrapper);
        System.assert(uWrapper!=null); 
        
        Test.stopTest();
    } 
    
//Test Method retrieveMissingDocumentAsString
    static testMethod void retrieveMissingDocumentAsString(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        Map<Id, List<String>> mapOrderitemDocument = new Map<Id, List<String>>();
        NE__Order__c config = XC_DF_Order.createOrder('InOrder');
        List<String> listString = new List<String>();
        XC_DocumentType__c doc = new XC_DocumentType__c();
        doc.XC_Configuration__c = config.id;
        doc.Category__c = 'Test';
        insert doc;
        listString.add('Test');
        mapOrderitemDocument.put(config.Id,listString);
        String result = XC_LCC069_ComplianceVerification1_U.retrieveMissingDocumentAsString(mapOrderitemDocument, config.Id);
        System.assert(result!=null); 
        
        Test.stopTest();
    } 
    

}