/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  19/06/2019 
* @description XC_WS001_InboundSocialPost_FindPost_TEST – Test class for XC_WS001_InboundSocialPost_FindPost
*/
@isTest
public class XC_WS001_InboundSocialPost_FindPost_TEST {
    
     @TestSetup static void testSetup() {
     OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
    
         SocialPost post= new SocialPost();
        
        SocialPost socialpos = new SocialPost();
    socialpos.Name='Name';
        socialpos.provider = 'Facebook';
        socialpos.messageType = 'Private';
        socialpos.responseContextExternalId='test';
        socialpos.recipient= 'test'; 
        socialpos.IsOutbound = false;
    insert socialpos;
        
        SocialPersona persona= new SocialPersona();
        
        persona.Provider='Facebook';
        persona.MediaProvider= 'Facebook Comments';
        persona.ExternalId='test';
        persona.ParentId= socialpos.Id; 
    persona.Name='Name';
        insert persona;
         
         
        socialpos.PersonaId = persona.Id;
        update socialpos;
        
        
         
        
        


  }
  
    
    //Test Method findLatestInboundPostBasedOnPersona
    static testMethod void findLatestInboundPostBasedOnPersona(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        list <SocialPost> post= [SELECT Id ,ParentId,  Name, messageType, ReplyToId , Recipient, ResponseContextExternalId, Provider, IsOutbound , PersonaId from SocialPost];
        
        SocialPost socialpos = new SocialPost();
    socialpos.Name='Name';
        socialpos.provider = 'Facebook';
        socialpos.messageType = 'Private';
        socialpos.responseContextExternalId='test';
        socialpos.recipient= 'test';
    socialpos.ReplyToId= post[0].Id;       
    insert socialpos;
        
        
        list <SocialPersona> persona= [SELECT Id, Provider, MediaProvider,  ExternalId, ParentId, Name from SocialPersona];
        
        
        
        SocialPost sp = XC_WS001_InboundSocialPost_FindPost.findLatestInboundPostBasedOnPersona( socialpos , persona[0]);
        SocialPost sp2 = XC_WS001_InboundSocialPost_FindPost.findLatestInboundPostBasedOnPersona( post[0] , persona[0]);
        
        SocialPersona socialp = new SocialPersona(); 
        SocialPost sp3 = XC_WS001_InboundSocialPost_FindPost.findLatestInboundPostBasedOnPersona( post[0] , socialp);
        
        
        System.assertEquals(true, sp!=null);
        Test.stopTest();
    }
    
    
    //Test Method findReplyTo
    static testMethod void findReplyTo(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        
        list <SocialPost> post= [SELECT Id ,ParentId, Name, messageType, ReplyToId , Recipient, ResponseContextExternalId, Provider, IsOutbound , PersonaId from SocialPost];
        list <SocialPersona> persona= [SELECT Id, Provider, MediaProvider,  ExternalId, ParentId, Name from SocialPersona];
        
        SocialPost socialpos = new SocialPost();
    socialpos.Name='Name';
        socialpos.provider = 'Facebook';
        socialpos.messageType = 'Private';
        socialpos.responseContextExternalId='test';
        socialpos.recipient= 'test';
    socialpos.ReplyToId= post[0].Id;       
    insert socialpos;
        
        SocialPost sp = XC_WS001_InboundSocialPost_FindPost.findReplyTo( post[0], persona[0]);
        SocialPost sp2 = XC_WS001_InboundSocialPost_FindPost.findReplyTo( socialpos , persona[0]);
        
        
       System.assertEquals(true, sp!=null);
        Test.stopTest();
    }
    
      //Test Method findReplyTo2
    static testMethod void findReplyTo2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        
        
        list <SocialPost> post= [SELECT Id ,ParentId, Name, messageType, ReplyToId , Recipient, ResponseContextExternalId, Provider, IsOutbound , PersonaId from SocialPost];
        list <SocialPersona> persona= [SELECT Id, Provider, MediaProvider,  ExternalId, ParentId, Name from SocialPersona];
        
