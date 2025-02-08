/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 08/05/2019
* @description XC_WS001_InboundSocialPost_Builder - Util Class for XC_WS001_InboundSocialPostHandlerImpl
*/

public without sharing class XC_WS001_InboundSocialPost_Builder {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_WS001_InboundSocialPostHandlerImpl');
    private static final String TAG_COUNTRY_SPAIN = 'SPAIN';
    private static final String TAG_COUNTRY_ITALY = 'ITALY';
    
    /**
    * @description Build Parent Case
    * @param buildParentCaseWrapper - XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseWrapper
    * @return XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseResultWrapper 
    */
    public static XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseResultWrapper buildParentCase(XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseWrapper buildParentCaseWrapper) {
        XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseResultWrapper resultWrapper = new XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseResultWrapper();
        if(XC_WS001_InboundSocialPostHandlerImpl_U.isUnsentParent(buildParentCaseWrapper.rawData)) {
            resultWrapper.caso = null;
            resultWrapper.isNewCaseCreated = buildParentCaseWrapper.isNewCaseCreated;
            return resultWrapper;
        }
        Case parentCase = XC_WS001_InboundSocialPost_CheckCase.findParentCase(buildParentCaseWrapper.post, buildParentCaseWrapper.persona);
        if (parentCase != null) {
            if (!parentCase.IsClosed) {
                resultWrapper.caso = parentCase;
                resultWrapper.isNewCaseCreated = buildParentCaseWrapper.isNewCaseCreated;
                return resultWrapper;
            }
            /*else if (XC_WS001_InboundSocialPost_CheckFields.caseShouldBeReopened(parentCase)) { //Commented by MC on 12/11/2020 > caseShouldBeReopened returns only false!
                XC_WS001_InboundSocialPost_CheckFields.reopenCase(parentCase);
                resultWrapper.caso = parentCase;
                resultWrapper.isNewCaseCreated = buildParentCaseWrapper.isNewCaseCreated;
                return resultWrapper;
            }*/
        }
        if(XC_WS001_InboundSocialPost_CheckFields.shouldCreateCase(buildParentCaseWrapper.post, buildParentCaseWrapper.rawData)){
            resultWrapper.caso = createCase(buildParentCaseWrapper.post, buildParentCaseWrapper.persona);
            resultWrapper.isNewCaseCreated = true;
            return resultWrapper;
        }
        resultWrapper.caso = null;
        resultWrapper.isNewCaseCreated = buildParentCaseWrapper.isNewCaseCreated;
        return resultWrapper;
    }

    /**
    * @description Create Attachments
    * @param post
    * @param attachments
    */
    public static void createAttachments(SocialPost post, List<XC_WS001_InboundSocialPostHandlerImpl.PostAttachment> attachments) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(XC_WS001_InboundSocialPostHandlerImpl.PostAttachment attachment : attachments) {
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

    /**
    * @description Create Case
    * @param post
    * @param persona
    * @return Case
    */
    public static Case createCase(SocialPost post, SocialPersona persona) {
        XC_WS001_InboundSocialPostHandlerImpl inboundSocialPostHandlerImpl = new XC_WS001_InboundSocialPostHandlerImpl();
        String caseSubject = inboundSocialPostHandlerImpl.getCaseSubject(post).abbreviate(inboundSocialPostHandlerImpl.getSubjectMaxLenght());
        
        //[IN] 07112018 - START
        Set<String> postTags = XC_WS001_InboundSocialPostHandlerImpl.getPostTags(post);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@postTags: '+postTags);
        String countryTag;
        if(postTags != null && postTags.contains(TAG_COUNTRY_SPAIN)){
            countryTag = TAG_COUNTRY_SPAIN;
        }
        else if(postTags != null && postTags.contains(TAG_COUNTRY_ITALY)){
            countryTag = TAG_COUNTRY_ITALY;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@countryTag: '+countryTag);
        //[IN] 07112018 - END
        
        Map<String,XC_CM_Case_Type_Setting__mdt> caseTypeMap = XC_Util_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_SocialPostCase, Label.XC_CL_SocialPostCaseItaliaB2C});
        Case newCase; // = new Case(subject = caseSubject, Country__c = countryTag, Description = post.Content);//[IN] 07112018 - Remember to check if the Country__c should be changed
        if(countryTag == TAG_COUNTRY_ITALY){
            newCase = XC_UTIL_Case.initCaseFromCaseSettings(caseTypeMap.get(Label.XC_CL_SocialPostCaseItaliaB2C));
            newCase.XC_Channel_Attribute__c = 'CA002';
            newCase.XC_LegalEntity__c = 'EnelXItalia';
        }else{
            newCase = XC_UTIL_Case.initCaseFromCaseSettings(caseTypeMap.get(Label.XC_CL_SocialPostCase));
            newCase.XC_LegalEntity__c = 'EndesaX';
        }
        newCase.Country__c = countryTag;
        newCase.Description = post.Content;
        newCase.XC_Segment__c = 'B2C';
        
        XC_WS001_InboundSocialPostHandlerImpl_U.populateCaseField(newCase, persona, post);
        
        /*newCase.Reason = caseTypeMap.get(Label.XC_CL_SocialPostCase).XC_Case_Reason__c;
        newCase.SubCause__c = caseTypeMap.get(Label.XC_CL_SocialPostCase).XC_Sub_Cause__c;
        newCase.XC_Subtype__c = caseTypeMap.get(Label.XC_CL_SocialPostCase).XC_Sub_Type__c;*/
        
        if(inboundSocialPostHandlerImpl.getUsingCaseAssignmentRule()) {
            //Find the active assignment rules on case
            Map<Id,AssignmentRule> rulesMap = new Map<Id,AssignmentRule>([SELECT id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true limit 1]);
            List<AssignmentRule> rules = rulesMap.values();
            if (rules.size() > 0){
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= rules[0].id;
                
                //Setting the DMLOption on Case instance
                newCase.setOptions(dmlOpts);
            }
        }
        
        //[IN] 07112018 - START
        //Id caseRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Case').getRecordTypeId(); //[MC-20200122] No set manually the Case RT]
        /*Map<Id, RecordType> listRecordTypeMap = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName 
                                                                        FROM RecordType 
                                                                        WHERE DeveloperName ='XC_ESP_Case']);
        List<RecordType> listRecordType = listRecordTypeMap.values(); 
        String caseRecordTypeID;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@listRecordType: '+listRecordType);
        if(listRecordType != null && listRecordType.size()>0){
            caseRecordTypeID=listRecordType.get(0).id;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@caseRecordTypeID: '+caseRecordTypeID);*/
        //newCase.RecordTypeId=caseRecordTypeID;  //[MC-20200122] No set manually the Case RT] 
        //[IN] 07112018 - END
        
        XC_UTIL_Sobject.insertRecord(newCase);//fix pmd SS 16/04/19 from : insert newCase; 
        return newCase;
    }

}