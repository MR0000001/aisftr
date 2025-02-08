/**
 * @description The Class XC_TR_Case_U_CreateObjectsLinked.
 */
public class XC_TR_Case_U_CreateObjectsLinked {

    /**
     * Check case and create on insert.
     *
     * @author           VBV
     * @param listNew the list new
     * @name           allwaysAfter
     * @description    method wich replaces "Casos Emergencias" node from  process bulder  "ATC Cases Prcess"
     * @email            vbarquero@deloitte.es
     * @lastChange       Marco Rosa, refactor
     */ 

    public static void checkCaseAndCreateOnInsert(List<Case> listNew){ 
        checkCaseAndCreate(listNew, false); 
    }

    /**
     * @description  Check case and create on update. 
     * @param listNew the list new  
     * @param mapOld the map old
     * @param mapNew the map new
     */   
    public static void checkCaseAndCreateOnUpdate(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){ 
        checkCaseAndCreate(listNew, true);
    } 

    /**
     * @description  Check case and create.
     * @param caseList the case list
     * @param isUpdate the is update
     */
    public static void checkCaseAndCreate(List<Case> caseList, Boolean isUpdate){ 
        Set<Id> caseIds = XC_UTIL_SObject.getSetIds(caseList); 
        if(!isUpdate) {
            createWorkOrders(caseList);
        }
        //updateParentCase(caseList, isUpdate);  
        //createTasks(caseList, caseIds); //commentato 20200309 MC -> email Alberto
        System.debug('@@@@ Case List' +caseList);
    }

