/**
 * @File Name          : XC_SC026_CheckWoRepairCreateCase.cls
 * @description        : batch giornaliero che quera i WO di Repair con "Verification of Repair Requested" = TRUE e "Date of Verification of 
 *                       Repair Case Creation" = TODAY. Per questi viene creato un case da assegnare al BO per il check della riparazione.
 *
 * @Author             : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Group              : 
 * @Last Modified By   : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Last Modified On   : 15/11/2019, 15:46:48
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    15/11/2019    Andrea Bravaccino          Initial Version
**/
public class XC_SC026_CheckWoRepairCreateCase implements Database.Batchable<sObject> {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC026_CheckWoRepairCreateCase');

    
    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 15/11/2019 
    * @param sc 
    **/
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC026_CheckWoRepairCreateCase());
    }


    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 15/11/2019 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!Schema.sObjectType.Case.isAccessible()) {
            return null;
        }
        String query = 'SELECT Id, XC_Address__c, XC_Urgent_Repair__c, XC_Commitment__c, XC_LegalEntity__c, AccountId, ContactId ' +
                       'FROM WorkOrder ' +
                       'WHERE XC_DateVerificationOfRepairCase__c = TODAY AND XC_VerificationOfRepairRequested__c = TRUE AND XC_WorkTypeCategory__c = \'' + Label.XC_CL_WorkType_Repair + '\'';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'query: ' + query);
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 15/11/2019 
    * @param bc 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bc, List<WorkOrder> scope) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'scope ' + scope); 
        QueueSobject ownerBo = getQueueDispatcher();
        List<Case> casesToInsert = new List<Case>();
        for (WorkOrder wo : scope) {
            casesToInsert.add(getNewCase(wo, ownerBo));
        }

        List<XC_UTIL_Sobject.WrapperResult> wrList = XC_UTIL_Sobject.insertListRecords(casesToInsert);
        createErrorLog(wrList);
    }

    private static void createErrorLog(List<XC_UTIL_Sobject.WrapperResult> listWrapperResult){
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        for(XC_UTIL_Sobject.WrapperResult wr : listWrapperResult){
            if(!wr.success){ 
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC026_CheckWoRepairCreateCase';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Create Case from Repair WO with "Verification of Repair Requested" = TRUE e "Date of Verification of Repair Case Creation" = TODAY.';
                errorLog.add(bel);
            }
        }
		XC_UTIL_Sobject.insertListRecords(errorLog);
    }

    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 15/11/2019 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC026_CheckWoRepairCreateCase');
    }

    private static QueueSobject getQueueDispatcher(){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'QueueSobject: ');
        QueueSobject queueDispatcher;
        List<QueueSobject> queueDispatcherList = new List<QueueSobject>([SELECT queue.id
                                                                        FROM queueSobject WHERE queue.developerName = 'XC_QU_DispatcherQueue' LIMIT 1]);
        if(!queueDispatcherList.isEmpty()) {
            queueDispatcher = queueDispatcherList[0];
        }
        return queueDispatcher;
    }

    private static Case getNewCase(WorkOrder wo, QueueSobject ownerBo){
        XC_CM_Case_Type_Setting__mdt caseMDT = getCaseMDT();

        Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
        c.XC_Address__c = wo.XC_Address__c;
        c.XC_WorkOrder__c = wo.Id;
        c.XC_Urgent__c = wo.XC_Urgent_Repair__c;
        c.XC_WithCommitment__c = wo.XC_Commitment__c;
        c.XC_LegalEntity__c = wo.XC_LegalEntity__c;
        c.AccountId = wo.AccountId;
        c.ContactId = wo.ContactId;
        c.OwnerId = ownerBo.QueueId;
       
        /*
        Case c = new Case();
        c.Reason = 'XCMOT002';
        c.SubCause__c = 'ATCL079';
        c.XC_Subtype__c = 'XC144';
        c.Origin = 'CAN002';*/
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId();
        return c;
    }

    private static XC_CM_Case_Type_Setting__mdt getCaseMDT(){
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{'XC_VerificationRepairCase'});
        XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get('XC_VerificationRepairCase');
        if(caseMDT == null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', 'XC_VerificationRepairCase'}));
        }
        return caseMDT;
    }
}