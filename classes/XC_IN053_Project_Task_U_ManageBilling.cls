/**
* @author dpalamides
* @date 21/05/2020
* @description: classes.XC_TR_PPM_Project_Task_U_ManageBilling this class manages zuora integration for billing tasks
*/

public without sharing class XC_IN053_Project_Task_U_ManageBilling {
    
    public class InputWrapper {

        /** The String. */
        @Invocablevariable
        public String taskId;

        /** The Boolean. */
        @Invocablevariable
        public Boolean generateInvoice;

        /** The Boolean. */
        @Invocablevariable
        public Boolean separateInvoice;

        /** The Boolean. */
        @Invocablevariable
        public Decimal initialTerm;

        /** The Boolean. */
        @Invocablevariable
        public Boolean autoRenew;
    }

    /**
     * @author dpalamides - dpalamides@deloitte.it
     * @description createZquote manages the creation of the zquote
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod
    public static void createZquote(List<InputWrapper> inputWrapperList) {
        List<String> allTaskId = new List<String>();
        for(InputWrapper iw : inputWrapperList){
            allTaskId.add(iw.taskId);
        }
        Map<Id, project_cloud__Project_Task__c> projectTaskNewMap = new Map<Id, project_cloud__Project_Task__c>(
                (List<project_cloud__Project_Task__c>)   XC_UTIL_Sobject.selectAllFields(allTaskId, 'project_cloud__Project_Task__c')
        );

        Map<Id, XC_UTIL_CreateZQuotePPM.MilestoneWrapper> wrMap = startBillingProcess(projectTaskNewMap, false);
        for (InputWrapper iw : inputWrapperList) {
            XC_UTIL_CreateZQuotePPM.MilestoneWrapper ew = wrMap.get(iw.taskId);
            if(ew!=null) {
                ew.generateInvoice = iw.generateInvoice;
                ew.separateInvoice = iw.separateInvoice;
                ew.autoRenew = iw.autoRenew;
                ew.initialTerm = iw.initialTerm;
            }
        }

        XC_UTIL_CreateZQuotePPM.createZquote(wrMap.values());
    }

    /**
     * @description startBillingProcess - Creates ZQuotes for WIP Billing Tasks
     * @author dpalamides - dpalamides@deloitte.it
     * @param projectTaskNewMap - Map<Id, project_cloud__Project_Task__c>
     * @param fromTrigger - Boolean: set this parameter to true when invoking the method from a trigger handler
     * @return List<XC_UTIL_CreateZQuotePPM.MilestoneWrapper> null if the method is called from trigger handler, otherwise the map will contain wrappers indexed by ProjTaskId
     */
    public static Map<Id, XC_UTIL_CreateZQuotePPM.MilestoneWrapper> startBillingProcess(Map<Id, project_cloud__Project_Task__c> projectTaskNewMap, Boolean fromTrigger) {
        Boolean isEmptyInput = projectTaskNewMap == null || projectTaskNewMap.isEmpty();
        if (isEmptyInput) {
            return new Map<Id, XC_UTIL_CreateZQuotePPM.MilestoneWrapper>();
        }

        Map<Id, project_cloud__Project_Task__c> tasksToBill = new Map<Id, project_cloud__Project_Task__c>();
        Map<Id, project_cloud__Project_Task__c> milestoneTasks = new Map<Id, project_cloud__Project_Task__c>();
        //List<XC_IN018_CreateZQuote.ExternalWrapper> in018WrapperList = new List<XC_IN018_CreateZQuote.ExternalWrapper>();

        for (Id theTaskId : projectTaskNewMap.keySet()) {
            project_cloud__Project_Task__c theTask = projectTaskNewMap.get(theTaskId);

            Boolean toBill = theTask != null
                            //&& theTask.XC_TaskReason__c == Constants.PPM_PROJECT_TASK_REASON_MILESTONE
                            && theTask.XC_TaskType__c == Constants.PPM_PROJECT_TASK_TYPE_BILLING;
            if (toBill) {
                if(theTask.XC_TaskReason__c == Constants.PPM_PROJECT_TASK_REASON_MILESTONE){
                    milestoneTasks.put(theTaskId, theTask);
                }
                tasksToBill.put(theTaskId, theTask);
            }
        }

        Map<Id, NE__OrderItem__c> orderItemsByMilestones = getOrderItemsByMilestones(tasksToBill);
        Map<Id, XC_Milestone__c> milestonesByTask = getMilestonesByTask(milestoneTasks);

        Boolean emptyBill = orderItemsByMilestones == null || milestonesByTask == null || orderItemsByMilestones.isEmpty();
        if(emptyBill){
            return new Map<Id, XC_UTIL_CreateZQuotePPM.MilestoneWrapper>();
        }
        List<XC_UTIL_CreateZQuotePPM.MilestoneWrapper> wrList = new List<XC_UTIL_CreateZQuotePPM.MilestoneWrapper>();

        String orderId = null;
        for (project_cloud__Project_Task__c theTask : tasksToBill.values()) {
            XC_Milestone__c mile = milestonesByTask.get(theTask.Id);
            //NE__OrderItem__c ordItem = orderItemsByMilestones.get(mile.Id);
            NE__OrderItem__c ordItem = orderItemsByMilestones.get(theTask.XC_OrderItem__c);

            XC_UTIL_CreateZQuotePPM.MilestoneWrapper ew = new XC_UTIL_CreateZQuotePPM.MilestoneWrapper();
            ew.generateInvoice = true;
            ew.separateInvoice = false;
            ew.autoRenew = false;
            ew.initialTerm = 1;
            ew.configurationItemId = ordItem.Id;
            ew.item = ordItem;
            ew.milestone = mile;
            ew.task = theTask;

            orderId = ordItem.NE__OrderId__c;
            wrList.add(ew);

        }

        String generateResult = B2WExtCat.WS_WorkOrders.generateWorkOrders(orderId);
        XC_UTIL_IntegrationLog.insertGenerateWorkOrderLog(generateResult, orderId, 'GenerateWorkOrder-XC_IN053_Project_Task_U_ManageBilling');

        if (fromTrigger) {
            XC_UTIL_CreateZQuotePPM.createZquote(wrList);
            return null;
        } else {
            Map<Id, XC_UTIL_CreateZQuotePPM.MilestoneWrapper> wrMap = new Map<Id, XC_UTIL_CreateZQuotePPM.MilestoneWrapper>();

            for (XC_UTIL_CreateZQuotePPM.MilestoneWrapper ew : wrList) {
                wrMap.put(ew.task.Id,ew);
            }
            return wrMap;
        }
    }


    /**
     * @description getOrderItemsByMilestones - queries the configuration items related to the milestone billing tasks
     * @author dpalamides - dpalamides@deloitte.it
     * @param milestoneTasks - Map<Id, project_cloud__Project_Task__c>
     * @return Map<Id,NE__OrderItem__c>  order item indexed by milestoneId
     */
    private static Map<Id, NE__OrderItem__c> getOrderItemsByMilestones(Map<Id, project_cloud__Project_Task__c> milestoneTasks) {
        if (!Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            return null;
        }
        Map<Id,XC_Milestone__c> milestoneIdsMap = new Map<Id,XC_Milestone__c>([
                select id, XC_OrderItem__c from XC_Milestone__c where id in :XC_UTIL_Sobject.getListFieldValues(milestoneTasks.values(), 'XC_Milestone__c')
        ]);

        List<String> ordItemIds   = XC_UTIL_Sobject.getListFieldValues(milestoneTasks.values(), 'XC_OrderItem__c');
        ordItemIds.addAll(XC_UTIL_Sobject.getListFieldValues(milestoneIdsMap.values(), 'XC_OrderItem__c'));

        Map<Id, NE__OrderItem__c> ordItemMap = new Map<Id, NE__OrderItem__c>(
        [
                select id, NE__OrderId__c, XC_BillingModel__c, (select id, XC_Rate__c,XC_StartDate__c,XC_EndDate__c,XC_OrderItem__c from XC_Milestones__r)
                From NE__OrderItem__c
                where id in :ordItemIds //(select XC_OrderItem__c from XC_Milestone__c where id in :milestoneIds)
        ]
        );
        System.debug('ordItemMap-'+ordItemMap);
        Map<Id, NE__OrderItem__c> retMap = new Map<Id, NE__OrderItem__c>();

        for (NE__OrderItem__c oi : ordItemMap.values()) {
            for (XC_Milestone__c m : oi.XC_Milestones__r) {
                retMap.put(m.Id, oi);
            }
        }

        System.debug('retMap-'+retMap);
        return ordItemMap;//retMap;

    }


    /**
     * @description getMilestonesByTask - queries the milestones related to the  billing tasks
     * @author dpalamides - dpalamides@deloitte.it
     * @param milestoneTasks - Map<Id, project_cloud__Project_Task__c>
     * @return Map<Id,XC_Milestone__c>  milestones indexed by taskId
     */
    private static Map<Id, XC_Milestone__c> getMilestonesByTask(Map<Id, project_cloud__Project_Task__c> milestoneTasks) {
        if (!Schema.sObjectType.XC_Milestone__c.isAccessible()) {
            return null;
        }
        List<String> milestoneIds = XC_UTIL_Sobject.getListFieldValues(milestoneTasks.values(), 'XC_Milestone__c');
        Map<Id, XC_Milestone__c> milestoneMap = new Map<Id, XC_Milestone__c>(
        [
                select id,XC_Rate__c,XC_StartDate__c,XC_EndDate__c,XC_OrderItem__c
                From XC_Milestone__c
                where id in :milestoneIds
        ]
        );
        System.debug('milestoneMap-'+milestoneMap);
        Map<Id, XC_Milestone__c> retMap = new Map<Id, XC_Milestone__c>();

        for (project_cloud__Project_Task__c tsk : milestoneTasks.values()) {
            retMap.put(tsk.id, milestoneMap.get(tsk.XC_Milestone__c));
        }
        System.debug('retMap1-'+retMap);
        return retMap;

    }
}