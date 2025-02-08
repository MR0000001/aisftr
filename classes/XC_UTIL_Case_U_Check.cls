/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 18/04/2019
* @date Modification 31/10/2019 
* @description XC_UTIL_Case_U_Check – Util class XC_UTIL_Case for check method
*/

public without sharing class XC_UTIL_Case_U_Check {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Case');

    /** @description Wrapper for check Case */
    public class CheckCaseWrapper {
        public String owner;
        public Map<id,List<WorkOrder>> caseToWorkOrder = new Map<id,List<WorkOrder>>();
        public Map<id,List<NE__Order__c>> caseToConf = new Map<id,List<NE__Order__c>>();
        public Map<id,List<Opportunity>> caseToOpp = new Map<id,List<Opportunity>>();
        public Map<id,List<Case>> caseToCase = new Map<id,List<Case>>();
        public Boolean closeWO = false;
        public Boolean closeConf = false;
        public Boolean closeO = false;
        public Boolean closeC = false;
        public Boolean foundedOpen = false;
        public Boolean foundedNotOwnerENotCompleted = false;
        public String caseId;
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Method to get Case RecordTypeId By Country.
     * @param listCountries
     * @return Map<String, Id>
    **/
    public static Map<String, Id> getRecordTypeByCountry(List<String> listCountries){ 
        Map<String, String> mapCountryRecordTypeName = new Map<String, String>{
            'SPAIN' => 'XC_ESP_Case',
            'Spain' => 'XC_ESP_Case',
            'UNITED KINGDOM' => 'XC_ESP_Case',
            'United Kingdom' => 'XC_ESP_Case'
        }; 
        return XC_UTIL_SObject.getRecordTypeMapByCountry('Case', listCountries, mapCountryRecordTypeName);
    }  

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Check if the Case in input is a Complian Case, consulting the CaseMapping metadata
     * @param caso - Case
     * @return Boolean
     */
    public static Boolean isComplianCase(Case caso){
        List<String> caseSettingNames = new List<String>{Label.XC_CL_ComplianCaseSettingsName};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_ComplianCaseSettingsName);
        return (caso.Reason == caseSettings.XC_Case_Reason__c &&
                caso.SubCause__c == caseSettings.XC_Sub_Cause__c &&
                caso.XC_Subtype__c == caseSettings.XC_Sub_Type__c &&
                caso.Status == caseSettings.XC_Status__c &&
                caso.Priority == caseSettings.XC_Priority__c);
    } 

    /**
    * @description Check from WorkOrder
    * @param caseWrapper - CheckCaseWrapper
    **/
    public static void checkFromWorkOrder(CheckCaseWrapper caseWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### XC_UTIL_Case_U_Check - checkFromWO ### caseWrapper = '+caseWrapper);
        for(WorkOrder wo : caseWrapper.caseToWorkOrder.get(caseWrapper.caseId)){
            //cr vdb 01-06-2022 In Progress
            if(!wo.Status.equals('In Progress') && !wo.Status.equals(Label.XC_CL_WorkOrder_Canceled) && !wo.Status.equals(Label.XC_CL_WorkOrder_Completed) && !wo.Status.equals(Label.XC_CL_CannotComplete) ){
                System.debug('foudnOpen true');
                caseWrapper.foundedOpen = true;
                return;
                /*
                if(wo.OwnerId != caseWrapper.owner){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'TROVATO WORKORDER NON MIO');
                    caseWrapper.foundedNotOwnerENotCompleted = true;
                }
                */
            }
            if(!wo.Status.equals(Label.XC_CL_WorkOrder_Canceled) && !wo.Status.equals(Label.XC_CL_CannotComplete) ){
                System.debug('closeWO true');
                caseWrapper.closeWO = true;
            }
        }
    }

    /**
    * @description Check from Conf
    * @param caseWrapper - CheckCaseWrapper
    **/
    public static void checkFromConf(CheckCaseWrapper caseWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### XC_UTIL_Case_U_Check - checkFromConf ### caseWrapper = '+caseWrapper);
        for(NE__Order__c conf : caseWrapper.caseToConf.get(caseWrapper.caseId)){
             //cr 763 vdb 01-06-2022 In Progress
            if(!conf.XC_Status__c.equals('In Progress') && !conf.XC_Status__c.equals(Label.XC_CL_Configuration_Closed) && !conf.XC_Status__c.equals(Label.XC_CL_Configuration_Cancelled)){
                caseWrapper.foundedOpen = true;
                return;
                /*if(t.OwnerId != caseWrapper.owner){
                    caseWrapper.foundedNotOwnerENotCompleted = true;
                }*/
            }
            if(conf.XC_Status__c.equals(Label.XC_CL_Configuration_Closed) ){
                caseWrapper.closeConf = true;
            }
        }
    }


    /**
    * @description Check from Opp
    * @param caseWrapper - CheckCaseWrapper
    **/
    public static void checkFromOpp(CheckCaseWrapper caseWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### XC_UTIL_Case_U_Check - checkFromOpp ### caseWrapper = '+caseWrapper);
        for(Opportunity opp : caseWrapper.caseToOpp.get(caseWrapper.caseId)){
            //cr 763 vdb 01-06-2022 Signed Contract
            if(!opp.StageName.equals('Signed Contract') && !opp.StageName.equals(Label.XC_CL_Opportunity_ClosedLost ) && !opp.StageName.equals(Label.XC_CL_Opportunity_ClosedWon)){
                caseWrapper.foundedOpen = true;
                return;
                /*if(t.OwnerId != caseWrapper.owner){
                    caseWrapper.foundedNotOwnerENotCompleted = true;
                }*/
            }
            if(opp.StageName.equals(Label.XC_CL_Opportunity_ClosedWon) ){
                caseWrapper.closeO = true;
            }
        }
    }


    /**
    * @description Check from Case
    * @param caseWrapper - CheckCaseWrapper
    **/
    public static void checkFromCase(CheckCaseWrapper caseWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### XC_UTIL_Case_U_Check - checkFromCase ### caseWrapper = '+caseWrapper);
        for(Case cs : caseWrapper.caseToCase.get(caseWrapper.caseId)){
            //cr 763 vdb 01-06-2022 In Progress
            if(!cs.Status.equals('In Progress') && !cs.Status.equals(Label.XC_CL_Case_Status007) && !cs.Status.equals(Label.XC_CL_Case_Status008)){
                caseWrapper.foundedOpen = true;
                return;
                /*if(cs.OwnerId != caseWrapper.owner) {
                    caseWrapper.foundedNotOwnerENotCompleted = true;
                }*/
            }
            if(!cs.Status.equals(Label.XC_CL_Case_Status008)){
                caseWrapper.closeC = true;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### result caseWrapper.closeC = '+caseWrapper.closeC);
    }

    /**
    * @description Check if is Parent
    * @param caseIds - Set<Id>
    **/
    public static Map<Id,XC_UTIL_Case_U.UpdateCaseWrapper> isParentCasePending(Set<Id> caseIds) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in isParentCasePending con ids = '+caseIds);
        if(caseIds.isEmpty()){
            return null;
        }
        Set<Id> caseSkeep= checkSkeepChildrenClosure(caseIds);
        List<Case> parentCaseList = new List<Case>();
        if(!caseSkeep.isEmpty()){
        	parentCaseList = XC_UTIL_Case.getRelatedParentCasesByCaseIds(caseSkeep);
        }
        Map<Id,XC_UTIL_Case_U.UpdateCaseWrapper> caseToCheck = new Map<Id,XC_UTIL_Case_U.UpdateCaseWrapper>();
        Map<id,Case> idToCase = new Map<id,Case>([
            SELECT id, OwnerId,XC_NeedInternalCheck__c, 
            (SELECT id, OwnerId, Status FROM WorkOrders),
            (SELECT id, OwnerId, XC_Status__c FROM Configurations__r), 
            (SELECT id, OwnerId, StageName FROM Opportunities__r),
            (SELECT id, OwnerId, Status,XC_NeedInternalCheck__c FROM Cases) 
            FROM Case 
            where id IN: caseIds]);
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'idToCase = '+idToCase);
        
        Map<id,List<WorkOrder>> caseToWorkorder = new Map<id,List<WorkOrder>>();
        Map<id,List<NE__Order__c>> caseToConf= new Map<id,List<NE__Order__c>>();
        Map<id,List<Opportunity>> caseToOpp = new Map<id,List<Opportunity>>();
        Map<id,List<Case>> caseToCase = new Map<id,List<Case>>();
        
        for(id i : idToCase.keySet()){
            caseToWorkorder.put(i,idToCase.get(i).WorkOrders);
            caseToConf.put(i,idToCase.get(i).Configurations__r);
            caseToOpp.put(i,idToCase.get(i).Opportunities__r);
            caseToCase.put(i,idToCase.get(i).Cases);
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'WorkOrderList = '+caseToWorkorder);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ConfList = '+caseToConf);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CaseList = '+caseToCase);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'OppList = '+caseToOpp);
        for (Case c : parentCaseList){
            String owner = c.OwnerId;
            //Boolean foundedNotOwnerENotCompleted = false;
            Boolean foundedOpenC = false;
            Boolean foundedOpenConf = false;
            Boolean foundedOpenWO = false;
            Boolean foundedOpenOpp = false;
            Boolean closeWO = false;
            Boolean closeConf = false;
            Boolean closeC = false;
            Boolean closeO = false;
            
            if(checkCaseStatus(c)){                
                // For cyclomatic complexity warning:
                XC_UTIL_Case_U_Check.CheckCaseWrapper caseWrapperWorkOrder = new XC_UTIL_Case_U_Check.CheckCaseWrapper();
                caseWrapperWorkOrder.owner = owner;
                caseWrapperWorkOrder.caseToWorkOrder = caseToWorkorder;
                caseWrapperWorkOrder.caseId = c.Id;
                XC_UTIL_Case_U_Check.checkFromWorkOrder(caseWrapperWorkOrder);
                closeWO = caseWrapperWorkOrder.closeWO;
                foundedOpenWO = caseWrapperWorkOrder.foundedOpen;
                //foundedNotOwnerENotCompleted = caseWrapperWorkOrder.foundedNotOwnerENotCompleted;

                XC_UTIL_Case_U_Check.CheckCaseWrapper caseWrapperConf = new XC_UTIL_Case_U_Check.CheckCaseWrapper();
                caseWrapperConf.owner = owner;
                caseWrapperConf.caseToConf = caseToConf;
                caseWrapperConf.caseId = c.Id;
                XC_UTIL_Case_U_Check.checkFromConf(caseWrapperConf);
                closeConf = caseWrapperConf.closeConf;
                foundedOpenConf = caseWrapperConf.foundedOpen;
                //foundedNotOwnerENotCompleted = caseWrapperConf.foundedNotOwnerENotCompleted;

                XC_UTIL_Case_U_Check.CheckCaseWrapper caseWrapperOpp = new XC_UTIL_Case_U_Check.CheckCaseWrapper();
                caseWrapperOpp.owner = owner;
                caseWrapperOpp.caseToOpp = caseToOpp;
                caseWrapperOpp.caseId = c.Id;
                XC_UTIL_Case_U_Check.checkFromOpp(caseWrapperOpp);
                closeO = caseWrapperOpp.closeO;
                foundedOpenOpp = caseWrapperOpp.foundedOpen;
                //foundedNotOwnerENotCompleted = caseWrapperOpp.foundedNotOwnerENotCompleted;

                XC_UTIL_Case_U_Check.CheckCaseWrapper caseWrapperCase = new XC_UTIL_Case_U_Check.CheckCaseWrapper();
                caseWrapperCase.owner = owner;
                caseWrapperCase.caseToCase = caseToCase;
                caseWrapperCase.caseId = c.Id;
                XC_UTIL_Case_U_Check.checkFromCase(caseWrapperCase);
                closeC = caseWrapperCase.closeC;
                foundedOpenC = caseWrapperCase.foundedOpen;
                //foundedNotOwnerENotCompleted = caseWrapperCase.foundedNotOwnerENotCompleted;
                
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'closeWO ='+closeWO);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'closeConf ='+closeConf);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'closeO ='+closeO);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'closeC ='+closeC);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'foundedOpenC ='+foundedOpenC);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'foundedOpenWO ='+foundedOpenWO);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'foundedOpenOpp ='+foundedOpenOpp);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'foundedOpenConf ='+foundedOpenConf);
                //XC_UTIL_Debug.debug(DEBUGACTIVE, 'foundedNotOwnerENotCompleted'+foundedNotOwnerENotCompleted);

                XC_UTIL_Case_U.UpdateCaseWrapper wrapper = new XC_UTIL_Case_U.UpdateCaseWrapper();
                wrapper.closeWO = closeWO;
                wrapper.closeConf = closeConf;
                wrapper.closeO= closeO;
                wrapper.closeC = closeC;
                wrapper.parentCaseArePending=false;
                wrapper.c = c;
                if(foundedOpenC || foundedOpenWO || foundedOpenConf || foundedOpenOpp){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'There is one or more child still open for Case: '+ c);
                    wrapper.parentCaseArePending=true;
                }
                caseToCheck.put(c.Id,wrapper);
            }
        }
        return caseToCheck; 
    }

    /**
     * @author Dario Tramontin - dtramontin@deloitte.it
     * @description update the parent Case' status
     * @param set of id of the parent cases
     * @return Set<Id>
    **/

    public static void updateParentCaseStatus(Set<Id> caseIds){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in updateParentCaseStatus');
        List<Case> parentCaseListToUpdate = new List<Case>();
        List<Case> caseList = new List<Case>();
        Set<String> reasonSet = new Set<String>();
        Set<String> subcauseSet = new Set<String>();
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule= true;
        Map<Id,XC_UTIL_Case_U.UpdateCaseWrapper> caseMap=XC_UTIL_Case_U_Check.isParentCasePending(caseIds);
        if(caseMap!= null){
            for(String c_id : caseMap.keySet() ){
                if(caseMap.get(c_id) != null && !caseMap.get(c_id).parentCaseArePending && 
                    caseMap.get(c_id).c.XC_NeedInternalCheck__c==false){
                    XC_UTIL_Case_U.populateCaseToUpdate(caseMap.get(c_id) );
                    caseList.add(caseMap.get(c_id).c );
                    reasonSet.add(caseMap.get(c_id).c.Reason);
                    subcauseSet.add(caseMap.get(c_id).c.SubCause__c);
                }else{
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Is not possible to close the case : '+caseMap.get(c_id).c);
                    //caseMap.get(c_id).c.addError(Label.XC_CL_Trigger_Error_IsRelatedObjectOpen);
                }
                
            }

            

            Map<Id, XC_CM_CaseClosureDependencies__mdt> fieldsMap = new Map<Id, XC_CM_CaseClosureDependencies__mdt>(
                    [SELECT XC_Resolution__c, XC_Result__c, XC_CaseRemarks__c, XC_CaseRemarksEnelXItalia__c, XC_ClousureType__c, XC_ReasonCode__c,XC_SubCause__c,XC_Type_Intermediary__c,
					 XC_CaseRemarksCogenio__c,XC_CaseRemarksEnelSole__c,XC_CaseRemarksEnelXMobility__c,	XC_CaseRemarksEnelXMSP__c,XC_CaseRemarksESCoComuniSrl__c,XC_CaseRemarksYouSaveSpA__c
                    FROM XC_CM_CaseClosureDependencies__mdt 
                    WHERE XC_ReasonCode__c IN :reasonSet AND XC_SubCause__c IN :subcauseSet ]);

            XC_TR_Case_U_ClosureManagement.pupulateCaseFields( fieldsMap, caseList);
            for(Case c : caseList){
                if(c.Status==Label.XC_CL_Case_Open){
                    c.setOptions(dmlOpts);
                    parentCaseListToUpdate.add(c);
                }else{
                    parentCaseListToUpdate.add(c);
                }
            }
            
        }
        
        List<XC_UTIL_Sobject.WrapperResult> dmlResult = XC_UTIL_DML.updateRecords(parentCaseListToUpdate); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'updateParentCaseStatus - dmlResult = '+dmlResult);
    }

    public static Set<Id> checkSkeepChildrenClosure(Set<Id> caseIds){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in checkSkeepChildrenClosure');
        List<Case> caseList =[SELECT Id, Reason,Subcause__c,XC_Subtype__c, Status,XC_NeedInternalCheck__c  FROM Case WHERE Id IN :caseIds];
        
        List<String> typeSetting= new List<String>();
        List< XC_CM_Case_Type_Setting__mdt> listTypeSetting = [SELECT DeveloperName,XC_Case_Reason__c,XC_Sub_Cause__c,XC_Sub_Type__c from XC_CM_Case_Type_Setting__mdt WHERE XC_SkeepChildrenClosure__c = true ];
        for(XC_CM_Case_Type_Setting__mdt caseType: listTypeSetting){
            String stringToIns= caseType.XC_Case_Reason__c + caseType.XC_Sub_Cause__c + caseType.XC_Sub_Type__c;
            System.debug('Label:' + stringToIns);
            typeSetting.add(stringToIns);
        }
        
        Set<Id> caseToCheck= new Set<Id>();
        for(Case c : caseList){
            String checkString= c.Reason + c.Subcause__c + c.XC_Subtype__c;
            if(!typeSetting.contains(checkString) ){
                System.debug('checkSkeepChildrenClosure add case: '+ c);
                caseToCheck.add(c.Id);
            }else{
                // if there is a closure and this field are egual, the closure of this case is indipendent by his childs. I don't make any checks on them
                continue;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'exit checkSkeepChilderClosure. caseToCheck: '+ caseToCheck);
        return caseToCheck;
    }

    /**
    * @description Check Case status
    * @param cs - Case
    * @return Boolean
    **/
    private static Boolean checkCaseStatus(Case cs) {
        return (cs.Status!=null && cs.Status!='CNT0009' && cs.Status!=Label.XC_CL_Case_Status007);
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 12/08/2019
    * @description Method to create a list of document needed
    * @param wrapper - AdministrativeCaseWrapper 
    * @return List<String>
    */
    public static List<String> retrieveListNeededDocuments(XC_UTIL_Case_U.AdministrativeCaseWrapper wrapper) {
        List<String> tempSubject = new List<String>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### XC_UTIL_Case_U_Check - mapConfItemComplianceMaster ###  => ' + wrapper.mapConfItemComplianceMaster);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '### XC_UTIL_Case_U_Check - mapConfItemComplianceWrapper ###  => ' + wrapper.mapConfItemComplianceWrapper);        
        for(String ordItemId : wrapper.mapConfItemComplianceWrapper.keySet()){
            if(wrapper.mapConfItemComplianceMaster.containsKey(ordItemId)){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '###  XC_UTIL_Case_U_Check => order item-->' + ordItemId);
                for(String token : wrapper.mapConfItemComplianceMaster.get(ordItemId)) {
                    if(!tempSubject.contains(token)) {
                        tempSubject.add(token);
                    }
                }
            }
        }
        return tempSubject;
    } 

}