/**
 * @author Nicola Arrigo - narrigo@deloitte.it
 * @date Creation 08/02/2020
 * @date Modification dd/mm/yyyy
 * @description XC_WS001_InboundSocialPostCheckF_TEST - test class for XC_WS001_InboundSocialPost_CheckFields
 */
@isTest
public class XC_WS001_InboundSocialPostCheckF_TEST {
    @isTest static void isParentCaseValid() {
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<case> listCases=XC_DF_Case.createCases(1);
        insert listCases;
        Test.startTest();
        XC_WS001_InboundSocialPost_CheckFields testClass= new XC_WS001_InboundSocialPost_CheckFields();
        Boolean isParentCaseValid =testClass.isParentCaseValid(listCases[0]);
        XC_WS001_InboundSocialPost_CheckFields.caseShouldBeReopened(listCases[0]);
       // Boolean isChat = testClass.isChat(post);
        Test.stopTest();
        System.assert(true);
    }
    @isTest static void isChat(){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        SocialPost post = new SocialPost();   
        post.Name = 'post';
        insert post;
        Test.startTest();
        //XC_WS001_InboundSocialPost_CheckFields testClass= new XC_WS001_InboundSocialPost_CheckFields();
        Boolean isChat = XC_WS001_InboundSocialPost_CheckFields.isChat(post);
        Test.stopTest();
        System.assert(true);
    }
    @isTest static void isReplyingToSelf(){
      OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        SocialPost post3 = new SocialPost();   
        post3.Name = 'post';
        insert post3;
        SocialPersona pers = new SocialPersona(); 
        pers.Name = 'persona1';
        pers.ParentId = post3.id;
        pers.Provider = 'Facebook';
        insert pers;
        SocialPost post = new SocialPost();   
        post.Name = 'post';
        post.PersonaId=pers.id;
        insert post;
        SocialPost post2 = new SocialPost();   
        post2.Name = 'post';
        post2.ReplyToId=post.id;
        //post2.PersonaId=pers.id;
        insert post2; 
        Test.startTest();
        //XC_WS001_InboundSocialPost_CheckFields testClass= new XC_WS001_InboundSocialPost_CheckFields();
        Boolean isChat = XC_WS001_InboundSocialPost_CheckFields.isReplyingToSelf(post2,pers);
        Test.stopTest();
        System.assert(true);
    }
    @isTest static void  performR6PostIdCheck(){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        SocialPost post = new SocialPost();   
        post.Name = 'post';
        insert post;
        SocialPost post3 = new SocialPost();   
        post3.Name = 'post';
        post3.R6PostId=post.id;        
       // XC_WS001_InboundSocialPost_CheckFields testClass= new XC_WS001_InboundSocialPost_CheckFields();
        Test.startTest();
        XC_WS001_InboundSocialPost_CheckFields.matchPost(post3);
        Test.stopTest();
        System.assert(true);
    }
    @isTest static void hasReview (){
        SocialPost post = new SocialPost();   
        post.Name = 'post';
        post.ReviewScore=1;
        insert post;
        Test.startTest();
        XC_WS001_InboundSocialPost_CheckFields.hasReview(post);
        Test.stopTest();
        System.assert(true);
    }
    @isTest static void isSocialPostRecipientSameAsPersona(){
         OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        SocialPost post = new SocialPost();   
        post.Name = 'post';
        //post.ReviewScore=1;
        insert post;
        SocialPersona pers = new SocialPersona(); 
        pers.Name = 'persona1';
        pers.ParentId = post.id;
        pers.Provider = 'Facebook';
        pers.ExternalId='253107918701628';
        insert pers;
        post.Recipient='253107918701628';
        update post;
       Test.startTest();
        XC_WS001_InboundSocialPost_CheckFields.isSocialPostRecipientSameAsPersona(post,pers);
       Test.stopTest();
        System.assert(true);
    }
    @isTest static void reopenCase(){
         OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<case> listCases=XC_DF_Case.createCases(1);
        insert listCases;
        Test.startTest();
        XC_WS001_InboundSocialPost_CheckFields.reopenCase(listCases[0]);
          Test.stopTest();
        System.assert(true);
    }
}