        SocialPost socialpos = new SocialPost();
    socialpos.Name='Name';
        socialpos.provider = 'Facebook';
        socialpos.messageType = 'Private';
        socialpos.responseContextExternalId='test';
        socialpos.recipient= 'test';
    socialpos.ReplyToId= post[0].Id;       
    insert socialpos;
        
        post[0].responseContextExternalId = null;
        update post[0];
        SocialPost sp = XC_WS001_InboundSocialPost_FindPost.findReplyTo( post[0], persona[0]);
        
        
        System.assertEquals(true, sp!=null);
        Test.stopTest();
    }
   
    
     //Test Method findReplyToBasedOnReplyToId
    static testMethod void findReplyToBasedOnReplyToId(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        list <SocialPost> post= [SELECT Id , ParentId,Name, messageType, ReplyToId , Recipient, ResponseContextExternalId, Provider, IsOutbound , PersonaId from SocialPost];
        list <SocialPersona> persona= [SELECT Id, Provider, MediaProvider,  ExternalId, ParentId, Name from SocialPersona];
        
        SocialPost sp = XC_WS001_InboundSocialPost_FindPost.findReplyToBasedOnReplyToId( post[0] );
        
        
        System.assertEquals(true, sp!=null);
        Test.stopTest();
    }
    
    
    //Test Method findReplyToBasedOnExternalPostIdAndProvider
    static testMethod void findReplyToBasedOnExternalPostIdAndProvider(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        list <SocialPost> post= [SELECT Id ,ParentId, Name, messageType, ReplyToId , Recipient, ResponseContextExternalId, Provider, IsOutbound , PersonaId from SocialPost];
        list <SocialPersona> persona= [SELECT Id, Provider, MediaProvider,  ExternalId, ParentId, Name from SocialPersona];
        
        SocialPost sp = XC_WS001_InboundSocialPost_FindPost.findReplyToBasedOnExternalPostIdAndProvider( post[0] );
        
        
        System.assertEquals(true, sp!=null);
        Test.stopTest();
    }
    
    //Test Method findReplyToBasedOnResponseContextExternalPostIdAndProvider
    static testMethod void findReplyToBasedOnResponseContextExternalPostIdAndProvider(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        list <SocialPost> post= [SELECT Id ,ParentId, Name, messageType, ReplyToId , Recipient, ResponseContextExternalId, Provider, IsOutbound , PersonaId from SocialPost];
        list <SocialPersona> persona= [SELECT Id, Provider, MediaProvider,  ExternalId, ParentId, Name from SocialPersona];
        
        SocialPost sp = XC_WS001_InboundSocialPost_FindPost.findReplyToBasedOnResponseContextExternalPostIdAndProvider( post[0]  );
        
        
        System.assertEquals(true, sp!=null);
        Test.stopTest();
    }
    
    //Test Method findLatestInboundPostBasedOnPersonaAndRecipient
    static testMethod void findLatestInboundPostBasedOnPersonaAndRecipient(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        list <SocialPost> post= [SELECT Id , ParentId,Name, messageType, ReplyToId , Recipient, ResponseContextExternalId, Provider, IsOutbound , PersonaId from SocialPost];
        list <SocialPersona> persona= [SELECT Id, Provider, MediaProvider,  ExternalId, ParentId, Name from SocialPersona];
        
        
        SocialPost sp = XC_WS001_InboundSocialPost_FindPost.findLatestInboundPostBasedOnPersonaAndRecipient( post[0] , persona[0] );
        SocialPersona pers = new SocialPersona();
        SocialPost sp2 = XC_WS001_InboundSocialPost_FindPost.findLatestInboundPostBasedOnPersonaAndRecipient( post[0] , pers );
        
        
        System.assertEquals(true, sp!=null);
        Test.stopTest();
    }
    
}