/**
* @author Emanuela Cacace  ecacace@deloitte.it &  Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com
* @date Creation  27/05/2019 
* @description XC_TR_Task_U_Care_SetParentCaseStat_TEST – Test class for XC_TR_Task_U_Care_SetParentCaseStatus
*/ 
@isTest
public with sharing class XC_TR_Task_U_Care_SetParentCaseStat_TEST {
    // Test method for modifyTaskByActionPlan 
    static testMethod void modifyTaskByActionPlan(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
            User u = XC_DF_User.createUserAdmin();
            insert u;
            Task t = new Task();
            List<Case> c= XC_DF_Case.createCases(1);
            c[0].OwnerId= u.Id ; 
            
            insert c ; 
            c[0].Status = 'ESTA002'; 
            t.Subject = 'Init'; 
            insert t ;
            t.OwnerId= c[0].OwnerId ; 
            t.Description= '1';
            update t ; 
            update c ; 
            System.assert(t!=null);
        Test.stopTest();
    }


        // Test method for modifyTaskByActionPlan2 
    static testMethod void modifyTaskByActionPlan2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
            User u = XC_DF_User.createUserAdmin();
            insert u;
            List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
            insert acc;
            Task t = new Task();
            List<Case> c= XC_DF_Case.createCases(1);
            c[0].OwnerId= u.Id ;  
            insert c ; 
            c[0].Status = Label.XC_CL_Case_InProgress; 
            update c; 
            t.WhatId = c[0].Id; 
            t.Subject = 'Init'; 
            insert t ;
            System.debug(LoggingLevel.FINEST,'@TASK-->'+t);
            t.OwnerId=   u.Id;
          
            t.Status = 'New'; 
            t.OwnerId= c[0].OwnerId ; 
            
            update t ; 
            System.debug(LoggingLevel.FINEST,'@TASK-->2'+t);
            

            System.assert(t!=null);
        Test.stopTest();
    }


      // Test method for modifyTaskByActionPlan3
    static testMethod void modifyTaskByActionPlan3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
            User u = XC_DF_User.createUserAdmin();
            insert u;
            Task t = new Task();
            List<Case> c= XC_DF_Case.createCases(1);
            c[0].OwnerId= u.Id ;  
            insert c ; 
            c[0].Status = Label.XC_CL_Case_InProgress; 
            update c; 
            t.WhatId = c[0].Id; 
            t.Subject = 'Init'; 
            insert t ;
            System.debug(LoggingLevel.FINEST,'@TASK-->'+t);
            t.OwnerId=   u.Id;
            t.Status = 'New'; 
            t.OwnerId= c[0].OwnerId ;
            update t ; 
            System.debug(LoggingLevel.FINEST,'@TASK-->2'+t);
            System.assert(t!=null);
        Test.stopTest();
    }



      // Test method for modifyTaskByActionPlan4
    static testMethod void modifyTaskByActionPlan4(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
            User u = XC_DF_User.createUserAdmin();
            insert u;
            List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
            insert acc;
            Task t = new Task();
            List<Case> c= XC_DF_Case.createCases(1);
            c[0].OwnerId= u.Id ;  
            insert c ; 
            c[0].Status = Label.XC_CL_Case_InProgress; 
            update c; 
            t.WhatId = c[0].Id; 
            t.Subject = 'Init'; 
            insert t ;
            System.debug(LoggingLevel.FINEST,'@TASK-->'+t);
            t.OwnerId=   u.Id;
            t.Status = 'New'; 
            t.OwnerId= c[0].OwnerId ; 
            t.Description= '4';
            update t ; 
            System.debug(LoggingLevel.FINEST,'@TASK-->2'+t);
            

            System.assert(t!=null);
        Test.stopTest();
    }
    
      // Test method for modifyTaskByActionPlan5
    static testMethod void modifyTaskByActionPlan5(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
            User u = XC_DF_User.createUserAdmin();
            insert u;
            List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
            insert acc;
            Task t = new Task();
            List<Case> c= XC_DF_Case.createCases(1);
            c[0].OwnerId= u.Id ;  
            insert c ; 
            c[0].Status = Label.XC_CL_Case_InProgress; 
            update c; 
        	List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery');
            insert woList;
            t.WhatId = woList[0].Id; 
            t.Subject = 'Init'; 
            insert t ;
            System.debug(LoggingLevel.FINEST,'@TASK-->'+t);
            t.OwnerId=   u.Id;
            t.Status = 'New'; 
            t.OwnerId= c[0].OwnerId ; 
            t.Description= '4';
            update t ; 
            System.debug(LoggingLevel.FINEST,'@TASK-->2'+t);
            

            System.assert(t!=null);
        Test.stopTest();
    }



}