/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_LCC186_CreateProjectPPM {
    @AuraEnabled
    public static String createProject(List<NE__OrderItem__c> listOrderItems){
        String orderID = listOrderItems[0].NE__OrderId__c;
        //List<NE__OrderItem__c> listOrderItems = quoeryOnOrderItems(orderID);
        System.debug('listOrderItems-->'+listOrderItems);
        List<NE__OrderItem__c> listOrderItemsWithTemplate = new List<NE__OrderItem__c>();
        listOrderItemsWithTemplate = checkTemplateIsFilled(listOrderItems);
        if(listOrderItemsWithTemplate.isEmpty()){
            checkTemplateIsFilledOrder(listOrderItems);
            NE__Order__c order = new NE__Order__c();
            order.Id = orderID;
            order.NE__FulfilmentStatus__c = Label.XC_CL_Order_StatusSent;
            order.NE__OrderStatus__c = Label.XC_CL_Order_StatusSent;
            order.XC_AssetsCreated__c = true;
            update order;
            NE.JS_RemoteMethods.order2asset(order.ID);
            //return 'OK';
           return Label.XC_CL_PPM_PROJECT_CREATE;

        }
        System.debug('listOrderItemsWithTemplate-->'+listOrderItemsWithTemplate);
        Map<Id,Id> mapOrderItemTemplateId = new Map<Id,Id>();
        mapOrderItemTemplateId = getTemplateNameByOrderItem(listOrderItemsWithTemplate);
        System.debug('mapOrderItemTemplateId-->'+mapOrderItemTemplateId);
        Map<Id,project_cloud__Project__c> mapIdOrderItemProjectTemplate = new Map<Id,project_cloud__Project__c>();
        mapIdOrderItemProjectTemplate = getProjectTemplates(mapOrderItemTemplateId);
        System.debug('mapIdOrderItemProjectTemplate-->'+mapIdOrderItemProjectTemplate);
        //XC_UTIL_Configuration.changeOrderStatusSent(orderID,TRUE);

        createProjectFromOrderItem(listOrderItems, listOrderItemsWithTemplate,mapIdOrderItemProjectTemplate);
        if(orderID != null){
            NE__Order__c order = new NE__Order__c();
            order.Id = orderID;
            order.NE__FulfilmentStatus__c = Label.XC_CL_Order_StatusSent;
            order.NE__OrderStatus__c = Label.XC_CL_Order_StatusSent;
            order.XC_AssetsCreated__c = true;
            update order;
            NE.JS_RemoteMethods.order2asset(order.ID);
          //  System.debug('NE.JS_RemoteMethods.order2asset(order.ID);-->'+NE.JS_RemoteMethods.order2asset(order.ID));
        }
        //return 'OK';
        return Label.XC_CL_PPM_PROJECT_CREATE;
    }

    private static List<NE__OrderItem__c> checkTemplateIsFilled(List<NE__OrderItem__c> listOrderItems){
        List<NE__OrderItem__c>  listOrderItemWithTemplate = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c ne :listOrderItems){
            System.debug('ne.XC_Project_Template__c-->'+ne.XC_Project_Template__c);
            if(ne.XC_Project_Template__c!= Null){
            listOrderItemWithTemplate.add(ne);
            }
        }
        return listOrderItemWithTemplate;
    }

    private static Map<Id,id> getTemplateNameByOrderItem(List<NE__OrderItem__c> listOrderItemWithTemplate){
        Map<Id,id> mapOrderItemTemplate = new Map<Id,id>();
        for(NE__OrderItem__c ne :listOrderItemWithTemplate){
            mapOrderItemTemplate.put(ne.id,ne.XC_Project_Template__c);
        }
        return mapOrderItemTemplate;

    }

    private static Map<Id,project_cloud__Project__c> getProjectTemplates(Map<Id,Id> mapOrderItemTemplateId){
        list<project_cloud__Project__c> listTemplate =
                [select Id,OwnerId,Name, project_cloud__Approved_Budget__c, project_cloud__Benefits_Planned__c, project_cloud__Benefits_Realized__c,
                project_cloud__Budget_Status__c, project_cloud__Business_Unit__c, project_cloud__Cloned_From__c,
                project_cloud__Completed_Percent__c, project_cloud__Customer_Collaboration_Group_Id__c,
                project_cloud__Duration_IsWorking__c, project_cloud__Expenses_Actual__c, project_cloud__Expenses_Budgeted__c,
                project_cloud__Functional_Area__c, project_cloud__Health_Image__c, project_cloud__Health_Reason__c,
                project_cloud__Health__c, project_cloud__Hide_Timecard__c, project_cloud__Hours_Block__c,
                project_cloud__Hours_In_Day__c, project_cloud__IsManual_Completed_Date__c, project_cloud__IsOnly_Subscriptions__c,
                project_cloud__IsTemplate__c, project_cloud__IsWorking_Friday__c, project_cloud__IsWorking_Monday__c,
                project_cloud__IsWorking_Saturday__c, project_cloud__IsWorking_Sunday__c, project_cloud__IsWorking_Thursday__c,
                project_cloud__IsWorking_Tuesday__c, project_cloud__IsWorking_Wednesday__c, project_cloud__Late_Ending_Tasks__c,
                project_cloud__Late_Starting_Tasks__c, project_cloud__Location__c, project_cloud__Monthly_Expenses__c,
                project_cloud__Project_Charter__c, project_cloud__Project_Duration__c, project_cloud__Self_Assign__c, project_cloud__Settings__c, project_cloud__Sorting_Hash__c, project_cloud__Status__c, project_cloud__Subscribed__c, project_cloud__Ticket__c, project_cloud__Type__c,
                project_cloud__Units__c, project_cloud__Worked_Hours__c, project_cloud__Duration__c, project_cloud__End__c, project_cloud__Estimated_Hours__c, project_cloud__Late_Task_End__c, project_cloud__Late_Task_Start__c, project_cloud__Phase_Status_Maximum__c, project_cloud__Phase_Status_Minimum__c,
                project_cloud__Start__c, ccpe_ocp__Account__c, ccpe_ocp__Opportunity__c, ccpe_r__Budget_Usage__c, ccpe_r__Budgeted_Labor_Cost__c, ccpe_r__Cost__c, ccpe_r__Rate_Card__c, ccpe_r__Rate__c, ccpe_r__Retainer__c, ccpe_r__Total_Actual_Costs__c, ccpe_r__Total_Budgeted_Costs__c, ccpe_r__Utilization_Category__c, ccpe_ppm__Dates_Changed_Modstamp__c, ccpe_ppm__Investment__c, ccpe_ppm__Portfolio_CCPE_Ignore__c, ccpe_ppm__Program__c, ccpe_ppm__Rollup_Unsubmitted_Expenses__c, XC_Status__c, XC_ConfigurationItem__c, XC_Country__c, XC_LegalEntity__c, project_cloud__Autonomous_End__c, project_cloud__Autonomous_Start__c, project_cloud__Calculated_End__c, project_cloud__Calculated_Start__c,
                project_cloud__Methodology__c, project_cloud__Resourcing_Mode__c, XC_Configuration__c, XC_ExternalProjectView__c
                   from    project_cloud__Project__c  where project_cloud__IsTemplate__c =true  AND Id IN: mapOrderItemTemplateId.values()];


        Map<Id,project_cloud__Project__c> mapIDOrderItemProjectTemplate = new Map<Id,project_cloud__Project__c>();
        for(Id nId : mapOrderItemTemplateId.keySet()){
            for(project_cloud__Project__c ppm :listTemplate){
                if(mapOrderItemTemplateId.get(nId)== ppm.id){
                    mapIDOrderItemProjectTemplate.put(nId,ppm);
                }
            }
        }

        return mapIDOrderItemProjectTemplate;
    }


    private static void createProjectFromOrderItem(List<NE__OrderItem__c> listOrderItems, List <NE__OrderItem__c> listOrderItemsWithTemplate,Map<Id,project_cloud__Project__c> mapIdOrderItemProjectTemplate){
        /*List<project_cloud__Project__c> listProjectCreates = new List<project_cloud__Project__c>();
        XC_SC031_PPM_CreateProject startBatch = new XC_SC031_PPM_CreateProject(mapIdOrderItemProjectTemplate,listOrderItemsWithTemplate,listOrderItems, listOrderItems[0].NE__OrderId__c);
        Id batchId = Database.executeBatch(startBatch);
*/
        List<project_cloud__Project__c> listProjectCreates = new List<project_cloud__Project__c>();
        for(NE__OrderItem__c oi : listOrderItems) {
            XC_SC031_PPM_CreateProject startBatch = new XC_SC031_PPM_CreateProject(mapIdOrderItemProjectTemplate, listOrderItemsWithTemplate, new List<NE__OrderItem__c>{oi}, listOrderItems[0].NE__OrderId__c);
            System.enqueueJob(startBatch);
        }

    }

    private static void checkTemplateIsFilledOrder(List<NE__OrderItem__c> listOrderItems){
        if(listOrderItems[0].NE__OrderId__r.XC_Project_Template__c!=Null){
            list<project_cloud__Project__c> listTemplate =
            [select Id,OwnerId,Name,project_cloud__Approved_Budget__c, project_cloud__Benefits_Planned__c, project_cloud__Benefits_Realized__c,
                    project_cloud__Budget_Status__c, project_cloud__Business_Unit__c, project_cloud__Cloned_From__c,
                    project_cloud__Completed_Percent__c, project_cloud__Customer_Collaboration_Group_Id__c,
                    project_cloud__Duration_IsWorking__c, project_cloud__Expenses_Actual__c, project_cloud__Expenses_Budgeted__c,
                    project_cloud__Functional_Area__c, project_cloud__Health_Image__c, project_cloud__Health_Reason__c,
                    project_cloud__Health__c, project_cloud__Hide_Timecard__c, project_cloud__Hours_Block__c,
                    project_cloud__Hours_In_Day__c, project_cloud__IsManual_Completed_Date__c, project_cloud__IsOnly_Subscriptions__c,
                    project_cloud__IsTemplate__c, project_cloud__IsWorking_Friday__c, project_cloud__IsWorking_Monday__c,
                    project_cloud__IsWorking_Saturday__c, project_cloud__IsWorking_Sunday__c, project_cloud__IsWorking_Thursday__c,
                    project_cloud__IsWorking_Tuesday__c, project_cloud__IsWorking_Wednesday__c, project_cloud__Late_Ending_Tasks__c,
                    project_cloud__Late_Starting_Tasks__c, project_cloud__Location__c, project_cloud__Monthly_Expenses__c,
                    project_cloud__Project_Charter__c, project_cloud__Project_Duration__c, project_cloud__Self_Assign__c, project_cloud__Settings__c, project_cloud__Sorting_Hash__c, project_cloud__Status__c, project_cloud__Subscribed__c, project_cloud__Ticket__c, project_cloud__Type__c,
                    project_cloud__Units__c, project_cloud__Worked_Hours__c, project_cloud__Duration__c, project_cloud__End__c, project_cloud__Estimated_Hours__c, project_cloud__Late_Task_End__c, project_cloud__Late_Task_Start__c, project_cloud__Phase_Status_Maximum__c, project_cloud__Phase_Status_Minimum__c,
                    project_cloud__Start__c, ccpe_ocp__Account__c, ccpe_ocp__Opportunity__c, ccpe_r__Budget_Usage__c, ccpe_r__Budgeted_Labor_Cost__c, ccpe_r__Cost__c, ccpe_r__Rate_Card__c, ccpe_r__Rate__c, ccpe_r__Retainer__c, ccpe_r__Total_Actual_Costs__c, ccpe_r__Total_Budgeted_Costs__c, ccpe_r__Utilization_Category__c, ccpe_ppm__Dates_Changed_Modstamp__c, ccpe_ppm__Investment__c, ccpe_ppm__Portfolio_CCPE_Ignore__c, ccpe_ppm__Program__c, ccpe_ppm__Rollup_Unsubmitted_Expenses__c, XC_Status__c, XC_ConfigurationItem__c, XC_Country__c, XC_LegalEntity__c, project_cloud__Autonomous_End__c, project_cloud__Autonomous_Start__c, project_cloud__Calculated_End__c, project_cloud__Calculated_Start__c,
                    project_cloud__Methodology__c, project_cloud__Resourcing_Mode__c, XC_Configuration__c, XC_ExternalProjectView__c
            from    project_cloud__Project__c where project_cloud__IsTemplate__c =true  AND Id =: listOrderItems[0].NE__OrderId__r.XC_Project_Template__c];

            listTemplate[0].ccpe_ocp__Account__c =listOrderItems[0].NE__OrderId__r.NE__AccountId__c;
            listTemplate[0].XC_Status__c= 'Assigned';
            listTemplate[0].ccpe_ocp__Opportunity__c = listOrderItems[0].NE__OrderId__r.NE__OptyId__c;
            listTemplate[0].XC_Configuration__c = listOrderItems[0].NE__OrderId__c;
            listTemplate[0].XC_Segment__c = listOrderItems[0].NE__OrderId__r.XC_Segment__c;
            listTemplate[0].XC_Country__c = listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_Country__c;
            listTemplate[0].XC_LegalEntity__c = listOrderItems[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
            listTemplate[0].name = listOrderItems[0].NE__OrderId__r.NE__AccountId__r.name +'_'+ listOrderItems[0].NE__OrderId__r.name;
            project_cloud__Project__c pp =  project_cloud.CloneHelper.cloneProject(listTemplate[0], Date.today());
            List<project_cloud__Project__c>listProjectCreates = new List<project_cloud__Project__c>();
            listProjectCreates.add(pp);
            Map<Id,project_cloud__Project_Phase__c> mapIdOrderPhaes = new Map<Id,project_cloud__Project_Phase__c>();
            mapIdOrderPhaes = getPhasesFromOrder(listOrderItems);
            if(!mapIdOrderPhaes.isEmpty()) {
                createTaskBillingFromOrder(listOrderItems, listProjectCreates, mapIdOrderPhaes);
            }
        }

    }




    private static void createTaskBillingFromOrder(List<NE__OrderItem__c> listOrderItems, List<project_cloud__Project__c>listProjectCreates,Map<Id,project_cloud__Project_Phase__c> mapIDConfItemPhases){
        List<NE__OrderItem__c> listMileStoneByItem = new List<NE__OrderItem__c>();
        List<project_cloud__Project_Task__c> listTaskToInsert = new List<project_cloud__Project_Task__c>();
        List<XC_Milestone__c> listMilestoneRelatedOrder = new List<XC_Milestone__c>();
        Map<Id,Double> mapIdParentTotalPrice = new Map<Id,Double>();
        mapIdParentTotalPrice = totalPriceItemsChild(listOrderItems);
        for(NE__OrderItem__c ne : listOrderItems) {
            if(ne.RecordType.DeveloperName != 'Technical_Item' && ne.NE__Parent_Order_Item__c == Null) {
                System.debug('ID Conf-->' + ne.id);
                System.debug('Billing Model-->' + ne.XC_BillingModel__c);
                if (ne.XC_BillingModel__c == 'Milestone') {
                    for (XC_Milestone__c m : ne.XC_Milestones__r) {
                        System.debug('Milestone--> ' + m);
                        project_cloud__Project_Task__c t = new project_cloud__Project_Task__c();
                        t.XC_TaskReason__c = 'Milestone';
                        t.XC_TaskStatus__c = m.XC_IsBilled__c ? 'Closed' : 'New';
                        t.project_cloud__Completed_Date__c = m.XC_IsBilled__c ? Date.today() : null;
                        t.Name = 'Milestone: ' + m.name;
                        t.XC_MilestonePercentage__c = m.XC_Rate__c;
                        t.XC_Milestone__c = m.id;
                        if(mapIDConfItemPhases.get(ne.NE__OrderId__c).project_cloud__Project__r.project_cloud__Units__c == 'Duration'){
                            t.project_cloud__Duration__c = 1;
                        }
                        else{
                            t.project_cloud__Estimated_Hours__c = 1;
                        }
                        t.XC_OrderItem__c = ne.id;
                        t.XC_AmountToBill__c = mapIdParentTotalPrice.get(ne.id)== Null ? ne.NE__OneTimeFeeOv__c / 100 * m.XC_Rate__c : mapIdParentTotalPrice.get(ne.id) / 100 * m.XC_Rate__c;
                        t.XC_TaskType__c = 'Billing Payment';
                        t.project_cloud__Autonomous_Start__c = m.XC_StartDate__c;
                        t.project_cloud__Project_Phase__c = mapIDConfItemPhases.get(ne.NE__OrderId__c).id;
                        listTaskToInsert.add(t);
                    }
                }
                if (ne.XC_BillingModel__c != 'Milestone' && ne.XC_BillingModel__c != 'Capex' && ne.NE__Parent_Order_Item__c == Null) {
                    project_cloud__Project_Task__c t = new project_cloud__Project_Task__c();
                    t.XC_TaskReason__c = ne.XC_BillingModel__c;
                    t.XC_TaskStatus__c = 'New';
                    if(mapIDConfItemPhases.get(ne.NE__OrderId__c).project_cloud__Project__r.project_cloud__Units__c == 'Duration'){
                        t.project_cloud__Duration__c = 1;
                    }
                    else{
                        t.project_cloud__Estimated_Hours__c = 1;
                    }
                    t.XC_TaskType__c = 'Billing Payment';
                    t.project_cloud__Autonomous_Start__c = Date.today();
                    t.Name = 'Task-' + ne.XC_BillingModel__c;
                    t.XC_RecurringPeriod__c = XC_UTIL_CreateZQuotePPM.getRecurringPeriodTranscodingMapToZuora().get(ne.NE__RecurringChargeFrequency__c) ;
                    t.XC_RecurringDuration__c = ne.XC_RecurringDuration__c;
                    t.XC_AmountToBill__c = ne.XC_TotalPriceRecurring__c;
                    t.XC_OrderItem__c = ne.id;
                    t.project_cloud__Project_Phase__c = mapIDConfItemPhases.get(ne.NE__OrderId__c).id;
                    listTaskToInsert.add(t);
                }
            }

        }
        System.debug('Lista di task--> '+ listTaskToInsert);
        Insert listTaskToInsert;
    }

    private static Map<Id,project_cloud__Project_Phase__c> getPhasesFromOrder(List<NE__OrderItem__c> listOrderItems){
        List<project_cloud__Project_Phase__c> listphases = new List<project_cloud__Project_Phase__c>();
        Map<Id,project_cloud__Project_Phase__c> mapIDConfItemPhases = new Map<Id,project_cloud__Project_Phase__c>();
        if(Schema.sObjectType.project_cloud__Project_Phase__c.isAccessible()) {
            listphases = [select id, Name, project_cloud__Project__r.XC_Configuration__c,project_cloud__Project__r.project_cloud__Units__c from project_cloud__Project_Phase__c where project_cloud__Project__r.XC_Configuration__c = :listOrderItems[0].NE__OrderId__c AND XC_billing_phase__c = True];
        }
        for(project_cloud__Project_Phase__c p : listphases){
            mapIDConfItemPhases.put(p.project_cloud__Project__r.XC_Configuration__c,p);
        }

        System.debug('Lista fase --> ' + listphases);

        return mapIDConfItemPhases;
    }

    private static Map<Id,Double> totalPriceItemsChild(List<NE__OrderItem__c> listOrderItems){
        Map<Id,Double> mapIdTotalPrice = new Map<Id,Double>();
        Double totalPrice = 0;
        for(NE__OrderItem__c ne : listOrderItems){
            if(ne.NE__Parent_Order_Item__c==Null){
                totalPrice =  ne.NE__OneTimeFeeOv__c!= null ? ne.NE__OneTimeFeeOv__c : 0;
                for(NE__OrderItem__c neChild :listOrderItems){
                    if(neChild.NE__Parent_Order_Item__c == ne.Id /*|| neChild.NE__Parent_Order_Item__c == Null*/){
                        totalPrice = totalPrice+neChild.NE__OneTimeFeeOv__c;
                        System.debug('Total Price'+ totalPrice);
                        mapIdTotalPrice.put(ne.id,totalPrice);
                    }
                }
            }
        }
        return mapIdTotalPrice;
    }

}