/**
*@author Federico Amici - federico.amici@nttdata.com 
*@date Creation 18/04/2019
*@date Modification 07/05/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
*@description XC_WS001_InboundSocialPostHandlerImpl_U - Util for XC_WS001_InboundSocialPostHandlerImpl
*/

public with sharing class XC_WS001_InboundSocialPostHandlerImpl_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_WS001_InboundSocialPostHandlerImpl');
    
    /** @description The wrapper of the post */
    public class PostAttachment {
        public String mediaType;
        public String mediaUrl;
        
        /**
        * @param mediaType the mediaType
        * @param mediaUrl the mediaUrl
        * @description Constructor of the class
        */
        public PostAttachment(String mediaType, String mediaUrl) {
            this.mediaType = mediaType;
            this.mediaUrl = mediaUrl;
        } 
    }

    /**
    *@author Federico Amici - federico.amici@nttdata.com 
    *@date Creation 18/04/2019  
    *@param post the post
    *@param contentVersions the list of files
    *@description createLinksForAttachmentsToSocialPost 
    */
    public static void createLinksForAttachmentsToSocialPost(SocialPost post, List<ContentVersion> contentVersions) {
        List<Id> versionIds = new List<Id>(new Map<Id, ContentVersion>(contentVersions).keySet());
        Map<Id, ContentDocument> contentDocumentsMap = new Map<Id, ContentDocument>([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :versionIds]);
        List<ContentDocument> contentDocuments = contentDocumentsMap.values();

        List<ContentDocumentLink> contentDocumentLinks = XC_WS001_InboundSocialPost_U_Builder.createListCDL(contentDocuments, post);
        
        XC_UTIL_Sobject.insertListRecords(contentDocumentLinks); //fix pmd SS 16/04/19 from : insert(contentDocumentLinks);
    }

    /**
     *@description Set Moderation
     *@param post
     *@param rawData
     */
    public static void setModeration(SocialPost post, Map<String, Object> rawData){
        //if we don't automatically create a case, we should flag the post as requiring moderator review.
        if(post.parentId == null && !isUnsentParent(rawData)) {
            post.reviewedStatus = 'Needed';
        }
    }

    /**
     *@description isUnsentParent
     *@param rawData
     *@return the boolean
     */
    public static boolean isUnsentParent(Map<String, Object> rawData) {
        Object unsentParent = rawData.get('unsentParent');
        return unsentParent != null && 'true'.equalsIgnoreCase(String.valueOf(unsentParent));
    }

     /**
     *@description Update Case Source
     *@param post
     *@param parentCase
     */
    public static void updateCaseSource(SocialPost post, Case parentCase){
        if(parentCase != null) {
            parentCase.SourceId = post.Id;
            //update as a new sobject to prevent undoing any changes done by insert triggers
            //fix pmd SS 16/04/19: from -> update new Case(Id = parentCase.Id, SourceId = parentCase.SourceId);
            Case cs = new Case(Id = parentCase.Id, SourceId = parentCase.SourceId);
            XC_UTIL_Sobject.updateRecord(cs);
            //end fix
        }
        
    }
    
    /**
    *@description handlePostAttachments
    *@param post
    *@param rawData
    */
    @TestVisible
    public static void handlePostAttachments(SocialPost post, Map<String, Object> rawData) {
        String attachmentRawData = JSON.serialize(rawData.get('mediaUrls'));
        if (String.isBlank(attachmentRawData)) {
            return;
        }

        List<PostAttachment> attachments = (List<PostAttachment>) JSON.deserialize(attachmentRawData, List<PostAttachment>.class);
        if (attachments != null && !attachments.isEmpty()) {
            XC_WS001_InboundSocialPost_U_Builder.createAttachments(post, attachments);
        }
    
    }

    /**
    *@description Handle Existing Post
    *@param post
    *@param persona
    */
    public static void handleExistingPost(SocialPost post, SocialPersona persona) {
        Map<Id, SocialPost> existingPostsMap = new Map<Id, SocialPost>([Select Recipient, IsOutbound from SocialPost where id = :post.Id limit 1]);
        List<SocialPost> existingPosts = existingPostsMap.values();
        // for any existing outbound post, we don't overwrite its recipient field
        if (!existingPosts.isEmpty() && existingPosts[0].IsOutBound == true && String.isNotBlank(existingPosts[0].Recipient)) {
            post.Recipient = existingPosts[0].Recipient;
        }
        
        update post;
        if (persona.id != null) {
            XC_UTIL_Sobject.updateRecord(persona);
        }
    }

    /**
     *@description setRelationshipsOnPost
     *@param postToUpdate
     *@param persona
     *@param parentCase
     */
    public static void setRelationshipsOnPost(SocialPost postToUpdate, SocialPersona persona, Case parentCase) {
        if (persona.Id != null) {
            postToUpdate.PersonaId = persona.Id;
            
            if(persona.ParentId.getSObjectType() != SocialPost.sObjectType) {
                postToUpdate.WhoId = persona.ParentId;
            }
        }
        if(parentCase != null) {
            postToUpdate.ParentId = parentCase.Id;
        }
    }

    /**
    * @description populateCaseField
    * @param newCase
    * @param persona
    * @param post
    */
    public static void populateCaseField(Case newCase, SocialPersona persona, SocialPost post) {
        if (persona != null && persona.XC_ContactId__c != null){ //[MC-20200124] 
        	newCase.ContactId = persona.XC_ContactId__c;
        }
        if (persona != null && persona.ParentId != null && newCase.ContactId == null) {
            if (persona.ParentId.getSObjectType() == Contact.sObjectType) {
                newCase.ContactId = persona.ParentId;
            }else if(persona.ParentId.getSObjectType() == Account.sObjectType) {
                newCase.AccountId = persona.ParentId;
            }
        }
        if (post != null && post.Provider != null) {
            if(post.Provider.equalsIgnoreCase(Label.XC_CL_CaseOriginFaceebook)){ //[MC-20200122]
                newCase.Origin = Label.XC_CL_CaseOriginCAN005;
            }else if(post.Provider.equalsIgnoreCase(Label.XC_CL_CaseOriginTwitter)){
                newCase.Origin = Label.XC_CL_CaseOriginCAN006;
            }else {
                newCase.Origin = post.Provider;
            }
        }
    }

    /**
    * @description findLatestOutboundReplyToPostBasedOnPersonaAndRecipient
    * @param post
    * @param persona
    * @return the post
    */
    public static SocialPost findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        if(persona != null && String.isNotBlank(persona.Id) && post != null) {
            Map<Id, ExternalSocialAccount> accountsMap =
                new Map<Id, ExternalSocialAccount>([SELECT Id FROM ExternalSocialAccount WHERE ExternalAccountId = :post.Recipient]);
            List<ExternalSocialAccount> accounts = accountsMap.values();
            if(accounts.isEmpty()) {
                return null;
            }
            ExternalSocialAccount account = accounts[0];
            Map<Id, SocialPost> postsMap = new Map<Id, SocialPost>([SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :persona.ExternalId AND OutboundSocialAccountId = :account.Id AND IsOutbound = true ORDER BY CreatedDate DESC LIMIT 1]);
            List<SocialPost> posts = postsMap.values();
            if (!posts.isEmpty()) {
                return posts[0];
            } 
        }
        return null;
    }

}