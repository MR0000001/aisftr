/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public class XC_SC031_PPM_CreateProject implements Queueable , Database.AllowsCallouts {//Database.Batchable<sObject>,Database.Stateful{
    public Map<Id,project_cloud__Project__c> mapIdOrderItemProjectTemplate;
    public List <NE__OrderItem__c> listOrderItemsWithTemplate;
    public List<NE__OrderItem__c> listOrderItems;
    public string OrderId;


    public XC_SC031_PPM_CreateProject(Map<Id,project_cloud__Project__c> mapIdOrderItemProjectTemplate,List <NE__OrderItem__c> listOrderItemsWithTemplate,List<NE__OrderItem__c> listOrderItems,String OrderId){
        this.mapIdOrderItemProjectTemplate = mapIdOrderItemProjectTemplate;
        this.listOrderItemsWithTemplate=listOrderItemsWithTemplate;
        this.listOrderItems= listOrderItems;
        this.OrderId= OrderId;
        XC_UTIL_Debug.debug(false,'mapIdOrderItemProjectTemplate  '+mapIdOrderItemProjectTemplate);
        XC_UTIL_Debug.debug(false,'listOrderItemsWithTemplate  '+listOrderItemsWithTemplate);
        XC_UTIL_Debug.debug(false,'listOrderItems  '+listOrderItems);
    }




    /**
     * @description execute method
     * @param sc - SchedulableContext
    */
    /*  public void execute(SchedulableContext sc) {
          //Id batchId = Database.executeBatch(new XC_SC031_PPM_CreateProject());
      }*/

    /**
     * @description start method
     * @param bc - BatchableContext
     * @return Database.QueryLocator
    */
    /*public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'select (select id from Projects__r), (select id, XC_Rate__c, name, XC_StartDate__c,XC_EndDate__c,XC_OrderItem__c from XC_Milestones__r), XC_BillingModel__c, XC_TotalPriceOneShot__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__c,XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_Country__c, id,NE__OrderId__r.NE__AccountId__r.name, XC_Country__c, NE__OrderId__r.name, NE__OrderId__r.NE__AccountId__c, Name,NE__Account__c, XC_Project_Template__c,  NE__OrderId__r.id, NE__OrderId__r.XC_Project_Template__c, XC_LegalEntityFormula__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c,  NE__Account__r.name    ' +
                //'from NE__OrderItem__c where NE__OrderId__c =\'' + OrderId  + '\'';
                'from NE__OrderItem__c where Id =\'' + listOrderItems[0].Id  + '\'';

        return Database.getQueryLocator(query);
    }*/

    /**
     * @description execute method
     * @param bc - BatchableContext
     * @param scope - list to execute logic on
    */
    public void execute(QueueableContext context) {
        Set<project_cloud.CloneHelper.Option> options = new Set<project_cloud.CloneHelper.Option>{
                project_cloud.CloneHelper.Option.CloneTickets,
                project_cloud.CloneHelper.Option.CloneCases,
                project_cloud.CloneHelper.Option.CloneSubscriptions,
                project_cloud.CloneHelper.Option.CloneExpenses,
                project_cloud.CloneHelper.Option.CloneSkills,
                project_cloud.CloneHelper.Option.IsBatch
        };

        Set<Id> setProjectId = new Set<Id>();
        String mockLegalEntity ='';
        String mock2LegalEntity ='';
        String mock3LegalEntity ='';
        String mock4LegalEntity ='';
        for(NE__OrderItem__c ne :listOrderItems){
            if(mapIdOrderItemProjectTemplate.get(ne.id)!= Null) {
                mapIdOrderItemProjectTemplate.get(ne.id).ccpe_ocp__Account__c = ne.NE__Account__c;
                mapIdOrderItemProjectTemplate.get(ne.id).XC_Status__c = 'Assigned';
                mapIdOrderItemProjectTemplate.get(ne.id).ccpe_ocp__Opportunity__c = ne.NE__OrderId__r.NE__OptyId__c;
                mapIdOrderItemProjectTemplate.get(ne.id).XC_Country__c = ne.NE__OrderId__r.NE__OptyId__r.XC_Country__c;
                mapIdOrderItemProjectTemplate.get(ne.id).XC_LegalEntity__c = ne.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
                mapIdOrderItemProjectTemplate.get(ne.id).XC_ConfigurationItem__c = ne.id;
                mapIdOrderItemProjectTemplate.get(ne.id).XC_Configuration__c = ne.NE__OrderId__c;
                mapIdOrderItemProjectTemplate.get(ne.id).XC_Segment__c = ne.NE__OrderId__r.XC_Segment__c;
                mapIdOrderItemProjectTemplate.get(ne.id).name = ne.NE__Account__r.name + '_' + ne.name;
                //mapIdOrderItemProjectTemplate.get(ne.id).ccpe_ocp__Account__c='ciao';
                project_cloud__Project__c pp = project_cloud.CloneHelper.cloneProject(mapIdOrderItemProjectTemplate.get(ne.id), Date.today(), options);
                setProjectId.add(pp.id);
            }

        }

        List<project_cloud__Project_Phase__c> listphases = new List<project_cloud__Project_Phase__c>();
        Map<Id,project_cloud__Project_Phase__c> mapIDConfItemPhases = new Map<Id,project_cloud__Project_Phase__c>();
        Map<Id,project_cloud__Project_Phase__c> mapIDConfigurationPhases = new Map<Id,project_cloud__Project_Phase__c>();
        System.debug('Order ID-->'+ listOrderItems[0].NE__OrderId__c);
        if(Schema.sObjectType.project_cloud__Project_Phase__c.isAccessible()) {
            listphases = [select id, Name, project_cloud__Project__r.XC_Configuration__c, project_cloud__Project__r.XC_ConfigurationItem__c, project_cloud__Project__r.project_cloud__Units__c from project_cloud__Project_Phase__c where project_cloud__Project__c = :setProjectId AND XC_billing_phase__c = True];
        }
        if(listphases.isEmpty()){
            return ;
        }

        for(project_cloud__Project_Phase__c p : listphases){
            mapIDConfItemPhases.put(p.project_cloud__Project__r.XC_ConfigurationItem__c,p);
        }
        for(project_cloud__Project_Phase__c p : listphases){
            mapIDConfigurationPhases.put(p.project_cloud__Project__r.XC_Configuration__c,p);
        }

        System.debug('Lista fase --> ' + listphases);
        List<NE__OrderItem__c> listMileStoneByItem = new List<NE__OrderItem__c>();
        List<project_cloud__Project_Task__c> listTaskToInsert = new List<project_cloud__Project_Task__c>();
        List<XC_Milestone__c> listMilestoneRelatedOrder = new List<XC_Milestone__c>();
        Map<Id,Double> mapIdParentTotalPrice = new Map<Id,Double>();
        mapIdParentTotalPrice = totalPriceItemsChild(listOrderItems);

        for(NE__OrderItem__c ne : listOrderItems) {
            if(ne.XC_Project_Template__c != Null) {
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
                            t.Name = 'Milstone: ' + m.name;
                            t.XC_MilestonePercentage__c = m.XC_Rate__c;
                            t.XC_Milestone__c = m.id;
                            project_cloud__Project_Phase__c projecPhase=mapIDConfItemPhases.get(ne.NE__OrderId__c);
                            if(projecPhase==null){
                                projecPhase=mapIDConfItemPhases.get(ne.id);
                            }  
                            if(projecPhase.project_cloud__Project__r.project_cloud__Units__c == 'Duration'){
                                 t.project_cloud__Duration__c = 1;
                            }
                            else{
                                t.project_cloud__Estimated_Hours__c = 1;
                            }
                            System.debug('Amount To Bill--> ' + ne.NE__OrderId__r.NE__One_Time_Fee_Total__c);
                            t.XC_AmountToBill__c = mapIdParentTotalPrice.get(ne.id)==Null ? ne.NE__OneTimeFeeOv__c / 100 * m.XC_Rate__c : mapIdParentTotalPrice.get(ne.id) / 100 * m.XC_Rate__c;
                            t.XC_TaskType__c = 'Billing Payment';
                            t.XC_OrderItem__c = ne.id;
                            t.project_cloud__Autonomous_Start__c = m.XC_StartDate__c;
                            if (mapIDConfItemPhases.get(ne.id) != Null) {
                                t.project_cloud__Project_Phase__c = mapIDConfItemPhases.get(ne.id).id;
                            } else {
                                t.project_cloud__Project_Phase__c = mapIDConfigurationPhases.get(ne.NE__OrderId__c).id;
                            }


                            listTaskToInsert.add(t);
                        }
                    }
                    if (ne.XC_BillingModel__c != 'Milestone' && ne.XC_BillingModel__c != 'Capex' && ne.NE__Parent_Order_Item__c == null) {
                        project_cloud__Project_Task__c t = new project_cloud__Project_Task__c();
                        t.XC_TaskReason__c = ne.XC_BillingModel__c;
                        t.XC_TaskStatus__c = 'New';
                        if(mapIDConfItemPhases.get(ne.id).project_cloud__Project__r.project_cloud__Units__c == 'Duration'){
                            t.project_cloud__Duration__c = 1;
                        }
                        else{
                            t.project_cloud__Estimated_Hours__c = 1;
                        }
                        t.XC_TaskType__c = 'Billing Payment';
                        t.project_cloud__Autonomous_Start__c = Date.today();
                        t.Name = 'Task-' + ne.XC_BillingModel__c;
                        t.XC_RecurringPeriod__c = XC_UTIL_CreateZQuotePPM.getRecurringPeriodTranscodingMapToZuora().get(ne.NE__RecurringChargeFrequency__c);
                        t.XC_RecurringDuration__c = ne.XC_RecurringDuration__c;
                        //t.XC_AmountToBill__c = ne.XC_TotalPriceRecurring__c;
                        t.XC_AmountToBill__c = ne.XC_TotalPriceRecurring__c;
                        t.XC_OrderItem__c = ne.id;
                        t.project_cloud__Project_Phase__c = mapIDConfigurationPhases.get(ne.NE__OrderId__c).id;
                        listTaskToInsert.add(t);

                    }
                }
            }

        }
        System.debug('Lista di task--> '+ listTaskToInsert);
        Insert listTaskToInsert;
    }

    /**
     * @description finish method
     * @param bc - BatchableContext
    */
    public void finish(Database.batchablecontext bc) {
        System.debug('Finish');



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
                        mapIdTotalPrice.put(ne.id,totalPrice);
                    }
                }
            }
        }
        return mapIdTotalPrice;
    }


}