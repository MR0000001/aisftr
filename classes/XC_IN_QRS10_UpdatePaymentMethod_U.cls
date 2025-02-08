/**
 * @File Name          : XC_IN_QRS10_UpdatePaymentMethod.cls
 * @Description        : 
 * @Author             : Simone Trenta - strenta@deloitte.it
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    
**/
public without sharing class XC_IN_QRS10_UpdatePaymentMethod_U {

    
    /**
    * @description set the status of the subsequent step as 'Skipped', only callback step will be always executed
    * @author Simone Trenta - strenta@deloitte.it | 3/7/2020 
    * @param inputs 
    **/
    @InvocableMethod
    public static void skipNotCallbackStepsInvocable(List<XC_IN_QRS10_UpdatePaymentMethod.InputWrapper> inputs){
        XC_IN_QRS10_UpdatePaymentMethod.InputWrapper iw = inputs[0];
        XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);
        XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);
        return;
    }

    /**
    * @description method to set provisioning step status   
    * @param mapQRStepToUpdate the order id
    * @param status the status to set on the step 
    * @param errorMessage the error message to set on the step
    */
    public static void updateStepsStatus(Map<Id, XC_QueuedRequestStep__c > mapQRStepToUpdate, String status, String errorMessage){
        
        for(XC_QueuedRequestStep__c qrStep : mapQRStepToUpdate.values()){   
            qrStep.XC_Status__c = status;
            qrStep.XC_ErrorMessage__c = errorMessage;
        }

        if(!mapQRStepToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(mapQRStepToUpdate.values()); 
        }
        
        if(status == 'Completed KO'){
            XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(mapQRStepToUpdate.values());
        }
    }


    /**
    * @description get queued request steps to complete
    * @param parentQueuedReq the parentQueuedReq id
    * @return Map<Id, XC_QueuedRequestStep__c >
    */
    public static Map<Id, XC_QueuedRequestStep__c > getQRStepsToComplete(String parentQueuedReq) {

        Map<Id, XC_QueuedRequestStep__c> qrsMap = new Map<Id, XC_QueuedRequestStep__c >([
            SELECT Id, XC_QueuedRequest__c, XC_Status__c, XC_StepLabel__c, XC_StepSequence__c 
            FROM XC_QueuedRequestStep__c 
            WHERE 
                XC_StepLabel__c =: 'Update Payment Method' AND 
                XC_QueuedRequest__r.XC_ParentQueuedRequest__c =: parentQueuedReq AND 
                XC_FlowAPIName__c =: 'XC_FL_QueuedRequestStep_UpdateMOP' AND 
                (XC_Status__c =: 'In Progress' OR XC_Status__c =: 'Completed KO' OR XC_Status__c =: 'Skipped' OR XC_Status__c =: 'Not Started')
            ]);

        return qrsMap;
    }


    /**
    * @description get queued request steps to complete
    * @param iban the iban
    * @return Boolean
    */
    public static Boolean checkIban(String iban){
        if(String.isBlank(iban)){
            return false;
        }

        Pattern ibanPattern = Pattern.compile('[A-Z]{2,2}[0-9]{2,2}[a-zA-Z0-9]{1,30}');
        Matcher bpNumberMatcher = ibanPattern.matcher(iban.toUpperCase());
        return bpNumberMatcher.matches();
    }



    /**
    * @description get queued request steps to complete
    * @param bpId
    * @param iban
    * @return Map<Id,Object>
    */
    public static Map<String,Object> updateBP(String bpId, String iban){

        Map<Id, NE__Billing_Profile__c> bpMap = new  Map<Id, NE__Billing_Profile__c>([
            SELECT id, Name, NE__Account__c, XC_Segment__c, XC_MandateType__c, NE__Payment__c, XC_CommodityContractID__c, XC_CommodityCupsID__c, XC_Token__c, NE__Iban__c, XC_SepaMandate__c, XC_SepaMandateDate__c, XC_Status__c
            FROM NE__Billing_Profile__c 
            WHERE id=:bpId LIMIT 1
        ]);

        Map<String,Object> paramsInfo = new Map<String,Object>();
        paramsInfo.put('bpId', bpId);
        paramsInfo.put('mop', 'Direct Debt');
        paramsInfo.put('accountNumber', iban);
        paramsInfo.put('bic', '');
        paramsInfo.put('mandateType', bpMap.values()[0].XC_MandateType__c);
        paramsInfo.put('skipDuplication', true);
        Map<String,Object> oldBpInfos = new Map<String,Object>();
        oldBpInfos.put('NE__Payment__c',bpMap.values()[0].NE__Payment__c);
        oldBpInfos.put('XC_CommodityContractID__c',bpMap.values()[0].XC_CommodityContractID__c);
        oldBpInfos.put('XC_CommodityCupsID__c',bpMap.values()[0].XC_CommodityCupsID__c);
        oldBpInfos.put('XC_Token__c',bpMap.values()[0].XC_Token__c);
        oldBpInfos.put('NE__Iban__c',bpMap.values()[0].NE__Iban__c);
        oldBpInfos.put('XC_SepaMandate__c',bpMap.values()[0].XC_SepaMandate__c);
        oldBpInfos.put('XC_SepaMandateDate__c',bpMap.values()[0].XC_SepaMandateDate__c);
        oldBpInfos.put('XC_Status__c',bpMap.values()[0].XC_Status__c);
        oldBpInfos.put('Id',bpMap.values()[0].Id);

        Map<String,Object> res = XC_LCC078_ChangePaymentMethod.updateCurrentBillingProfile(paramsInfo);
        res.put('iban', iban);
        res.put('mandateType', bpMap.values()[0].XC_MandateType__c);
        res.put('oldBpInfos', oldBpInfos);
        res.put('accountID', bpMap.values()[0].NE__Account__c);

        return res;  
    }


    /**
    * @description get queued request steps to complete
    * @param bpId the parentQueuedReq id
    * @param uilMap the util Map 
    * @return Case
    */
    public static Case createCase(String bpId, Map<String,Object> uilMap){

        Map<Id,NE__Billing_Profile__c> bp = new Map<Id,NE__Billing_Profile__c>([
            SELECT Id, NE__Account__c, NE__Iban__c, NE__Payment__c, XC_LegalEntity__c, XC_CommodityContractID__c
            FROM NE__Billing_Profile__c
            WHERE Id = :bpId
        ]);

        Map<Id,Contact> primaryContact = new Map<Id,Contact>([
            SELECT Id FROM Contact WHERE XC_PrimaryContact__c = true AND AccountId = :bp.values()[0].NE__Account__c
        ]);

        // assignment rules
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;

        List<String> caseSettingNames = new List<String>{Label.XC_CL_CMD_NewMOPAfterUnbundling,'XC_NewMOPAfterUnbundling_New'};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        
        XC_CM_Case_Type_Setting__mdt caseSettings = new XC_CM_Case_Type_Setting__mdt();       
        if(bp.values()[0].XC_LegalEntity__c == 'EnelXRomania'){
            caseSettings = caseSettingsMap.get('XC_NewMOPAfterUnbundling_New');
        } else {
            caseSettings = caseSettingsMap.get(Label.XC_CL_CMD_NewMOPAfterUnbundling);
        }
        
        Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
        c.AccountId = bp.values()[0].NE__Account__c;
        c.ContactId = primaryContact.values()[0].Id;
        c.Description = 'Update Billing Profile with Id: ' + bp.values()[0].Id + ((!String.isBlank(bp.values()[0].XC_CommodityContractID__c)) ? ' and CommodityNumber:' + bp.values()[0].XC_CommodityContractID__c: '');
        c.setOptions(dmlOpts);
        c.XC_LegalEntity__c = bp.values()[0].XC_LegalEntity__c;
            
        XC_UTIL_Sobject.WrapperResult wrRes = XC_UTIL_SObject.insertRecord(c);
        uilMap.put('wrRes', wrRes);
        if(wrRes.success){
            Map<Id,Case> mapCase = new Map<Id,Case>([SELECT CaseNumber FROM Case WHERE Id =: c.Id]);
            return mapCase.get(c.Id);
        }
        
        return c;
    }


    /**
    * @description get queued request steps to complete
    * @param acc
    * @param updateBPres
    * @return XC_UTIL_RESTCallout.HttpResponseWrapper
    */
    public static XC_UTIL_RESTCallout.HttpResponseWrapper callSIA(XC_UTIL_Account.AccountIFWrapper acc, Map<String,Object> updateBPres){

        String accId = (String)updateBPres.get('accountID');

        Map<Id, Account> accMap = new Map<Id,Account>([SELECT Id, XC_FirstName__c, PrimaryEmail__c, XC_LastName__c, IdentityNumber__c,
                                                      (SELECT Id, Email, Name, LastName FROM Contacts WHERE XC_PrimaryContact__c = true)
                                                      FROM Account
                                                      WHERE Id =: accId
                                                      LIMIT 1]);

     
        XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA requestWr = new XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA();
		requestWr.name = XC_UTIL_String.removeDiacriticsSIA(accMap.values()[0].XC_FirstName__c);
		requestWr.surname =XC_UTIL_String.removeDiacriticsSIA(accMap.values()[0].XC_LastName__c);
        //requestWr.email = acc.PrimaryEmail;
        requestWr.email = String.isNotBlank(accMap.values()[0].PrimaryEmail__c) ? accMap.values()[0].PrimaryEmail__c : (!accMap.values()[0].Contacts.isEmpty() && String.isNotBlank(accMap.values()[0].Contacts[0].Email)) ? accMap.values()[0].Contacts[0].Email : accMap.values()[0].IdentityNumber__c +'@sepa.com';
        requestWr.iban = (String)updateBPres.get('iban');
        requestWr.mandateID = (String)updateBPres.get('mandateID');
        requestWr.type = (String)updateBPres.get('mandateType')=='One Time' ? 'ONE_SHOT' : (String)updateBPres.get('mandateType');
        requestWr.sdd = new XC_REST_PaymentMethodSIA_U.SDDWrapper();
        requestWr.sdd.iban = (String)updateBPres.get('iban');
        requestWr.sdd.mandateId = (String)updateBPres.get('mandateID');
        requestWr.sdd.mandateDate = (updateBPres.get('mandateDate')+'').split(' ')[0];
        requestWr.addressCountry = 'ES'; //tbd

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('PaymentMethodSIA_SEPA');
        string body = JSON.serialize(requestWr,true);
        Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'PaymentMethodSIA_SEPA', 'PaymentMethodSIA_SEPA');
        headerDefinitions.put('X-Request-ID', '1');
        headerDefinitions.put('channel', 'CRMWEBAPP_SDD');
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', isActiveInterface.url, headerDefinitions, body);
        request.setClientCertificateName('SIA_CERT');
        System.debug('[Payment Method SIA] request Body -> ' + body);
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'PaymentMethodSIA_SEPA';
        logWrapper.insertLogging = false;

        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request,  headerDefinitions , logWrapper);
        httpRWr.integrationLog.get(0).XC_Log_TransactionId__c = headerDefinitions.get('TransactionID');
      
        return httpRWr;
    }


    

}