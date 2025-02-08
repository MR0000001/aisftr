/**
 * @author           AJJL
 * @version          V0.1
 * @className        XC_TR_Case_U_Care
 * @description      Class with general methods to ENEL X application
 * @email            ajimenez@deloitte.es
 * @testClass        pte
 * @dateCreated      2019/01/10
 */

public without sharing class XC_TR_Case_U_Care {

    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_Care');

    //public XC_TR_Case_U_Care() {}
    
    /**
     * @author           AJJL
     * @param workOrderCaseMap the work order case map
     * @name             createTasksFromCases
     * @description      Crear una tarea por cada caso de tipo reclamo
     * @params           workOrderCaseMap
     * @email            ajimenez@deloitte.es
     * @lastChange       Federico Amici, [21/01/2019], Substituted the insert method with the XC_UTIL_SObject.insertListRecords()
     */
    public static void createTasksFromCases(Map<Id,Case> workOrderCaseMap){
        if(!Schema.sObjectType.WorkOrder.isAccessible()){
            return;
        }
        Map<Id,WorkOrder> workorderListMap = new Map<Id,WorkOrder>([SELECT Id, OwnerId FROM WorkOrder WHERE Id IN: workOrderCaseMap.keySet()]);
        List<WorkOrder> workorderList = workorderListMap.values();
        List<Task> taskList = new List<Task>();
        for(WorkOrder wo : workorderList){
            /* Se il WO è assegnato ad una coda NON creo il Task (ESCEP-427) MCutillo 04/02/2019 */
            if(XC_UTIL_Sobject.getObjectType(wo.OwnerId) != 'User'){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Task non created for WO assigned to Group - woId='+wo.Id);
                continue;
            }
            Case caso = workOrderCaseMap.get(wo.Id);
            //Change MC 25/06/2019
            /*Id recordTypeId = 
                Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA).getRecordTypeId();*/
            Id mngmRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId();
                        
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'createTasksFromCases, caso ' + caso);
            //Change MC 25/06/2019
            /*if(caso.RecordTypeId == recordTypeId && (caso.XC_WorkOrder__c != null / *|| caso.XC_Opportunity__c != null || caso.ParentId != null* /) && 
                caso.Reason != null && 
                caso.Reason == XC_AT_Constants.TRIGGER_REASON_MOT005 / *&& caso.Type == && caso.SubCause__c == * /){*/
            if( caso.RecordTypeId == mngmRT && caso.XC_WorkOrder__c != null && caso.Reason != null ){
                //String taskRT = XC_AT_Constants.TASK_RECORD_TYPE_XC_ATTENTION_ESPANA;
                Task task = new Task();
                if(caso.XC_WorkOrder__c != null){
                    task.WhatId = caso.XC_WorkOrder__c;
                }
                //else if(caso.XC_Opportunity__c != null) tarea.WhatId = caso.XC_Opportunity__c;
                //else if(caso.ParentId != null) tarea.WhatId = caso.ParentId;
                //task.RelatedCase__c = caso.Id;
                task.OwnerId = wo.OwnerId;
                task.Subject = Label.XC_CL_WOReclamationMessage;
                //task.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('XC_Task_Spain').getRecordTypeId();
                //set reminder
                task.IsReminderSet = true;
                task.ReminderDateTime = System.now();
                task.ActivityDate = Date.today();
                taskList.add(task);
            }
        }
        XC_UTIL_SObject.insertListRecords(taskList);  
    }

    /**
     * @author           AJJL
     * @param casoIds    the caso ids
     * @name             existCaseRelatedAccount
     * @description      conseguir mapa de workorder por el caso Id buscando por el campo XC_WorkOrder__c
     * @params           casoIds
     * @email            ajimenez@deloitte.es
     * @return           Map<Id,Case>
     */
    public static Map<Id,Case> getWorkOrderByCaseIds(Set<Id> casoIds){
        if(!Schema.sObjectType.Case.isAccessible()){
            return new Map<Id, Case>();
        }
        List<Case> caseList = [SELECT  Id, XC_WorkOrder__c,Reason,RecordTypeId,OwnerId FROM Case WHERE Id IN: casoIds];
        Map<Id,Case> workOrderCaseMap = new Map<Id,Case>();
        for(Case c : caseList){
            workOrderCaseMap.put(c.XC_WorkOrder__c,c);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getWorkOrderByCaseIds , workOrderCaseMap ' + workOrderCaseMap);
        return workOrderCaseMap;
    }

    /**
     * @author Monica Cutillo monica.cutillo@nttdata.com
     * @param casoIds the caso ids
     * @return the work order in provisioning by case ids
     * @date 25/01/2019
     * @description Returns, from the imput, Cases associated with WO in provisioning
     * (i.e. of type Delivery, Installation or Delivery & Installation)
     */  
    public static Map<Id,Case> getWorkOrderInProvisioningByCaseIds(Set<Id> casoIds){
        List<String> workTypes = new List<String> {Label.XC_CL_WorkType_Delivery, Label.XC_CL_WorkType_Installation, Label.XC_CL_WorkType_DeliveryInstallation};
        Map<Id,Case> workOrderCaseMap = getWorkOrderByCaseIds(casoIds);
        Map<Id,Case> results = new Map<Id,Case>();

        if(!Schema.sObjectType.WorkOrder.isAccessible()){
            return new Map<Id, Case>();
        }
        Map<Id,WorkOrder> workorderListMap = new Map<Id,WorkOrder>([SELECT Id 
                                              FROM WorkOrder
                                              WHERE Id IN: workOrderCaseMap.keySet()
                                              AND XC_WorkTypeCategory__c  IN: workTypes ]);
       List<WorkOrder> workOrdersFiltered = workorderListMap.values();
        
        for(WorkOrder wo : workOrdersFiltered){
            results.put(wo.Id, workOrderCaseMap.get(wo.Id));
        }

        return results;
    }

   
    /**
    * @author           VBV
    * @param            newCaseList the new case list
    * @param            catalogCategoryNamesMap the catalog category names map
    * @name             createOpWoByCScoverage
    * @description      Funcionalidad crear WorkOrder u oportunidad segun encuentre cobertura o no según la custom setting XC_CS001_CaseTypologyAndCoverage
    * @email            vbarquero@deloitte.es
    /*
    * MCutillo - REVIEW CODE ESCEP-431 - INIZIO
    /*public static void createOpWoByCScoverage(List<Case> newCaseList, Map<Id, String>  catalogCategoryNamesMap){
        List<WorkOrder> listWoToinsert = new List<WorkOrder>();
        List<Opportunity> listOpToinsert = new List<Opportunity>();

        if(newCaseList!=null && !newCaseList.isEmpty()){
            for (Case newCase : newCaseList) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_CS001_CaseTypologyAndCoverage  instance '+ newCase.Reason + '_' + newCase.Subcause__c + '_' + newCase.XC_Subtype__c);
                if (newCase.Reason!=null && newCase.Subcause__c!=null && newCase.XC_Subtype__c!=null &&
                    XC_CS001_CaseTypologyAndCoverage__c.getInstance(newCase.Reason + '_' + newCase.Subcause__c + '_' + newCase.XC_Subtype__c)!=null) 
                {
                    XC_CS001_CaseTypologyAndCoverage__c coverageCS = XC_CS001_CaseTypologyAndCoverage__c.getInstance(newCase.Reason + '_' + newCase.Subcause__c + '_' + newCase.XC_Subtype__c);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_CS001_CaseTypologyAndCoverage  '+coverageCS);                                             
                    

                    if (coverageCS.XC_Coverage__c!=null) {
                        // vb 1. coverage tendra el name de la cobertura (Asset) y tendra que tenedner la direccion del caso 
                        // 2. el asset del caso tiene que tener enganchado el asset coverage de la custom setting 
                        // 3. si no se cumplen 1 y 2 pero check esta a true la creo igualemente 
                        // 4. sino se cumplen Opprotunity
                        String catalogName;
                        if(newCase.AssetId!=null && catalogCategoryNamesMap!=null) catalogName = catalogCategoryNamesMap.get(newCase.AssetId);
                        if((catalogName!=null && coverageCS.XC_Coverage__c.equals(catalogName)) ||
                            coverageCS.XC_CompleteCoverage__c) {
                            XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_CS001_CaseTypologyAndCoverage  con covegare, creamos WorkOrder'); 
                            listWoToinsert.add(XC_AT_Utils.getNewWorkOrderRepair(newCase));    
                        }else{
                            XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_CS001_CaseTypologyAndCoverage  sin matches con Asset, creamos Oppotunity'); 
                            Opportunity opCoverageXC = new Opportunity();
                            if(newCase.CaseNumber!=null) opCoverageXC.CaseNumber__c = newCase.CaseNumber;
                            listOpToinsert.add(opCoverageXC);  
                        }
                    }else{
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_CS001_CaseTypologyAndCoverage  sin covegare, creamos Oppotunity'); 
                        Opportunity opCoverageXC = new Opportunity();
                        if(newCase.CaseNumber!=null) opCoverageXC.CaseNumber__c = newCase.CaseNumber;
                        listOpToinsert.add(opCoverageXC);  
                    } 
                }else XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_CS001_CaseTypologyAndCoverage , Falta info del caso o no se encuentra resgistro custom setting');  
            }
        }

        //vb actualizacion objectos
        XC_UTIL_SObject.upsertListRecords(listWoToinsert);
        XC_UTIL_SObject.upsertListRecords(listOpToinsert);
    }
    * MCutillo - REVIEW CODE ESCEP-431 - FINE
    */

    /**
     * @author           AJJL
     * @param            caso the caso
     * @name             addOriginUser
     * @description      Metodo para añadir el origen al caso
     * @params 
     * @email            ajimenez@deloitte.es
     */
    public static void addOriginCase(Case caso){
        if(!Schema.sObjectType.User.isAccessible()){
            return;
        }
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id,Origin__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1]);
        List<User> user = userMap.values();

        if(caso != null && caso.Origin != null) {
            if(user!=null && !user.isEmpty()) {
                caso.Origin = user.get(0).Origin__c;
            }
        }
    }
}