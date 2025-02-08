/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
@Istest
public with sharing class XC_LCC186_CreateProjectPPM_TEST {
    static testMethod void createProjectTestBatch(){
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        
        insert oi;
        
        XC_Milestone__c m = new XC_Milestone__c(name = 'test', XC_OrderItem__c =oi[0].id, XC_Rate__c = 4, XC_StartDate__c = Date.today());
        insert m;
        List<NE__Order__c> listOrde = [SELECT ID,XC_Project_Template__c, NE__AccountId__c,NE__Configuration_Type__c FROM NE__Order__c WHERE id =:oi[0].NE__OrderId__c];
        List<Account> listAcc = [SELECT ID,XC_FirstName__c, XC_LastName__c,RecordType.DeveloperName, NAME FROM Account WHERE ID = :listOrde[0].NE__AccountId__c];
        listAcc[0].XC_FirstName__c = 'D1';
        listAcc[0].XC_LastName__c = 'L1';
        listAcc[0].NAME = 'L1D1';
        listAcc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        update listAcc;

        project_cloud__Project__c p = new project_cloud__Project__c(name='Progetto Master Donato',
                project_cloud__Type__c='Provisioning',project_cloud__Units__c= 'Duration',
                project_cloud__IsTemplate__c = true);
        insert p;

        project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c(name='Phase Progetto di Test',
                project_cloud__Project__c=p.id, XC_billing_phase__c =true);
        insert ph;
        oi[0].XC_Project_Template__c=p.id;
        oi[0].NE__OneTimeFeeOv__c = 50;
        
        //update oi;
        Test.startTest();
        XC_LCC186_CreateProjectPPM.createProject(oi);
        Test.stopTest();
        
        
        
        
    }
   /* static testMethod void createProjectTestProjectOnCofiguration(){
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        insert oi;
        List<NE__OrderItem__c> listOrderItems = [select (select id from Projects__r), (select id, XC_Rate__c, name, XC_StartDate__c,XC_EndDate__c,XC_OrderItem__c from XC_Milestones__r), XC_BillingModel__c, XC_TotalPriceOneShot__c,XC_RecurringDuration__c,NE__RecurringChargeFrequency__c,XC_TotalPriceRecurring__c, NE__OrderId__r.XC_Segment__c,NE__OrderId__r.NE__Configuration_Type__c, NE__OrderId__r.XC_Compliance_Approval__c, NE__OrderId__c,XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_Country__c, id,NE__OrderId__r.NE__AccountId__r.name,  XC_Country__c, NE__OrderId__r.name, NE__OrderId__r.NE__AccountId__c, Name,NE__Account__c, XC_Project_Template__c, NE__Parent_Order_Item__c, RecordType.DeveloperName,  NE__OrderId__r.id, NE__OrderId__r.XC_Project_Template__c, XC_LegalEntityFormula__c, NE__OneTimeFeeOv__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c,  NE__Account__r.name, NE__OrderId__r.NE__One_Time_Fee_Total__c, XC_PaymentMethod__c FROM NE__orderItem__c WHERE id =:oi[0].id];
        List<Account> listAcc = [SELECT ID, NAME,XC_FirstName__c,XC_LastName__c FROM Account WHERE ID = :listOrderItems[0].NE__OrderId__r.NE__AccountId__c];
        listAcc[0].XC_FirstName__c = 'D2';
        listAcc[0].XC_LastName__c = 'L2';
        listAcc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        listAcc[0].NAME = 'L1D1';
        update listAcc;
        project_cloud__Project__c p = new project_cloud__Project__c(name='Progetto Master Donato',
                project_cloud__Type__c='Provisioning',project_cloud__Units__c= 'Duration',
                project_cloud__IsTemplate__c = true);
        insert p;

        project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c(name='Phase Progetto di Test',
                project_cloud__Project__c=p.id, XC_billing_phase__c =true);
        insert ph;
        listOrderItems[0].NE__OrderId__r.XC_Project_Template__c=p.id;
        listOrderItems[0].NE__OneTimeFeeOv__c = 50;
        listOrderItems[0].NE__OrderId__r.NE__Configuration_Type__c = 'Disconnect';
        listOrderItems[0].NE__OrderId__r.NE__AccountId__r.name ='Donato';
        update listOrderItems;
        List<Account> listAccu= [SELECT ID, NAME,XC_FirstName__c,XC_LastName__c FROM Account WHERE ID = :listAcc[0].id];
        listAccu[0].XC_FirstName__c = 'D2';
        listAccu[0].XC_LastName__c = 'L2';
        listAccu[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        listAccu[0].NAME = 'L1D1';
        update listAccu;
        //update oi;
        XC_LCC186_CreateProjectPPM.createProject(listOrderItems);

    }*/
    
    static testMethod void createProjectTestBatchDisconnect(){
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingModel__c= 'Milestone';
        oi[0].XC_LegalEntity__c= 'EnelXItalia';
        oi[0].XC_ConfigurationType__c= 'InOrder';
        oi[0].NE__OneTimeFeeOv__c=100;
        insert oi;
        XC_Milestone__c m = new XC_Milestone__c(name = 'test', XC_OrderItem__c =oi[0].id, XC_Rate__c = 4, XC_StartDate__c = Date.today());
        insert m;
        List<NE__Order__c> listOrde = [SELECT ID,XC_Project_Template__c, NE__AccountId__c,NE__Configuration_Type__c FROM NE__Order__c WHERE id =:oi[0].NE__OrderId__c];
      	listOrde[0].NE__Configuration_Type__c ='Disconnect';
        update listOrde;
        List<Account> listAcc = [SELECT ID,XC_FirstName__c, XC_LastName__c,RecordType.DeveloperName, NAME FROM Account WHERE ID = :listOrde[0].NE__AccountId__c];
        listAcc[0].XC_FirstName__c = 'D1';
        listAcc[0].XC_LastName__c = 'L1';
        listAcc[0].NAME = 'L1D1';
        listAcc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        update listAcc;        
        project_cloud__Project__c p = new project_cloud__Project__c(name='Progetto Master Donato',
                project_cloud__Type__c='Provisioning',project_cloud__Units__c= 'Duration',XC_LegalEntity__c= oi[0].XC_LegalEntity__c,XC_Country__c='Italy',
                project_cloud__IsTemplate__c = true);
        insert p;

        project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c(name='Phase Progetto di Test',
                project_cloud__Project__c=p.id, XC_billing_phase__c =true);
        insert ph;
        oi[0].XC_Project_Template__c=p.id;   
        update oi;        
        List<NE__OrderItem__c> listOrderItems = [select (select id from Projects__r), (select id, XC_Rate__c, name, XC_StartDate__c,XC_EndDate__c,XC_OrderItem__c,XC_IsBilled__c from XC_Milestones__r), XC_BillingModel__c, XC_TotalPriceOneShot__c,XC_RecurringDuration__c,NE__RecurringChargeFrequency__c,XC_TotalPriceRecurring__c, NE__OrderId__r.XC_Segment__c,NE__OrderId__r.NE__Configuration_Type__c, NE__OrderId__r.XC_Compliance_Approval__c, NE__OrderId__c,XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_Country__c, id,NE__OrderId__r.NE__AccountId__r.name,  XC_Country__c, NE__OrderId__r.name, NE__OrderId__r.NE__AccountId__c, Name,NE__Account__c, XC_Project_Template__c, NE__Parent_Order_Item__c, RecordType.DeveloperName,  NE__OrderId__r.id, NE__OrderId__r.XC_Project_Template__c, XC_LegalEntityFormula__c, NE__OneTimeFeeOv__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c,  NE__Account__r.name, NE__OrderId__r.NE__One_Time_Fee_Total__c, XC_PaymentMethod__c FROM NE__orderItem__c WHERE id =:oi[0].id];           
        listOrderItems[0].NE__OrderId__r.NE__Configuration_Type__c ='Disconnect';
        update listOrderItems[0].NE__OrderId__r;
        Test.startTest();
        XC_LCC186_CreateProjectPPM.createProject(listOrderItems);
        Test.stopTest();        
    }
    static testMethod void getProjectTemplatesTest(){
         List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingModel__c= 'Milestone';
        oi[0].XC_LegalEntity__c= 'EnelXItalia';
        oi[0].XC_ConfigurationType__c= 'InOrder';
        oi[0].NE__OneTimeFeeOv__c=100;
        insert oi;
        XC_Milestone__c m = new XC_Milestone__c(name = 'test', XC_OrderItem__c =oi[0].id, XC_Rate__c = 4, XC_StartDate__c = Date.today());
        insert m;
        List<NE__Order__c> listOrde = [SELECT ID,XC_Project_Template__c, NE__AccountId__c,NE__Configuration_Type__c FROM NE__Order__c WHERE id =:oi[0].NE__OrderId__c];
        List<Account> listAcc = [SELECT ID,XC_FirstName__c, XC_LastName__c,RecordType.DeveloperName, NAME FROM Account WHERE ID = :listOrde[0].NE__AccountId__c];
        listAcc[0].XC_FirstName__c = 'D1';
        listAcc[0].XC_LastName__c = 'L1';
        listAcc[0].NAME = 'L1D1';
        listAcc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        update listAcc;
        project_cloud__Project__c p = new project_cloud__Project__c(name='Progetto Master Donato',
                project_cloud__Type__c='Provisioning',project_cloud__Units__c= 'Duration',XC_LegalEntity__c= oi[0].XC_LegalEntity__c,XC_Country__c='Italy',
                project_cloud__IsTemplate__c = true);
       // p.XC_LegalEntity__c='EnelXItalia';
        insert p;
        project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c(name='Phase Progetto di Test',
                project_cloud__Project__c=p.id, XC_billing_phase__c =true);
        insert ph;
        List<NE__OrderItem__c> listOrderItems = [select (select id from Projects__r), (select id, XC_Rate__c, name, XC_StartDate__c,XC_EndDate__c,XC_OrderItem__c,XC_IsBilled__c from XC_Milestones__r), XC_BillingModel__c, XC_TotalPriceOneShot__c,XC_RecurringDuration__c,NE__RecurringChargeFrequency__c,XC_TotalPriceRecurring__c, NE__OrderId__r.XC_Segment__c,NE__OrderId__r.NE__Configuration_Type__c, NE__OrderId__r.XC_Compliance_Approval__c, NE__OrderId__c,XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_Country__c, id,NE__OrderId__r.NE__AccountId__r.name,  XC_Country__c, NE__OrderId__r.name, NE__OrderId__r.NE__AccountId__c, Name,NE__Account__c, XC_Project_Template__c, NE__Parent_Order_Item__c, RecordType.DeveloperName,  NE__OrderId__r.id, NE__OrderId__r.XC_Project_Template__c, XC_LegalEntityFormula__c, NE__OneTimeFeeOv__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c,  NE__Account__r.name, NE__OrderId__r.NE__One_Time_Fee_Total__c, XC_PaymentMethod__c FROM NE__orderItem__c WHERE id =:oi[0].id];      
       listOrderItems[0].NE__OrderId__r.XC_Project_Template__c=p.id;
       listOrderItems[0].NE__OrderId__r.XC_LegalEntity__c=oi[0].XC_LegalEntity__c;
        listOrderItems[0].NE__OrderId__r.NE__Type__c='InOrder';    
        update listOrderItems[0].NE__OrderId__r;
        Test.startTest();
        XC_LCC186_CreateProjectPPM.createProject(listOrderItems);
        Test.stopTest();        
    }
}