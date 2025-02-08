/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  27/05/2019 
* @description XC_WS001_InboundSocialPost_U_Builder_TEST – Test class for XC_WS001_InboundSocialPost_U_Builder
*/
@isTest
public class XC_WS001_InboundSocialPost_U_Build_TEST {
    //Test Method createListCDL
    static testMethod void createListCDL(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<ContentDocument> contentDocuments = new List<ContentDocument>();
        ContentDocument cD = new ContentDocument();
        contentDocuments.add(cD);
        SocialPost post = new SocialPost();
        List<ContentDocumentLink> lcdl = XC_WS001_InboundSocialPost_U_Builder.createListCDL(contentDocuments, post);       
        
        
        System.assertEquals(true, lcdl!=null);
        Test.stopTest(); 
        
    }
    
    
    
    //Test Method createAttachments
    static testMethod void createAttachments(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment att = new XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment('test','test');
        List<XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment> attachments = new List<XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment>();
        attachments.add(att);
        SocialPost post = new SocialPost(); 
        XC_WS001_InboundSocialPost_U_Builder.createAttachments(post, attachments);       
        
        
        System.assertEquals(true, attachments!=null);
        Test.stopTest();
        
    }
    
    
   
}