    /**
     * Creates the work orders.
     *
     * @author           VBV
     * @param caseList the case list
     * @name           createWorkOrders
     * @description    vb - 2. Según motivo y submotivo crearemos difretnes WorkOrder
     *         return         -
     * @email            vbarquero@deloitte.es
     * @lastChange       Federico Amici, [21/01/2019], -Moved the methods from the one-classes-method XC_TR_Case_U_Care_CreateWorkOrders
     *                                                         -Inserted the new method XC_UTIL_SObject.upsertListRecords() instead of the replicated
     *                                                         classes
     */
    public static void createWorkOrders(List<Case> caseList) {
        
        //retrive data from Case metadata settings
        List<String> caseSettingNames = new List<String>{Label.XC_CL_RepairCaseSettingsName, Label.XC_CL_MantenanceCaseSettingsName, Label.XC_CL_QualityCheckIspection};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        System.debug('@@@@@ caseSettingsMap='+caseSettingsMap);
        
        //XC_CM_Case_Type_Setting__mdt repairSettings = caseSettingsMap.get(Label.XC_CL_RepairCaseSettingsName);
        XC_CM_Case_Type_Setting__mdt mantenanceSettings = caseSettingsMap.get(Label.XC_CL_MantenanceCaseSettingsName);
        XC_CM_Case_Type_Setting__mdt qualCheckIspSettings = caseSettingsMap.get(Label.XC_CL_QualityCheckIspection);

        List<WorkOrder> listWoToinsert = new List<WorkOrder>();

        List<String> workTypeName = new List<String>{
            Label.XC_CL_WorkType_QualityCheckInspection,
            Label.XC_CL_WorkType_Repair
        }; 

        Map<String,Id> mapWorkType = XC_UTIL_WorkType.getMapWorkTypeNameId(workTypeName);
        Map<Id,WorkOrder> relatedWO = XC_UTIL_Case.retriveRelatedWO(caseList);
        for(Case newCase : caseList){
            System.debug('XC_TR_Case_Care_Handler, caso ' + newCase);

            /*if(repairSettings==null){
                System.debug( String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_RepairCaseSettingsName}));
                System.debug('@@@@@ XC_TR_Case_Care_Handler - CAN NOT create Work Order for Repair Case!');
                return;
            } else if( (newCase.Reason!=null && newCase.Reason.equals(repairSettings.XC_Case_Reason__c)) &&
                       (newCase.Subcause__c!=null && newCase.Subcause__c.equals(repairSettings.XC_Sub_Cause__c)) &&
                       (repairSettings.XC_Sub_Type__c == null || (newCase.XC_Subtype__c.equals(repairSettings.XC_Sub_Type__c))) &&
                       newCase.AssetId != null ){
                listWoToinsert.add(XC_UTIL_WorkOrder.createWorkOrderRepair(newCase, mapWorkType.get(Label.XC_CL_WorkType_NonUrgentRepair)));
                System.debug('XC_TR_Case_Care_Handler - New WorkOrder Repair');
                continue;
            } */ 
            if(mantenanceSettings==null){
                System.debug( String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_MantenanceCaseSettingsName}));
                return;
            } else if(checkConditionMaintenance(newCase, mantenanceSettings)) {
                List<WorkOrder> workOrders = XC_UTIL_WorkOrder.retriveMaintenanceWOByAsset(newCase.AssetId);
                if(workOrders != null && workOrders.size() > 0){
                    for(WorkOrder wo : workOrders){
                        wo.CaseId =  newCase.Id;
                        listWoToinsert.add(wo);
                    }
                } else {
                    newCase.addError(Label.XC_CL_NoMantenanceServiceMess);
                }
                continue;
            }
            if(qualCheckIspSettings==null){
                System.debug( String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_QualityCheckIspection}));
                System.debug('@@@@@ XC_TR_Case_Care_Handler - CAN NOT create Work Order for Quality Check Ispection Case!');
                return;
            } else if(XC_UTIL_Case.matchSettings(newCase, qualCheckIspSettings)) {
                Id workTypeId = mapWorkType.get(Label.XC_CL_WorkType_QualityCheckInspection);
                WorkOrder wo = XC_UTIL_WorkOrder.initWorkOrderIspection(newCase, workTypeId, relatedWO.get(newCase.XC_WorkOrder__c));
                listWoToinsert.add(wo);
                continue;
            }
        }
        
        XC_UTIL_SObject.upsertListRecords(listWoToinsert); 
    }

    private static Boolean checkConditionMaintenance(Case newCase,  XC_CM_Case_Type_Setting__mdt mantenanceSettings){
        return (newCase.Reason!=null && newCase.Reason.equals(mantenanceSettings.XC_Case_Reason__c)) &&
                      (newCase.Subcause__c!=null && newCase.Subcause__c.equals(mantenanceSettings.XC_Sub_Cause__c)) &&
                      (mantenanceSettings.XC_Sub_Type__c == null || (newCase.XC_Subtype__c.equals(mantenanceSettings.XC_Sub_Type__c))) &&
                      newCase.AssetId != null;
    }

    /**
     * Creates the tasks.
     *
     * @author           VBV
     * @param caseList the case list
     * @param caseIds the case ids
     * @name           updateParentCase
     * @description    vb - 2. Según motivo y submotivo actualizaremos caso Padre
     *     return         -
     * @email            vbarquero@deloitte.es
     * @lastChange       vbarquero , this method will be executed by Trigger
     */
    /*public static void updateParentCase(List<Case> caseList, Boolean isUpdate) {

        Set<Id> caseParentdIsPending = new Set<Id>();
        Set<Id> caseParentdIsInProgress = new Set<Id>();
        
        for(Case newCase : caseList){
            //vb . si el caso padre esta abierto lo pasaremos a a pte cuando el hijo este abierto
            if (!isUpdate && newCase.Status != null && newCase.Status.equals(XC_AT_Constants.TRIGGER_STATUS_ESTA001) && newCase.ParentId!=null) {
                caseParentdIsPending.add(newCase.ParentId);
            }

            //vb . si el caso padre esta pendiente lo pasaremos a en progreso cuando el hijo este cerrado
            if (newCase.Status!=null &&
                (newCase.Status.equals(XC_AT_Constants.TRIGGER_STATUS_ESTA007) || newCase.Status.equals(XC_AT_Constants.TRIGGER_STATUS_ESTA008)) &&
                newCase.ParentId!=null) {
                caseParentdIsInProgress.add(newCase.ParentId);
            }
        }
        //vb métodos asincronos desde trigger
        if(!System.isFuture()){
            try{
                //vb . si el caso padre esta abierto o en progreso, y el caso hijo se inserta pasa a pendiente
                System.debug('XC_TR_Case_Care_Handler, casos padres a pendiente');
                if(!isUpdate) 
                    XC_UTIL_Case.isParentCasePending(caseParentdIsPending);
                
                //vb . si el caso padre esta pendiente lo pasaremos a en progreso cuando el hijo este cerrado
                //vb ,cierre del caso sea automático, es decir que el trigger cierre el caso automáticamente si esas 3 entidades que puede tener relacionadas estén o bien cerradas o bien canceladas.
                System.debug('XC_TR_Case_Care_Handler, casos padres a en progreso o cerrado ');
                XC_AT_Utils.setParentCaseStatus(caseParentdIsInProgress);
                
            } catch(Exception e) {
                System.debug('XC_TR_Case_U_Care_UpdateParentCase updateParentCase error,' +e);
            }
        }
    }*/

    /**
    @name           setActionPlan
    @description    vb - 2. Según motivo y submotivo actualizaremos caso Padre
    return         -
    @author           VBV
    @email            vbarquero@deloitte.es
    @lastChange       vbarquero , this method will be executed by Trigger 
    **/
    /*public static void setActionPlan(List<Case> caseList, Set<Id> assetIds) {

        //vb Actionaplan
        List<String> apTemplatesNames = new List<String>();
        Map<Id, String> caseTemplateMap = new Map<Id, String>(); // Id del caso y name del template
        List<Case> casesToAssingOpWoByCoverage  = new List<Case>();
        //vb Map SAL contains as key AssetId en as value the catalog category Name
        Map<Id, String> catalogCategoryNamesMap = new Map<Id, String>();
        //vb info Catalog category
        catalogCategoryNamesMap = XC_AT_Utils.getCatalogCategoryNamesMap(assetIds);
        
        for(Case newCase : caseList){

            if //Trigger.isInsert && 
                (newCase.Reason!=null && newCase.Subcause__c!=null && newCase.XC_Subtype__c!=null){ 
                /** 
                * vb - Activity Plan. 
                En líneas generales, cuando crees un Caso, se han de asociar al mismo una serie de Tasks en la related list conforme a una lista parametrizada.
                Para la parametrización, hemos creado una custom setting de nombre “ESP Attention Types�?. Ahora mismo están definidos los campos del caso a los que mirar, 
                y hemos de meter campos de Tasks para ver cómo se rellenarían según la tipología del caso.
                El Activity Plan también tiene que crearse al darle al “Save�? en la creación del caso. En este caso, se podrán crear N tasks, 
                tantas como estén parametrizadas según la tipología del caso en la custom setting. Hemos de plantear la posibilidad de que, una vez creado el caso,
                si se cambian las variables de entrada del mismo que afectan a las Tasks que se crean, se recalcule el Plan de Acción en base a los nuevos parámetros, 
                pero de momento tirar con la creación al menos.
                */
                /**
                * vb - Funcionalidad crear WorkOrder u oportunidad segun encuentre cobertura o no según la custom setting XC_CS001_CaseTypologyAndCoverage (Reason, Subcause, SubType)
                        CASUISTICAS:
                        1. Que no ecuentre registro Custom setting de Actiona plan  XC_CS001_ESPAttentionTypes__c
                        2. Que encuentre pero no tenga tarea Video llamada 
                        3. Que la tarea de video llamada pase a Cancelada (Status)
            
                * /
                System.debug('Activity Plan'); 
                XC_CS001_ESPAttentionTypes__c espAttentionType = 
                    XC_CS001_ESPAttentionTypes__c.getInstance(newCase.Reason + '_' + newCase.Subcause__c + '_' + newCase.XC_Subtype__c);

                if (espAttentionType != null) {
                    //XC_CS001_ESPAttentionTypes__c espAttentionType = XC_CS001_ESPAttentionTypes__c.getInstance(newCase.Reason + '_' + newCase.Subcause__c + '_' + newCase.XC_Subtype__c);
                    System.debug('XC_CS001_ESPAttentionTypes__c '+espAttentionType);                                             
                    if (espAttentionType.XC_ActionPlanTemplate__c!=null) {
                        apTemplatesNames.add(espAttentionType.XC_ActionPlanTemplate__c);
                        caseTemplateMap.put(newCase.Id, espAttentionType.XC_ActionPlanTemplate__c);
                    }else{
                        System.debug('XC_ActionPlanTemplate__c sin info ');  
                        // vb - XC_CS001_CaseTypologyAndCoverage Caso 1
                        casesToAssingOpWoByCoverage.add(newCase);
                    } 
                }
                // vb - XC_CS001_CaseTypologyAndCoverage Caso 1
                else {
                    System.debug('XC_CS001_ESPAttentionTypes__c ActionPlantemplate , Falta info del caso o no se encuentra resgistro-');   
                    casesToAssingOpWoByCoverage.add(newCase);
                }
            }
        }
        //vb métodos asincronos desde trigger
        if(!System.isFuture()){
            try{
                //if(Trigger.isInsert){
                /*** vb - Activity Plan. * /
                if(!apTemplatesNames.isEmpty()) {
                    XC_AT_Utils.createActionPlanXCSpain(caseList, caseTemplateMap, apTemplatesNames, catalogCategoryNamesMap);
                }
                /*** vb - XC_CS001_CaseTypologyAndCoverage caso 1 * /
                if(!casesToAssingOpWoByCoverage.isEmpty()) {
                    XC_TR_Case_U_Care.createOpWoByCScoverage(casesToAssingOpWoByCoverage, catalogCategoryNamesMap);
                }
                //} 
                
            }catch(Exception e){
                System.debug('XC_TR_Case_U_Care_UpdateParentCase updateParentCase error,' +e);
            }
        }
    }*/

    /**
    @name           createTasks
    @description    vb - creacion de tareas
    return         -
    @author           VBV
    @email            vbarquero@deloitte.es
    @lastChange       vbarquero , this method will be executed by Trigger 
    @param  caseList
    @param caseIds
    **/
    /*public static void createTasks(List<Case> caseList, Set<Id> caseIds) {

        Map<Id,Case> workOrderCaseMap = new Map<Id,Case>();
        try{
            workOrderCaseMap = XC_TR_Case_U_Care.getWorkOrderByCaseIds(caseIds);
            System.debug('XC_TR_Case_U_CreateObjectsLinked.createTasks');
            XC_TR_Case_U_Care.createTasksFromCases(workOrderCaseMap);
            
        }catch(Exception e){
            System.debug('XC_TR_Case_U_Care_UpdateParentCase updateParentCase error,' +e);
        }
    }*/

	/**
	 * @author Dario Tramontin dtramontin@deloitte.it
	 * @date Creation 03/09/2019
	 * @date Modification dd/mm/yyyy
	 * @description Create case closure disconnect 
	 * @param listNew list of case

	 */
    public static void createCaseDisconnect(List<Case> caseList){
        System.debug('## createCaseDisconnect ##');

        List<Case> newListcases = new List<Case>();
        List<String> caseSettingNames = new List<String>{Label.XC_CL_Disconnect_BadSale, Label.XC_CL_Disconnect_Not_BadSale};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        for(Case c : caseList){
            checkCaseDisconnect(c, caseSettingsMap, newListcases);
        }
        List<XC_UTIL_Sobject.WrapperResult>  insertCases = XC_UTIL_DML.insertRecords(newListCases);
        System.debug( '@@@@@@@@@@@@@ insertCases = '+insertCases);
    }

    private static void checkCaseDisconnect(Case c, Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap, List<Case> newListcases ){
        //si potrebbe usare XC_UTIL_Case.matchSettings() al posto del hardcoding di Reason e SubCause se lo avessi nel metadato
        if( c.Reason == 'XCMOT005' && c.SubCause__c == 'ATCL070' && (c.XC_Subtype__c == 'XC069' || c.XC_Subtype__c == 'XC104') && c.XC_CompliantApplicable__c == true ){
            System.debug('BadSale');               
            Case newCase =XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_Disconnect_BadSale) );
            newCase.AccountId=c.AccountId;
            newCase.ContactId= c.ContactId;
            newCase.AssetId = c.AssetId;
            newCase.OwnerId = c.OwnerId;
            newCase.ParentId=c.Id;
            newListcases.add(newCase);
        }

        if( c.Reason == 'XCMOT005' && c.SubCause__c != 'ATCL070'  && c.XC_CompliantApplicable__c == true ){
            System.debug('NoBadSale');
            Case newCase =XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_Disconnect_Not_BadSale)  );
            newCase.AssetId = c.AssetId;
            newCase.AccountId=c.AccountId;
            newCase.ContactId= c.ContactId;
            newCase.OwnerId = c.OwnerId;
            newCase.ParentId=c.Id;
            newListcases.add(newCase);
            
        }
    }

    /**
	 * @author Giuseppe Di Bonito - gdibonito@deloitte.it
	 * @date Creation 17/10/2019
	 * @date Modification dd/mm/yyyy
	 * @description Create customer interaction after owner update on case
	 * @param listNew list of case

	 */
    /********
     * NOTA MC: se deve essere decommentato questo metodo, non chiamarlo direttamente nell'Handler come prima, ma integrarlo nella logica
     * del metodo principale createCustomerInteractionOnCaseUpdate, in modo da evitare l'aggiunta di altre query e DML - [20201125 - mcutillo@deloitte.it]
     ********/
    /*public static void createCustomerInteractionOnCaseUpdateOwner(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        
        List<String> fieldList = new List<String>{'OwnerId'};
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }
        
        Map<Id, Case> caMap = new Map<Id, Case> ([
            SELECT Id, OwnerId, Owner.Name, Owner.Email, XC_LegalEntity__c
            FROM Case 
            WHERE Id in: XC_UTIL_Sobject.getIds(listChanged)
        ]);

        List<XC_Customer_Interaction__c> cis = new List<XC_Customer_Interaction__c>();
        for (Case ca : caMap.values()) {
            XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
            ci.XC_CaseId__c = ca.Id;
            ci.XC_UserId__c = ca.OwnerId;
            ci.XC_Recipient__c = ca.Owner.Name;
            ci.XC_Email__c = ca.Owner.Email;
            ci.XC_Channel__c = 'Email';
            ci.XC_Communication_Type__c = 'Case_Assigned';
            ci.XC_LegalEntity__c = ca.XC_LegalEntity__c;
            cis.add(ci);
        }
        XC_UTIL_Sobject.insertListRecords(cis);
    }*/

    /**
	 * @author Monica Cutillo - mcutillo@deloitte.it
	 * @date Creation 25/11/2020
	 * @date Modification dd/mm/yyyy
	 * @description Create customer interaction after generic update on case
	 * @param listNew list of case
	 */
    public static void createCustomerInteractionOnCaseUpdate(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        List<Case> listSubStatusChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_SubStatus__c'}, mapOld, mapNew);
        XC_UTIL_Sobject.ChangeWrapper chWrapper = new XC_UTIL_Sobject.ChangeWrapper();
        chWrapper.listSObjects = listNew;
        chWrapper.oldMap = mapOld;
        chWrapper.newMap = mapNew;
        chWrapper.fieldList = new List<String>{'XC_CompanyQualificationStatus__c'};
        chWrapper.checkOldValueNull = true; //to consider only changes from null
        List<Case> listcompQStatusChanged = XC_UTIL_Sobject.getListChanged(chWrapper);

        if(!listSubStatusChanged.isEmpty() || !listcompQStatusChanged.isEmpty()) {
            //retrieve ContactData
            List<Case> listChanged = new List<Case>();
            listChanged.addAll(listSubStatusChanged);
            listChanged.addAll(listcompQStatusChanged);
            Map<Id, Case> caMap = new Map<Id, Case> ([
                SELECT Id, ContactId, AccountId, Contact.Name, Contact.Email, Contact.XC_Preferredlanguageofcontact__c, XC_LegalEntity__c, 
                       Origin, XC_SubStatus__c, XC_CompanyQualificationStatus__c, XC_Segment__c
                FROM Case 
                WHERE Id in: XC_UTIL_Sobject.getSetIds(listChanged)
            ]);

            //Customer Interactions Creation
            List<XC_Customer_Interaction__c> cis = new List<XC_Customer_Interaction__c>();
            if(!listSubStatusChanged.isEmpty()){
                cis.addAll(createCustomerInteractionOnCaseUpdateSubstatus(listSubStatusChanged, caMap));
            }
            if(!listcompQStatusChanged.isEmpty()){
                cis.addAll(createCustomerIntOnCaseUpdateCompanyQualStatus(listcompQStatusChanged, caMap));
            }

            //INSERT all CIs
            if(!cis.isEmpty()){
                XC_UTIL_DML.insertRecords(cis);
            }
        }
    }

        /**
         * @author Giuseppe Di Bonito - gdibonito@deloitte.it
         * @date Creation 17/10/2019
         * @date Modification 25/11/2020
         * @description Create customer interaction after substatus update on case
         * @param listNew list of case
         * @param caseMap Cases data
         * @return CIs to insert
         */
        public static List<XC_Customer_Interaction__c> createCustomerInteractionOnCaseUpdateSubstatus(List<Case> listNew, Map<Id, Case> caseMap){
        List<XC_Customer_Interaction__c> cis = new List<XC_Customer_Interaction__c>();
        XC_Customer_Interaction__c ci;
        Case ca;
        for (Case caso : listNew){
            ca = caseMap.get(caso.Id);
            if(ca!= null && ca.Origin=='CAN001' && ca.XC_SubStatus__c=='SUB005'){
                System.debug(ca.Origin);
                System.debug(ca.XC_SubStatus__c);
                ci = new XC_Customer_Interaction__c();
                ci.XC_CaseId__c = ca.Id;
                ci.XC_ContactId__c = ca.ContactId;
                ci.XC_AccountId__c = ca.AccountId;
                ci.XC_Recipient__c = ca.Contact.Name;
                ci.XC_Email__c = ca.Contact.Email;
                ci.XC_Channel__c = (String.isNotBlank(ca.Contact.Email)) ? 'Email' : 'SMS';
                ci.XC_Communication_Type__c = 'Case_Doc_Received';
                ci.XC_LegalEntity__c = ca.XC_LegalEntity__c;
                cis.add(ci);  
            }
        }
        return cis;
    }

    
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @date Creation 25/11/2020
     * @date Modification dd/MM/yyyy
     * @description Create customer interaction after XC_CompanyQualificationStatus__c update on case
     * @param listNew list of case
     * @param caMap Cases data
     * @return CIs to insert
     */
    public static List<XC_Customer_Interaction__c> createCustomerIntOnCaseUpdateCompanyQualStatus(List<Case> listNew, Map<Id, Case> caseMap){
        List<XC_Customer_Interaction__c> cis = new List<XC_Customer_Interaction__c>();
        List<Case> casesForCI = XC_UTIL_Case_D.filterCasesByCaseTypeSettings(listNew, Label.XC_CL_SuperBonus110);
        XC_Customer_Interaction__c ci;
        Case ca;
        for (Case caso : casesForCI) {
            ca = caseMap.get(caso.Id);
            if(ca == null || ca.Contact == null || String.isBlank(ca.Contact.Email) || 
               (ca.XC_CompanyQualificationStatus__c != 'Company to be qualified' && ca.XC_CompanyQualificationStatus__c != 'Qualified company')){
                continue;
            }
            ci = new XC_Customer_Interaction__c();
            ci.XC_CaseId__c = ca.Id;
            ci.XC_ContactId__c = ca.ContactId;
            ci.XC_AccountId__c = ca.AccountId;
            ci.XC_Recipient__c = ca.Contact.Name;
            ci.XC_Email__c = ca.Contact.Email;
            ci.XC_Preferredlanguageofcontact__c = ca.Contact.XC_Preferredlanguageofcontact__c;
            ci.XC_Channel__c = 'Email';
            ci.XC_Communication_Type__c = 'Superbonus_Company';
            ci.XC_LegalEntity__c = ca.XC_LegalEntity__c;
            ci.XC_Segment__c = ca.XC_Segment__c;
            cis.add(ci);
        }
        return cis;
    }

    /**
	 * @author Giuseppe Di Bonito - gdibonito@deloitte.it
	 * @date Creation 18/10/2019
	 * @date Modification dd/mm/yyyy
	 * @description Create customer interaction after status change on case
	 * @param listNew list of case

	 */
    /*public static void createCustomerInteractionOnCaseUpdateStatus(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        System.debug('*CaseUpdateStatus');
        List<String> fieldList = new List<String>{'Status'};
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }
        
        Map<Id, Case> caMap = new Map<Id, Case> ([
            SELECT Id, ContactId, AccountId, Contact.Name, Contact.Email, XC_LegalEntity__c, Origin, XC_Resolution__c, Status
            FROM Case 
            WHERE Id in: XC_UTIL_Sobject.getIds(listChanged)
        ]);

        List<XC_Customer_Interaction__c> cis = new List<XC_Customer_Interaction__c>();
        for (Case ca : caMap.values()) {
            if(ca.Origin=='CAN001' && ca.Status=='ESTA007'){
                XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
                ci.XC_CaseId__c = ca.Id;
                ci.XC_ContactId__c = ca.ContactId;
                ci.XC_AccountId__c = ca.AccountId;
                ci.XC_Recipient__c = ca.Contact.Name;
                ci.XC_Email__c = ca.Contact.Email;
                ci.XC_Channel__c = (String.isNotBlank(ca.Contact.Email)) ? 'Email' : 'SMS';
                ci.XC_Communication_Type__c = 'Case_Closed';
                ci.XC_LegalEntity__c = ca.XC_LegalEntity__c;
                if(ca.XC_Resolution__c == 'R004' || ca.XC_Resolution__c == 'R005'){
                    ci.XC_SurveyId__c = 'S6';
                    ci.XC_CATICase__c = 
                }
                cis.add(ci);  
            }
        }
        XC_UTIL_Sobject.insertListRecords(cis);
    }*/
}