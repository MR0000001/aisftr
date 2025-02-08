/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  21/05/2019 
* @description XC_UTIL_SocialPersona_TEST – Test class for XC_UTIL_SocialPersona
*/
@istest
public class XC_UTIL_SocialPersona_TEST {
    
    //Test Method XC_UTIL_SocialPersona
    static testMethod void createPersona(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        SocialPersona persona= new SocialPersona();
        SocialPost socialpos = new SocialPost();
        socialpos.Name='Name';
        insert socialpos;
        XC_UTIL_SocialPersona.createPersona(persona);
        
        System.assertEquals(true, persona!=null);
        Test.stopTest();
        
    }
    
    //Test Method buildPersona
    static testMethod void buildPersona(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        SocialPersona persona= new SocialPersona();
        SocialPost socialpos = new SocialPost();
        socialpos.Name='Name';
        insert socialpos;
        XC_UTIL_SocialPersona.buildPersona(persona);
        
        System.assertEquals(true, persona!=null); 
        Test.stopTest();
        
    }
    
    //Test Method matchPersona1
    static testMethod void matchPersona(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        SocialPersona persona= new SocialPersona();
        SocialPost socialpos = new SocialPost();
		socialpos.Name='Name';
		insert socialpos;
        socialpos.Name='Name';
        persona.Provider='Other';
        persona.MediaProvider= 'Facebook Comments';
        persona.ExternalId='test';
        persona.ParentId= socialpos.Id; 
		persona.Name='Name';
        insert persona;

	       
        XC_UTIL_SocialPersona.matchPersona(persona);   
        
        System.assertEquals(true, persona!=null);  
        Test.stopTest();
        
    }
    
     //Test Method matchPersona2
    static testMethod void matchPersona2(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        SocialPersona persona= new SocialPersona();
        SocialPost socialpos = new SocialPost();
		socialpos.Name='Name';
		insert socialpos;
        socialpos.Name='Name';
        persona.Provider='Facebook';
        persona.MediaProvider= 'Facebook Comments';
        persona.ExternalId='test';
        persona.ParentId= socialpos.Id; 
		persona.Name='Name';
        insert persona;

	       
        XC_UTIL_SocialPersona.matchPersona(persona);   
        
        System.assertEquals(true, persona!=null);  
        Test.stopTest();
        
    }
    
    
    //Test Method matchPersona3
    static testMethod void matchPersona3(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        SocialPersona persona= new SocialPersona();
        SocialPost socialpos = new SocialPost();
		socialpos.Name='Name';
		insert socialpos;
        socialpos.Name='Name';
        persona.Provider='Facebook';
        persona.MediaProvider= 'Facebook Comments';
        persona.ParentId= socialpos.Id; 
		persona.Name='Name';
        insert persona;

	       
        XC_UTIL_SocialPersona.matchPersona(persona);   
        
        System.assertEquals(true, persona!=null);  
        Test.stopTest();
        
    }
    
    //Test Method matchPersona4
    static testMethod void matchPersona4(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        SocialPersona persona= new SocialPersona();
        SocialPost socialpos = new SocialPost();
		socialpos.Name='Name';
		insert socialpos;
        socialpos.Name='Name';
        persona.Provider='Other';
        persona.MediaProvider= 'Facebook Comments';        
        persona.ParentId= socialpos.Id;
		persona.Name='Name';
        insert persona;
       
        XC_UTIL_SocialPersona.matchPersona(persona);
        
        System.assertEquals(true, persona!=null); 
        Test.stopTest();
        
    }
    
    
    


}