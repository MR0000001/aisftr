@isTest
public class XC_TR_DocumentType_Account_NDA_TEST {
@isTest
    static void ndaManagedStatus(){
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
        insert accList;
        list<XC_DocumentType__c> listNew = new list<XC_DocumentType__c>();
        XC_DocumentType__c doc = new XC_DocumentType__c();
        doc.Category__c='SF_NDA_SIGNED';
        doc.XC_Account__c = accList[0].id;
        listNew.add(doc);
        
        Test.startTest();
        	XC_TR_DocumentType_Account_NDA_Signed.ndaManagedStatus(listNew);
        Test.stopTest();
        
    }

}