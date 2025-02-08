/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 08/05/2019
* @description XC_WS001_InboundSocialPost_CheckFields - Util Class for XC_WS001_InboundSocialPostHandlerImpl
*/

public without sharing class XC_WS001_InboundSocialPost_CheckFields {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_WS001_InboundSocialPostHandlerImpl');
    
    /**
    * @description Check Post isChat
    * @param post
    * @return Boolean
    */
    public static Boolean isChat(SocialPost post) {
        return (post.messageType == 'public static' || post.messageType == 'Direct');
    }

    /**
    * @description Check if Case isParentCaseValid
    * @param parentCase
    * @return Boolean
    */
    public Boolean isParentCaseValid(Case parentCase) {
        return (parentCase != null && (!parentCase.IsClosed || caseShouldBeReopened(parentCase))); 
    }

    /**
    * @description Check SocialPost (isReplyingToOutboundPost)
    * @param post
    * @return Boolean
    */
    public static Boolean isReplyingToOutboundPost(SocialPost post) {
        return (post != null && post.ReplyTo != null && post.ReplyTo.IsOutbound);
    }

    /**
    * @description Check SocialPost (isSocialPostRecipientSameAsPersona)
    * @param postWithRecipient
    * @param persona
    * @return Boolean
    */
    public static Boolean isSocialPostRecipientSameAsPersona(SocialPost postWithRecipient, SocialPersona persona) {
        return (postWithRecipient != null && postWithRecipient.Recipient == persona.ExternalId);
    }

    /**
    * @description Check SocialPost (isReplyingToSelf)
    * @param post
    * @param persona
    * @return Boolean
    */
    public static Boolean isReplyingToSelf(SocialPost post, SocialPersona persona) {
        return (post != null && 
                persona != null && 
                String.isNotBlank(persona.Id) && 
                post.ReplyTo != null &&
                String.isNotBlank(post.ReplyTo.PersonaId) &&
                post.ReplyTo.PersonaId == persona.id);
    }

    /**
    * @description Reopen Case
    * @param parentCase
    */
    public static void reopenCase(Case parentCase) {
        Map<Id, SObject> statusMap = new Map<Id, SObject>([SELECT MasterLabel FROM CaseStatus WHERE IsClosed = false AND IsDefault = true]);
        List<SObject> status = statusMap.values();
        parentCase.Status = ((CaseStatus)status[0]).MasterLabel;
        XC_UTIL_Sobject.updateRecord(parentCase);  //fix pmd SS 16/04/19 from : update parentCase;
    }

    /**
    * @description Match Post
    * @param post
    */
    public static void matchPost(SocialPost post) {
        if(post.Id != null) {
            return;
        }
        performR6PostIdCheck(post);
        if(post.Id == null){
            performExternalPostIdCheck(post);
        }
    }

    /**
    * @description Perform R6PostId 
    * @param post
    */
    public static void performR6PostIdCheck(SocialPost post){
        if(post.R6PostId == null) {
            return;
        }
        List<SocialPost> postList = new List<SocialPost>();
        if(Schema.SObjectType.SocialPost.isAccessible() && Schema.sObjectType.SocialPost.fields.Id.isAccessible()){
            postList = [SELECT Id FROM SocialPost WHERE R6PostId = :post.R6PostId LIMIT 1];
        }
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }

    /**
    * @description Perform ExternalPostId
    * @param post
    */
    public static void performExternalPostIdCheck(SocialPost post) {
        if (post.provider == 'Facebook' && post.messageType == 'public static') {return;}
        if (post.provider == null || post.externalPostId == null) {return;}
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE ExternalPostId = :post.ExternalPostId AND Provider = :post.provider LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }

    /**
    * @description Create Case
    * @param post
    * @param rawData
    * @return Boolean
    */
    public static Boolean shouldCreateCase(SocialPost post, Map<String, Object> rawData) {
        return !XC_WS001_InboundSocialPostHandlerImpl_U.isUnsentParent(rawData) &&
                    (!hasSkipCreateCaseIndicator(rawData) || hasPostTagsThatCreateCase(post));
    }

    /**
    * @description Skip Create Case Indicator
    * @param rawData
    * @return Boolean
    */
    public static Boolean hasSkipCreateCaseIndicator(Map<String, Object> rawData) {
        Object skipCreateCase = rawData.get('skipCreateCase');
        return skipCreateCase != null && 'true'.equalsIgnoreCase(String.valueOf(skipCreateCase));
    }

    /**
    * @description Check Post Tags that create case
    * @param post
    * @return Boolean
    */
    public static Boolean hasPostTagsThatCreateCase(SocialPost post){
        Set<String> postTags = XC_WS001_InboundSocialPostHandlerImpl.getPostTags(post);
        XC_WS001_InboundSocialPostHandlerImpl inboundSocialPostHandlerImpl  = new XC_WS001_InboundSocialPostHandlerImpl();
        postTags.retainAll(inboundSocialPostHandlerImpl.getPostTagsThatCreateCase());
        return !postTags.isEmpty();
    }

    /**
    * @description Check if Post has review
    * @param post
    * @return Boolean
    */
    public static Boolean hasReview(SocialPost post) {
        return (post.ReviewScore != null);
    }

    /**
    * @description Check if case should be reopenend
    * @param c
    * @return Boolean
    */
    public static Boolean caseShouldBeReopened(Case c){
        //XC_WS001_InboundSocialPostHandlerImpl inboundSocialPostHandlerImpl = new XC_WS001_InboundSocialPostHandlerImpl();
        //return (c.id != null && c.isClosed); // && System.now() < c.closedDate.addDays(inboundSocialPostHandlerImpl.getMaxNumberOfDaysClosedToReopenCase()) [MC/IN - 20200122]
        return false;
    }

}