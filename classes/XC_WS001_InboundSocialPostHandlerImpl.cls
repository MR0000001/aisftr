/**
* @date Modification for PMD: 08/05/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_WS001_InboundSocialPostHandlerImpl - Class Social.InboundSocialPostHandler
*/

global virtual without sharing class XC_WS001_InboundSocialPostHandlerImpl implements Social.InboundSocialPostHandler {

    final static Integer CONTENT_MAX_LENGTH = SocialPost.Content.getDescribe().getLength();
    final static Integer SUBJECT_MAX_LENGTH = Case.Subject.getDescribe().getLength();
    private static final String TAG_COUNTRY_SPAIN = 'SPAIN';
    Boolean isNewCaseCreated = false; 
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_WS001_InboundSocialPostHandlerImpl');

    /** @description BuildParentCaseResultWrapper */
    public class BuildParentCaseResultWrapper {
        /** @description Getter and Setter */
        public Case caso{get;set;}
        /** @description Getter and Setter */
        public Boolean isNewCaseCreated{get;set;}
    }

    /** @description BuildParentCaseWrapper */
    public class BuildParentCaseWrapper {
        /** @description Getter and Setter */
        public SocialPost post{get;set;}
        /** @description Getter and Setter */
        public SocialPersona persona{get;set;}
        /** @description Getter and Setter */
        public Map<String, Object> rawData{get;set;}
        /** @description Getter and Setter */
        public Boolean isNewCaseCreated{get;set;}
    }

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
    * @description Reopen case if it has not been closed for more than this number
    * @return Integer the integer
    */
    global virtual Integer getMaxNumberOfDaysClosedToReopenCase() {
        return 0;
    }

    /** 
    * @description Create a case if one of these post labels are on the SocialPost, regardless of the skipCreateCase indicator.
    * @return Set<String>
    */
    global virtual Set<String> getPostTagsThatCreateCase(){
        return new Set<String>();
    }

    /** 
    * @description If true, use the active case assignment rule if one is found
    * @return Boolean
    */ 
    global virtual Boolean getUsingCaseAssignmentRule(){
        return true; //[IN] 07112018 insert case running assignment rules
    }

    /** 
    * @description Get Default AccountId
    * @return String
    */
    global virtual String getDefaultAccountId() {
        return null;
    }

    /**
    * @description Get Case Subject
    * @param post 
    * @return String 
    */
    global virtual String getCaseSubject(SocialPost post) {
        String caseSubject = post.Name;
        if(XC_WS001_InboundSocialPost_CheckFields.hasReview(post)) {
            String ratingsStr = getRatingString(post);
            caseSubject = ratingsStr + ' • ' + caseSubject;
        }
        return caseSubject;
    }

    /**
    * @description handleInboundSocialPost
    * @param post
    * @param persona
    * @param rawData
    * @return Social.InboundSocialPostResult
    */ 
    global Social.InboundSocialPostResult handleInboundSocialPost(SocialPost post, SocialPersona persona, Map<String, Object> rawData) {
        Social.InboundSocialPostResult result = new Social.InboundSocialPostResult();
        result.setSuccess(true);
        XC_WS001_InboundSocialPost_CheckFields.matchPost(post);
        XC_UTIL_SocialPersona.matchPersona(persona);
        
        if((post.Content != null) && (post.Content.length() > CONTENT_MAX_LENGTH)) {
            post.Content = post.Content.abbreviate(CONTENT_MAX_LENGTH);
        }
        if(post.Id != null) {
            XC_WS001_InboundSocialPostHandlerImpl_U.handleExistingPost(post, persona);
            return result;
        }
        
        setReplyTo(post, persona);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@post: '+post);
        
        SocialPersona p = XC_UTIL_SocialPersona.buildPersona(persona);//[IN] 07112018 

        BuildParentCaseWrapper buildParentCaseWrapper = new BuildParentCaseWrapper();
        buildParentCaseWrapper.post = post;
        buildParentCaseWrapper.persona = persona;
        buildParentCaseWrapper.rawData = rawData;
        buildParentCaseWrapper.isNewCaseCreated = isNewCaseCreated;
        BuildParentCaseResultWrapper buildParentCaseResultWrapper = XC_WS001_InboundSocialPost_Builder.buildParentCase(buildParentCaseWrapper); //, TAG_COUNTRY_SPAIN
        Case parentCase = buildParentCaseResultWrapper.caso;
        isNewCaseCreated = buildParentCaseResultWrapper.isNewCaseCreated;

        XC_WS001_InboundSocialPostHandlerImpl_U.setRelationshipsOnPost(post, persona, parentCase);
        XC_WS001_InboundSocialPostHandlerImpl_U.setModeration(post, rawData);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Post -> ' + post);
        XC_UTIL_Sobject.upsertRecord(post); //fix pmd SS 16/04/19 from : upsert post;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@post after:'+post);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'SocialPersona -> ' + p);
        //[IN] 07112018 Reparenting socialPersona with related post - START
        p.parentId=post.Id;
        XC_UTIL_Sobject.updateRecord(p); //fix pmd SS 16/04/19 from :  update p;
        //[IN] 07112018 Reparenting socialPersona with related post - END
        
        Set<String> postTags = getPostTags(post);
        // if(postTags != null && postTags.contains(TAG_COUNTRY_SPAIN)){ //fix pmd SS 16/04/19: void block statement
        // }
        if(isNewCaseCreated) {
           XC_WS001_InboundSocialPostHandlerImpl_U.updateCaseSource(post, parentCase);
        }
        handlePostAttachments(post, rawData);
        return result;
    }

    /**
    * @description Set ReplayTo
    * @param post
    * @param persona
    */
    private void setReplyTo(SocialPost post, SocialPersona persona) {
        SocialPost replyTo = XC_WS001_InboundSocialPost_FindPost.findReplyTo(post, persona);
        if(replyTo.id != null) {
            post.replyToId = replyTo.id;
            post.replyTo = replyTo;
        }
    }

    /**
    * @description Get SUBJECT_MAX_LENGTH
    * @return Integer
    */
    public Integer getSubjectMaxLenght() {
        return SUBJECT_MAX_LENGTH;
    }

    /**
    * @description Get TAG_COUNTRY_SPAIN
    * @return String
    */
    public String getTagCountrySpain() {
        return TAG_COUNTRY_SPAIN;
    }

    /**
    * @description Get Rating String
    * @param post
    * @return String
    */
    @TestVisible
    private String getRatingString(SocialPost post) {
        Integer maxNumberOfStars = 5;
        Double reviewScore = post.ReviewScore;
        Double reviewScale = post.ReviewScale;
        if (reviewScore == null) {
            reviewScore = 0;
        }
        if (reviewScale == null) { 
            reviewScale = maxNumberOfStars;
        }
        Integer numberOfStars = Math.floor((reviewScore / reviewScale) * maxNumberOfStars).intValue();
        return numberOfStars.format() + '-Star';
    }

    /**
    * @description Get Post Tags
    * @param post
    * @return Set<String>
    */
    public static Set<String> getPostTags(SocialPost post){
        Set<String> postTags = new Set<String>();
        if(post.postTags != null) {
            postTags.addAll(post.postTags.split(',', 0));
        }
        return postTags;
    }

    /**
     * @description Get Persona FirstName
     * @param  persona
     * @return String
     */
    global String getPersonaFirstName(SocialPersona persona) {
        String name = getPersonaName(persona);      
        String firstName = '';
        if (name.contains(' ')) {
            firstName = name.substringBeforeLast(' ');
        }
        firstName = firstName.abbreviate(40);
        return firstName;
    }

    /**
     * @description Get Persona LastName
     * @param persona
     * @return String
     */
    global String getPersonaLastName(SocialPersona persona) {   
        String name = getPersonaName(persona);   
        String lastName = name;
        if (name.contains(' ')) {
            lastName = name.substringAfterLast(' ');
        }
        lastName = lastName.abbreviate(80);
        return lastName;
    }

    /**
    * @description Get Persona Name
    * @param persona
    * @return String
    */
    @TestVisible
    private String getPersonaName(SocialPersona persona) {
        String name = persona.Name.trim();
        if (String.isNotBlank(persona.RealName)) {
            name = persona.RealName.trim();
        }
        return name;
    }

    /**
    * @description Post Attachments
    * @param post
    * @param rawData
    */
    @TestVisible
    private void handlePostAttachments(SocialPost post, Map<String, Object> rawData) {
        String attachmentRawData = JSON.serialize(rawData.get('mediaUrls'));
        if (String.isNotBlank(attachmentRawData)) {
            List<PostAttachment> attachments = (List<PostAttachment>) JSON.deserialize(attachmentRawData, List<PostAttachment>.class);
            if (attachments != null && !attachments.isEmpty()) {
                XC_WS001_InboundSocialPost_Builder.createAttachments(post, attachments);
            }
        }
    }

    /** New methods - to be tested before uncomment */     
    /*private Case manageParentCase(Case parentCase) {
        if (!parentCase.IsClosed) {
            return parentCase;
        } else if (caseShouldBeReopened(parentCase)) {
            reopenCase(parentCase);
        }

        return parentCase;
    }
    private Case buildParentCase(SocialPost post, SocialPersona persona, Map<String, Object> rawData){
        if(!isUnsentParent(rawData)) {
            Case parentCase = findParentCase(post, persona);
            if (parentCase != null) {
               parentCase = manageParentCase(parentCase);
               return parentCase;
            }
            if(shouldCreateCase(post, rawData)){
                isNewCaseCreated = true;
                return createCase(post, persona, TAG_COUNTRY_SPAIN);
            }
        }
        
        return null;
    } */

    /*global virtual SObject createPersonaParent(SocialPersona persona) {
    String firstName = getPersonaFirstName(persona);
    String lastName = getPersonaLastName(persona);

    Contact contact = new Contact(LastName = lastName, FirstName = firstName);
    String defaultAccountId = getDefaultAccountId();
    if (defaultAccountId != null)
    contact.AccountId = defaultAccountId;
    insert contact;
    return contact;
    }*/

}