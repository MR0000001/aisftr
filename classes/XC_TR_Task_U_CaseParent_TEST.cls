/**
* @author Emanuela Cacace  ecacace@deloitte.it 
* @date Creation  27/05/2019 
* @description XC_TR_Task_U_CaseParent_TEST – Test class for XC_TR_Task_U_CaseParent
*/ 
@isTest
public with sharing class XC_TR_Task_U_CaseParent_TEST {
     // Test method for checkIfDenyCreations 
     static testMethod void checkIfDenyCreations(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        Task t = new Task();
         t.WhatId = null; 
        insert t ; 
        System.assert(t!=null);
        Test.stopTest();
    }

       // Test method for checkIfDenyCreations2 
     @isTest
     static void checkIfDenyCreations2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<Case> c= XC_DF_Case.createCases(1);
        c[0].Status = 'ESTA001';
        insert c; 
        Task t = new Task();
        t.WhatId = c[0].Id; 
        insert t ; 
        System.debug('??? TASK'+ t.WhatId );
        System.assert(t!=null);
        Test.stopTest();
    } 

           // Test method for checkIfDenyCreations3 
     @isTest
     static void checkIfDenyCreations3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<Case> c= XC_DF_Case.createCases(1);
        c[0].Status = 'ESTA001';
        insert c;
        c[0].Status = 'ESTA007';
        update c;
        Task t = new Task();
        t.WhatId = c[0].Id; 
     
                try{
        insert t;
        }
         catch(Exception e) {
             Boolean expectedExceptionThrown =  e.getMessage().contains(Label.XC_CL_TaskCreationBlockedMess) ? true : false;
             System.assertEquals(expectedExceptionThrown, true);
        }

        System.debug('??? TASK   '+ t.WhatId );
        System.assert(t!=null);
        Test.stopTest();
    } 
       

  
}