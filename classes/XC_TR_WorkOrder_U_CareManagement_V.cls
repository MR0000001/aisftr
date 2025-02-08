/**
* @author Monica Cutillo - mcutillo@deloitte.it
* @date 20/01/2020
* @date Modification MAY 2022 - PERFORMANCE IMPROVEMENT - GDB/FA
* @description XC_TR_WorkOrder_U_CareManagement_V - Class to manage Case created for WorkOrder
**/
public without sharing class XC_TR_WorkOrder_U_CareManagement_V {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_CareManagement');
    
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Care ManagementToScheduleAppointmet
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void careManagementToScheduleAppointmetOnUpdate(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String> {'XC_Configuration__c'};
        List<WorkOrder> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){  
            return;
        }
        careManagementToScheduleAppointmet(listChanged);
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getWOWithOrderParentToScheduleApp
     * @param listNew
     * @return Map<String,List<WorkOrder>> with data to cases creation (keys: 'FromMarket', 'FromCompliance')
     */
    public static void careManagementToScheduleAppointmet(List<WorkOrder> listNew){
        
        //1- filter WO with only Order parent
        List<WorkOrder> woWithOrderParent = new List<WorkOrder>();
        for(WorkOrder wo : listNew){
            if(wo.XC_Configuration__c != null && wo.ParentWorkOrderId == null && wo.XC_WorkTypeLabel__c != Label.XC_CL_WorkType_SiteInspection_CIE && wo.XC_WorkTypeCategory__c != Label.XC_CL_WorkType_PlannedMaintenance){
                woWithOrderParent.add(wo);
            }
        }
        if(woWithOrderParent.isEmpty()){  
            return;
        }
        
        //PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA - START        
        //FS - 20220615 - Fix queuable limits exceeded when starting provisioning from API - START
        if(!System.isQueueable() && !System.isFuture() && !System.isBatch() && !System.isScheduled()){
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                System.enqueueJob(new careManagementToScheduleAppointmetAsync(woWithOrderParent));
            }else{
                careManagementToScheduleAppointmetLogic(woWithOrderParent);
            }   
        }
        //FS - 20220615 - Fix queuable limits exceeded when starting provisioning from API - END
        else{
                careManagementToScheduleAppointmetLogic(woWithOrderParent);
        } 
        //PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA - END
    }
        
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getWOWithOrderParentToScheduleApp
     * @param listNew
     * @return Map<String,List<WorkOrder>> with data to cases creation (keys: 'FromMarket', 'FromCompliance')
     */
    public static void careManagementToScheduleAppointmetLogic(List<WorkOrder> woWithOrderParent){        
        
        //2- retrieve WO to analize
        List<WorkOrder> woData = getDataToCaseScheduleAppointment(woWithOrderParent); //listNew
        if(woData.isEmpty()){  
            return;
        }
        //3- retrieve eventual existing SA cases
        Map<String, XC_CM_Case_Type_Setting__mdt> caseMDT = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CaseToScheduleAppointment});
        if(caseMDT.isEmpty() || caseMDT.get(Label.XC_CL_CaseToScheduleAppointment)==null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CaseToScheduleAppointment}));
        }
        List<Case> existingCases = retrieveExistingSACases(woData, caseMDT.get(Label.XC_CL_CaseToScheduleAppointment));
        Map<Id,NE__OrderItem__c> mapOrderItemAdministrativeSteps = getAdministrativeStep(woData);
        //4- check for Case creations
        Boolean skeepCreatin = false;
        List<Case> caseToInsert = new List<Case>();
        
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
        Case newCaso;
        for(WorkOrder wo : woData){
            skeepCreatin = false;
            //no other SA Cases have to exixt
            for(Case caso : existingCases){
                if(wo.Id == caso.XC_WorkOrder__c && wo.XC_Configuration__c == caso.XC_Order__c
                   && wo.AccountId == caso.AccountId && wo.ContactId == caso.ContactId){
                    skeepCreatin = true;
                    break;
                }
            }
            if(skeepCreatin){
                continue;
            }
            //FIRST: check for order from Market
            if(Label.XC_CL_Order_ChannelValue_Market == wo.XC_Configuration__r.XC_Channel__c){
                newCaso = initNewSACase(wo, caseMDT.get(Label.XC_CL_CaseToScheduleAppointment), Label.XC_CL_CaseOriginCAN003);
                newCaso.setOptions(dmlOpts);
                caseToInsert.add(newCaso);
                continue;
            }
            //SECOND: check for order in provisioning, with compliance
            if(wo.XC_Configuration__r.XC_Compliance_Approval__c == Label.XC_CL_ComplianceVerificationStatus_StatusOK){
                newCaso = initNewSACase(wo, caseMDT.get(Label.XC_CL_CaseToScheduleAppointment), Label.XC_CL_CaseOriginCAN002);
                newCaso.setOptions(dmlOpts);
                caseToInsert.add(newCaso);
                continue;
            }
            //THIRD: Check if an Administrative Step has been completed (Subsidy)
            if(mapOrderItemAdministrativeSteps.get(wo.XC_Configuration_Item__c) != null && !(mapOrderItemAdministrativeSteps.get(wo.XC_Configuration_Item__c).Provisioning_Steps__r).isEmpty()){
                newCaso = initNewSACase(wo, caseMDT.get(Label.XC_CL_CaseToScheduleAppointment), Label.XC_CL_CaseOriginCAN002);
                newCaso.setOptions(dmlOpts);
                caseToInsert.add(newCaso);
                continue;
            }
        }
        
        List<XC_UTIL_Sobject.WrapperResult> insSACaseRW = XC_UTIL_DML.insertRecords(caseToInsert);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getWOWithOrderParentToScheduleApp insertRW=' + insSACaseRW);
        return;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getDataToCaseScheduleAppointment
     * @param listNew
     * @return List<WorkOrder>
     */
    private static List<WorkOrder> getDataToCaseScheduleAppointment(List<WorkOrder> listNew){
        Set<Id> ids = XC_UTIL_Sobject.getSetIds(listNew);
        Map<Id,WorkOrder> data = new Map<Id,WorkOrder>([
            SELECT Id, AccountId, ContactId, ParentWorkOrderId, XC_LegalEntity__c, XC_Country__c, XC_Segment__c,
                   XC_Configuration__c, XC_Configuration__r.XC_Compliance_Approval__c, XC_Configuration__r.XC_Channel__c, XC_Configuration_Item__c
              FROM WorkOrder
             WHERE Id IN: ids
               AND ParentWorkOrderId = NULL 
               AND XC_Configuration__c <> NULL
               AND XC_Configuration__r.NE__Type__c =: Label.XC_CL_Configuration_TypeInOrder
               AND XC_Configuration__r.XC_Status__c =: Label.XC_CL_Configuration_OrderInProvisioning
        ]);
        return data.values();
    }
    
     /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getDataToCaseScheduleAppointment
     * @param listNew
     * @return List<WorkOrder>
     */
    private static  Map<Id,NE__OrderItem__c> getAdministrativeStep(List<WorkOrder> listNew){
        List<String> woOrderItems = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Configuration_Item__c');
        Map<Id,NE__OrderItem__c> mapOrderItemAdministrativeSteps = new Map<Id,NE__OrderItem__c>([
            SELECT Id,
                (SELECT Id
                 FROM Provisioning_Steps__r
                 WHERE XC_Status__c =: Label.XC_CL_Completed_Ok
                 AND XC_StepLabel__c =: 'Administrative Tasks')
            FROM NE__OrderItem__c
            WHERE Id IN: woOrderItems]);
        return mapOrderItemAdministrativeSteps;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description retrieveExistingSACases
     * @param listNew
     * @param caseMDT
     * @return List<Case> query result
     */
    private static List<Case> retrieveExistingSACases(List<WorkOrder> listNew, XC_CM_Case_Type_Setting__mdt caseMDT){
        Set<Id> woIds = XC_UTIL_Sobject.getSetIds(listNew);
        Set<Id> ordIds = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'XC_Configuration__c');
        List<String> originFilter = new List<String>{Label.XC_CL_CaseOriginCAN002,Label.XC_CL_CaseOriginCAN003};
        Map<Id,Case> casesSA = new Map<Id,Case>([
            SELECT Id, XC_WorkOrder__c, XC_Order__c, Status, AccountId, ContactId
              FROM Case
             WHERE XC_WorkOrder__c IN: woIds
                AND XC_Order__c IN: ordIds
                AND Reason =: caseMDT.XC_Case_Reason__c
                AND SubCause__c =: caseMDT.XC_Sub_Cause__c
                AND XC_Subtype__c =: caseMDT.XC_Sub_Type__c
                AND Origin IN: originFilter
        ]);
        return casesSA.values();
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description initNewSACaseFromMarket
     * @param wo
     * @param caseMDT
     * @return an initialized case
     */
    private static Case initNewSACase(WorkOrder wo, XC_CM_Case_Type_Setting__mdt caseMDT, String originVal){
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
        caso.AccountId = wo.AccountId;
        caso.ContactId = wo.ContactId;
        caso.XC_WorkOrder__c = wo.Id;
        caso.XC_Order__c = wo.XC_Configuration__c;
        caso.XC_LegalEntity__c = wo.XC_LegalEntity__c;
        caso.XC_Segment__c = wo.XC_Segment__c;
        caso.Country__c = wo.XC_Country__c;
        
        caso.Origin = originVal;
        return caso;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getOrderInProvisioningToScheduleCreation
     * @param mapOld the map old
     * @param mapNew the map new
     * @return List<NE__Order__c> 
     */
    /*private static List<NE__Order__c> getOrderInProvisioningToScheduleCreation(Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        List<NE__Order__c> result = new List<NE__Order__c>();
        for(NE__Order__c orderNew : mapNew.values()){
            if(orderNew.XC_Status__c == Label.XC_CL_Configuration_OrderInProvisioning //XC_CL_Configuration_OrderInProgress 
               && (mapOld.get(orderNew.Id)).XC_Status__c == Label.XC_CL_Configuration_OrderToBeValidated
               && orderNew.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder
               && orderNew.XC_Compliance_Approval__c == Label.XC_CL_ComplianceVerificationStatus_StatusOK){
                result.add(orderNew);
            }
        }
        return result;
    }*/

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description bookAppointmentCaseCreation
     * @param orders
     */
    /*private static void bookAppointmentCaseCreation(List<NE__Order__c> orders){
        if(orders == null || orders.isEmpty()){
            return;
        }
        Map<String, XC_CM_Case_Type_Setting__mdt> caseMDT = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CaseToScheduleAppointment});
        if(caseMDT.isEmpty() || caseMDT.get(Label.XC_CL_CaseToScheduleAppointment)==null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CaseToScheduleAppointment}));
        }
        Map<Id,NE__Order__c> ordersData = retrieveOrderDataForCases(orders);
        List<Case> caseSAtoInsert = new List<Case>();
        Case caso;
        for(NE__Order__c order : orders){
            caso = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT.get(Label.XC_CL_CaseToScheduleAppointment));
            caso.Origin = Label.XC_CL_CaseOriginCAN002;
            if(ordersData.get(order.Id) != null){
                caso.AccountId = (ordersData.get(order.Id)).NE__OptyId__r.AccountId;
                caso.ContactId = (ordersData.get(order.Id)).NE__OptyId__r.XC_Contact__c;
                caso.XC_WorkOrder__c = (ordersData.get(order.Id)).NE__OptyId__r.XC_WorkOrder__c;
                //caso.XC_LegalEntity__c = wo.XC_LegalEntity__c;
                //caso.XC_Country__c = wo.XC_Country__c;
            }
            caseSAtoInsert.add(caso);
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'bookAppointmentCaseCreation: Cases to insert=' + caseSAtoInsert);
        List<XC_UTIL_Sobject.WrapperResult> caseSAInsertRW = XC_UTIL_DML.insertRecords(caseSAtoInsert);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'caseSAInsertRW=' + caseSAInsertRW);
    }*/

    /**
     * @description retrieveOrderDataForCases
     * @param orders order list to retrieve data
     * @return Map<Id,NE__Order__c> query result
     */
    /*private static Map<Id,NE__Order__c> retrieveOrderDataForCases(List<NE__Order__c> orders){
        Set<Id> ids = XC_UTIL_Sobject.getSetIds(orders);
        return new Map<Id,NE__Order__c>([
            SELECT Id, NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, NE__OptyId__r.XC_WorkOrder__c
              FROM NE__Order__c
              WHERE Id IN: ids
        ]);
    }*/
    
   /**
    * @description INNER QUEABLE CLASS
    * @author PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA 
    * @return Boolean
    */
    public class careManagementToScheduleAppointmetAsync implements Queueable{
        List<WorkOrder> woWithOrderParent;
        public careManagementToScheduleAppointmetAsync(List<WorkOrder> woWithOrderParent){
            this.woWithOrderParent = woWithOrderParent;
        }

        public void execute(QueueableContext context) {
            careManagementToScheduleAppointmetLogic(this.woWithOrderParent);
        }
    }
}