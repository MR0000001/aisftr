/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 08/05/2019
* @description XC_WS001_InboundSocialPost_CheckCase - Util Class for XC_WS001_InboundSocialPostHandlerImpl
*/

public without sharing class XC_WS001_InboundSocialPost_CheckCase {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_WS001_InboundSocialPostHandlerImpl');
    
    /**
    * @description Find ParentCase Of Chat From Persona And Recipient
    * @param post
    * @param persona
    * @return Case
    */
    public static Case findParentCaseOfChatFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        SocialPost lastestReplyToPost = XC_WS001_InboundSocialPostHandlerImpl_U.findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestReplyToPost != null) {
            Map<Id, Case> casesMap = new Map<Id, Case>([SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestReplyToPost.parentId LIMIT 1]);
            List<Case> cases = casesMap.values();
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

    /**
    * @description Find Parent Case
    * @param post
    * @param persona
    * @return Case
    */
    public static Case findParentCase(SocialPost post, SocialPersona persona) {
        Case parentCase = null;
        if(!XC_WS001_InboundSocialPost_CheckFields.isChat(post) && (XC_WS001_InboundSocialPost_CheckFields.isReplyingToOutboundPost(post) && XC_WS001_InboundSocialPost_CheckFields.isSocialPostRecipientSameAsPersona(post.ReplyTo, persona)) || (!XC_WS001_InboundSocialPost_CheckFields.isReplyingToOutboundPost(post) && XC_WS001_InboundSocialPost_CheckFields.isReplyingToSelf(post,persona))) {
            parentCase = findParentCaseFromPostReply(post);
            XC_WS001_InboundSocialPost_CheckFields inboundSocialPostHandlerImpl = new XC_WS001_InboundSocialPost_CheckFields();
            if(inboundSocialPostHandlerImpl.isParentCaseValid(parentCase)) { 
                return parentCase;
            }
        }
        parentCase = findParentCaseFromPersonaAndRecipient(post, persona);
        if(parentCase == null && XC_WS001_InboundSocialPost_CheckFields.isChat(post)) {
            parentCase = findParentCaseOfChatFromPersonaAndRecipient(post, persona);    
        }
        return parentCase;
    }

    /**
    * @description Find Parent case from post reply
    * @param post
    * @return Case
    */
    public static Case findParentCaseFromPostReply(SocialPost post) {
        if(post.ReplyTo != null && String.isNotBlank(post.ReplyTo.ParentId)) {
            Map<Id, Case> casesMap = new Map<Id, Case>([SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE Id = :post.ReplyTo.ParentId LIMIT 1]);
            List<Case> cases = casesMap.values();
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

    /**
    * @description Find ParentCase From Persona
    * @param post
    * @param persona
    * @return Boolean
    */
    public static Case findParentCaseFromPersona(SocialPost post, SocialPersona persona) {
        SocialPost lastestInboundPostWithSamePersona = XC_WS001_InboundSocialPost_FindPost.findLatestInboundPostBasedOnPersona(post, persona);
        if (lastestInboundPostWithSamePersona != null) {
            Map<Id, Case> casesMap = new Map<Id, Case>([SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersona.parentId LIMIT 1]);
            List<Case> cases = casesMap.values();
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

    /**
    * @description Find ParentCase From Persona And Recipient
    * @param post
    * @param persona
    * @return Case
    */
    public static Case findParentCaseFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        SocialPost lastestInboundPostWithSamePersonaAndRecipient = XC_WS001_InboundSocialPost_FindPost.findLatestInboundPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestInboundPostWithSamePersonaAndRecipient != null) {
            Map<Id, Case> casesMap = new Map<Id, Case>([SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersonaAndRecipient.parentId LIMIT 1]);
            List<Case> cases = casesMap.values();
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

}