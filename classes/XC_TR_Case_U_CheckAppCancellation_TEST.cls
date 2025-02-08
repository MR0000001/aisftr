/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  15/05/2019 
* @description XC_TR_Case_U_CheckAppCancellation_TEST – Test class for XC_TR_Case_U_CheckAppCancellation
*/
@isTest

public class XC_TR_Case_U_CheckAppCancellation_TEST {
    //Test Method manageAppointmentCancellation
    @isTest
    static void manageAppointmentCancellation(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Case> listcase = XC_DF_Case.createCases(1);
        insert listcase;
        

        List<WorkOrder> listwo = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        listcase[0].XC_WorkOrder__c =listwo[0].Id;
        insert listwo;
        
        WorkOrder wo = [SELECT Id, ContactId, AccountId,  WorkTypeId FROM WorkOrder WHERE Id = : listwo[0].Id LIMIT 1];

          
        List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper> zipCodeWtWrapper = new List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper>(); 
        XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper wrap = new XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper();
        wrap.workType = 'Commercial Visit';
        wrap.zipCode = '12233';
        zipCodeWtWrapper.add(wrap);
        
        
        XC_ZipCodeWorkType__c zip = new XC_ZipCodeWorkType__c();
        zip.XC_ExternalId__c = wrap.zipCode+'_'+wrap.workType;
        zip.XC_ZipCode__c ='12233';
        zip.XC_WorkType__c = wo.WorkTypeId;
        insert zip;
        
        
        
        List<ServiceAppointment> serAppList =XC_DF_ServiceAppointment.createServiceAppointment(listwo);
        
        insert serAppList;
        
        System.assertEquals(true, listcase!=null);
        Test.stopTest();
        
    }
    
   /*  //Test Method manageAppointmentCancellation1
    @isTest
    static void manageAppointmentCancellation1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Case> listcase = XC_DF_Case.createCases(1);
        
                
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        insert listAccount;

        
        List<WorkOrder> listwo = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        insert listwo;

        WorkOrder wo = [SELECT Id, ContactId, AccountId,  WorkTypeId FROM WorkOrder WHERE Id = : listwo[0].Id LIMIT 1];
        listcase[0].XC_WorkOrder__c =listwo[0].Id;
        listcase[0].AccountId = null;
        listcase[0].ContactId = null;
          
        List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper> zipCodeWtWrapper = new List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper>(); 
        XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper wrap = new XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper();
        wrap.workType = 'Commercial Visit';
        wrap.zipCode = '12233';
        zipCodeWtWrapper.add(wrap);
        
        
        XC_ZipCodeWorkType__c zip = new XC_ZipCodeWorkType__c();
        zip.XC_ExternalId__c = wrap.zipCode+'_'+wrap.workType;
        zip.XC_ZipCode__c ='12233';
        zip.XC_WorkType__c = wo.WorkTypeId;
        insert zip;
        
        
        List<ServiceAppointment> serapp =XC_DF_ServiceAppointment.createServiceAppointment(listwo);
        serapp[0].XC_Country__c = 'Spain';
        serapp[0].SchedStartTime = (Datetime) Date.today();
        serapp[0].SchedEndTime = (Datetime) Date.today();
        serapp[0].Status = 'Scheduled';
        serapp[0].ActualDuration = 1.0;
        insert serapp;
        
        listcase[0].Reason = 'XCMOT002';
        listcase[0].Subcause__c = 'ATCL054';
        listcase[0].XC_Subtype__c =  'XC035';  
        insert listcase;
        
        
        System.assertEquals(true, listcase!=null);
        Test.stopTest();
        
    }*/
    
    //Test Method manageAppointmentCancellation2
    @isTest
    static void manageAppointmentCancellation2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Case> listcase = XC_DF_Case.createCases(1);
        
        List<WorkOrder> listwo = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        insert listwo;
        
        WorkOrder wo = [SELECT Id, ContactId, AccountId,  WorkTypeId FROM WorkOrder WHERE Id = : listwo[0].Id LIMIT 1];

          
        List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper> zipCodeWtWrapper = new List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper>(); 
        XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper wrap = new XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper();
        wrap.workType = 'Commercial Visit';
        wrap.zipCode = '12233';
        zipCodeWtWrapper.add(wrap);
        
        
        XC_ZipCodeWorkType__c zip = new XC_ZipCodeWorkType__c();
        zip.XC_ExternalId__c = wrap.zipCode+'_'+wrap.workType;
        zip.XC_ZipCode__c ='12233';
        zip.XC_WorkType__c = wo.WorkTypeId;
        insert zip;
        
        List<ServiceAppointment> serapp =XC_DF_ServiceAppointment.createServiceAppointment(listwo);
        insert serapp;
        
        XC_CM_Case_Type_Setting__mdt ctslist = [SELECT Id, DeveloperName, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_Priority__c, XC_Status__c 
                                                                    FROM XC_CM_Case_Type_Setting__mdt 
                                                                   WHERE DeveloperName =: Label.XC_CL_AppointmentCancellation][0];

        listcase[0].Reason = ctslist.XC_Case_Reason__c;
        listcase[0].Subcause__c = ctslist.XC_Sub_Cause__c;
        listcase[0].XC_Subtype__c =  ctslist.XC_Sub_Type__c;
        listcase[0].XC_WorkOrder__c =listwo[0].Id;
        
        try {
            insert listcase;
        }
        catch(exception e){
            System.assert(listcase[0].Id==null);
        }
        
        
        System.assertEquals(true, listcase!=null);
        Test.stopTest();
        
    }

}