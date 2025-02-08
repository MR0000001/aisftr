/**
 * The Class XC_LCC139_DocumentVerification.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 30/07/2019 
 * @date Modification dd/mm/yyyy
 * @description XC_LCC139_DocumentVerification – Controller for XC_LCP139_DocumentVerification Component
 */
public without sharing class XC_LCC139_DocumentVerification {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC139_DocumentVerification');
     /**
     * @description The Class resultWrapper.
     */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String  message = 'Error'; 
    }
    /**
     * @description Util class wrapper of document verification
     */
    public class UtilWrapperDocumentVerification {
        public List <XC_OrderItemCompliance__c> listOfOrderItemCompliance = new List <XC_OrderItemCompliance__c> ();
        public Boolean statusHighKo = false;
        public List <XC_OrderItemCompliance__c> listOfOICRecoveryData = new List <XC_OrderItemCompliance__c> ();
        public List <XC_OrderItemCompliance__c> listOfOICSalesPartner = new List <XC_OrderItemCompliance__c> ();
        public List <XC_OrderItemCompliance__c> listOfOICInstallation = new List <XC_OrderItemCompliance__c> ();
        public Boolean documentOk = false;
        public Case caseMaster = new Case();
        public Map<String, XC_CM_Case_Type_Setting__mdt> caseClosureMap = new Map<String, XC_CM_Case_Type_Setting__mdt>();
        public Boolean isReturn = false;
    }
    /**
     * @description Util class wrapper of document verification for populate recovery responsible list
     */
    public class RecoveryResponsibleList{
        public List <XC_OrderItemCompliance__c> listOfOICRecoveryData = new List <XC_OrderItemCompliance__c> ();
        public List <XC_OrderItemCompliance__c> listOfOICSalesPartner = new List <XC_OrderItemCompliance__c> ();
        public List <XC_OrderItemCompliance__c> listOfOICInstallation = new List <XC_OrderItemCompliance__c> ();
    }

  
    /**
    * @description
    * @author Del Prete Domenico | 30/7/2019
    * @param recordId String 
    * @return resultWrapper
    */
    public static ResultWrapper documentVerification (Id recordId){
        ResultWrapper rw = new ResultWrapper();
        RecoveryResponsibleList recoveryWrapper = new RecoveryResponsibleList();
        Boolean statusHighKo = false;
        Boolean documentOk = false;
        User userContact = new User();
        List <Case> listOfChildCase = new List <Case>();
        List <XC_OrderItemCompliance__c> listOfOrderItemCompliance = new List <XC_OrderItemCompliance__c> ();
        List <XC_OrderItemCompliance__c> listOfOICSalesPartner = new List <XC_OrderItemCompliance__c> ();
        List <XC_OrderItemCompliance__c> listOfOICInstallation = new List <XC_OrderItemCompliance__c> ();
        List <XC_OrderItemCompliance__c> listOfOICRecoveryData = new List <XC_OrderItemCompliance__c> ();
        Map<String, XC_CM_Case_Type_Setting__mdt> caseClosureMap = getCaseClosureInfoFromCustomMetadata();
        List <Case> listOfCase = new List <Case>([SELECT Id, XC_Order__r.CreatedById, XC_OrderItem__c, ParentId, Status, AccountId, XC_FirstCheckOnCompliance__c,
                                                        XC_Order__c, Reason, Subject, Type, ContactId, Country__c, XC_LegalEntity__c,
                                                    (SELECT Id, XC_Status__c, XC_RecoveryResponsible__c, XC_KoCriticality__c FROM Order_Item_Compliance__r), 
                                                    (SELECT Id, Status FROM Cases WHERE ParentId =: recordId)
                                                  FROM Case 
                                                  WHERE Id =: recordId]);
        Case caseMaster = listOfCase[0];
        for(Case caseapp : caseMaster.Cases){
            listOfChildCase.add(caseapp);
        }
        if(!listOfChildCase.isEmpty()){
            for(Case caseapp : listOfChildCase){
                if(checkStatusChildCase(caseapp)){
                    rw.success = false;
                    rw.message = Label.XC_CL_DocumentVerification_Error_Child_Must_Be_Closed;
                    return rw;
                }
            }
        }
        for(XC_OrderItemCompliance__c orderItemCompliance : caseMaster.Order_Item_Compliance__r){
            listOfOrderItemCompliance.add(orderItemCompliance);
            if(String.isBlank(orderItemCompliance.XC_Status__c)){
                rw.message = Label.XC_CL_DocumentVerification_Document_NeedToVerify;
                return rw;
            }
            if(String.isBlank(orderItemCompliance.XC_RecoveryResponsible__c)){
                documentOK = true;
            }
            populateList(recoveryWrapper, orderItemCompliance);
            listOfOICSalesPartner = recoveryWrapper.listOfOICSalesPartner;
            listOfOICInstallation = recoveryWrapper.listOfOICInstallation;
            listOfOICRecoveryData = recoveryWrapper.listOfOICRecoveryData;
            if(checkHighValue(orderItemCompliance)){ 
                statusHighKo = true;
                break;
            }
        }
        UtilWrapperDocumentVerification wrapper = new UtilWrapperDocumentVerification();
        wrapper.listOfOrderItemCompliance = listOfOrderItemCompliance;
        wrapper.statusHighKo = statusHighKo;
        wrapper.listOfOICRecoveryData = listOfOICRecoveryData;
        wrapper.listOfOICSalesPartner = listOfOICSalesPartner;
        wrapper.listOfOICInstallation = listOfOICInstallation;
        wrapper.documentOk = documentOk;
        wrapper.caseMaster = caseMaster;
        wrapper.caseClosureMap = caseClosureMap;
        return rw = selectedCase(wrapper);    
    }


    private static Map<String, XC_CM_Case_Type_Setting__mdt> getCaseClosureInfoFromCustomMetadata(){
        List<String> caseSettingNames = new List<String>{Label.XC_CL_Compliance_ClosedOkCase, Label.XC_CL_Compliance_ClosedKoCase};

        return XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);                                                                                                             
    } 


    /**
    * @description
    * @author Del Prete Domenico | 28/8/2019
    * @param recordId String 
    */
    public static void populateResolutionAndResultOnCaseFather(String recordId){
        Case caseFather = new Case(Id= recordId);
        /*caseFather.XC_Resolution__c = caseClosureMap.get(Label.XC_CL_Compliance_ClosedKoCase).XC_Resolution__c;
        caseFather.XC_Result__c = caseClosureMap.get(Label.XC_CL_Compliance_ClosedKoCase).XC_Result__c;
        caseFather.CaseRemarks__c = Label.XC_CL_DocumentVerification_ValidationCompletedKoLow;*/
        caseFather.Status = 'ESTA002';
        caseFather.XC_FirstCheckOnCompliance__c = true;
        XC_UTIL_Sobject.updateRecord(caseFather);
    } 

    private static Boolean checkSalesPartnerQueue(XC_OrderItemCompliance__c orderItemCompliance){
        return (!String.isBlank(orderItemCompliance.XC_RecoveryResponsible__c) && orderItemCompliance.XC_RecoveryResponsible__c.equals(Label.XC_CL_DocumentVerification_SalesQueue));
    }

    private static Boolean checkInstallationPartnerQueue(XC_OrderItemCompliance__c orderItemCompliance){
        return (!String.isBlank(orderItemCompliance.XC_RecoveryResponsible__c) && orderItemCompliance.XC_RecoveryResponsible__c.equals(Label.XC_CL_DocumentVerification_InstallationQueue));
    }

    private static Boolean checkRecoveryDataQueue(XC_OrderItemCompliance__c orderItemCompliance){
        return (!String.isBlank(orderItemCompliance.XC_RecoveryResponsible__c) && orderItemCompliance.XC_RecoveryResponsible__c.equals(Label.XC_CL_DocumentVerification_RecoveryQueue) && orderItemCompliance.XC_Status__c.equals('Ko'));
    }
    private static Boolean checkHighValue(XC_OrderItemCompliance__c orderItemCompliance){
        return (!String.isBlank(orderItemCompliance.XC_KoCriticality__c) && orderItemCompliance.XC_KoCriticality__c.equals(Label.XC_CL_DocumentVerification_High_Value));
    } 

    private static Boolean checkDocumentOk(UtilWrapperDocumentVerification wrapper){
        return (wrapper.documentOk && wrapper.listOfOICSalesPartner.isEmpty() && wrapper.listOfOICInstallation.isEmpty() && wrapper.listOfOICRecoveryData.isEmpty());
    }
    private static Boolean checkFirstCheckBoolean(UtilWrapperDocumentVerification wrapper){
        return (wrapper.caseMaster.XC_FirstCheckOnCompliance__c && !(wrapper.listOfOICSalesPartner.isEmpty() && wrapper.listOfOICInstallation.isEmpty() && wrapper.listOfOICRecoveryData.isEmpty()));
    }
    private static Boolean checkStatusChildCase(Case caseapp){
        return (!caseapp.Status.equals(Label.XC_CL_DocumentVerification_Case_Closed_Status) && !caseapp.Status.equals(Label.XC_CL_Case_Status007));
    }

    private static void populateList(RecoveryResponsibleList recoveryWrapper, XC_OrderItemCompliance__c orderItemCompliance){
        if(checkSalesPartnerQueue(orderItemCompliance)){
            recoveryWrapper.listOfOICSalesPartner.add(orderItemCompliance);
        }else if(checkInstallationPartnerQueue(orderItemCompliance)){
            recoveryWrapper.listOfOICInstallation.add(orderItemCompliance);
        }else if (checkRecoveryDataQueue(orderItemCompliance)){
            recoveryWrapper.listOfOICRecoveryData.add(orderItemCompliance);
        }
    }

    /**
    * @description
    * @author Del Prete Domenico | 29/8/2019
    * @param wrapper UtilWrapperDocumentVerification 
    * @return ResultWrapper
    */
    public static ResultWrapper selectedCase (UtilWrapperDocumentVerification wrapper){
        ResultWrapper rw = new ResultWrapper();
        rw = initialCheck(wrapper);
        if(wrapper.isReturn){
            return rw;
        }
        if(!wrapper.listOfOICRecoveryData.isEmpty()){
            rw = XC_LCC139_DocumentVerification_U.recoveryDataQueueKo(wrapper.listOfOICRecoveryData, wrapper.caseMaster);
            return rw;                         
        }
        if(!wrapper.listOfOICSalesPartner.isEmpty()){
            rw = XC_LCC139_DocumentVerification_U.salesPartnerQueueKo(wrapper.listOfOICSalesPartner, wrapper.caseMaster);
            return rw;
        } 
        if(!wrapper.listOfOICInstallation.isEmpty()){
            rw = XC_LCC139_DocumentVerification_U.installationPartnerQueueKo(wrapper.listOfOICInstallation, wrapper.caseMaster);
            return rw;
        }
        if(checkDocumentOk(wrapper)){ 
            rw = XC_LCC139_DocumentVerification_U.populateCaseMasterOk(wrapper.caseMaster, wrapper.caseClosureMap);
            return rw;
        }
        return rw;
    }

    private static ResultWrapper initialCheck (UtilWrapperDocumentVerification wrapper){
        ResultWrapper rw = new ResultWrapper();
        if(wrapper.listOfOrderItemCompliance.isEmpty()){
            rw.success = false; 
            rw.message = Label.XC_CL_DocumentVerification_No_OrderItemCompliance_Found;
            wrapper.isReturn = true;
            return rw;     
        }
        if(checkFirstCheckBoolean(wrapper)){
            rw.message = Label.XC_CL_AnyDocumentStillKo;
            wrapper.isReturn = true;
            return rw;
        }
        if(wrapper.statusHighKo){
            rw = XC_LCC139_DocumentVerification_U.populateCaseMasterKoHigh(wrapper.caseMaster, wrapper.caseClosureMap);
            wrapper.isReturn = true;
            return rw;
        }
        return rw;
    }  
}