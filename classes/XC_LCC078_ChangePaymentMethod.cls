/**
*@author Monica Cutillo - monica.cutillo@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
*@date Creation 13/02/2019
*@date Modification dd/MM/yyyy
*@description XC_LCC078_ChangePaymentMethod - Controller of XC_LCP078_ChangePaymentMethod component, to update the PaymentMethodId on Billing Profile
*/
public without sharing class XC_LCC078_ChangePaymentMethod {

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description Check to change payment method.
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkToChangePaymentMethod(String recordId){
        System.debug('@@@@ checkToChangePaymentMethod - recordId='+recordId);
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        List<NE__Billing_Profile__c> billingProfile = new List<NE__Billing_Profile__c>();
        if(Schema.sObjectType.NE__Billing_Profile__c.fields.Id.isAccessible() && Schema.sObjectType.NE__Billing_Profile__c.fields.NE__Payment__c.isAccessible() && Schema.sObjectType.NE__Billing_Profile__c.fields.Zuora_Account_Id__c.isAccessible() && Schema.sObjectType.NE__Billing_Profile__c.fields.NE__Account__c.isAccessible() &&  Schema.SObjectType.NE__Billing_Profile__c.isAccessible()){
            billingProfile = [
                SELECT Id, NE__Payment__c, Zuora_Account_Id__c,XC_MandateType__c,NE__Account__r.XC_Country__c, XC_CommodityContractID__c,XC_CommodityCupsID__c, NE__Iban__c,
                    (SELECT ID,Name,XC_LegalEntity__c,XC_CustomerAccount__c,XC_CustomerAccount__r.Name,
                    XC_ZuoraId__c
                    ,XC_BillToAddress__c,XC_SoldToAddress__c,XC_BillToContactId__c,XC_SoldToContactId__c
                    FROM Billing_Profile_Line_Items__r
                    WHERE XC_Status__c='Active')
                FROM NE__Billing_Profile__c
                WHERE Id =: recordId LIMIT 1];
            
            System.debug('@@@@ billingProfile[0].NE__Payment__c='+billingProfile[0].NE__Payment__c);
        }

        if(billingProfile[0].Billing_Profile_Line_Items__r.isEmpty()){
            throw new AuraHandledException(Label.XC_CL_UpdateMOP_NoActive_Error);
        }


        //if((billingProfile[0].NE__Payment__c == null && billingProfile[0].NE__Payment__c != Label.XC_CL_DirectDebt)  && billingProfile[0].NE__Payment__c != Label.XC_CL_Credit_Card ){
        if( billingProfile[0].NE__Payment__c != 'Direct Debt' && billingProfile[0].NE__Payment__c != 'Credit Card' && billingProfile[0].NE__Payment__c != 'Commodity Bill'){
            rw.success = false;
            rw.resultMessage = Label.XC_CL_PaymentMethodNotEditable;
            return rw;
        }
        // if(billingProfile[0].NE__Payment__c == Label.XC_CL_DirectDebt){ 
        //     billingProfile[0].NE__Payment__c = 'SEPA';
        // }
        
        Account a = [SELECT id, (SELECT Id FROM Contacts WHERE XC_PrimaryContact__c=true limit 1) FROM Account where id=: billingProfile[0].NE__Account__c];
        
        List<Contact> primaryContact = a.Contacts;
        Map<String,Object> mapObjInfo = new Map<String,Object>();
        
        mapObjInfo.put('NE__Payment__c', billingProfile[0].NE__Payment__c);
        mapObjInfo.put('AccountId', billingProfile[0].NE__Account__c);
        mapObjInfo.put('ContactId', primaryContact[0].Id);
        // mapObjInfo.put('Zuora_Account_Id__c', billingProfile[0].Zuora_Account_Id__c);
        mapObjInfo.put('Country__c', billingProfile[0].NE__Account__r.XC_Country__c);
        mapObjInfo.put('AffectedBpli',billingProfile[0].Billing_Profile_Line_Items__r);
        mapObjInfo.put('SEPAMandates',getSepaMandatePickList());
        mapObjInfo.put('currentMandate',billingProfile[0].XC_MandateType__c);
        mapObjInfo.put('NE__Iban__c', billingProfile[0].NE__Iban__c);

        if(billingProfile[0].NE__Payment__c == Label.XC_CL_Commodity_Bill){
            mapObjInfo.put('commodityContract',billingProfile[0].XC_CommodityContractID__c);
            mapObjInfo.put('commodityCUPS',billingProfile[0].XC_CommodityCupsID__c);
        }
        
        rw.objectInfo = JSON.serialize(mapObjInfo);
        rw.success = true;
        return rw;
    }

    /**
    *@description Creates the payment method.
    *@param paymentMethod the payment method
    *@param entityName the entity name
    *@return the string
    */
    @AuraEnabled
    public static String createPaymentMethod(String paymentMethod, String entityName){
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        ZuoraWebservice.CreatePaymentMethodResponse resp = zws.createPaymentMethod(paymentMethod);
        return JSON.serialize(resp);     
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to call Sia and manage Operation after call
     * @param contactId
     * @param lang
     * @param paymentMethod
     * @param billingProfileId
     
     *@return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper manageOperationBeforeCallSia(String contactId,String lang,String paymentMethod,String billingProfileId){
        
        return ZuoraBillingProfileCreationController.manageOperationBeforeCallSia(contactId,lang,paymentMethod,billingProfileId);
    }

    /**
    *@description Creates the payment method.
    *@param paymentMethod the payment method
    *@param entityName the entity name
    *@param billingProfId the billingProfId
    *@return the string
    */
    @AuraEnabled
    public static Map<String,Object> updatePaymentMethod(String paymentMethod,String billingProfId){
        System.debug('entrato in updatePaymentMethod');

        //TODO:Change return value F.Imperioli
        Map<String,Object> result = new Map<String,Object>();

        // List<String> paymentWrapper = new List<String>(); 
        Map<String, Object> paymentMethodNew = (Map<String, Object>)JSON.deserializeUntyped(paymentMethod);
        Map<Id, NE__Billing_Profile__c> bpMap = new  Map<Id, NE__Billing_Profile__c>([select id, Name, XC_Segment__c, (Select ID, XC_ZuoraId__c,XC_LegalEntity__c from Billing_Profile_Line_Items__r) from NE__Billing_Profile__c WHERE id=:billingProfId LIMIT 1] ); 
        List<NE__Billing_Profile__c> bpList = bpMap.values();
        NE__Billing_Profile__c bp = bpList[0];


       
        for(XC_BillingProfileLineItem__c bpli : bp.Billing_Profile_Line_Items__r ){
            if(bpli.XC_ZuoraId__c!=null){
                paymentMethodNew.put('AccountId', bpli.XC_ZuoraId__c);
                paymentMethodNew.put('AccountKey', bpli.XC_ZuoraId__c);
                String entityName = XC_Util_Integration_U.getEntityNameWithStream(bpli.XC_LegalEntity__c, bp.XC_Segment__c);
                ZuoraWebservice zws = new ZuoraWebservice(entityName);
                ZuoraWebservice.CreatePaymentMethodResponse resp = zws.updatePaymentMethod(JSON.serialize(paymentMethodNew));
                resp.ZuoraAccountId = bpli.XC_ZuoraId__c;
                // paymentWrapper.add(JSON.serialize(resp));
                result.put(entityName,JSON.serialize(resp));

            } 
        }
        return result;
    }


    /**
    *@description Link payment method to account.
    *@param zuoraAccountId the zuora account id
    *@param paymentMethodId the payment method id
    *@param entityName the entity name
    *@return the string
    */
    @AuraEnabled
    public static String linkPaymentMethodToAccount(String zuoraAccountId, String paymentMethodId, String entityName,String gateWay){
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        ZuoraWebservice.LinkPaymentMethodToAccountResponse resp;
        if(String.isNotBlank(gateWay)){
            resp= zws.linkPaymentMethodToAccountWithGateWay(zuoraAccountId, paymentMethodId,gateWay);
        }else{
            resp = zws.linkPaymentMethodToAccount(zuoraAccountId, paymentMethodId,entityName);
        }

        if(resp.integrationLog!=null){
            List<XC_Integration_Log__c> logs = new List<XC_Integration_Log__c>{resp.integrationLog};
            XC_UTIL_Sobject.insertListRecords(logs);
        }
        System.debug('Response from zuora = '+resp);
        return JSON.serialize(resp);
    }

    /**
     *@description Creates the change payment method case.
     *@param recordId the record id
     *@return the XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createChangePaymentMethodCase(String recordId, String oldValue) {

        system.debug('ENTRO A createCase');
        XC_UTIL_ResultWrapper newWr = new XC_UTIL_ResultWrapper();
        newWr.success=false;

        List<String> caseSettingNames = new List<String>{Label.XC_CL_ChangePaymentMethod};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        if(caseSettingsMap.isEmpty() || caseSettingsMap.get(Label.XC_CL_ChangePaymentMethod)==null){
            System.debug('@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+Label.XC_CL_ChangePaymentMethod);
            System.debug('@@@@@ Case By Insistence NOT created!');
            newWr.resultMessage =  String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_ChangePaymentMethod});
            return newWr;
        }
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_ChangePaymentMethod);
        System.debug('@@@@@ caseSettings='+caseSettings);
        
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
        //Id recordTypeId = CaseDAO.newInstance().getActiveRecordtypeIdByDeveloperName(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA);

        NE__Billing_Profile__c bp = [SELECT Id, NE__Account__c, NE__Iban__c, NE__Payment__c, XC_LegalEntity__c
                                    FROM NE__Billing_Profile__c
                                    WHERE Id = :recordId];

        Contact primaryContact = [SELECT Id FROM Contact WHERE XC_PrimaryContact__c = true AND AccountId = :bp.NE__Account__c];

        //caso.RecordTypeId = recordTypeId;
      
        caso.Reason = caseSettings.XC_Case_Reason__c;
        caso.SubCause__c = caseSettings.XC_Sub_Cause__c;
        caso.XC_Subtype__c = caseSettings.XC_Sub_Type__c;
        caso.Status = caseSettings.XC_Status__c;
        caso.Origin = caseSettings.XC_Origin__c;
        caso.Priority = caseSettings.XC_Priority__c;
        caso.AccountId = bp.NE__Account__c;
        caso.ContactId = primaryContact.Id;
        caso.XC_IsCloned__c = true;
        if(!String.isBlank(oldValue) && bp.NE__Payment__c == Label.XC_CL_DirectDebt){

            Map<String,String> labelParameters = new Map<String,String>();
            labelParameters.put('<1>', oldValue);
            labelParameters.put('<2>', bp.NE__Iban__c);
            labelParameters.put('<Método de Pago>', Schema.NE__Billing_Profile__c.fields.NE__Iban__c.getDescribe().getLabel());
            caso.CaseRemarks__c = XC_UTIL_Case_U.getCaseRemarksByLegalEntity(caseSettings, bp.XC_LegalEntity__c, labelParameters);
            //caso.CaseRemarks__c = caseSettings.XC_CaseRemarks__c.replace('<Método de Pago>', Schema.NE__Billing_Profile__c.fields.NE__Iban__c.getDescribe().getLabel()).replace('<1>', oldValue).replace('<2>', bp.NE__Iban__c);
        }

        XC_UTIL_SObject.WrapperResult wr = XC_UTIL_SObject.insertRecord(caso);

        return new XC_UTIL_ResultWrapper(wr);

    }


        /**
    *@author: francesco imperioli - fimperioli@deloitte.it
    *@description : retrieve dynamically available payment methods from Billing Profile Object.
    *@createddate 2019-11-06 - modified 18-11-2019 added legalentity filter
    **/
    @AuraEnabled
    public static Map<String,Object> getPaymentMethodsPicklist(){

        Map<String,Object> result = new Map<String,Object>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.NE__Payment__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            result.put(ple.getLabel(),ple.getValue());
        }
        // return filterMopWithLegalEntity(legalEntity, result);
        return result;
    }

    /**
    *@author: Francesco Imperioli-fimperioli@deloitte.it
    *@description : returns picklist values for SepaMandate field on Billing profile Object
    *@return List<String> of picklistvalues
    **/
    private static Map<String,Object> getSepaMandatePickList(){
        Map<String,Object> result = new Map<String,Object>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.XC_MandateType__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            result.put(ple.getLabel(),ple.getValue());
        }
        return result;
    }


    /**
    *@author: Francesco Imperioli-fimperioli@deloitte.it
    *@description: update current billing profile with new debtor code or account number 
    *@return the boolean
    */
    @AuraEnabled
    public static Map<String,Object> updateCurrentBillingProfile(Map<String,Object> paramsInfo){
        Map<String,Object> result = new Map<String,Object>(); 
        String recordId = String.valueOf(paramsInfo.get('bpId'));
        String mop = String.valueOf(paramsInfo.get('mop'));
        // String SIAToken = String.valueOf(paramsInfo.get('debtorCode'));
        String accountNumber = String.valueOf(paramsInfo.get('accountNumber'));
        String bic = String.valueOf(paramsInfo.get('bic'));
        String mandateType = String.valueOf(paramsInfo.get('mandateType'));
        List<XC_BillingProfileLineItem__c> childrenToUpdate = new List<XC_BillingProfileLineItem__c>();

        
        NE__Billing_Profile__c currentBp = [SELECT ID,XC_LegalEntity__c,XC_Status__c,XC_TalendProcessed__c,XC_SepaAutoNumber__c,NE__Account__c,NE__Payment__c,
            (SELECT Id,XC_Status__c FROM Billing_Profile_Line_Items__r WHERE XC_Status__c = 'Active') 
        FROM NE__Billing_Profile__c WHERE ID = :recordId LIMIT 1];

        String currentMOP = currentBp.NE__Payment__c;


        //check duplication on SEPA:
        Boolean skip = paramsInfo.get('skipDuplication') == null ? false : Boolean.valueOf(paramsInfo.get('skipDuplication'));
        if(mop == 'Direct Debt'&&!skip){
            String mopName = mop + ' - ' + accountNumber;
            List<NE__Billing_Profile__c> checkDuplicates = [SELECT ID,Name FROM NE__Billing_Profile__c WHERE Id!=:recordId AND Name = :mopName AND XC_BIC__c = :bic LIMIT 1];
            
            if(!checkDuplicates.isEmpty()){
                String dupErrorCode = Label.XC_CL_UpdateMOP_DUP_Error + ' '+ checkDuplicates[0].Name;
                throw new AuraHandledException(dupErrorCode);
            }
        }
        //NE__Billing_Profile__c currentBp = new NE__Billing_Profile__c(Id = recordId);
        // currentBP.XC_Token__c = SIAToken;

        //only in case of update from commodity field, we have to update also the payment method field
        if(currentMop!=mop && currentMop==Label.XC_CL_Commodity_Bill){
            currentBp.NE__Payment__c = mop;
            currentBp.XC_CommodityContractID__c = null;
            currentBp.XC_CommodityCupsID__c = null;
        }

        if(String.isNotBlank(accountNumber) && mop == 'Direct Debt'){

            //Add Italy custom sepa management
            List<XC_CM_SEPA_Configuration__mdt> SEPAConfigurations = [SELECT 
            XC_LegalEntity__c,XC_MandateCodeFormat__c,XC_Segment__c,
            XC_SIASDDAgencyCode__c,XC_SIASDDRequestCause__c,XC_SIASDDSEPASchema__c,
            XC_SIASDDSequenceType__c,XC_SIASDDServiceLevel__c,XC_SIASDDCreditorCode__c 
            FROM XC_CM_SEPA_Configuration__mdt WHERE XC_LegalEntity__c = :currentBp.XC_LegalEntity__c LIMIT 1];

            //check if sepa must be autoactivated for this LE
            List<XC_CM_LegalEntity_Configuration__mdt> currentConfiguration = [SELECT XC_LegalEntity__c,XC_DisableSDDAutoActive__c 
                        FROM XC_CM_LegalEntity_Configuration__mdt 
                        WHERE XC_LegalEntity__c = :currentBp.XC_LegalEntity__c AND XC_OrgId__c = :UserInfo.getOrganizationId() LIMIT 1];

            Integer randomNumber = Math.round((Math.random() * (900000) + 100000));
            currentBp.Name = mop + ' - ' + accountNumber;
            currentBp.XC_BIC__c = bic;
            currentBp.NE__Iban__c = accountNumber;

            //check on italian configuration
            if(!SEPAConfigurations.isEmpty()){

                XC_CM_SEPA_Configuration__mdt currentConf = SEPAConfigurations[0];
                String progressiveCode = '2'+DateTime.now().getTime();
                currentBp.XC_SepaMandate__c = currentConf.XC_MandateCodeFormat__c.replace('{autonumber}',progressiveCode.length()>9 ? progressiveCode.substring(0,8) : progressiveCode);
                currentBp.XC_SIASDDAgencyCode__c = currentConf.XC_SIASDDAgencyCode__c;
                currentBp.XC_SIASDDRequestCause__c = currentConf.XC_SIASDDRequestCause__c;
                currentBp.XC_SIASDDSEPASchema__c = currentConf.XC_SIASDDSEPASchema__c;
                currentBp.XC_SIASDDSequenceType__c = currentConf.XC_SIASDDSequenceType__c;
                currentBp.XC_SIASDDServiceLevel__c = currentConf.XC_SIASDDServiceLevel__c;
                currentBp.XC_SIASDDCreditorCode__c = currentConf.XC_SIASDDCreditorCode__c;

            }else{
                currentBp.XC_SepaMandate__c = 'SEPA'+randomNumber+currentBp.XC_SepaAutoNumber__c+'XC'+String.valueof(DateTime.now().getTime());
            }
            //currentBp.XC_SepaMandateDate__c = Date.today();
            currentBp.XC_SepaMandateDate__c = DateTime.Now().dateGMT();
            currentBp.XC_MandateType__c = mandateType;

            //check on status 
            if(!currentConfiguration.isEmpty() && currentConfiguration[0].XC_DisableSDDAutoActive__c){
                currentBp.XC_Status__c = 'Waiting External Activation';
                currentBp.XC_TalendProcessed__c = false;
                for(XC_BillingProfileLineItem__c bpli : currentBp.Billing_Profile_Line_Items__r){
                    bpli.XC_Status__c = 'Waiting External Activation';
                    childrenToUpdate.add(bpli);
                }
            }

        
        }else if(mop == 'Credit Card'){

            currentBp.Name = 'Credit Card - ';
            for(XC_BillingProfileLineItem__c bpli : currentBp.Billing_Profile_Line_Items__r){
                bpli.XC_Status__c = 'Draft';
                childrenToUpdate.add(bpli);
            }

        }


        if(!childrenToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(childrenToUpdate);
        }

       XC_UTIL_Sobject.WrapperResult resultUpdate = XC_UTIL_Sobject.updateRecord(currentBp);
       result.put('success',resultUpdate.success);

       if(mop=='Direct Debt'){
           result.put('mandateID',currentBP.XC_SepaMandate__c);
           result.put('mandateDate',currentBP.XC_SepaMandateDate__c);
       }

       return result;

    }


    /**
    * @description global method to update back the billing profile data in case of error, called from component
    * @author Francesco Imperioli - fimperioli@deloitte.it | 09-18-2020 
    * @param oldBpInfo 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> rollbackBP(Map<String,Object> oldBpInfo){
        
        Map<String,Object> result = new Map<String,Object>();
        NE__Billing_Profile__c bpToUpdate = new NE__Billing_Profile__c(Id=String.valueOf(oldBpInfo.get('Id')));

        for(String fieldName : oldBpInfo.keySet()){
            if(fieldName!='XC_SepaMandateDate__c'){
                bpToUpdate.put(fieldName,String.valueOf(oldBpInfo.get(fieldName)));
            } else {
                bpToUpdate.put(fieldName,Date.valueOf(oldBpInfo.get(fieldName)));
            }
            
        }

        XC_UTIL_Sobject.WrapperResult updateRes =  XC_UTIL_Sobject.updateRecord(bpToUpdate);
        result.put('success',updateRes.success);

        return result;

    }

}