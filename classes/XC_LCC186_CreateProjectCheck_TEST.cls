/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
@Istest
public with sharing class XC_LCC186_CreateProjectCheck_TEST {
    static testMethod void createProjectTestProjectOnCofiguration(){
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        insert oi;
        List<NE__OrderItem__c> listOrderItems = [select (select id from Projects__r), (select id, XC_Rate__c, name, XC_StartDate__c,XC_EndDate__c,XC_OrderItem__c from XC_Milestones__r), XC_BillingModel__c, XC_TotalPriceOneShot__c,XC_RecurringDuration__c,NE__RecurringChargeFrequency__c,XC_TotalPriceRecurring__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.XC_Compliance_Approval__c, NE__OrderId__c,XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_Country__c, id,NE__OrderId__r.NE__AccountId__r.name, XC_Country__c, NE__OrderId__r.name, NE__OrderId__r.NE__AccountId__c, Name,NE__Account__c, XC_Project_Template__c, NE__Parent_Order_Item__c, RecordType.DeveloperName,  NE__OrderId__r.id, NE__OrderId__r.XC_Project_Template__c, XC_LegalEntityFormula__c, NE__OneTimeFeeOv__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c,  NE__Account__r.name, NE__OrderId__r.NE__One_Time_Fee_Total__c, XC_PaymentMethod__c FROM NE__orderItem__c WHERE id =:oi[0].id];
        List<Account> listAcc = [SELECT ID, NAME,XC_FirstName__c,XC_LastName__c FROM Account WHERE ID = :listOrderItems[0].NE__OrderId__r.NE__AccountId__c];
        listAcc[0].XC_FirstName__c = 'D';
        listAcc[0].XC_LastName__c = 'L';
        update listAcc;
        project_cloud__Project__c p = new project_cloud__Project__c(name='Progetto Master Donato',
                project_cloud__Type__c='Provisioning',project_cloud__Units__c= 'Duration',XC_LegalEntity__c= 'EnelXItalia',XC_Country__c='Italy',
                project_cloud__IsTemplate__c = true);
        insert p;

        project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c(name='Phase Progetto di Test',
                project_cloud__Project__c=p.id, XC_billing_phase__c =true);
        insert ph;
        //listOrderItems[0].XC_Project_Template__c=p.id;
        listOrderItems[0].NE__OneTimeFeeOv__c = 50;
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw = XC_LCC186_CreateProjectCheckProvIsOk.checkProvvisioning(listOrderItems[0].NE__OrderId__c);
        NE__Order__c ord = new NE__Order__c(id=listOrderItems[0].NE__OrderId__c,XC_Project_Template__c=p.id, XC_LegalEntity__c = 'EnelXItalia');
        update ord;
        //update listOrderItems;
        rw = XC_LCC186_CreateProjectCheckProvIsOk.checkProvvisioning(listOrderItems[0].NE__OrderId__c);
        
        update listOrderItems;
        Boolean check = false;
       //  check = XC_LCC186_CreateProjectCheckProvIsOk.checkProjectIsLinkedToOpportunity(listOrderItems);


    }

}