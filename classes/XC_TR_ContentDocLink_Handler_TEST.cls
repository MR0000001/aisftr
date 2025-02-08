/**
* @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
* @date Creation  25/06/2019 
* @description XC_TR_ContentDocLink_Handler_TEST – Test class for XC_TR_ContentDocumentLink_Handler
*/ 
@isTest
public class XC_TR_ContentDocLink_Handler_TEST {

    @TestSetup
    static void setup(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Attach Name';
        cv.PathOnClient = cv.Title;
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cv;

        System.assert(cv != null);
        
        Test.stopTest(); 
    }

    @isTest
    static void test1(){
        List<ContentDocumentLink> cdlList = [SELECT ID FROM ContentDocumentLink where LinkedEntityId = :UserInfo.getUserId()];
        delete cdlList;
        System.assert(!cdlList.isEmpty());
    }
    
    @isTest
    static void test2(){
        List<ContentDocumentLink> cdlList = [SELECT ID, Visibility FROM ContentDocumentLink where LinkedEntityId = :UserInfo.getUserId()];
        cdlList[0].Visibility = 'AllUsers';
        update cdlList[0];
        System.assert(!cdlList.isEmpty());
    }
}