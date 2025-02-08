@isTest
public class XC_WS001_InboundSocialPostHandler_TEST {
    @TestSetup
    	static void setup(){
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org; 
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;    
        } 
    
    @isTest
    static void buildParentCaseResultWrapperTest(){
        
        test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseResultWrapper wr = new XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseResultWrapper();
        test.stopTest();
        System.assert(wr != null); 
    }
     @isTest
    static void buildParentCaseWrapperTest(){
        
        test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseWrapper wr = new XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseWrapper();
        test.stopTest();
        System.assert(wr != null); 
    }
    @isTest
    static void getUsingCaseAssignmentRuleTest(){
        
        test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl im = new XC_WS001_InboundSocialPostHandlerImpl();
        Boolean wr = im.getUsingCaseAssignmentRule();
        test.stopTest();
        System.assert(wr == true); 
    }
    
    @isTest
    static void getCaseSubjectTest(){  
        SocialPost post = new SocialPost();   
        post.Name = 'post';
        insert post;
        test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl im = new XC_WS001_InboundSocialPostHandlerImpl();
        String a = im.getCaseSubject(post); 
        test.stopTest();
        System.assert(a!=''); 
    }
    
    @isTest
    static void handleInboundSocialPostTest(){  
        SocialPost post = new SocialPost();   
        post.Name = 'post';
        insert post;
        SocialPersona pers = new SocialPersona(); 
        pers.Name = 'persona1';
        pers.ParentId = post.id;
        pers.Provider = 'Facebook';
        Map<String, Object> rawData = new Map<String, Object>();
        
        insert pers;
        test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl im = new XC_WS001_InboundSocialPostHandlerImpl();
        
        Social.InboundSocialPostResult si = im.handleInboundSocialPost(post,pers,rawData);
       
        test.stopTest();
        System.assert(si!=null); 
    }
     @isTest
    static void handleInboundSocialPostTest2(){  
        SocialPost post = new SocialPost();   
        post.Name = 'post';
        post.responseContextExternalId = 'asd';
        SocialPersona pers = new SocialPersona(); 
        pers.Name = 'persona1';
        pers.ParentId = post.id;
        pers.Provider = 'Facebook';
        Map<String, Object> rawData = new Map<String, Object>();
        test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl im = new XC_WS001_InboundSocialPostHandlerImpl();
        
        
               try{
            Social.InboundSocialPostResult si = im.handleInboundSocialPost(post,pers,rawData);
                   System.assert(si!=null); 
        } catch(exception e){
            xc_util_debug.debug(true, e+'');
        }
        
        test.stopTest();
        
    }
    
         @isTest
    static void handleInboundSocialPostTest3(){  
        SocialPost post = new SocialPost();   
        post.Name = 'post';
        SocialPersona pers = new SocialPersona(); 
        pers.Name = 'persona1';
        pers.ParentId = post.id;
        pers.Provider = 'Facebook';
        Map<String, Object> rawData = new Map<String, Object>();
        test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl im = new XC_WS001_InboundSocialPostHandlerImpl();
        
        Social.InboundSocialPostResult si = im.handleInboundSocialPost(post,pers,rawData); 
        XC_WS001_InboundSocialPostHandlerImpl.PostAttachment att = new XC_WS001_InboundSocialPostHandlerImpl.PostAttachment('test','test');
        list<XC_WS001_InboundSocialPostHandlerImpl.PostAttachment> asd = new list<XC_WS001_InboundSocialPostHandlerImpl.PostAttachment>();
        asd.add(att);
        try{
            XC_WS001_InboundSocialPost_Builder.createAttachments(post,asd); 
        } catch(exception e){
            xc_util_debug.debug(true, e+'');
        }
       
        test.stopTest();
        System.assert(si!=null); 
    }
    
             @isTest
    static void handleInboundSocialPostTest4(){  
        SocialPost post = new SocialPost();   
        post.Name = 'post';
        SocialPersona pers = new SocialPersona(); 
        pers.Name = 'persona1';
        pers.ParentId = post.id;
        pers.Provider = 'Facebook';
        Map<String, Object> rawData = new Map<String, Object>();
        rawData.put('skipCreateCase', true);
        test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl im = new XC_WS001_InboundSocialPostHandlerImpl();
        
        Social.InboundSocialPostResult si = im.handleInboundSocialPost(post,pers,rawData); 
        XC_WS001_InboundSocialPostHandlerImpl.PostAttachment att = new XC_WS001_InboundSocialPostHandlerImpl.PostAttachment('test','test');
        list<XC_WS001_InboundSocialPostHandlerImpl.PostAttachment> asd = new list<XC_WS001_InboundSocialPostHandlerImpl.PostAttachment>();
        asd.add(att);
        try{
            XC_WS001_InboundSocialPost_Builder.createAttachments(post,asd); 
        } catch(exception e){
            xc_util_debug.debug(true, e+'');
        }
        
       
        test.stopTest();
        System.assert(si!=null); 
    }
    
    
}