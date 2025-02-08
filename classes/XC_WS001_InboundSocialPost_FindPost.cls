/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 08/05/2019
* @description XC_WS001_InboundSocialPost_FindPost - Util Class for XC_WS001_InboundSocialPostHandlerImpl
*/

public without sharing class XC_WS001_InboundSocialPost_FindPost {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_WS001_InboundSocialPostHandlerImpl');

    /**
    * @description Find Latest Inbound Post Based On Persona
    * @param post
    * @param persona
    * @return SocialPost
    */
    public static SocialPost findLatestInboundPostBasedOnPersona(SocialPost post, SocialPersona persona) {
        if(persona != null && String.isNotBlank(persona.Id) && post != null) {
            if(post.replyToId != null && post.replyTo == null) {
                return findReplyToBasedOnReplyToId(post);
            }
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND PersonaId = :persona.id AND IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1];
            if(!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }

    /**
    * @description Find ReplyTo
    * @param post
    * @param persona
    * @return SocialPost
    */
    public static SocialPost findReplyTo(SocialPost post, SocialPersona persona) {
        if(post.replyToId != null && post.replyTo == null) {
            return findReplyToBasedOnReplyToId(post);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,  '@@@@@post before: ' + post);
        SocialPost replyTo;
        if(post.responseContextExternalId != null){
            if((post.provider == 'Facebook' && post.messageType == 'Private') || (post.provider == 'Facebook' && post.messageType == 'Comment') || (post.provider == 'Facebook' && post.messageType == 'Reply') || (post.provider == 'Twitter' && post.messageType == 'Reply') || (post.provider == 'Twitter' && post.messageType == 'Direct')) {
                XC_UTIL_Debug.debug(DEBUGACTIVE,  '@@@ post ' + post);
                replyTo = findReplyToBasedOnResponseContextExternalPostIdAndProvider(post);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@reply: ' + replyTo);
            }
            if(replyTo.id == null){ 
                return findReplyToBasedOnExternalPostIdAndProvider(post);
            }
            return replyTo;
        }
        return new SocialPost();
    }

    /**
    * @description Find Reply To Based O nReplyToId
    * @param post
    * @return SocialPost
    */
    public static SocialPost findReplyToBasedOnReplyToId(SocialPost post){
        if(!Schema.sObjectType.SocialPost.isAccessible()){
            return new SocialPost();
        }
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient FROM SocialPost WHERE id = :post.replyToId LIMIT 1];
        if(posts.isEmpty()){
            return new SocialPost();
        }
        return posts[0];
    }

    /**
    * @description Find Reply To Based On External PostId And Provider
    * @param post
    * @return SocialPost
    */
    public static SocialPost findReplyToBasedOnExternalPostIdAndProvider(SocialPost post){
        if(!Schema.sObjectType.SocialPost.isAccessible()){
            return new SocialPost();
        }
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient FROM SocialPost WHERE Provider = :post.provider AND ExternalPostId = :post.responseContextExternalId LIMIT 1];
        if(posts.isEmpty()) {
            return new SocialPost();
        }
        return posts[0];
    }

    /**
    * @description Find Reply To Based O nResponse Context External PostId And Provider
    * @param post
    * @return SocialPost
    */
    public static SocialPost findReplyToBasedOnResponseContextExternalPostIdAndProvider(SocialPost post){
        if(!Schema.sObjectType.SocialPost.isAccessible()){
            return new SocialPost();
        }
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND responseContextExternalId = :post.responseContextExternalId ORDER BY posted DESC NULLS LAST LIMIT 1];
        if(posts.isEmpty()) {
            return new SocialPost();
        }
        return posts[0];
    }

    /**
    * @description Find Latest InboundPost Based On Persona And Recipient
    * @param post
    * @param persona
    * @return SocialPost
    */
    public static SocialPost findLatestInboundPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        if(!Schema.sObjectType.SocialPost.isAccessible()){
            return new SocialPost();
        }
        if(persona != null && String.isNotBlank(persona.Id) && post != null && String.isNotBlank(post.Recipient)) {
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND PersonaId = :persona.id AND IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }

}