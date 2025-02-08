/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_TR_ZuoraInvItem_U_PPM_FinancialBen {
    public static void createRecordFinancialBenefit(List<Zuora__InvoiceItem__c> listNew){
        Set<Id> invoiceIds = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'Zuora__Subscription__c');
        if(invoiceIds.isEmpty()) {
            return;
        }

        Map<Id,Zuora__Subscription__c> mapSubscription = new Map<Id,Zuora__Subscription__c>();
        mapSubscription = retrieveSubscription(invoiceIds);
        if(mapSubscription.isEmpty()){
            return ;
        }
        System.debug('retrivato la mappa');
        createBenefitRecord(mapSubscription);



    }


    private static Map<Id,Zuora__Subscription__c> retrieveSubscription(Set<Id> invoiceIds){
        Map<Id,Zuora__Subscription__c> mapSubscription = new Map<Id,Zuora__Subscription__c>([
                select id,XC_ProjectTaskId__c,XC_ProjectId__c,
                (select id, Zuora__Charge_Amount2__c,Zuora__Charge_Date__c, Name, XC_SubscriptionNumber__c
                from Zuora__Invoice_Items__r),
                (select id, Zuora__Type__c from Zuora__Subscription_Product_Charges__r)
                from Zuora__Subscription__c where id IN :invoiceIds AND XC_ProjectTaskId__c != Null  AND XC_ProjectTaskId__c != '0'
        ]);

        return mapSubscription;

    }

    private static void createBenefitRecord(Map<Id,Zuora__Subscription__c> mapSubscripion){
        List<project_cloud__Financial_Benefit__c> listRecordFinancialBenefit = new List<project_cloud__Financial_Benefit__c>();
        Map<Id,project_cloud__Project_Task__c> mapProjectTask = new Map<Id,project_cloud__Project_Task__c>();
        mapProjectTask = getRelatedTasks(mapSubscripion);
        for(Zuora__Subscription__c subscription : mapSubscripion.values()){
            for(Zuora__InvoiceItem__c invoiceItems : subscription.Zuora__Invoice_Items__r){
                 project_cloud__Financial_Benefit__c finalcialBenefit = new project_cloud__Financial_Benefit__c();
                 finalcialBenefit.project_cloud__Amount__c = invoiceItems.Zuora__Charge_Amount2__c;
                 finalcialBenefit.project_cloud__Date__c = invoiceItems.Zuora__Charge_Date__c.date();
                 if(mapProjectTask.get(subscription.XC_ProjectTaskId__c).XC_TaskReason__c=='Recurring'){
                     finalcialBenefit.project_cloud__Type__c = 'Planned';
                 }else{
                     finalcialBenefit.project_cloud__Type__c = 'Realized';
                 }
                 finalcialBenefit.XC_ProjectTask__c = subscription.XC_ProjectTaskId__c;
                 finalcialBenefit.project_cloud__Description__c = invoiceItems.name;
                 finalcialBenefit.project_cloud__Project__c = subscription.XC_ProjectId__c;
                 listRecordFinancialBenefit.add(finalcialBenefit);

            }
        }

        insert listRecordFinancialBenefit;

    }

    private static Map<Id,project_cloud__Project_Task__c> getRelatedTasks(Map<Id,Zuora__Subscription__c> mapSubscription){
        Set<String> setIdTask = new Set<String>();
        for(Zuora__Subscription__c sub : mapSubscription.values()){
            if(String.isNotBlank(sub.XC_ProjectTaskId__c)){
            	setIdTask.add(sub.XC_ProjectTaskId__c);
            }
        }
        
        Map<Id,project_cloud__Project_Task__c> mapProjectTask = new Map<Id,project_cloud__Project_Task__c>([select id, XC_TaskReason__c, XC_TaskType__c from project_cloud__Project_Task__c	where ID IN :setIdTask]);
        System.debug('Map Task Project'+ mapProjectTask);
        return mapProjectTask;
    }


}