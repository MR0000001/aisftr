/**
 * @File Name          : gl_WorkspaceConnectorController_Test.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 2/7/2020, 15:31:45
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/7/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@isTest
private class gl_WorkspaceConnectorController_Test {
    
     static testMethod void IsPersonAccountEnabled_Test()
     {
        String result = gl_WorkspaceConnectorController.IsPersonAccountEnabled(); 
        System.assert(result!=null);
     }

     static testMethod void findContactFromCase_Test()
     {
        String test_subject = '123test321test';
        //error leg
        String result = gl_WorkspaceConnectorController.findContactFromCase('1');
        System.assert(result == null);
        
        Id [] fixedSearchResults= new Id[2];
         
        List<Case> listCase = XC_DF_Case.createCases(1);
        insert listCase;
        
        fixedSearchResults[0] = listCase[0].ContactId;
        fixedSearchResults[1] = listCase[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        result = gl_WorkspaceConnectorController.findContactFromCase(listCase[0].Id);
        System.assert(result!=null);
     }

    static testMethod void findObjectFromANI_Test(){
        Object result = gl_WorkspaceConnectorController.findObjectFromANI('5555');
        System.assert(result == 'not found');
        
        /* From Salesforce documentation: Adding SOSL Queries to Unit Tests
        To ensure that test methods always behave in a predictable way, any Salesforce Object Search Language (SOSL) query that is 
        added to an Apex test method returns an empty set of search results when the test method executes.
        Need to use setFixedSearchResults to set the results.       
        */    
        //Create Account test data
        Id [] fixedSearchResultsACC= new Id[1];
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;        
        fixedSearchResultsACC[0] = aList[0].Id;
        
        Test.setFixedSearchResults(fixedSearchResultsACC);
        result = gl_WorkspaceConnectorController.findObjectFromANI('5555');
        System.assert(result!=null);
        
        //Create Contact test data
        Id [] fixedSearchResults= new Id[1];
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;       
        fixedSearchResults[0] = cList[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        result = gl_WorkspaceConnectorController.findObjectFromANI('4444');       
        System.assert(result!=null);  
        
        //Create Lead test data
        Id [] fixedSearchResultsLead= new Id[1];
        List<Lead> lList = XC_DF_Lead.createResidentialLeads(1);
        insert lList;       
        fixedSearchResultsLead[0] = lList[0].Id;
        Test.setFixedSearchResults(fixedSearchResultsLead);
        result = gl_WorkspaceConnectorController.findObjectFromANI('2424');       
        System.assert(result!=null); 
    }


    static testMethod void findObjectFromANIByType_Test(){
        Object result = gl_WorkspaceConnectorController.findObjectFromANI('5555');
        System.assert(result == 'not found');       
  
        //Create Account test data
        Id [] fixedSearchResultsACC= new Id[1];
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;  
        fixedSearchResultsACC[0] = aList[0].Id;
        Test.setFixedSearchResults(fixedSearchResultsACC);
        result = gl_WorkspaceConnectorController.findObjectFromANIByType('5555', 'account');
        System.assert(result!=null);  
        
        result = gl_WorkspaceConnectorController.findObjectFromANIByType('5555', 'personaccount');
        System.assert(result!=null);  
    }
    
    static testMethod void findContactFromANI_Test() 
    {
         Object id;
        //error
        id = gl_WorkspaceConnectorController.findContactFromANI('');
        System.assert(id == null);
        
        id = gl_WorkspaceConnectorController.findContactFromANI('4444');
        System.assert(id == 'not found');
        
        Id [] fixedSearchResults = new Id[2];
        List<Account> aList = XC_DF_Account.createResidentialAccounts(2);
        insert aList;  
        
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        //Create Contact test data
        fixedSearchResults[0] = cList[0].Id;
        fixedSearchResults[1] = cList[1].Id; 

        Test.setFixedSearchResults(fixedSearchResults);
        String test_phone = '4444'; 
        id = gl_WorkspaceConnectorController.findContactFromANI(test_phone);
        System.assert(id == 'multiple found');
    }  

    static testMethod void findContactFromANI2_Test() 
    {
         Object id;
        //error
        id = gl_WorkspaceConnectorController.findContactFromANI('');
        System.assert(id == null);
        
        id = gl_WorkspaceConnectorController.findContactFromANI('4444');
        System.assert(id == 'not found');
        
        Id [] fixedSearchResults = new Id[1];
        List<Account> aList = XC_DF_Account.createResidentialAccounts(2);
        insert aList;  
        
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        //Create Contact test data
        fixedSearchResults[0] = cList[0].Id; 

        Test.setFixedSearchResults(fixedSearchResults);
        String test_phone = '4444'; 
        id = gl_WorkspaceConnectorController.findContactFromANI(test_phone);
    }  


    static testMethod void findContactFromEmailAddress_Test() 
    {
         Object id;
        //error
        id = gl_WorkspaceConnectorController.findContactFromEmailAddress('john.doer@somewhere.com');
        System.assert(id == null);
         
        Id [] fixedSearchResults = new Id[1];       
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;  
        
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        
        fixedSearchResults[0] = cList[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);

        String emailC = [Select Email From contact where id =: cList[0].Id][0].Email;

        
        id = gl_WorkspaceConnectorController.findContactFromEmailAddress(emailC);
    }


    static testMethod void findContactFromChatAddress_Test() 
    {
        Object id;
        //error
        id = gl_WorkspaceConnectorController.findContactFromChatAddress('John Doer');
        System.assert(id == null);
                 
        Id [] fixedSearchResults = new Id[1];       
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;  
        
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList; 

        String name = [Select Name From contact where id =: cList[0].Id][0].Name;
        
        fixedSearchResults[0] = cList[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        id = gl_WorkspaceConnectorController.findContactFromChatAddress(name);
    }

    static testMethod void findContactFromWorkItemAddress_Test() 
    {
        Object id;
        //error
        id = gl_WorkspaceConnectorController.findContactFromWorkItemAddress('John Doe');
        System.assert(id == null);
                 
        Id [] fixedSearchResults = new Id[1];       
        //Create Contact test data
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;  
        
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        fixedSearchResults[0] = cList[0].Id;

        String name = [Select Name From contact where id =: cList[0].Id][0].Name;

        Test.setFixedSearchResults(fixedSearchResults);
        
        id = gl_WorkspaceConnectorController.findContactFromWorkItemAddress(name);
    }
    
    static testMethod void findContactFromOpenMediaAddress_Test() 
    {
         Object id;
        //error
        id = gl_WorkspaceConnectorController.findContactFromOpenMediaAddress('John Doe');
        System.assert(id == null);
                 
        Id [] fixedSearchResults = new Id[1];       
        //Create Contact test data
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;  
        
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        String name = [Select Name From contact where id =: cList[0].Id][0].Name;

        fixedSearchResults[0] = cList[0].Id; 
        Test.setFixedSearchResults(fixedSearchResults);
        
        id = gl_WorkspaceConnectorController.findContactFromOpenMediaAddress(name);
    }    


    // static testMethod void createCase_Test() 
    // {
    //     Map<String,String> fieldsMap = new Map<String,String>();
    //     //create map  
    //     fieldsMap.put('IXN Type','Call');
    //     fieldsMap.put('Media Type','');
    //     fieldsMap.put('DATE','June1');
    //     String result = gl_WorkspaceConnectorController.createCase(fieldsMap);
    //     System.assert(result != 'case not created');
    // }
    
    
    static testMethod void findAccountFromOpenMediaAddress_Test()
    {
        
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1); 
        insert aList;  
        String acName = [SELECT Name FROM Account WHERE Id =: aList[0].Id][0].Name;
        Object result = gl_WorkspaceConnectorController.findAccountFromOpenMediaAddress(acName, 'account');
        System.assert(result!=null);    
    }
    
    static testMethod void createActivity_Test() 
    {
        String ID = '';
        Map<String,String> fieldsMap = new Map<String,String>();
        //create map
        fieldsMap.put('Genesys Call Type','Inbound');
        fieldsMap.put('LOOKUP','4444');
        fieldsMap.put('Call Duration','35');
        fieldsMap.put('DATE','June1');
        fieldsMap.put('Comments','');
        fieldsMap.put('ANI','4444');
        fieldsMap.put('IXN Type','Phone');
        fieldsMap.put('Media Type','');
        fieldsMap.put('sfdc Object Id',ID);
        
        //Activity created as orhpan
        String noIDResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account');
        
        //Create Account test data
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;
        
        //Create Contact test data
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        
        //Activity created under Contact using search
        String contactResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account');

        fieldsMap.put('IXN Type','Email');
        fieldsMap.put('LOOKUP','john.doer@somewhere.com');
        contactResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account'); 

        fieldsMap.put('IXN Type','Chat');
        fieldsMap.put('LOOKUP','John Doer');
        contactResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account'); 
        
        fieldsMap.put('IXN Type','OpenMedia');
        fieldsMap.put('LOOKUP','John Doer');
        contactResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account'); 
    
        //Activity created under Contact using ID
        //ID = con.Id;
        System.Debug('sfdc Object Id = '+ID);
        fieldsMap.put('sfdc Object Id',ID);
        fieldsMap.put('SFDC1field','Description');
        fieldsMap.put('SFDC1value','Test1');
        fieldsMap.put('SFDC2field','Description');
        fieldsMap.put('SFDC2value','Test2');
        fieldsMap.put('SFDC3field','Description');
        fieldsMap.put('SFDC3value','Test3');
        fieldsMap.put('SFDC4field','Description');
        fieldsMap.put('SFDC4value','Test4');
        fieldsMap.put('SFDC5field','Description');
        fieldsMap.put('SFDC5value','Test5');    
        contactResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account'); 
    } 
    
    
    
    static testMethod void findActivity_Test() 
    {
        String connID = '12345abc123';      
        String ID = '';
        Map<String,String> fieldsMap = new Map<String,String>();
        //create map
        fieldsMap.put('Genesys Call Type','Inbound');
        fieldsMap.put('LOOKUP','4444');
        fieldsMap.put('Call Duration','35');
        fieldsMap.put('DATE','June1');
        fieldsMap.put('Comments','');
        fieldsMap.put('ANI','4444');
        fieldsMap.put('IXN Type','Phone');
        fieldsMap.put('Media Type','');
        fieldsMap.put('sfdc Object Id',ID);
        fieldsMap.put('GenesysId',connID);
        
        //Activity created as orhpan
        String noIDResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account');
        
        String result = gl_WorkspaceConnectorController.findActivity(connID); 
    }
    
    static testMethod void updateActivity_Test() 
    {
        String connID = '12345abc123';      
        String ID = '';
        Map<String,String> fieldsMap = new Map<String,String>();
        //create map
        fieldsMap.put('Genesys Call Type','Inbound');
        fieldsMap.put('LOOKUP','4444');
        fieldsMap.put('Call Duration','35');
        fieldsMap.put('DATE','June1');
        fieldsMap.put('Comments','');
        fieldsMap.put('ANI','4444');
        fieldsMap.put('IXN Type','Phone');
        fieldsMap.put('Media Type','');
        fieldsMap.put('sfdc Object Id',ID);
        fieldsMap.put('GenesysId',connID);
        
        //Activity created as orhpan
        String noIDResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account');
        
        String taskId = gl_WorkspaceConnectorController.findActivity(connID);
        
        fieldsMap.put('Comments','updated comment');
        
        String updateResult = gl_WorkspaceConnectorController.updateActivity(taskId, fieldsMap); 
    }
    

    static testMethod void addAttachment_Test()
    {
        Task t = new Task (
              Type = 'Call',
              Status = 'Completed',
              Subject = 'Testttt',
              Priority = 'Normal',
              ActivityDate = System.today()
            );
        insert t;
        String blobString= 'This is a string';
        Blob b = Blob.valueOf(blobString);
        String result = gl_WorkspaceConnectorController.addAttachment(t.Id,'Test Description','TestName1','txt',b,null);
        System.assert(result != 'error');
    }
    

    static testMethod void testConnection_Test()
    {
        Object result = gl_WorkspaceConnectorController.testConnection();
    }
    
    
    static testMethod void findCaseObject_Test() 
    {
        Id [] fixedSearchResults = new Id[4];

        
        List<Case> listCase = XC_DF_Case.createCases(2);
        listCase[1].XC_IsCloned__c = true;
        insert listCase;
        
        fixedSearchResults[0] = listCase[0].AccountId;
        fixedSearchResults[1] = listCase[0].ContactId;
        
        fixedSearchResults[2] = listCase[0].Id;
        fixedSearchResults[3] = listCase[1].Id;  
        
        Test.setFixedSearchResults(fixedSearchResults);
                    
        gl_WorkspaceConnectorController.findCaseObject('Subject','test_subject2');
        gl_WorkspaceConnectorController.findCaseObject('Account.Id', listCase[0].AccountId);
        gl_WorkspaceConnectorController.findCaseObject('AccountId', listCase[0].AccountId);
    }
    
    
    static testMethod void findCaseObjectMapSearch_Test() 
    {
        Id [] fixedSearchResults = new Id[4];
        
        List<Case> listCase = XC_DF_Case.createCases(2);
        listCase[1].XC_IsCloned__c = true;
        insert listCase;
        
        fixedSearchResults[0] = listCase[0].AccountId;
        fixedSearchResults[1] = listCase[0].ContactId;
        
        fixedSearchResults[2] = listCase[0].Id;
        fixedSearchResults[3] = listCase[1].Id;  
        
        Test.setFixedSearchResults(fixedSearchResults);             
        
        Boolean searchAllFields = true;
        // Create map 
        Map<String,String> fieldsMap = new Map<String,String>();
        fieldsMap.put('Subject','test_subject2');
        fieldsMap.put('Account.Phone','5555');        

        Object result = gl_WorkspaceConnectorController.findObjectMapSearch(fieldsMap, searchAllFields);
        System.assert(result!=null); 
    }

    static testMethod void findObject_Test() 
    {               
        Object result = gl_WorkspaceConnectorController.findObject('Phone','5');
        System.assert(result != null);
    
        /* From Salesforce documentation: Adding SOSL Queries to Unit Tests
        To ensure that test methods always behave in a predictable way, any Salesforce Object Search Language (SOSL) query that is 
        added to an Apex test method returns an empty set of search results when the test method executes.
        Need to use setFixedSearchResults to set the results.       
        */
        Id [] fixedSearchResults = new Id[5];
        List<Case> listCase = XC_DF_Case.createCases(2);
        listCase[1].XC_IsCloned__c = true;
        insert listCase;

        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        insert listLead;
        
        fixedSearchResults[0] = listCase[0].AccountId;
        fixedSearchResults[1] = listCase[0].ContactId;
        fixedSearchResults[2] = listLead[0].Id; 
        fixedSearchResults[3] = listCase[0].Id;
        fixedSearchResults[4] = listCase[1].Id;  
        
        Test.setFixedSearchResults(fixedSearchResults);
        
        result = gl_WorkspaceConnectorController.findObject('Phone','4444');       
        System.assert(result!=null);
        
        result = gl_WorkspaceConnectorController.findObject('Phone','2424');       
        System.assert(result!=null);
            
        result = gl_WorkspaceConnectorController.findCaseObject('Subject', 'test_subject2');    
    }
    
    
    static testMethod void findObjectMapSearch_Test() 
    {    
        Boolean searchAllFields = true;
        // Create map 
        Map<String,String> fieldsMap = new Map<String,String>();
        fieldsMap.put('Name','John Doer');
        fieldsMap.put('Phone','5555');   
        fieldsMap.put('FirstName','Jack');             
 
        Id [] fixedSearchResults= new Id[3];     

        
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;  
        fixedSearchResults[0] = aList[0].Id;
        
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        fixedSearchResults[1] = cList[0].Id;
        
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        insert listLead;
        fixedSearchResults[2] = listLead[0].Id; 
        
        Test.setFixedSearchResults(fixedSearchResults);
        
        Object result = gl_WorkspaceConnectorController.findObjectMapSearch(fieldsMap, searchAllFields);
        System.assert(result!=null);
        
        result = gl_WorkspaceConnectorController.findObjectMapSearch(fieldsMap, false);
        System.assert(result!=null);
    }

    static testMethod void findObjectByType_Test() 
    {
        //Create Account test data
        Id [] fixedSearchResults= new Id[3];

        List<Account> accList = XC_DF_Account.createResidentialAccounts(3);
        insert accList;
        fixedSearchResults[0] = accList[0].Id;
        fixedSearchResults[1] = accList[1].Id;
        fixedSearchResults[2] = accList[2].Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Object result = gl_WorkspaceConnectorController.findObjectByType('Phone','1111', 'account');
        System.assert(result!=null);   
    }
    
    static testMethod void findObjectByTypeMapSearch_Test() 
    {    
        Boolean searchAllFields = true;
        // Create map 
        Map<String,String> fieldsMap = new Map<String,String>();
        fieldsMap.put('Name','test Account2');
        fieldsMap.put('Phone','1111');        
        
        Id [] fixedSearchResults= new Id[3];

        List<Account> accList = XC_DF_Account.createResidentialAccounts(3);
        insert accList;
        fixedSearchResults[0] = accList[0].Id;
        fixedSearchResults[1] = accList[1].Id;
        fixedSearchResults[2] = accList[2].Id; 
        Test.setFixedSearchResults(fixedSearchResults);
        
        Object result = gl_WorkspaceConnectorController.findObjectByTypeMapSearch(fieldsMap, searchAllFields, 'account');
        System.assert(result!=null);
    }
      

    @isTest
    static  void createInteractionContact_Test() {
        Map<String,String> activityMap = new Map<String,String>();

        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;  
        
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        cList[0].XC_ContactPhone__c = '612345678';
        cList[0].XC_PhonePrefix__c = '+34';
        insert cList; 
        
        activityMap.put('Phone', '612345678');
        gl_WorkspaceConnectorController.createInteraction(activityMap);    
    }

    @isTest
    static  void createInteractionLead_Test() {
        Map<String,String> activityMap = new Map<String,String>();  

        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);  
        leadList[0].XC_LeadPhone__c = '612345678';
        leadList[0].XC_PhonePrefix__c = '+34';
        insert leadList;  
        
        activityMap.put('Phone', '612345678');
        gl_WorkspaceConnectorController.createInteraction(activityMap);    
    }

    @isTest
    static  void createInteraction_Test() {
        Map<String,String> activityMap = new Map<String,String>();

        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;  
        
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        cList[0].XC_ContactPhone__c = '612345678';
        cList[0].XC_PhonePrefix__c = '+34';
        insert cList; 

        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1); 
        leadList[0].XC_LeadPhone__c = '612345678';
        leadList[0].XC_PhonePrefix__c = '+34';
        insert leadList; 
        
        activityMap.put('Phone', '612345678');
        gl_WorkspaceConnectorController.createInteraction(activityMap);    
    }

    @isTest
    static  void updateInteractionLead_Test() {
        Map<String,String> activityMap = new Map<String,String>();  

        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);  
        leadList[0].XC_LeadPhone__c = '612345678';
        leadList[0].XC_PhonePrefix__c = '+34';
        insert leadList;  
        
        activityMap.put('Phone', '612345678');
        gl_WorkspaceConnectorController.createInteraction(activityMap);  
        gl_WorkspaceConnectorController.updateInteraction(activityMap);   
    }

    @isTest
    static  void createInteractionOutBound_Test() {  
        
        List<Case> listCase = XC_DF_Case.createCases(1);
        insert listCase; 
           
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        leadList[0].XC_LeadPhone__c = '612345678';
        leadList[0].XC_PhonePrefix__c = '+34';
        insert leadList;  
    
        Map<String,String> objectMap = new Map<String,String>();  
        objectMap.put('objectType','XC_CTI_Interaction__c');
        XC_CTI_Interaction__c ci = new XC_CTI_Interaction__c();
        insert ci;
        objectMap.put('recordId',ci.Id);
        gl_WorkspaceConnectorController.createInteractionOutBound(objectMap);  
        objectMap.put('objectType','Lead');
        objectMap.put('recordId',leadList[0].Id);
        gl_WorkspaceConnectorController.createInteractionOutBound(objectMap); 
        objectMap.put('objectType','Contact');
        objectMap.put('recordId', listCase[0].ContactId);
        gl_WorkspaceConnectorController.createInteractionOutBound(objectMap); 
        objectMap.put('objectType','Case');
        objectMap.put('recordId', listCase[0].ContactId);
        gl_WorkspaceConnectorController.createInteractionOutBound(objectMap); 
        objectMap.put('objectType','Account');
        objectMap.put('recordId', listCase[0].Id);
        gl_WorkspaceConnectorController.createInteractionOutBound(objectMap);  
        objectMap.put('objectType','');  
        objectMap.put('calledPhone','1');
    }
    
    @isTest
    static  void createInteractionOutBoundCI_Test() {  
        
        List<Case> listCase = XC_DF_Case.createCases(1);
        insert listCase; 
           
    
        Map<String,String> objectMap = new Map<String,String>();  
        objectMap.put('objectType','XC_CTI_Interaction__c');
        XC_CTI_Interaction__c ci = new XC_CTI_Interaction__c();
        insert ci;
        objectMap.put('recordId',ci.Id);
    }

    @isTest
    static  void getActivityComments_Test() { 
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;  
        
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList; 

        Task t = new Task();
        t.Subject           = 'High';
        t.WhoId             = cList[0].Id;
        t.WhatId             = aList[0].Id;
        t.Status        = 'Not Started';
        insert t;
        gl_WorkspaceConnectorController.getActivityComments(t.Id);   
    }

    @isTest
    static  void updateActivity2_Test() { 
        Map<String,String> activityMap = new Map<String,String>();  
        activityMap.put('Call Duration','2');
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;  
        
        activityMap.put('sfdc Object Id', aList[0].Id);
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList; 

        Task t = new Task();
        t.Subject           = 'High';
        t.WhoId             = cList[0].Id;
        t.WhatId             = aList[0].Id;
        t.Status        = 'Not Started';
        insert t;
        gl_WorkspaceConnectorController.updateActivity(t.Id, activityMap);   
    }
    
    @isTest
    static void findCaseObjectMapSearch_Test2() { 
        Map<String,String> activityMap = new Map<String,String>();   
        gl_WorkspaceConnectorController.findCaseObjectMapSearch(activityMap, false);
    }

    @isTest
    static void getPrefixCompletePhoneNumber_Test() { 
        Map<String,String> payload = new Map<String,String>(); 
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;  
        
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        cList[0].XC_ContactPhone__c = '612345678';
        cList[0].XC_PhonePrefix__c = '+34';
        insert cList;  
        payload.put('objectType', 'Contact'); 
        payload.put('recordId', cList[0].Id);
        payload.put('number','+393208286771');

        gl_WorkspaceConnectorController.getPrefixCompletePhoneNumber(payload);
    }

    @isTest
    static void getRecords_Test() {  
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;
        gl_WorkspaceConnectorController.getRecords(aList[0].Id, 'Id');
    }


    @isTest
    static void getWDERecordingMessage_Test(){

        Map<String,Object> testParamsMap = new Map<String,Object>();
        testParamsMap.put('CI_connectionData','test:"123"');
        String mode = 'START';

        XC_CTI_Interaction__c interaction = new XC_CTI_Interaction__c(XC_Connection_ID__c='AA1234',XC_InteractionStatus__c='Open');
        insert interaction;

        Test.startTest();
            gl_WorkspaceConnectorController.getWDERecordingMessage(testParamsMap, mode);
        Test.stopTest();
    }

    @isTest
    static void manageWDERecordingURL_Test(){

        NE__Order__c ord = XC_DF_Order.createOrder('InOrder');

        Map<String,Object> testParamsMap = new Map<String,Object>();
        testParamsMap.put('recUrl','https://test.salesforce.com');
        testParamsMap.put('recDuration','3.00');
        testParamsMap.put('recId','1234');
        testParamsMap.put('connId','AA1234');
        testParamsMap.put('contextRecordId',ord.Id);

        XC_CTI_Interaction__c interaction = new XC_CTI_Interaction__c(XC_Connection_ID__c='AA1234',XC_InteractionStatus__c='Open');
        insert interaction;

        Test.startTest();
            gl_WorkspaceConnectorController.manageWDERecordingURL(testParamsMap);
        Test.stopTest();

    }
    
        @isTest
    static void testtt(){
        Test.startTest();
    	gl_WorkspaceConnectorController.createWDEToSfPlatformEvent(new Map<String,Object>());
        gl_WorkspaceConnectorController.checkShowRecordingPanel(new Map<String,Object>());
        Test.stopTest();
    }
    

}