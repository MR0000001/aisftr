/**
 * The Class XC_LCC139_DocumentVerification_U.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 02/08/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC139_DocumentVerification_U – Util for XC_LCP139_DocumentVerification Component
 */
public without sharing class XC_LCC139_DocumentVerification_U {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC139_DocumentVerification_U');
    /**
    * @description
    * @author Del Prete Domenico | 28/8/2019
    * @param listOfOICSalesPartner List<XC_OrderItemCompliance__c> 
    * @param caseMaster Case
    * @return XC_LCC139_DocumentVerification.ResultWrapper
    */
    public static XC_LCC139_DocumentVerification.ResultWrapper salesPartnerQueueKo(List<XC_OrderItemCompliance__c> listOfOICSalesPartner, Case caseMaster){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START salesPartnerQueueKo');
        XC_LCC139_DocumentVerification.ResultWrapper rw = new XC_LCC139_DocumentVerification.ResultWrapper();
        Case subcase = new Case();
        List<XC_OrderItemCompliance__c> listOfKo = new List<XC_OrderItemCompliance__c>();
        for(XC_OrderItemCompliance__c orderItemCompliance : listOfOICSalesPartner){
                if(orderItemCompliance.XC_Status__c.equals(Label.XC_CL_DocumentVerification_Ko_Value)){
                    listOfKo.add(orderItemCompliance);
                } 
            }
            if(!listOfKo.isEmpty()){ 
                subcase.Subject = Label.XC_CL_DocumentVerification_SubjectName_For_Sales;
                subcase.ParentId = caseMaster.id;
                subcase.OwnerId = caseMaster.XC_Order__r.CreatedById;
                subcase.AccountId = caseMaster.AccountId; 
                subcase.XC_Order__c = caseMaster.XC_Order__c;
                subcase.Reason = caseMaster.Reason;
                subcase.Type = caseMaster.Type;
                subcase.ContactId = caseMaster.ContactId;
                subcase.XC_LegalEntity__c = caseMaster.XC_LegalEntity__c;
                subcase.Country__c = caseMaster.Country__c;
                subcase.SubCause__c = 'ATCL006';
                subcase.Origin = 'CAN002';
                //subcase.XC_Subtype__c = 'XC120';
                XC_LCC139_DocumentVerification.populateResolutionAndResultOnCaseFather(caseMaster.id);
                XC_UTIL_Sobject.WrapperResult dmlResult= XC_UTIL_Sobject.insertRecord(subcase);
                if(!dmlResult.success) {
                    return populateWrapperError(new List<XC_UTIL_Sobject.WrapperResult> {dmlResult}, rw);               
                }
                for(XC_OrderItemCompliance__c oicKo : listOfKo){
                    oicKo.XC_Case__c = subcase.id;
                    /*oicKo.XC_Status__c = '';
                    oicKo.XC_KoCriticality__c = '';
                    oicKo.XC_RecoveryResponsible__c = '';
                    oicKo.XC_KoReason__c = '';*/
                }
                List<XC_UTIL_Sobject.WrapperResult> dmlResults= XC_UTIL_Sobject.updateListRecords(listOfKo);
                if(!XC_UTIL_Sobject.checkDMLResults(dmlResults)){
                    return populateWrapperError(dmlResults, rw);
                }
                rw.success = true;
                rw.message = Label.XC_CL_DocumentVerification_ToastValue_For_Sales;
                return rw;
            }
            return rw;
    }

    /**
    * @description
    * @author Del Prete Domenico | 28/8/2019
    * @param listOfOICInstallation List<XC_OrderItemCompliance__c> 
    * @param caseMaster Case 
    * @return XC_LCC139_DocumentVerification.ResultWrapper
    */
    public static  XC_LCC139_DocumentVerification.ResultWrapper installationPartnerQueueKo(List<XC_OrderItemCompliance__c> listOfOICInstallation, Case caseMaster){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START installationPartnerQueueKo');
        XC_LCC139_DocumentVerification.ResultWrapper rw = new XC_LCC139_DocumentVerification.ResultWrapper();
        Case subcase = new Case();
        List<XC_OrderItemCompliance__c> listOfKo = new List<XC_OrderItemCompliance__c>();
        List <WorkOrder> listOfWorkOrder = new List <WorkOrder>();
        List <Contact> listOfContact = new List <Contact>();
        User userContact = new User();
        for(XC_OrderItemCompliance__c orderItemCompliance : listOfOICInstallation){
                if(orderItemCompliance.XC_Status__c.equals(Label.XC_CL_DocumentVerification_Ko_Value)){
                    listOfKo.add(orderItemCompliance);
                }
        }
        if(!listOfKo.isEmpty()){
            listOfWorkOrder = new List <WorkOrder>([SELECT id, XC_AssignedResource__r.RelatedRecordId, XC_AssignedResource__r.AccountId
                                                        FROM WorkOrder 
                                                        WHERE XC_Configuration_Item__c =:caseMaster.XC_OrderItem__c AND XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_DeliveryInstallation]);
            listOfContact = new List <Contact> ([SELECT Id, (SELECT Id FROM Users)
                                        FROM Contact 
                                        WHERE AccountId =:listOfWorkOrder[0].XC_AssignedResource__r.AccountId and XC_PrimaryContact__c = true]);
            if(!Test.isRunningTest()){
                for(User us : listOfContact[0].Users){
                    userContact = us;
                    break;
                }
            }
            subcase = populateSubcaseInstallation(caseMaster, userContact);
            XC_UTIL_Sobject.WrapperResult dmlResult= XC_UTIL_Sobject.insertRecord(subcase);
            if(!dmlResult.success) {
                return populateWrapperError(new List<XC_UTIL_Sobject.WrapperResult> {dmlResult}, rw);               
            }
            for(XC_OrderItemCompliance__c oicKo : listOfKo){
                oicKo.XC_Case__c = subcase.id;
                /*oicKo.XC_Status__c = '';
                oicKo.XC_KoCriticality__c = '';
                oicKo.XC_RecoveryResponsible__c = '';
                oicKo.XC_KoReason__c = '';*/
            }
            List<XC_UTIL_Sobject.WrapperResult> dmlResults= XC_UTIL_Sobject.updateListRecords(listOfKo);
            if(!XC_UTIL_Sobject.checkDMLResults(dmlResults)){                
                return populateWrapperError(dmlResults, rw);
            }
            rw.success = true;
            rw.message = Label.XC_CL_DocumentVerification_ToastValue_For_Installation;
            return rw;
        }
        return rw;
    }


    /**
    * @description
    * @author Del Prete Domenico | 28/8/2019
    * @param listOfOICRecoveryData List<XC_OrderItemCompliance__c> 
    * @param caseMaster Case 
    * @return XC_LCC139_DocumentVerification.ResultWrapper
    */
    public static XC_LCC139_DocumentVerification.ResultWrapper recoveryDataQueueKo(List<XC_OrderItemCompliance__c> listOfOICRecoveryData, Case caseMaster){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START recoveryDataQueueKo');
        XC_LCC139_DocumentVerification.ResultWrapper rw = new XC_LCC139_DocumentVerification.ResultWrapper();
        List<XC_OrderItemCompliance__c> listOfKo = new List<XC_OrderItemCompliance__c>();
        for(XC_OrderItemCompliance__c orderItemCompliance : listOfOICRecoveryData){
            if(orderItemCompliance.XC_Status__c.equals(Label.XC_CL_DocumentVerification_Ko_Value)){
                listOfKo.add(orderItemCompliance);
            }
        }
        if(!listOfKo.isEmpty()){
            List<Group> setQueue = new List<Group>([SELECT Id
                                                    FROM Group 
                                                    WHERE Name =: Label.XC_CL_DocumentVerification_Compliance_Verification_Queue]);
            caseMaster.ownerId = setQueue[0].id;
            XC_UTIL_Sobject.WrapperResult dmlResult= XC_UTIL_Sobject.updateRecord(caseMaster);
            if(!dmlResult.success) {
                return populateWrapperError(new List<XC_UTIL_Sobject.WrapperResult> {dmlResult}, rw);                  
            }
            rw.success = true;
            rw.message = Label.XC_CL_DocumentVerification_ComplianceVerificationAssigned;
            return rw; 
        }
        return rw; 
    }

    /**
    * @description
    * @author Del Prete Domenico | 28/8/2019
    * @param caseMaster Case 
    * @param userContact User 
    * @return Case
    */
    public static Case populateSubcaseInstallation (Case caseMaster, User userContact){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START populateSubcaseInstallation');
        Case subcase = new Case();
        subcase.Subject = Label.XC_CL_DocumentVerification_SubjectName_For_Installation;
        subcase.AccountId = caseMaster.AccountId;
        subcase.XC_Order__c = caseMaster.XC_Order__c;
        subcase.Reason = caseMaster.Reason;
        subcase.Type = caseMaster.Type;   
        subcase.ParentId = caseMaster.Id;
        subcase.ContactId = caseMaster.ContactId;
        subcase.XC_LegalEntity__c = caseMaster.XC_LegalEntity__c;
        subcase.Country__c = caseMaster.Country__c;
        subcase.SubCause__c = 'ATCL006';
        subcase.Origin = 'CAN002';
        //subcase.XC_Subtype__c = 'XC120'; 
        XC_LCC139_DocumentVerification.populateResolutionAndResultOnCaseFather(caseMaster.Id);
        if(!Test.isRunningTest()){
            subcase.OwnerId = userContact.id;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'STOP populateSubcaseInstallation');
        return subcase; 
    }

    /**
    * @description
    * @author Del Prete Domenico | 28/8/2019
    * @param caseMaster Case 
    * @param caseClosureMap Map<String, XC_CM_Case_Type_Setting__mdt> 
    * @return XC_LCC139_DocumentVerification.ResultWrapper
    */
    public static XC_LCC139_DocumentVerification.ResultWrapper populateCaseMasterOk (Case caseMaster, Map<String, XC_CM_Case_Type_Setting__mdt> caseClosureMap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START populateCaseMasterOk');
        XC_LCC139_DocumentVerification.ResultWrapper rw = new XC_LCC139_DocumentVerification.ResultWrapper();
        caseMaster.Status = caseClosureMap.get(Label.XC_CL_Compliance_ClosedOkCase).XC_Status__c;
        caseMaster.XC_Resolution__c = caseClosureMap.get(Label.XC_CL_Compliance_ClosedOkCase).XC_Resolution__c;
        caseMaster.XC_Result__c = caseClosureMap.get(Label.XC_CL_Compliance_ClosedOkCase).XC_Result__c;
        caseMaster.CaseRemarks__c = Label.XC_CL_DocumentVerification_ValidationCompleted;
        XC_UTIL_Sobject.WrapperResult dmlResult= XC_UTIL_Sobject.updateRecord(caseMaster);
        if(!dmlResult.success) {
           return populateWrapperError(new List<XC_UTIL_Sobject.WrapperResult> {dmlResult}, rw);                    
        }
        rw.success = true;
        rw.message = Label.XC_CL_DocumentVerification_DocumentsVerified;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'STOP populateSubcaseInstallation');
        return rw;        
    }

        /**
    * @description
    * @author Del Prete Domenico | 28/8/2019
    * @param caseMaster Case 
    * @param caseClosureMap Map<String, XC_CM_Case_Type_Setting__mdt> 
    * @return XC_LCC139_DocumentVerification.ResultWrapper
    */
    public static XC_LCC139_DocumentVerification.ResultWrapper populateCaseMasterKoHigh(Case caseMaster, Map<String, XC_CM_Case_Type_Setting__mdt> caseClosureMap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START populateCaseMasterKoHigh');
        XC_LCC139_DocumentVerification.ResultWrapper rw = new XC_LCC139_DocumentVerification.ResultWrapper();
        caseMaster.Status = caseClosureMap.get(Label.XC_CL_Compliance_ClosedKoCase).XC_Status__c;
        caseMaster.XC_Resolution__c = caseClosureMap.get(Label.XC_CL_Compliance_ClosedKoCase).XC_Resolution__c;
        caseMaster.XC_Result__c = caseClosureMap.get(Label.XC_CL_Compliance_ClosedKoCase).XC_Result__c;
        caseMaster.CaseRemarks__c = Label.XC_CL_DocumentVerification_ValidationCompletedKoHigh;
        XC_UTIL_Sobject.WrapperResult dmlResult= XC_UTIL_Sobject.updateRecord(caseMaster);
            if(!dmlResult.success) {
                return populateWrapperError(new List<XC_UTIL_Sobject.WrapperResult> {dmlResult}, rw);
            }
        rw.success = true;
        rw.message = Label.XC_CL_DocumentVerification_Case_Closed_OrderItemCompliance_KO;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'STOP populateCaseMasterKoHigh');
        return rw;
    }

    /**
    * @description 
    * @author Del Prete Domenico | 12/3/2020 
    * @param dmlResults 
    * @param rw 
    * @return XC_LCC139_DocumentVerification.ResultWrapper 
    **/
    public static XC_LCC139_DocumentVerification.ResultWrapper populateWrapperError(List<XC_UTIL_Sobject.WrapperResult> dmlResults, XC_LCC139_DocumentVerification.ResultWrapper rw){
        rw.success = false;
        rw.message = dmlResults[0].errorMessage;
        return rw;        
    }
}