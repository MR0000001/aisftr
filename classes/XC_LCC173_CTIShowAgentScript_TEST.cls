/**
 * @File Name          : XC_LCC173_CTIShowAgentScript_TEST.cls
 * @Description        : TC FOR XC_LCC173_CTIShowAgentScript
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 01-25-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    21/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@isTest
public without sharing class XC_LCC173_CTIShowAgentScript_TEST {

    @TestSetup
    static void setup(){
         
        User itAdmin = XC_DF_User.createUserAdmin();
        itAdmin.XC_LegalEntity__c = 'EnelXItalia';
        itAdmin.XC_LegalEntities__c = 'EnelXItalia';
        insert itAdmin;
        System.runAs(itAdmin) {
             NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
        
            XC_CTI_Interaction__c ctiInt = new XC_CTI_Interaction__c(XC_InteractionStatus__c='Open',XC_Connection_ID__c = '1234567');
            insert ctiInt;
    
            Opportunity opp = XC_DF_Opportunity.createOpportunity(1,false)[0];
            opp.XC_CTI_Interaction__c = ctiInt.Id;
            insert opp;
    
            ord.NE__OptyId__c = opp.Id;
            update ord;
    
    
            Task t = new Task (WhatId = ord.Id,Description = 'TEST',Subject = 'TESTTASK');
            insert t;
        
        }
       
        

    }
    


    @isTest
    static void initScriptContainerCmp_TEST(){

        NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];
		List<User> userList = [SELECT Id FROM USER WHERE XC_LegalEntity__c ='EnelXItalia' AND UserName = 'pablo123@gmail.com' LIMIT 1];
        System.runAs(userList[0]) {
             Test.startTest();
            XC_LCC173_CTIShowAgentScript.initScriptContainerCmp(ord.Id);
        	Test.stopTest();
        }
       

    }
    
    @isTest
    static void initScriptContainerCmp_TESTCAse(){
        
        List<Contact> contactSel = [SELECT Id, AccountId FROM Contact WHERE AccountId!=null LIMIT 1];
        List<XC_CTI_Interaction__c> cti=[SELECT Id FROM XC_CTI_Interaction__c WHERE XC_Connection_ID__c = '1234567' LIMIT 1];
		Case newCase = new Case();
        newCase.Status = 'ESTA001';
        newCase.Reason = 'XCMOT010';
        newCase.SubCause__c = 'ATCL058';
        newCase.AccountId = contactSel[0].AccountId;
        newCase.ContactId = contactSel[0].Id; 
        newCase.XC_CTI_Interaction__c = cti[0].Id;
       
        
        //NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];
		List<User> userList = [SELECT Id FROM USER WHERE XC_LegalEntity__c ='EnelXItalia' AND UserName = 'pablo123@gmail.com' LIMIT 1];
        System.runAs(userList[0]) {
             Test.startTest();
             insert newCase;
            XC_LCC173_CTIShowAgentScript.initScriptContainerCmp(newCase.Id);
        	Test.stopTest();
        }
       

    }
    
    

    
     @isTest
    static void initScriptContainerCmp_TEST2(){

        NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];
		List<User> userList = [SELECT Id FROM USER WHERE XC_LegalEntity__c ='EnelXItalia' AND UserName = 'pablo123@gmail.com' LIMIT 1];
        for(User u: userList) {
            u.XC_LegalEntity__c ='EndesaX';
        }
        update userList;
        System.runAs(userList[0]) {
            Test.startTest();
            XC_LCC173_CTIShowAgentScript.initScriptContainerCmp(ord.Id);
        	Test.stopTest();
        }
             
 
    }


    @isTest
    static void getDynamicScriptInfo_TEST(){
        NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];
        Map<String,Object> paramsMap = new Map<String,Object>{'objectName'=>'NE__Order__c','recordId'=>ord.Id};
		List<User> userList = [SELECT Id FROM USER WHERE XC_LegalEntity__c ='EnelXItalia' AND UserName = 'pablo123@gmail.com' LIMIT 1];
        System.runAs(userList[0]) {
        Test.startTest();
            XC_LCC173_CTIShowAgentScript.getDynamicScriptInfo(paramsMap);
        Test.stopTest();
        }
    }
    
     @isTest
    static void getDynamicScriptInfo_TEST2(){
        NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];
        Map<String,Object> paramsMap = new Map<String,Object>{'objectName'=>'NE__Order__c','recordId'=>ord.Id};
              
        Test.startTest();
            XC_LCC173_CTIShowAgentScript.getDynamicScriptInfo(paramsMap);
        Test.stopTest();
   
    }


    @isTest
    static void sendStartStopRecordingEvent_TEST(){
        NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];
        Map<String,Object> paramsMap = new Map<String,Object>{'eventType'=>'REMOTERECSTART','recordId'=>ord.Id};
		List<User> userList = [SELECT Id FROM USER WHERE XC_LegalEntity__c ='EnelXItalia' AND UserName = 'pablo123@gmail.com' LIMIT 1];
        System.runAs(userList[0]) {
        Test.startTest();
            XC_LCC173_CTIShowAgentScript.sendStartStopRecordingEvent(paramsMap);
        Test.stopTest();
        }
    }


    @isTest
    static void retrieveScriptTextFromTask_TEST(){
        NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];
        Task t = [SELECT Id FROM Task LIMIT 1];
        
        Map<String,Object> paramsMap = new Map<String,Object>{'taskId'=>t.Id,'recordId'=>ord.Id};
		List<User> userList = [SELECT Id FROM USER WHERE XC_LegalEntity__c ='EnelXItalia' AND UserName = 'pablo123@gmail.com' LIMIT 1];
        System.runAs(userList[0]) {
        Test.startTest();
            XC_LCC173_CTIShowAgentScript.retrieveScriptTextFromTask(paramsMap);
        Test.stopTest();
        }
    }
    
    @isTest
    static void checkRecEnabled_TEST(){
		List<User> userList = [SELECT Id FROM USER WHERE XC_LegalEntity__c ='EnelXItalia' AND UserName = 'pablo123@gmail.com' LIMIT 1];
        System.runAs(userList[0]) {
        Test.startTest();
        	XC_LCC173_CTIShowAgentScript.getIsRecodingEnabled();
        Test.stopTest();
        }
    }
      @isTest
    static void checkRecEnabled_TEST2(){
       
        Test.startTest();
        	XC_LCC173_CTIShowAgentScript.getIsRecodingEnabled();
        Test.stopTest();
        
    }
    
	@isTest
    static void coreSkipTriggerTEST(){
        Test.startTest();
		Map<String,XC_CM_OneOrgFW__mdt> c = Constants.coreSkipTrigger;
        Test.stopTest();
    }

    @isTest
    static void initScriptContainerCmp_NOTCTI(){

        NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];
        List<XC_CTI_Interaction__c> ctiInt= [SELECT Id FROM XC_CTI_Interaction__c WHERE XC_Connection_ID__c = '1234567' LIMIT 1];
        
		Database.Delete (ctiInt);
		Database.emptyRecycleBin(ctiInt);
        

             Test.startTest();
            XC_LCC173_CTIShowAgentScript.initScriptContainerCmp(ord.Id);
        	Test.stopTest();
       

    }


    @isTest
    static void initScriptContainerCmp_NoCTIOnOpty(){

        NE__Order__c ord = [SELECT Id,NE__OptyId__c FROM NE__Order__c LIMIT 1];
        Opportunity opty = [SELECT Id,XC_CTI_Interaction__c FROM Opportunity WHERE Id =: ord.NE__OptyId__c];
        opty.XC_CTI_Interaction__c = null;
        update opty;
		List<User> userList = [SELECT Id FROM USER WHERE XC_LegalEntity__c ='EnelXItalia' AND UserName = 'pablo123@gmail.com' LIMIT 1];
        System.runAs(userList[0]) {
             Test.startTest();
            XC_LCC173_CTIShowAgentScript.initScriptContainerCmp(ord.Id);
        	Test.stopTest();
        }
       

    }

}