/**
*@author Salvatore Agrillo - salvatore.agrillo@nttdata.com
*@date 07/05/2019
*@description XC_WS001_InboundSocialPostHandlerImpl_U_Builder - Util for XC_WS001_InboundSocialPostHandlerImpl
*/

public with sharing class XC_WS001_InboundSocialPost_U_Builder {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_WS001_InboundSocialPostHandlerImpl');

    /**
    * @description Create List CDL
    * @param contentDocuments
    * @param post 
    * @return List<ContentDocumentLink>
    */
    public static List<ContentDocumentLink> createListCDL(List<ContentDocument> contentDocuments, SocialPost post) {
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        ContentDocumentLink contentDocLink;
        for(ContentDocument contentDocument : contentDocuments) {
            contentDocLink = new ContentDocumentLink();
            contentDocLink.contentDocumentId = contentDocument.Id;
            contentDocLink.linkedEntityId = post.Id;
            contentDocLink.shareType = 'I';
            contentDocLink.visibility = 'AllUsers';
            contentDocumentLinks.add(contentDocLink);
        }
        return contentDocumentLinks;
    } 

    /**
    * @description Create Attachments
    * @param post
    * @param attachments
    */
    @TestVisible
    public static void createAttachments(SocialPost post, List<XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment> attachments) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment attachment : attachments) {
            if (String.isNotBlank(attachment.mediaUrl) && attachment.mediaUrl != null && attachment.mediaUrl.length() <= ContentVersion.ContentUrl.getDescribe().getLength()) {
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.contentUrl = attachment.mediaUrl;
                contentVersion.contentLocation = 'L';
                contentVersions.add(contentVersion);
            }
        }
        if (!contentVersions.isEmpty()) {
            XC_UTIL_Sobject.insertListRecords(contentVersions); //fix pmd SS 16/04/19 from : insert(contentVersions);
            XC_WS001_InboundSocialPostHandlerImpl_U.createLinksForAttachmentsToSocialPost(post, contentVersions);
        }
    }
    
}