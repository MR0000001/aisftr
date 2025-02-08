/**
* @author Dario Tramontin- d.tramontin@deloitte.it
* @date Creation 17/07/2019
* @date Last Modification 26/08/2019 by Luisana Rocco - lrocco@deloitte.it
* @description XC_LCC136_UpCompliantCaseIndemnif - Util class for XC_LCC136_UpCompliantCaseOnIndemnification
*/
public without sharing class XC_LCC136_UpCompliantCaseIndemnif {

 private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCP136_UpCompliantCaseOnIndemnificationHelper');

     public class ResultWrapper{
        @AuraEnabled
        public List<Map<String, String>> resultPicklistMap = new List<Map<String, String>>();
    
        @AuraEnabled
        public List<String> lookupString; 

        @AuraEnabled
        public Map<String,Object> mapfieldcase = new Map<String,Object>();
            
        }

    public class CaseIndemnification  {
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String resultMessage;
    }

    /**
     * @description getBillingInfo get all information for the button Indemnification in Case with Compliant recordType
     * @param caseID 
     * @return ResultWrapper
     */
    @AuraEnabled
    public static ResultWrapper getBillingInfo(String caseID) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getBillingInfo - caseID='+caseID);
        ResultWrapper rw= new ResultWrapper();
        if(!Schema.SObjectType.Case.isAccessible() && !Schema.SObjectType.Account.isAccessible()  ) {
            return rw;
        }

        try{
            Map<Id,Account> mapAccount =new Map<Id,Account>([Select  id, ( SELECT id, XC_Status__c FROM NE__Billing_Profiles__r WHERE XC_Status__c =: Label.XC_CL_Billing_Active)
                                                            FROM Account 
                                                            WHERE id IN (SELECT AccountId FROM Case WHERE id= :caseID )]);
            List<NE__Billing_Profile__c > listBillingProfile= mapAccount.values()[0].NE__Billing_Profiles__r ;
            List<String> listID= new List<String>();
            for(NE__Billing_Profile__c  b : listBillingProfile){
                listID.add(b.id);
            }

            if(listID.isEmpty()){
                rw.lookupString=new List<String>();
                return rw;
            }
            rw.lookupString= listID;
            Map<Id,Case> casesMap = new Map<Id,Case>([SELECT Id, XC_ApprovalStatus__c, XC_SentToZuora__c, XC_SendStatus__c, XC_Billing_Profile_Line_Item__c, 
                                                    AccountId, XC_Amount__c, XC_Automatic_Refund__c, XC_Case_Comments__c,
                                                    XC_IndemnificationReason__c, RecordTypeId, XC_LegalEntity__c, XC_Subtype__c
                                                  FROM Case 
                                                  WHERE Id =: caseID
                                                  LIMIT 1]);
            
            rw.mapfieldCase.put('XC_Amount__c',casesMap.values()[0].XC_Amount__c);
            rw.mapfieldCase.put('AccountId',casesMap.values()[0].AccountId);
            rw.mapfieldCase.put('XC_Billing_Profile_Line_Item__c',casesMap.values()[0].XC_Billing_Profile_Line_Item__c);
            rw.mapfieldCase.put('XC_Automatic_Refund__c',casesMap.values()[0].XC_Automatic_Refund__c);
            rw.mapfieldCase.put('XC_Case_Comments__c',casesMap.values()[0].XC_Case_Comments__c);
            rw.mapfieldCase.put('XC_IndemnificationReason__c',casesMap.values()[0].XC_IndemnificationReason__c);
            rw.mapfieldCase.put('XC_ApprovalStatus__c', casesMap.values()[0].XC_ApprovalStatus__c);
            rw.mapfieldCase.put('XC_SentToZuora__c', casesMap.values()[0].XC_SentToZuora__c);
            rw.mapfieldCase.put('XC_SendStatus__c', casesMap.values()[0].XC_SendStatus__c);
            rw.mapfieldCase.put('XC_LegalEntity__c', casesMap.values()[0].XC_LegalEntity__c);
            

            List<Case> caseList = casesMap.values();
            List<Map<String, String>> filteredPicklistMap = new List<Map<String, String>>();
            filteredPicklistMap.add(new Map<String, String>{'value' => '', 'label' => '--None--'});
            XC_UTIL_DependentPicklist.PicklistWrapper mapWrapper = XC_UTIL_DependentPicklist.getDependentPicklist('Case', 'XC_Subtype__c', 'XC_IndemnificationReason__c');
            List<Schema.PicklistEntry> picklistResolution = Schema.Case.XC_IndemnificationReason__c.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry pe : picklistResolution) {
                if(pe.isActive() && mapWrapper.pickListMap.get(caseList[0].XC_Subtype__c).contains(pe.getValue())) {
                    filteredPicklistMap.add(new Map<String, String>{'value' => pe.getValue(), 'label' => pe.getLabel()});
                }
            }
            rw.resultPicklistMap.addAll(getValidPicklistValue(caseList[0].RecordTypeId, filteredPicklistMap ));
        }catch(Exception e){
            System.debug(e.getMessage() );
        }
        return rw;
	}


    /**
     * @description Comparision between two list of picklistValue
     * @param  recordTypeId 
     * @param  filteredPicklistMap List of Map with active values for the dependent picklist
     * @return 
     */
    public static List<Map<String, String>> getValidPicklistValue(String recordTypeId, List<Map<String, String>> filteredPicklistMap ){
        List<Map<String, String>> result= new List<Map<String, String>>();
        System.debug('RecordType: '+ recordTypeId);
        result.addAll(XC_LCC068_Care_NewCaseByInsistence.getActiveValueByRecordType('Case', recordTypeId, 'XC_IndemnificationReason__c'));
            
        List<Map<String, String>> resultPicklistValues = new List<Map<String, String>>();
        resultPicklistValues.add(new Map<String, String>{'value' => '', 'label' => '--None--'});
        for(Map<String, String> elementAll : filteredPicklistMap) {
                Boolean found = false;
            for(Map<String, String> element : result) {
                if(element.get('value') == elementAll.get('value')) {
                    found = true;
                    break;
                }
            }
            if(found){
                resultPicklistValues.add(elementAll);
            }
        }
        return resultPicklistValues;
    }
    

     /**
     * @description getBillingInfo get all information for the button Indemnification in Case with Compliant recordType
     * @param caseID recordId of case to update
     * @param jsonCaseUpdate JSON - field to update
     * @return CaseIndemnification
     */
    @AuraEnabled 
    public static CaseIndemnification updateComplaintCase(String jsonCaseUpdate,String caseID){
     
        CaseIndemnification result = new CaseIndemnification();

        try {
            Map<String,String> mapDes=  (Map<String,String>)JSON.deserialize(jsonCaseUpdate,Map<String,String>.class);
            System.debug('Here mapDes:'+mapDes);
            if(!Schema.SObjectType.Case.isAccessible() ) {
                System.debug('CaseNotAccessible');
                return result;
            }
           
            /*if(caseID !=null){
                System.debug('Check caseID: '+ caseID );
                Case c= new Case();
                Map<Id,Case> mapCase= new Map<Id,Case>([SELECT ID, XC_Amount__c,XC_Billing_Profile_Line_Item__c, XC_Automatic_Refund__c,XC_Billing_Profile_Line_Item__r.XC_ZuoraId__c, XC_Case_Comments__c, XC_IndemnificationReason__c, XC_LegalEntity__c,  FROM Case WHERE id=:caseId LIMIT 1]);
                c= mapCase.values();

                XC_REST_Indemnification.WrapperRequest wrapReq= new XC_REST_Indemnification.WrapperRequest();

                wrapReq.Amount=Decimal.valueof(mapDes.get('XC_Amount__c') );
                wrapReq.ReasonCode= mapDes.get('XC_IndemnificationReason__c');
                wrapReq.AccountId = mapDes.get('XC_ZuoraId__c');
                //valori di zuora
                //wrapReq.ReasonCode = 'Write-off';
                //wrapReq.AccountId = '8adcc59c6b07724e016b08ed01a04f19';
                wrapReq.legalEntity = c.XC_LegalEntity__c;
                XC_REST_Indemnification.WrapperResponse  resultRest = XC_REST_Indemnification.createIndemnification(wrapReq);
                if(resultRest.errors != null ){
                    result.success = false;
                    result.resultMessage = resultRest.errors[0].title;
                }else{
                    Case caseToUp= new Case();
                    caseToUp = checkUpdateField(c,mapDes );

                    c.Status=XC_AT_Constants.TRIGGER_STATUS_ESTA002;
                    XC_Util_Sobject.WrapperResult wr=XC_Util_Sobject.updateRecord(c);
                    result.success = wr.success;
                    System.debug('Result Success: '+ result.success);
                    result.resultMessage = (result.success) ? Label.XC_CL_OperationCompleted : wr.errorMessage;
                    System.debug('result update: '+ result.success);
                }
            }*/

           if(caseID !=null){

                // automatic approval not needed -> approval process needed
                if(mapDes.get('XC_ApprovalStatus__c') == Label.XC_CL_Configuration_NotNeeded){
                    
                    Map<Id,XC_BillingProfileLineItem__c> mabBp= new  Map<Id,XC_BillingProfileLineItem__c>([SELECT XC_ZuoraId__c, XC_BillingProfile__r.XC_Segment__c FROM XC_BillingProfileLineItem__c WHERE id=:mapDes.get('XC_Billing_Profile_Line_Item__c') LIMIT 1]); 
                    System.debug('Approval Notneeded');
                    Case caseToUpdate = new Case();
                    caseToUpdate.ID = caseID;
                    checkUpdateField(caseToUpdate, mapDes);
                    caseToUpdate.Status=XC_AT_Constants.TRIGGER_STATUS_ESTA002;
                    mapDes.put('zuoraAccountId', mabBp.get(mapDes.get('XC_Billing_Profile_Line_Item__c')).XC_ZuoraId__c);
                    mapDes.put('stream', mabBp.get(mapDes.get('XC_Billing_Profile_Line_Item__c')).XC_BillingProfile__r.XC_Segment__c);
                    result = manageCallToZuora(mapDes, caseID, caseToUpdate);

                }else if(mapDes.get('XC_ApprovalStatus__c') == Label.XC_CL_ApprovalProcessNeeded){ // automatic approval needed -> approval process not needed

                    result = checkApprovalProcessAndUpdateCase(caseID, mapDes);

                }else if(mapDes.get('XC_ApprovalStatus__c') == Label.XC_CL_Configuration_Approved){
                    
                    Map<Id,XC_BillingProfileLineItem__c> mabBp= new  Map<Id,XC_BillingProfileLineItem__c>([SELECT XC_ZuoraId__c, XC_BillingProfile__r.XC_Segment__c FROM XC_BillingProfileLineItem__c WHERE id=:mapDes.get('XC_Billing_Profile_Line_Item__c') LIMIT 1]);
                                
                    Case caseToUpdate = new Case();
                    caseToUpdate.ID = caseID;
                    mapDes.put('caseId',caseID);
                    mapDes.put('zuoraAccountId', mabBp.get(mapDes.get('XC_Billing_Profile_Line_Item__c')).XC_ZuoraId__c);
                    mapDes.put('stream', mabBp.get(mapDes.get('XC_Billing_Profile_Line_Item__c')).XC_BillingProfile__r.XC_Segment__c);

                    result = manageCallToZuora(mapDes, caseID, caseToUpdate);

                }else if(mapDes.get('XC_ApprovalStatus__c') == Label.XC_CL_ApprovalProcessRefused){

                    result.success = false;
                    System.debug('Result Success: '+ result.success);
                    result.resultMessage = Label.XC_CL_IndemnificationRefused;
                    System.debug('result update: '+ result.success);
                }
            }
        
        } catch(Exception e) {
            System.debug('Exception '+e.getMessage()+ ' '+e.getLineNumber());
            return result;
        }
        
        return result;

    }


    /**
     * @description manage the call to Zuora 
     * @param mapDes the map with case api field (key) and field value (value)
     * @param caseId the case ID
     * @param caseToUpdate the case to update
     * @return CaseIndemnification
     */
    public static CaseIndemnification manageCallToZuora(Map<String,String> mapDes, String caseID, Case caseToUpdate){

        CaseIndemnification result = new CaseIndemnification();
        
        if(mapDes.get('XC_SentToZuora__c') != Label.XC_CL_Yes){

            caseToUpdate.XC_SentToZuora__c = Label.XC_CL_Yes;
            result = callZuora(mapDes, caseID, caseToUpdate);

        } else if(mapDes.get('XC_SentToZuora__c') == Label.XC_CL_Yes){
            
            if(mapDes.get('XC_SendStatus__c') == Label.XC_CL_DocumentVerification_Ko_Value){
                result = callZuora(mapDes, caseID, caseToUpdate);
            }else{
                result.success = false;
                result.resultMessage = Label.XC_CL_IndemnificationDone;
            }
        }

        return result;
    }


     /**
     * @description callZuora manage the call to Zuora when sentToZuora = No
     * @param mapDes the map with case api field (key) and field value (value)
     * @param caseId the case ID
     * @param caseToUpdate the case to update
     * @return CaseIndemnification
     */
    public static CaseIndemnification  callZuora(Map<String,String> mapDes, String caseID, Case caseToUpdate){

        CaseIndemnification result = new CaseIndemnification(); 

              
        caseToUpdate.XC_SendStatus__c = Label.XC_CL_OkStatus;
        caseToUpdate.XC_ErrorMessage__c = '';
        
        // call zuora
        mapDes.put('CaseId', caseID);
        XC_REST_Indemnification.WrapperResponse  callResult = sendRequestToZuora(mapDes);
        if(callResult.errors != null){
            caseToUpdate.XC_ErrorMessage__c = callResult.errors[0].title;
            caseToUpdate.XC_SendStatus__c = Label.XC_CL_DocumentVerification_Ko_Value;
        }
        /*
        else if(!caseToUpdate.XC_Automatic_Refund__c){
            System.debug('###callZuora - Automatic Refund is false');
            caseToUpdate.Status = Label.XC_CL_Case_Status007;
            caseToUpdate.XC_Result__c =Label.XC_CL_Case_Result001;
            caseToUpdate.XC_Resolution__c =Label.XC_CL_Case_Resolution050;
            caseToUpdate.CaseRemarks__c =Label.XC_CL_CaseRemark_RefundNextInvoice;
        }
        */

        XC_Util_Sobject.WrapperResult wr=XC_Util_Sobject.updateRecord(caseToUpdate);
        result.success = wr.success;
        System.debug('Result Success: '+ result.success);
        result.resultMessage = (result.success) ? Label.XC_CL_OperationCompleted : wr.errorMessage;
        System.debug('result update: '+ result.success);


        return result;
    }


     /**
     * @description sendRequestToZuora to request indemnification
     * @param mapDes the map with case api field (key) and field value (value)
     * @return XC_REST_Indemnification.WrapperResponse
     */
    public static XC_REST_Indemnification.WrapperResponse sendRequestToZuora(Map<String,String> mapDes){

        XC_REST_Indemnification.WrapperRequest wrapReq= new XC_REST_Indemnification.WrapperRequest();
        
        wrapReq.Amount=Decimal.valueof(mapDes.get('XC_Amount__c') );
        wrapReq.AccountId = mapDes.get('zuoraAccountId');
        wrapReq.AutomaticRefund = (mapDes.get('XC_Automatic_Refund__c') == 'true') ? 'Yes' : 'No';
        wrapReq.CaseId= mapDes.get('CaseId');
        wrapReq.legalEntity =  mapDes.get('XC_LegalEntity__c');
        wrapReq.stream =  mapDes.get('stream');
        wrapReq.CommentsForApproval = mapDes.get('XC_Case_Comments__c');
        wrapReq.ReasonCode= mapDes.get('XC_IndemnificationReason__c');
        XC_REST_Indemnification.WrapperResponse resultRest = XC_REST_Indemnification.createIndemnification(wrapReq);
        
        return resultRest;

    }


    /**
     * @description casting input value with the correct type
     * @param c the case to update 
     * @param mapCase the map case
     * @return the case to update
     */
    public static Case checkUpdateField(Case c, Map<String,String> mapCase){

         for( String field: mapCase.keySet() ){
            if(mapCase.get(field)!= null ){
                System.debug('update '+field+': ' + mapCase.get(field) );
                if(field == 'XC_Amount__c') {
                // System.debug('Campo: '+ field + 'Valore: '+Decimal.valueOf(mapCase.get(field)));
                    c.put(field,Decimal.valueOf(mapCase.get(field)));
                } else if(field == 'XC_Automatic_Refund__c'){
                    c.put(field, Boolean.valueOf(mapCase.get(field)));
                } else {
                    c.put(field, mapCase.get(field));
                }
            }
        }
        return c; 
    }


    /**
     * @description check if process already started otherwise start process and update the case
     * @param caseId the case ID
     * @param mapDes the map with case api field (key) and field value (value)
     * @return CaseIndemnification
     */
    public static CaseIndemnification checkApprovalProcessAndUpdateCase(String caseID, Map<String,String> mapDes){

        CaseIndemnification result = new CaseIndemnification(); 

        // check if process already start 
        Map<Id, ProcessInstance> piMap = new  Map<Id, ProcessInstance> ([Select ID From ProcessInstance  Where TargetObjectID =: caseID]);
        if(!piMap.values().isEmpty()){
            result.success = false; 
            result.resultMessage = Label.XC_CL_PendingApproval;
            return result;
        } else{

            Case caseToUpdate = new Case();
            caseToUpdate.Id = caseID; 
            checkUpdateField(caseToUpdate, mapDes);
            caseToUpdate.Status=XC_AT_Constants.TRIGGER_STATUS_ESTA002;

            XC_Util_Sobject.WrapperResult wr=XC_Util_Sobject.updateRecord(caseToUpdate);
            result.success = wr.success;

            if(result.success){
                result.resultMessage = Label.XC_CL_OperationCompleted;
            }else{
                result.resultMessage =  wr.errorMessage;
                return result; 
            }
        
            result =  manageApprovalProcess(caseID); 
        }

        return result;
    }


    /**
     * @description manage the approval process
     * @param caseId the case ID
     * @return CaseIndemnification
     */
    public static CaseIndemnification  manageApprovalProcess(String caseID){

        CaseIndemnification result = new CaseIndemnification(); 

        // start approval process
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(caseID);
        req1.setProcessDefinitionNameOrId('XC_AP_Case_Indemnification3'); // name of approval process
        
        Approval.ProcessResult resultApproval = Approval.process(req1); // Submit the approval request for the account
        
        if(resultApproval.isSuccess()){
            result.resultMessage = Label.XC_CL_OperationCompleted;
            result.success = true;
        }else{
            result.resultMessage = Label.XC_CL_SomethingWrong;
            result.success = false;
        }

        return result;
    }


     /**
     * @description getAmount get the Amount value based on indemnification reason
     * @param indemnificationReason the indemnification Reason
     * @return ResultWrapper
     */
    @AuraEnabled 
    public static ResultWrapper getAmount(String indemnificationReason){
      
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getAmount - indemnificationReason='+indemnificationReason);
        ResultWrapper rw= new ResultWrapper();
        if(!Schema.SObjectType.Case.isAccessible() && !Schema.SObjectType.Account.isAccessible()  ) {
            return rw;
        }

        try{
            Map<Id,XC_CM_IndemnificationDependencies__mdt> indemnifMap = new Map<Id,XC_CM_IndemnificationDependencies__mdt>(
                                                    [SELECT XC_Amount__c, XC_AutomaticApproval__c FROM XC_CM_IndemnificationDependencies__mdt 
                                                    WHERE  XC_IndemnificationReason__c =: indemnificationReason
                                                    LIMIT 1]);
            
            rw.mapfieldCase.put('XC_Amount__c', indemnifMap.values()[0].XC_Amount__c);
            rw.mapfieldCase.put('XC_AutomaticApproval__c', indemnifMap.values()[0].XC_AutomaticApproval__c);
        }catch(Exception e){
            System.debug(e.getMessage() );
        }
        return rw;

    }


}