/**
* @author Pasquale Pelliccia ppelliccia@deloitte.it
* @date Creation 29/11/2018
* @date Modification 29/11/2018
* @description Utility class for executing rest calls to Zuora
*/

public class ZuoraWebservice{

    /********Class Fields********/

    public String host;
    public String entityId;
    public String entityName;
    public String client_secret; //
    public String client_id; //
    public String sequenceSetId;//
    public String apiToken;
    public String currencyIsoCode;
    public String token;

    /********Object Class Wrappers********/

    public class CreatePaymentMethodResponse{
        public String Id;
        public String Success;
        public List<Error> Errors;
        public String ZuoraAccountId;
        /** @description XC_UTIL_IntegrationLog to insert **/
        public XC_Integration_Log__c integrationLog;
    }


    public class Reason{
        public String code;
        public String message;
    }
    public class CreateZuoraAccountResponse{

        public String success;
        public String accountId;
        public String accountNumber;
        public String paymentMethodId;

        public String processId;
        public List<Reason> reasons;
        /** @description XC_UTIL_IntegrationLog to insert **/
        public XC_Integration_Log__c integrationLog;
    }


    public class Error{
        public String Code;
        public String Message;
    }
    public class LinkPaymentMethodToAccountResponse{
        public String Success;
        public String Id;
        public List<Error> Errors;
        /** @description XC_UTIL_IntegrationLog to insert **/
        public XC_Integration_Log__c integrationLog;
    }


    public class RequestWrapper{
        public String comment;
        public FinanceInformationWrapper financeInformation;
        public String methodType;
        public String reasonCode;
        public String referenceId;
        public String refundDate;
        public String secondRefundReferenceId;
        public Double totalAmount;		// Y
        public String type;				// Y
        public String IntegrationIdNS;
        public String IntegrationStatusNS;
        public String OriginNS;
        public String SyncDateNS;
        public String SynctoNetSuiteNS;
    }


    public class ResponseWrapper{
        public String accountId;
        public Double amount;
        public String cancelledOn;
        public String comment;
        public String createdById;
        public String createdDate;
        public String creditMemoId;
        public FinanceInformationWrapper financeInformation;
        public String gatewayId;
        public String gatewayResponse;
        public String gatewayResponseCode;
        public String gatewayState;
        public String id;
        public String markedForSubmissionOn;
        public String methodType;
        public String numberResponse;
        public String paymentId;
        public String paymentMethodId;
        public String paymentMethodSnapshotId;
        public String reasonCode;
        public String referenceId;
        public String refundDate;
        public String refundTransactionTime;
        public String secondRefundReferenceId;
        public String settledOn;
        public String softDescriptor;
        public String softDescriptorPhone;
        public String status;
        public String submittedOn;
        public Boolean success;
        public String type;
        public String updatedById;
        public String updatedDate;
        public String IntegrationIdNS;
        public String IntegrationStatusNS;
        public String OriginNS;
        public String SyncDateNS;
        public String SynctoNetSuiteNS;
        public ReasonWrapper[] reasons;
    }
    public class FinanceInformationWrapper{
        public String bankAccountAccountingCode;
        public String bankAccountAccountingCodeType;
        public String transferredToAccounting;
        public String unappliedPaymentAccountingCode;
        public String unappliedPaymentAccountingCodeType;
    }

    public class ReasonWrapper{
        String code;
        String message;
    }

    public class GenerateRSASignatureResponse{
        public String signature;
        public String token;
        public String tenantId;
        public String key;
        public String success;
    }


    public class GetProductRatePlansResponse{
        public List<ProductRatePlan> productRatePlans;
        public Boolean success;
    }
    public class ProductRatePlanCharge{
        public String id;
        public String type;
    }
    public class ProductRatePlan{
        public String id;
        public List<ProductRatePlanCharge> productRatePlanCharges;
    }

    public class GetSubscriptionResponse {
        public List<RatePlan> ratePlans;
    }

    public class RatePlan{
        public String id;
        public List<RatePlanCharge> ratePlanCharges;
    }

    public class RatePlanCharge{
        public String type;
    }

    public class CreateSendInvoiceToCommodityLog{
        public String Id;
        public String Success;
        public List<Error> Errors;
        public String ZuoraAccountId;
        /** @description XC_UTIL_IntegrationLog to insert **/
        public XC_Integration_Log__c integrationLog;
    }

    public class requestEditPlafond{
        public String IDCRM;
        public String Scadenza;
        public String Plafond;
        public String Residuo;
    }



    /*******START OF CLASS METHODS********/


    public ZuoraWebservice(String entityName){

        //Constructor Method to get entity references and ids

        String entity = '%'+entityName+'%';
        String orgId = UserInfo.getOrganizationId();
        XC_CM_ZuoraOAuth__mdt authData = [SELECT Id, XC_EntityName__c, XC_ClientId__c, XC_ClientSecret__c, XC_EntityId__c, XC_Host__c, XC_apiToken__c, XC_SequenceSetId__c, XC_Currency__c, XC_OrgName__c FROM XC_CM_ZuoraOAuth__mdt WHERE XC_EntityName__c LIKE:entity AND XC_OrgId__c =: orgId][0];
        this.host = authData.XC_Host__c;
        this.entityId = authData.XC_EntityId__c;
        this.entityName = entityName;
        this.client_secret = authData.XC_ClientSecret__c;
        this.client_id = authData.XC_ClientId__c;
        this.sequenceSetId = authData.XC_SequenceSetId__c;
        this.apiToken = authData.XC_apiToken__c;
        this.currencyIsoCode = authData.XC_Currency__c;

        System.debug('[ZuoraWebservice] OrgName: ' + authData.XC_OrgName__c +  ' - ZuoraEntityName: '+ authData.XC_EntityName__c);
    }


    /**
    * @description create payment method object on zuora, needs a full json in input
    * @author Francesco Imperioli - fimperioli@deloitte.it | 01-29-2021 
    * @param paymentMethod 
    * @return CreatePaymentMethodResponse 
    **/
    public CreatePaymentMethodResponse createPaymentMethod(String paymentMethod){

        CreatePaymentMethodResponse wrapperRes = new CreatePaymentMethodResponse();
        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        headerDefinitions.put('Zuora-Entity-Ids', this.entityId);

        String body = paymentMethod;
        String url = 'callout:XC_ZuoraBasePath/v1/object/payment-method';
        HttpRequest req = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        
        //http callout

        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'createPaymentMethod';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
        
        //integration log management can be inserted on demand
    
        HTTPResponse res = httpRWr.response;
        wrapperRes = (CreatePaymentMethodResponse) JSON.deserialize(res.getBody(), CreatePaymentMethodResponse.class);
        XC_Integration_Log__c intLog = httpRWr.integrationLog.get(0);
        intLog.XC_Log_ServerSystem__c = 'Zuora';
        wrapperRes.integrationLog = intLog;

        return wrapperRes;
    }


    /**
    * @description update a payment method on zuora, needs a full json in iput
    * @author Francesco Imperioli - fimperioli@deloitte.it | 01-29-2021 
    * @param paymentMethod 
    * @return CreatePaymentMethodResponse 
    **/
    public CreatePaymentMethodResponse updatePaymentMethod(String paymentMethod){
        
        CreatePaymentMethodResponse wrapperRes = new CreatePaymentMethodResponse();
        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        headerDefinitions.put('Zuora-Entity-Ids', this.entityId);

        String body = paymentMethod;
        String url = 'callout:XC_ZuoraBasePath/v1/object/payment-method';
        HttpRequest req = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);

        //http callout
        
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'updatePaymentMethod';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);

        //integration log management can be inserted on demand

        HTTPResponse res = httpRWr.response;
        wrapperRes = (CreatePaymentMethodResponse) JSON.deserialize(res.getBody(), CreatePaymentMethodResponse.class);
        XC_Integration_Log__c intLog = httpRWr.integrationLog.get(0);
        intLog.XC_Log_ServerSystem__c = 'Zuora';
        wrapperRes.integrationLog = intLog;

        return wrapperRes;
    }


    // public String getAccessToken(){

    //     if(Test.isRunningTest())
    //         return '';

    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint('https://'+this.host+'/oauth/token');
    //     req.setMethod('POST');
    //     req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    //     req.setBody('grant_type=client_credentials'+'&client_secret='+ EncodingUtil.urlEncode(this.client_secret, 'UTF-8')+'&client_id='+this.client_id);
    //     System.debug('Body -> ' + req.getBody());
    //     System.debug('Request -> ' + req);
    //     Http http = new Http();
    //     HTTPResponse res = http.send(req);
    //     System.debug('res-->'+res);
    //     Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

    //     return (String) response.get('access_token');
    // }


    /**
    * @description create zuora billing account for b2b stream
    * @author Francesco Imperioli - fimperioli@deloitte.it | 01-29-2021 
    * @param salesforceAccount 
    * @param billTo 
    * @param soldTo 
    * @param options 
    * @param billingProfLineItemId 
    * @param zuoraPayment 
    * @return CreateZuoraAccountResponse 
    **/
    public CreateZuoraAccountResponse createUnlinkedZuoraAccountB2B(Account salesforceAccount, Contact billTo, Contact soldTo, String options, String billingProfLineItemId, String zuoraPayment ){
        
        
        CreateZuoraAccountResponse returnResp = new CreateZuoraAccountResponse();
        Map<String,Object> bodyMap = new Map<String,Object>();
        XC_BillingProfileLineItem__c currentBpli = (XC_BillingProfileLineItem__c) XC_UTIL_Sobject.selectAllFields(billingProfLineItemId)[0];
    
    
    
        String autoPay = 'false';
        String stream = salesforceAccount.XC_Segment__c;
        String firstName = salesforceAccount.XC_FirstName__c == null ? null : salesforceAccount.XC_FirstName__c.replaceAll('"', '').replaceAll('°', '').replaceAll('\\\\ ', ' ').normalizeSpace();
        salesforceAccount.XC_FirstName__c = firstName;
        String lastName = salesforceAccount.XC_LastName__c == null ? null : salesforceAccount.XC_LastName__c.replaceAll('"', '').replaceAll('°', '').replaceAll('\\\\ ', ' ').normalizeSpace();
        salesforceAccount.XC_LastName__c = lastName;
        String name = salesforceAccount.name == null ? null : salesforceAccount.name.replaceAll('"', '').replaceAll('°', '').replaceAll('\\\\ ', ' ').normalizeSpace();
        salesforceAccount.name = name;
        String PrimaryEmail = salesforceAccount.PrimaryEmail__c  == null ? null : salesforceAccount.PrimaryEmail__c.replaceAll('\\.@', '@');
        salesforceAccount.PrimaryEmail__c = PrimaryEmail;
        String accountHpmCreditCardPaymentMethodId =   'null';
        String accountBillCycleDay = '1';
        String soldToContactJSON = generateContactObjectJSON(soldTo);
        String billToContactJSON = generateContactObjectJSON(billTo);
        String additionalFields = ZuoraWebserviceUtil.generateAdditionalFields('zqu__CustomAccountFields','Account', salesforceAccount);
        Map<String, Object> optionsMap = (Map<String, Object>)JSON.deserializeUntyped(zuoraPayment);

        Map<String,Object> optionsToDeserialize = (Map<String,Object>) JSON.deserializeUntyped(options);
        Boolean invoiceDeliveryPrefsEmail = (Boolean)optionsToDeserialize.get('invoiceDeliveryPrefsEmail');
        if(invoiceDeliveryPrefsEmail != null && invoiceDeliveryPrefsEmail){
            if(String.isBlank(billTo.email)){
                optionsToDeserialize.put('invoiceDeliveryPrefsEmail',false);
                optionsToDeserialize.put('invoiceDeliveryPrefsPrint',true);
            }
        }

        //[R1.1 2022 - NR2459 - mariateresa.mollica@accenture - 06/06/2022 - added new legal entity EnelXEwiva to the Set ]
        Set<String> itaLE = new Set<String>{'EnelXEwiva','EnelXItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMobility','Cogenio', 'EnelXMSP','EnelXMobilityItalia','EnelXMobilityHolding'};
        if(itaLE.contains(String.valueOf(optionsMap.get('legalE')))) {
            soldToContactJSON = getEnrichExtraContactFieldsB2B(soldToContactJSON, billingProfLineItemId);
            billToContactJSON = getEnrichExtraContactFieldsB2B(billToContactJSON, billingProfLineItemId);
        }

        
        String language = optionsMap.containsKey('language') ? String.valueOf(optionsMap.get('language')) :
                        optionsMap.containsKey('invoicePreferredLanguage') ? adjustLanguage_CM(String.valueOf(optionsMap.get('invoicePreferredLanguage'))) :
                        adjustLanguage_CM(billTo.XC_Preferredlanguageofcontact__c);

        String sohoType = optionsMap.containsKey('sohoType') ? String.valueOf(optionsMap.get('sohoType')) : 
                        String.isNotBlank(salesforceAccount.XC_SohoType__c) ? salesforceAccount.XC_SohoType__c : '';

        Boolean fromBillingProfile = optionsMap.containsKey('fromBillingProfile') ? Boolean.valueOf(optionsMap.get('fromBillingProfile')) : false;
        String contractId = optionsMap.containsKey('contractId') ? String.valueOf(optionsMap.get('contractId')) : '';
        String nif = optionsMap.containsKey('docNif') ? String.valueOf(optionsMap.get('docNif')) : '';
        String docNumber = optionsMap.containsKey('docNumber') ? String.valueOf(optionsMap.get('docNumber')) : '';
        String expedition = optionsMap.containsKey('expedition') ? String.valueOf(optionsMap.get('expedition')) : '';
        String expiration = optionsMap.containsKey('expiration') ? String.valueOf(optionsMap.get('expiration')) : '';
        String personTypeCode = optionsMap.containsKey('personTypeCode') ? String.valueOf(optionsMap.get('personTypeCode')) : '';
        String countryCode = optionsMap.containsKey('countryCode') ? String.valueOf(optionsMap.get('countryCode')) : '';
        String legalEntity= optionsMap.containsKey('legalE') ? String.valueOf(optionsMap.get('legalE')) : '';
        String smartInvoice = String.valueOf(optionsMap.containsKey('smartInvoice')).equalsIgnoreCase('SmartInvoice') ? 'Yes': 'No';
        String tradingPartner = (sohoType == Label.XC_CL_AssociatedCompaniesSohoType || sohoType == 'B2B') && !String.isBlank(salesforceAccount.XC_TradingPartner__c) ? salesforceAccount.XC_TradingPartner__c :'NaN';
        String sequenceSetId =  '';
        String taxInfo = '';
        String activitySector =salesforceAccount.XC_GIRO__c; 
        String docNumber2 = salesforceAccount.XC_IdentityNumber2__c;
        String docType2 = salesforceAccount.XC_DocumentType2__c;
        String supply = SalesforceAccount.XC_EnelXSupply__c? 'y': 'n';
        String tipoDeRegimen =salesforceAccount.XC_TipoDeRegimen__c;
        String obligaciones =salesforceAccount.XC_ObligacionesDelContribuyente__c;
        String nit = salesforceAccount.IdentityNumber__c;
        String vatGroupType = salesforceAccount.XC_VatGroupType__c != null ? salesforceAccount.XC_VatGroupType__c : 'No Gruppo IVA'; 
        String companyFiscalCode = salesforceAccount.XC_CompanyFiscalCode__c;
        String isInterCompany= (tradingPartner == 'NaN') ? 'No': 'Yes';
        String isWhiteListed = String.valueOf(salesforceAccount.XC_BillingAgency__c!=null);
        String billingAgency = salesforceAccount.XC_BillingAgency__r.Name != null ? salesforceAccount.XC_BillingAgency__r.Name : 'Italia'; //null; //TODO 
    
    
        
        Map<Id,XC_CM_LegalEntity_Configuration__mdt> dataCMlegalEntity = new Map<Id,XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_CompanyCode__c, XC_EntityNIF__c, XC_PaymentGateway__c, XC_SimpleZuoraSequenceSetId__c
            FROM XC_CM_LegalEntity_Configuration__mdt
            WHERE XC_LegalEntity__c = :legalEntity
            AND XC_Stream__c = :stream
            AND XC_OrgId__c = :UserInfo.getOrganizationId()
        ]);

        if(!dataCMlegalEntity.isEmpty()){
            String paymentGatewayList = dataCMlegalEntity.values()[0].XC_PaymentGateway__c;
            List<String> listOfAllPaymentGateway = new List<String>();
            if(paymentGatewayList != null){
                if(paymentGatewayList.contains(';')){
                    listOfAllPaymentGateway = paymentGatewayList.split(';'); 
                } else {
                    listOfAllPaymentGateway.add(paymentGatewayList);
                }
            }
            Map<String,String> mapPaymentMethodGateway = new Map<String,String>();
            for(String tempPaymentMethodGateway : listOfAllPaymentGateway){
                if(tempPaymentMethodGateway.contains('/')){
                    List<String> listTempPaymentMethodGateway = tempPaymentMethodGateway.split('/');
                    mapPaymentMethodGateway.put(listTempPaymentMethodGateway[0], listTempPaymentMethodGateway[1]);
                }
            }
            if(currentBpli.XC_PaymentMethod__c != null){
                if(mapPaymentMethodGateway.containsKey(currentBpli.XC_PaymentMethod__c)){
                    bodymap.put('paymentGateway', mapPaymentMethodGateway.get(currentBpli.XC_PaymentMethod__c));
                }
            }
        }
    
        String companyCodeString = !dataCMlegalEntity.isEmpty() ? dataCMlegalEntity.values()[0].XC_CompanyCode__c : '';
        String entityNIF = !dataCMlegalEntity.isEmpty() ? dataCMlegalEntity.values()[0].XC_EntityNIF__c : '';
    
    
        if(optionsMap.containsKey('sequenceSetId') && optionsMap.get('sequenceSetId')=='Yes'){
            if(dataCMlegalEntity != null && dataCMlegalEntity.values()[0].XC_SimpleZuoraSequenceSetId__c != null ){
                sequenceSetId = dataCMlegalEntity.values()[0].XC_SimpleZuoraSequenceSetId__c;
            }else{
                sequenceSetId = this.sequenceSetId;
            }
        }
        if(String.isBlank(sequenceSetId) && optionsMap.containsKey('vatGroupSequenceSetId') && String.isNotBlank(String.valueof(optionsMap.get('vatGroupSequenceSetId')))){
            sequenceSetId = String.valueof(optionsMap.get('vatGroupSequenceSetId'));
        }
        if(String.isBlank(sequenceSetId) && optionsMap.containsKey('zuoraSequenceSetId') && String.isNotBlank(String.valueof(optionsMap.get('zuoraSequenceSetId')))){
            sequenceSetId = String.valueof(optionsMap.get('zuoraSequenceSetId'));
        }

        if(optionsMap.containsKey('taxInfo')){
            String taxPick = String.valueOf(optionsMap.get('taxInfo'));
            if(taxPick == 'Tax-free'){
                taxInfo = '{"exemptStatus": "Yes", "exemptCertificateId":"7"}';
            }else{
                taxInfo = '{"exemptStatus": "No", "exemptCertificateId":""}';
            }
        }

        if((nif=='CF' && docNumber.length()==11) || nif =='Partita IVA'){
            personTypeCode = 'J';
        }
        if(nif=='CF' && docNumber.length()==16){
            personTypeCode = 'F';
        }

        /*20220402 NicoloFodera NR1954  override sequenceSetId boleta vs factura soho [start]*/
        sequenceSetId = overrideZuoraSequenceSetId(legalEntity, stream, personTypeCode, sequenceSetId);
        /*20220402 NicoloFodera NR1954  override sequenceSetId boleta vs factura soho [end]*/ 
        bodyMap.putAll(optionsToDeserialize);
        bodyMap.put('name',salesforceAccount.Name);
        bodyMap.put('billCycleDay',accountBillCycleDay);
        bodyMap.put('XC_BillingProfileLineItemID__c',billingProfLineItemId);
        bodyMap.put('XC_CommodityContractID__c',contractId);
        bodyMap.put('PersonTypeCode__c',personTypeCode);
        bodyMap.put('IdentityType__c',nif);
        bodyMap.put('IdentityNumber__c',docNumber);
        bodyMap.put('XC_NIE_expedition_date__c',expedition);
        bodyMap.put('XC_NIE_expiration_date__c',expiration);
        bodyMap.put('XC_DocumentCountry__c',countryCode);
        bodyMap.put('PreferredLanguage__c',language);
        bodyMap.put('sequenceSetId',sequenceSetId);
        bodyMap.put('crmId',salesforceAccount.Id);
        bodyMap.put('currency',this.currencyIsoCode);
        bodyMap.put('billToContact',(Map<String,Object>) JSON.deserializeUntyped(billToContactJSON));
        bodyMap.put('soldToContact',(Map<String,Object>) JSON.deserializeUntyped(soldToContactJSON));
        //bodymap.put('LegalEntity__c',legalEntity);
        bodyMap.put('XC_Activity_sector__c',activitySector);
        bodyMap.put('XC_ObligacionesDelContribuyente__c',obligaciones);
        bodyMap.put('SmartInvoice__c',smartInvoice);
        bodyMap.put('TradingPartner__c',tradingPartner);
        bodyMap.put('isWhitelisted__c',isWhiteListed);               
        bodyMap.put('autoPay',autoPay);
        bodyMap.put('XC_Segment__c',stream);
        bodyMap.put('EntityAccountNumber__c',companyCodeString);
        //JJP 24/03/2022 - DUNNING - Start
        if(countryCode=='ES'){
            bodyMap.put('XC_Management__c', 'Personalized');
        }
        //JJP 24/03/2022 - DUNNING - End

		//JJP 31/01/2022 - Start 
        bodyMap.put('isInterCompany__c',isInterCompany);
        if(legalEntity.toLowerCase() == 'codensa'){
            legalEntity = 'Enel Colombia';
            bodymap.put('LegalEntity__c', legalEntity);
        }else{
            bodymap.put('LegalEntity__c',legalEntity);
        }
        //JJP 31/01/2022 - End						
        if(String.isNotBlank(additionalFields)){
            bodyMap.putAll((Map<String,Object>) JSON.deserializeUntyped(additionalFields));
        }
        if(String.isNotBlank(taxInfo)){
            bodyMap.put('taxInfo',(Map<String,Object>) JSON.deserializeUntyped(taxInfo));
        }

        if(String.isNotBlank(entityNIF)){
            bodyMap.put('EntityNIF__c',entityNIF);
        }
        if(String.isNotBlank(tipoDeRegimen)){
            bodyMap.put('XC_TipoDeRegimen__c',tipoDeRegimen);
        }
        if(String.isNotBlank(vatGroupType)  && itaLE.contains(legalEntity)){
            bodyMap.put('XC_VatGroupType__c',vatGroupType);
        }
        if(String.isNotBlank(billingAgency)  && itaLE.contains(legalEntity) && legalEntity!='EnelXMSP' && legalEntity!='EnelXMobilityHolding'){
            //[START - R1.1 2022 - NR2459 - mariateresa.mollica@accenture - 06/06/2022]
            if(legalEntity.equalsIgnoreCase('EnelXEwiva')) {
                billingAgency = billingAgency.toUpperCase();
                bodymap.put('LegalEntity__c', 'Ewiva S.r.l.'); //NR2459 - 20/07/2022
            }        
            //[END - R1.1 2022 - NR2459 - mariateresa.mollica@accenture - 06/06/2022]
            bodyMap.put('Data_Access__h',billingAgency);
        }
        if(legalEntity == 'Codensa' || legalEntity == 'EnelX' || legalEntity == 'EnelDistribucion'){
            bodyMap.put('XC_CustomerSupplier__c',supply);
        }
        
        if(String.isNotBlank(companyFiscalCode)){
            bodyMap.put('XC_CompanyFiscalCode__c',companyFiscalCode);
        }
        if(String.isNotBlank(docNumber2)){
            bodyMap.put('XC_IdentityNumber2__c',docNumber2);
        }
        if(String.isNotBlank(docType2)){
            bodyMap.put('XC_IdentityType2__c',docType2);
        }
        if(String.isNotBlank(personTypeCode)){
            bodyMap.put('PersonTypeCode__c',personTypeCode);
        }
            
        
        //http callout
        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        headerDefinitions.put('Zuora-Entity-Ids', this.entityId);

        String url ='callout:XC_ZuoraBasePath/v1/accounts';
        HttpRequest req = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions,JSON.serialize(bodyMap));
        
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'createUnlinkedZuoraAccountB2B';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
        HTTPResponse res = httpRWr.response;
        returnResp = (CreateZuoraAccountResponse) JSON.deserialize(res.getBody(), CreateZuoraAccountResponse.class);
        
        //integration log management can be inserted on demand
        XC_Integration_Log__c intLog = httpRWr.integrationLog.get(0);
        intLog.XC_BillingProfileLineItem__c = billingProfLineItemId;
        intLog.XC_Log_ServerSystem__c = 'Zuora';
        returnResp.integrationLog = intLog;
        
        return returnResp;
    }


    /**
    * @description create zuora billing account for b2c stream
    * @author Francesco Imperioli - fimperioli@deloitte.it | 02-01-2021 
    * @param salesforceAccount 
    * @param billTo 
    * @param soldTo 
    * @param options 
    * @param billingProfLineItemId 
    * @param zuoraPayment 
    * @return CreateZuoraAccountResponse 
    **/
    public CreateZuoraAccountResponse createUnlinkedZuoraAccount(Account salesforceAccount, Contact billTo, Contact soldTo, String options, String billingProfLineItemId, String zuoraPayment){
    
        CreateZuoraAccountResponse returnResp = new CreateZuoraAccountResponse();
        Map<String,Object> bodyMap = new Map<String,Object>();
        Map<Id, XC_CM_CountryISOCodeAssociation__mdt> isoCodeMap = new Map<Id, XC_CM_CountryISOCodeAssociation__mdt>([SELECT XC_ISOCode__c FROM XC_CM_CountryISOCodeAssociation__mdt WHERE XC_Country__c =: salesforceAccount.XC_Country__c]);
        XC_BillingProfileLineItem__c currentBpli = (XC_BillingProfileLineItem__c) XC_UTIL_Sobject.selectAllFields(billingProfLineItemId)[0];
    
        
    
        String autoPay = 'false';
    
        String accountHpmCreditCardPaymentMethodId = 'null';
        String activitySector = salesforceAccount.XC_GIRO__c ;
        String nit = salesforceAccount.IdentityNumber__c;
        String vatGroupType = salesforceAccount.XC_VatGroupType__c;
        String companyFiscalCode = salesforceAccount.XC_CompanyFiscalCode__c;
        String stream = salesforceAccount.XC_Segment__c;
        String firstName = salesforceAccount.XC_FirstName__c == null ? null : salesforceAccount.XC_FirstName__c.replaceAll('"', '').replaceAll('°', '').replaceAll('\\\\ ', ' ').normalizeSpace();
        salesforceAccount.XC_FirstName__c = firstName;
        String lastName = salesforceAccount.XC_LastName__c == null ? null : salesforceAccount.XC_LastName__c.replaceAll('"', '').replaceAll('°', '').replaceAll('\\\\ ', ' ').normalizeSpace();
        salesforceAccount.XC_LastName__c = lastName;
        String name = salesforceAccount.name == null ? null : salesforceAccount.name.replaceAll('"', '').replaceAll('°', '').replaceAll('\\\\ ', ' ').normalizeSpace();
        salesforceAccount.name = name;
        String PrimaryEmail = salesforceAccount.PrimaryEmail__c  == null ? null : salesforceAccount.PrimaryEmail__c.replaceAll('\\.@', '@');
        salesforceAccount.PrimaryEmail__c = PrimaryEmail;
        String soldToContactJSON = generateContactObjectJSON(soldTo);
        soldToContactJSON = getEnrichExtraContactFields(soldToContactJSON,billingProfLineItemId);
        String billToContactJSON = generateContactObjectJSON(billTo);
        Set<String> itaLE = new Set<String>{'EnelXItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMobility','Cogenio','EnelXMobilityItalia','EnelXMobilityHolding'};
    
        String additionalFields = ZuoraWebserviceUtil.generateAdditionalFields('zqu__CustomAccountFields','Account', salesforceAccount);
        Map<String, Object> optionsMap = (Map<String, Object>)JSON.deserializeUntyped(zuoraPayment);
        // set invoiceDeliveryPrefsPrint to true if the contact missing the email
        Map<String,Object> optionsToDeserialize = (Map<String,Object>) JSON.deserializeUntyped(options);
        Boolean invoiceDeliveryPrefsEmail = (Boolean)optionsToDeserialize.get('invoiceDeliveryPrefsEmail');
        if(invoiceDeliveryPrefsEmail != null && invoiceDeliveryPrefsEmail){
            if(String.isBlank(billTo.email)){
                optionsToDeserialize.put('invoiceDeliveryPrefsEmail',false);
                optionsToDeserialize.put('invoiceDeliveryPrefsPrint',true);
            }
        }



        Boolean fromBillingProfile = optionsMap.containsKey('fromBillingProfile') ? Boolean.valueOf('fromBillingProfile') : false;

        String language = optionsMap.containsKey('language') ? String.valueOf(optionsMap.get('language')) : 
                        optionsMap.containsKey('invoicePreferredLanguage') ? adjustLanguage_CM(String.valueOf(optionsMap.get('invoicePreferredLanguage'))) :
                        adjustLanguage_CM(billTo.XC_Preferredlanguageofcontact__c);
        
        String countryCode = optionsMap.containsKey('countryCode') && String.isNotBlank(String.valueOf(optionsMap.get('countryCode'))) ? String.valueOf(optionsMap.get('countryCode')) : 
                        String.isNotBlank(salesforceAccount.XC_Country__c) && !isoCodeMap.isEmpty() ? isoCodeMap.values()[0].XC_ISOCode__c : '' ;

        String sohoType = optionsMap.containsKey('sohoType') ? String.valueOf(optionsMap.get('sohoType')) : 
                        String.isNotBlank(salesforceAccount.XC_SohoType__c) ? salesforceAccount.XC_SohoType__c : '' ;


        String contractId = optionsMap.containsKey('contractId') ? String.valueOf(optionsMap.get('contractId')) : '';
        String nif = optionsMap.containsKey('docNif') ? String.valueOf(optionsMap.get('docNif')) : '';
        String docNumber = optionsMap.containsKey('docNumber') ? String.valueOf(optionsMap.get('docNumber')) : '';
        String expedition = optionsMap.containsKey('expedition') ? String.valueOf(optionsMap.get('expedition')) : '';
        String expiration = optionsMap.containsKey('expiration') ? String.valueOf(optionsMap.get('expiration'))  :'';
        String personTypeCode = optionsMap.containsKey('personTypeCode') ? String.valueOf(optionsMap.get('personTypeCode')) : '' ;
        String legalEntity = optionsMap.containsKey('legalE') ? String.valueOf(optionsMap.get('legalE')) : '';
        String accountBillCycleDay = legalEntity.equalsIgnoreCase('EnelXItalia') ? '1' : '0';
        String tradingPartner= (sohoType == Label.XC_CL_AssociatedCompaniesSohoType || sohoType == 'B2B') && !String.isBlank(salesforceAccount.XC_TradingPartner__c) ? salesforceAccount.XC_TradingPartner__c :'NaN';
        String isInterCompany= (tradingPartner == 'NaN') ? 'No': 'Yes';
        String taxInfo='';
        String sequenceSetId = '';

        String tpbCode = optionsMap.containsKey('tpbCode') ? String.valueOf(optionsMap.get('tpbCode')) : '';//[2021-09-30 :: TP :: Third Party Billing :: Recover zuoraSequenceSetId for Partners]

        Map<Id,XC_CM_LegalEntity_Configuration__mdt> dataCMlegalEntity = new Map<Id,XC_CM_LegalEntity_Configuration__mdt>();
        //BEGIN - [2022-02-15 :: Check if legalEntity not blank/null]
        if(String.isNotBlank(legalEntity)) {
            //BEGIN - [2021-12-27 :: TP :: Third Party Billing :: SEND Legal Entity Infos]
            dataCMlegalEntity = new Map<Id,XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id,XC_Country__c, XC_CompanyCode__c, XC_EntityNIF__c, XC_PaymentGateway__c, XC_SimpleZuoraSequenceSetId__c,
            XC_CompanyName__c,XC_Filial__c,XC_Municipality__c,XC_State__c // Raviprakash.soda, 16/06/2022,EnelX - Legal Entities CR-added  XC_CompanyName__c,XC_Filial__c,XC_Municipality__c,XC_State__c 
            FROM XC_CM_LegalEntity_Configuration__mdt
            WHERE XC_LegalEntity__c = :legalEntity
            AND XC_Stream__c = :stream
            AND XC_OrgId__c = :UserInfo.getOrganizationId()
            ]);
    
            String companyCodeString = !dataCMlegalEntity.isEmpty() ? dataCMlegalEntity.values()[0].XC_CompanyCode__c : '';
             //[ START, Raviprakash.soda, 16/06/2022,EnelX - Legal Entities CR]
            String branch = !dataCMlegalEntity.isEmpty() ? dataCMlegalEntity.values()[0].XC_Municipality__c +'|'+ dataCMlegalEntity.values()[0].XC_State__c +'|'+ dataCMlegalEntity.values()[0].XC_Filial__c : ''; 
             //[ END, Raviprakash.soda, 16/06/2022,EnelX - Legal Entities CR
            String entityNIF = !dataCMlegalEntity.isEmpty() ? dataCMlegalEntity.values()[0].XC_EntityNIF__c : '';
            bodyMap.put('EntityAccountNumber__c', companyCodeString);
            bodyMap.put('EntityNIF__c', entityNIF);
            
            //RGS 10/03/2022 - Start
            //bodymap.put('LegalEntity__c', legalEntity);
            if(legalEntity.toLowerCase() == 'codensa'){
            legalEntity = 'Enel Colombia';
            bodymap.put('LegalEntity__c', legalEntity);
            }
             //[ START, Raviprakash.soda, 16/06/2022,EnelX - Legal Entities CR, Added check]
            else if(!dataCMlegalEntity.isEmpty() && dataCMlegalEntity.values()[0].XC_Country__c == 'Brazil'){		
                  bodymap.put('LegalEntity__c',dataCMlegalEntity.values()[0].XC_CompanyName__c); //Modified
                  bodymap.put('XC_Branch__c',branch); //Modified
			  }
             //[ END, Raviprakash.soda, 16/06/2022,EnelX - Legal Entities CR,Added check]
            else{
            bodymap.put('LegalEntity__c',legalEntity);
            }
            //RGS 10/03/2022 - End
            //END - [2021-12-27 :: TP :: Third Party Billing :: SEND Legal Entity Infos]
            if(!dataCMlegalEntity.isEmpty()){
                String paymentGatewayList = dataCMlegalEntity.values()[0].XC_PaymentGateway__c;
                List<String> listOfAllPaymentGateway = new List<String>();
                if(paymentGatewayList != null){
                    if(paymentGatewayList.contains(';')){
                        listOfAllPaymentGateway = paymentGatewayList.split(';'); 
                    } else {
                        listOfAllPaymentGateway.add(paymentGatewayList);
                    }
                }
                Map<String,String> mapPaymentMethodGateway = new Map<String,String>();
                for(String tempPaymentMethodGateway : listOfAllPaymentGateway){
                    if(tempPaymentMethodGateway.contains('/')){
                        List<String> listTempPaymentMethodGateway = tempPaymentMethodGateway.split('/');
                        mapPaymentMethodGateway.put(listTempPaymentMethodGateway[0], listTempPaymentMethodGateway[1]);
                    }
                }
                if(currentBpli.XC_PaymentMethod__c != null){
                    if(mapPaymentMethodGateway.containsKey(currentBpli.XC_PaymentMethod__c)){
                        bodymap.put('paymentGateway', mapPaymentMethodGateway.get(currentBpli.XC_PaymentMethod__c));
                    }
                }
            }
        }
        //END - [2022-02-15 :: Check if legalEntity not blank/null]
        
        if(optionsMap.containsKey('sequenceSetId') && optionsMap.get('sequenceSetId')=='Yes') {
            if(dataCMlegalEntity != null && dataCMlegalEntity.values()[0].XC_SimpleZuoraSequenceSetId__c != null ){
                sequenceSetId = dataCMlegalEntity.values()[0].XC_SimpleZuoraSequenceSetId__c;
            }else{
                sequenceSetId = this.sequenceSetId;
            }
        }
        if(String.isBlank(sequenceSetId) && optionsMap.containsKey('vatGroupSequenceSetId') && String.isNotBlank(String.valueof(optionsMap.get('vatGroupSequenceSetId')))) {
            sequenceSetId = String.valueof(optionsMap.get('vatGroupSequenceSetId'));
        }
        if(String.isBlank(sequenceSetId) && optionsMap.containsKey('zuoraSequenceSetId') && String.isNotBlank(String.valueof(optionsMap.get('zuoraSequenceSetId')))) {
            sequenceSetId = String.valueof(optionsMap.get('zuoraSequenceSetId'));
        }

        if(optionsMap.containsKey('taxInfo')){
            String taxPick = String.valueOf(optionsMap.get('taxInfo'));
            if(taxPick == 'Tax-free'){
                taxInfo = '{"exemptStatus": "Yes", "exemptCertificateId":"7"}';
            }else{
                taxInfo = '{"exemptStatus": "No", "exemptCertificateId":""}';
            }
        }
        /*20220402 NicoloFodera NR1954  override sequenceSetId boleta vs factura soho [start]*/
        sequenceSetId = overrideZuoraSequenceSetId(legalEntity, stream, personTypeCode, sequenceSetId);
        /*20220402 NicoloFodera NR1954  override sequenceSetId boleta vs factura soho [end]*/
        bodyMap.putAll(optionsToDeserialize);
        if(String.isNotBlank(additionalFields)) {
            bodyMap.putAll((Map<String,Object>) JSON.deserializeUntyped(additionalFields));
        }
        bodyMap.put('name',salesforceAccount.Name);
        bodyMap.put('XC_BillingProfileLineItemID__c',billingProfLineItemId);
        bodyMap.put('XC_CommodityContractID__c',contractId);
        bodyMap.put('IdentityType__c',nif);
        bodyMap.put('IdentityNumber__c',docNumber);
        bodyMap.put('XC_NIE_expedition_date__c',expedition);
        bodyMap.put('XC_NIE_expiration_date__c',expiration);
        bodyMap.put('XC_DocumentCountry__c',countryCode);
        bodyMap.put('PreferredLanguage__c',language); 
        bodyMap.put('PersonTypeCode__c',personTypeCode);
        bodyMap.put('sequenceSetId',sequenceSetId);
        bodyMap.put('crmId',salesforceAccount.Id);
        bodyMap.put('currency',this.currencyIsoCode);
        bodyMap.put('billToContact',(Map<String,Object>) JSON.deserializeUntyped(billToContactJSON));
        bodyMap.put('soldToContact',(Map<String,Object>) JSON.deserializeUntyped(soldToContactJSON));
        bodyMap.put('autoPay',autoPay);
        bodyMap.put('TradingPartner__c',tradingPartner);
        bodyMap.put('isInterCompany__c',isInterCompany);
        bodyMap.put('billCycleDay',accountBillCycleDay);
        bodyMap.put('XC_Segment__c',stream);

        //BEGIN - [2021-09-30 :: TP :: Third Party Billing :: Recover zuoraSequenceSetId for Partners]
        if(String.isNotBlank(tpbCode))
        {
            bodyMap.put('XC_TPBCode__c', tpbCode);
        }
        //END - [2021-09-30 :: TP :: Third Party Billing :: Recover zuoraSequenceSetId for Partners]
        if(itaLE.contains(legalEntity) && legalEntity != 'EnelXMobilityHolding'){
            bodyMap.put('Data_Access__h', 'Italia');
        }

        if(String.isNotBlank(taxInfo)){
            bodyMap.put('taxInfo',(Map<String,Object>) JSON.deserializeUntyped(taxInfo));
        }

        if(String.isNotBlank(activitySector)){
            bodyMap.put('XC_Activity_sector__c',activitySector);
        }

        if(String.isNotBlank(vatGroupType)){
            bodyMap.put('XC_VatGroupType__c',vatGroupType);
        }

        if(String.isNotBlank(companyFiscalCode)){
            bodyMap.put('XC_CompanyFiscalCode__c',companyFiscalCode);
        }


        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        // headerDefinitions.put('Authorization', 'Bearer ' + this.token);
        headerDefinitions.put('Zuora-Entity-Ids', this.entityId);


        String url ='callout:XC_ZuoraBasePath/v1/accounts';
        HttpRequest req = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, JSON.serialize(bodyMap));

        
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'createUnlinkedZuoraAccount';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
        HTTPResponse res = httpRWr.response;
        returnResp = (CreateZuoraAccountResponse) JSON.deserialize(res.getBody(), CreateZuoraAccountResponse.class);
        XC_Integration_Log__c intLog = httpRWr.integrationLog.get(0);
        intLog.XC_BillingProfileLineItem__c = billingProfLineItemId;
        intLog.XC_Log_ServerSystem__c = 'Zuora';
        returnResp.integrationLog = intLog;

        return returnResp;
    }


    public GenerateRSASignatureResponse generateRSASignature(String pageId){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://'+this.host+'/v1/rsa-signatures');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+this.token);
        req.setHeader('Zuora-Entity-Ids', this.entityId);
        req.setBody('{"method":"POST","pageId":"'+pageId+'","uri":"https://sandbox.eu.zuora.com/apps/PublicHostedPageLite.do"}');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return (generateRSASignatureResponse)JSON.deserialize(res.getBody(), generateRSASignatureResponse.class);
    }


    public static void sleep(Integer sleepSeconds) {
        Long startTS = System.currentTimeMillis();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://1.cuzillion.com/bin/resource.cgi?sleep=' + sleepSeconds);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Long duration = System.currentTimeMillis() - startTS;
        System.debug('Duration: ' + duration + 'ms');
    }


    /**
    * @description link newly created payment method to the zuora account as default
    * @author Francesco Imperioli - fimperioli@deloitte.it | 02-01-2021 
    * @param zuoraAccountId 
    * @param paymentMethodId 
    * @Param paymentMethodType
    * @return LinkPaymentMethodToAccountResponse 
    **/
    public LinkPaymentMethodToAccountResponse linkPaymentMethodToAccount(String zuoraAccountId, String paymentMethodId, String paymentMethodType) {

        String paymentTerm = 'Net 30';
        if(paymentMethodType == 'SEPA'){
            paymentTerm = 'Net 15';
        }

        LinkPaymentMethodToAccountResponse linkpaymentresp = new LinkPaymentMethodToAccountResponse();
        Map<String,String> headerDefinitions = new Map<String,String>();
        Map<String,Object> bodyMap = new Map<String,Object>();
        bodyMap.put('DefaultPaymentMethodId', paymentMethodId);
        bodyMap.put('AutoPay', true);
        bodyMap.put('PaymentTerm', paymentTerm);

        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        headerDefinitions.put('Zuora-Entity-Ids', this.entityId);

        //http callout
        String url ='callout:XC_ZuoraBasePath/v1/object/account/' + zuoraAccountId;
        HttpRequest req = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, JSON.Serialize(bodyMap));
        
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'linkPaymentMethodToAccount';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
        HTTPResponse res = httpRWr.response;
        linkpaymentresp=(LinkPaymentMethodToAccountResponse) JSON.deserialize(res.getBody(), LinkPaymentMethodToAccountResponse.class);

        //integration log management can be inserted on demand
        XC_Integration_Log__c intLog = httpRWr.integrationLog.get(0);
        intLog.XC_Log_ServerSystem__c = 'Zuora';
        linkpaymentresp.integrationLog = httpRWr.integrationLog.get(0);


        return linkpaymentresp;

    }


    /**
    * @description link newly created payment method to the zuora account as default
    * @author Francesco Imperioli - fimperioli@deloitte.it | 02-01-2021 
    * @param zuoraAccountId 
    * @param paymentMethodId 
    * @return LinkPaymentMethodToAccountResponse 
    **/
    public LinkPaymentMethodToAccountResponse linkPaymentMethodToAccount(String zuoraAccountId, String paymentMethodId){
        LinkPaymentMethodToAccountResponse linkpaymentresp = new LinkPaymentMethodToAccountResponse();
        Map<String,String> headerDefinitions = new Map<String,String>();
        Map<String,Object> bodyMap = new Map<String,Object>();
        bodyMap.put('DefaultPaymentMethodId',paymentMethodId);
        bodyMap.put('AutoPay',true);

        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        // headerDefinitions.put('Authorization', 'Bearer ' + this.token);
        headerDefinitions.put('Zuora-Entity-Ids', this.entityId);

        // String url ='https://'+this.host+'/v1/object/account/'+zuoraAccountId;

        //http callout
        String url ='callout:XC_ZuoraBasePath/v1/object/account/' + zuoraAccountId;
        HttpRequest req = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, JSON.Serialize(bodyMap));
        
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'linkPaymentMethodToAccount';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
        HTTPResponse res = httpRWr.response;
        linkpaymentresp=(LinkPaymentMethodToAccountResponse) JSON.deserialize(res.getBody(), LinkPaymentMethodToAccountResponse.class);

        //integration log management can be inserted on demand
        XC_Integration_Log__c intLog = httpRWr.integrationLog.get(0);
        intLog.XC_Log_ServerSystem__c = 'Zuora';
        linkpaymentresp.integrationLog = httpRWr.integrationLog.get(0);


        return linkpaymentresp;

    }


    /**
    * @description link newly created payment method to the zuora account as default
    * @author Francesco Imperioli - fimperioli@deloitte.it | 02-01-2021 
    * @param zuoraAccountId 
    * @param paymentMethodId 
    * @param paymentGateway 
    * @return LinkPaymentMethodToAccountResponse 
    **/
    public LinkPaymentMethodToAccountResponse linkPaymentMethodToAccountWithGateWay(String zuoraAccountId, String paymentMethodId,String paymentGateway){
        LinkPaymentMethodToAccountResponse linkpaymentresp = new LinkPaymentMethodToAccountResponse();
        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        // headerDefinitions.put('Authorization', 'Bearer ' + this.token);
        headerDefinitions.put('Zuora-Entity-Ids', this.entityId);

        Map<String,Object> bodyMap = new Map<String,Object>();
        bodyMap.put('DefaultPaymentMethodId',paymentMethodId);
        bodyMap.put('AutoPay',true);
        bodyMap.put('PaymentGateway',paymentGateway);

        //http callout
        String url ='callout:XC_ZuoraBasePath/v1/object/account/' + zuoraAccountId;
        HttpRequest req = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, JSON.Serialize(bodyMap));

        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'linkPaymentMethodToAccountWIthGateWay';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
        HTTPResponse res = httpRWr.response;
        linkpaymentresp=(LinkPaymentMethodToAccountResponse) JSON.deserialize(res.getBody(), LinkPaymentMethodToAccountResponse.class);
        //integration log management can be inserted on demand
        linkpaymentresp.integrationLog = httpRWr.integrationLog.get(0);

        return linkpaymentresp;

    }


    public String generateContactObjectJSON(Contact con){

        Map<String,Object> jsonMap = new Map<String,Object>();
        String streetNumber = con.XC_StreetNumber__c == null ? null : con.XC_StreetNumber__c.replace(' \\ ',' ').replace(' / ',' ').replace('\\',' ').replace('/',' ');
        String mailingStreet = con.MailingStreet == null ? null : con.MailingStreet.replace('"','').replaceAll('\\\\ ', ' ').normalizeSpace();
        String firstName = con.firstName == null ? null : con.firstName.replaceAll('"', '').replaceAll('°', '').replaceAll('\\\\ ', ' ').normalizeSpace();
        String lastName = con.lastName == null ? null : con.lastName.replaceAll('"', '').replaceAll('°', '').replaceAll('\\\\ ', ' ').normalizeSpace();
        String email = con.Email  == null ? null : con.Email.replaceAll('\\.@', '@');
		//JJP 24/03/2022 - DUNNING - Start
		List<Account> accList = [SELECT id , Owner.Email FROM account WHERE id = :con.AccountId ORDER BY CreatedDate desc LIMIT 1];
		if(!accList.isEmpty()){
			jsonMap.put('XC_GestorEmail__c', accList[0].Owner.Email);
		}
		//JJP 24/03/2022 - DUNNING - End
        jsonMap.put('XC_Door__c',con.XC_Door__c);
        jsonMap.put('XC_Floor__c',con.XC_Floor__c);
        jsonMap.put('XC_Stair__c',con.XC_Stair__c);
        jsonMap.put('firstName',firstName);
        jsonMap.put('lastName',lastName);
        jsonMap.put('address1',mailingStreet);
        jsonMap.put('address2',null);
        jsonMap.put('city',con.MailingCity);
        jsonMap.put('country',con.MailingCountry);
        jsonMap.put('county',con.zqu__County__c);
        jsonMap.put('fax',con.Fax);
        jsonMap.put('homePhone',null);
        jsonMap.put('mobilePhone',con.MobilePhone);
        jsonMap.put('nickname',null);
        jsonMap.put('otherPhone',null);
        jsonMap.put('otherPhoneType',null);
        jsonMap.put('personalEmail',null);
        jsonMap.put('state',con.MailingState);
        jsonMap.put('taxRegion',null);
        jsonMap.put('workEmail',email);
        jsonMap.put('workPhone',con.Phone);
        jsonMap.put('zipCode',con.MailingPostalCode);
        jsonMap.put('XC_StreetNumber__c',streetNumber);
        
        //JJP - ENELx - 5/11/2021 - Start
        //NR2014 - AddInformationToInvoicesIssuedFromDTE_v2
        if(!Test.isRunningTest()){
            List<Contact> conlist = [SELECT AccountId FROM contact WHERE id = :con.id LIMIT 1];
            List<XC_BillingProfileLineItem__c> bp = [SELECT XC_LegalEntity__c FROM XC_BillingProfileLineItem__c WHERE XC_Account__c = :conlist[0].AccountId  Order by CreatedDate DESC LIMIT 1];
            String legalEntity = bp[0].XC_LegalEntity__c.toLowerCase();
            
            if(!String.isBlank(con.XC_Municipality__c) && (legalEntity == 'eneldistribucion' || legalEntity == 'enelx')){
                jsonmap.put('XC_Municipality__c', con.XC_Municipality__c);
            }
        }
        //JJP - ENELx - 5/11/2021 - End
        
        return JSON.Serialize(jsonMap);

    }


    private String adjustLanguage_CM(String l) {
        String returnString ='ENG';
        Map<Id, XC_CM_LanguageZuoraMapping__mdt> mapLanguageZuora = new Map<Id,XC_CM_LanguageZuoraMapping__mdt>([SELECT Id, DeveloperName, XC_Invoice_Language__c, XC_ZuoraLanguage__c  FROM XC_CM_LanguageZuoraMapping__mdt WHERE XC_Invoice_Language__c =: l LIMIT 1]);
        
        if(!mapLanguageZuora.isEmpty()) {
            XC_CM_LanguageZuoraMapping__mdt languageZuora = mapLanguageZuora.values()[0];
            returnString = (String.isNotBlank(languageZuora.XC_ZuoraLanguage__c)) ? languageZuora.XC_ZuoraLanguage__c : 'ENG';
        }

        return returnString;
    }


    public static Map<String,Object> linkAccountToExternalPaymentMethod(String accountId, String externalPaymentMethodType, String entityName){//String entityName
        /*String country = '%'+entityName+'%';
        Zuora_OAuth__c authData = [SELECT apiToken__c from Zuora_OAuth__c where EntityName__c like :country][0];
        String apiToken = authData.apiToken__c;*/
        Map<String,Object> result = new Map<String,Object>();

        String entity = '%'+entityName+'%';
        String orgId = UserInfo.getOrganizationId();
        String apiToken = [SELECT XC_apiToken__c FROM XC_CM_ZuoraOAuth__mdt WHERE XC_EntityName__c LIKE:entity AND XC_OrgId__c  =: orgId][0].XC_apiToken__c;
        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        headerDefinitions.put('API-Token', apiToken);
        
        
        if(externalPaymentMethodType == 'BankTransfer'){
            externalPaymentMethodType = 'Bank Transfer';
        }
        if(externalPaymentMethodType == 'CommodityBill'){
            externalPaymentMethodtype = 'Commodity Bill';
        }
        
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'linkAccountToExternalPaymentMethod';
        logWrapper.insertLogging = false; 
        String body = '{"externalPaymentMethodType": "'+externalPaymentMethodType+'","accountId": "'+accountId+'"}';
        HttpRequest req = XC_UTIL_RESTCallout.newRequest('POST', 'callout:XC_ZuoraWebServiceWorkflow/LinkAccountToExternalPaymentMethod/run', headerDefinitions, body);

        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
        XC_Integration_Log__c log = httpRWr.integrationLog.get(0);
        log.XC_Log_ServerSystem__c = 'Zuora';
        result.put('integrationLog',log);
        return result;
        //TO DO INSERT Integration LOG
    }


    /**
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @description update Zuora Account
    * @param parametersMap - Map<String, String>
    * @return CreateZuoraAccountResponse wrapper
    */
    public CreateZuoraAccountResponse updateZuoraAccount(Map<String, String> parametersMap) {

        // Parameter in the input map
        Map<String,Object> bodyMap = new Map<String,Object>();

        String zuoraAccountId = parametersMap.get('zuoraAccountId');        // REQUIRED
        String billToId = parametersMap.get('billToId');                    // REQUIRED
        String soldToId = parametersMap.get('soldToId');                    // REQUIRED
        String billAddrId = parametersMap.get('billAddrId');                // REQUIRED
        String soldAddrId = parametersMap.get('soldAddrId');                // REQUIRED
        String isWhitelisted = parametersMap.get('newIsWhitelisted'); 
        String newBillingAgency = parametersMap.get('newBillingAgency') != null ? parametersMap.get('newBillingAgency') : 'Italia';
        String newAccountName = parametersMap.get('newAccountName');
        String newAccountIdentityType = parametersMap.get('newAccountIdentityType');
        String newAccountIdentityNumber = parametersMap.get('newAccountIdentityNumber');
        String newAccountDocumentCountry = parametersMap.get('newAccountDocumentCountry');
        String newAccountDocumentReleaseDate = parametersMap.get('newAccountDocumentReleaseDate');
        String newAccountDocumentExpirationDate = parametersMap.get('newAccountDocumentExpirationDate');
        String legalEntity = parametersMap.get('legalEntity');
        String billingProfLineItemId = parametersMap.get('billingProfileLineItemId');
        String batch = parametersMap.containsKey('batch') ? parametersMap.get('batch') : '';        
        String oldBatch = parametersMap.containsKey('oldBatch') ? parametersMap.get('oldBatch') : '';
        String commodityContractId = parametersMap.containsKey('commodityContractId') ? parametersMap.get('commodityContractId') : '';
        String commodityAccountId =  parametersMap.containsKey('commodityAccountId') ? parametersMap.get('commodityAccountId') : ''; /*20220402 NicoloFodera correctly ingest CommodityBP*/
        String isCommodityCustomer = parametersMap.containsKey('isCommodityCustomer') ? parametersMap.get('isCommodityCustomer') : '';
        String commodityFrequency = parametersMap.containsKey('commodityFrequency') ? parametersMap.get('commodityFrequency') : null;
        String otherPaymentMethodType = parametersMap.containsKey('otherPaymentMethodType') ? parametersMap.get('otherPaymentMethodType') : null;
        
        String newOfficeCode = parametersMap.containsKey('newOfficeCode') ? parametersMap.get('newOfficeCode') : null;
        String newRecipientCodeB2B = parametersMap.containsKey('newRecipientCodeB2B') ? parametersMap.get('newRecipientCodeB2B') : null;   
        String newPersonTypeCode = null;
        
        // Manage Contact to send to Zuora
        Contact contactBill;
        Contact contactSold;

        if(billToId == soldToId && billAddrId == soldAddrId){
            ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper contactBillWr = ZuoraBillingProfileCreationController.prepareContactForZuora(billToId, billAddrId, legalEntity);
            contactBill = contactBillWr.c;
            contactSold = contactBillWr.c;
        } else {
            ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper contactBillWr = ZuoraBillingProfileCreationController.prepareContactForZuora(billToId, billAddrId, legalEntity);
            contactBill = contactBillWr.c;
            ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper contactSoldWr = ZuoraBillingProfileCreationController.prepareContactForZuora(soldToId, soldAddrId, legalEntity);
            contactSold = contactSoldWr.c;
        }

        String billToContactJSON = generateContactObjectJSON(contactBill);
        String soldToContactJSON = generateContactObjectJSON(contactSold);

        if(!String.isBlank(billingProfLineItemId)){
            soldToContactJSON = getEnrichExtraContactFields(soldToContactJSON, billingProfLineItemId);
        }
        
        Set<String> itaLE = new Set<String>{'EnelXItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMobility','Cogenio', 'EnelXMSP'};
        Set<String> b2bg = new Set<String>{'B2B','B2G'};
        if(itaLE.contains(legalEntity) && parametersMap.get('segment') != null && b2bg.contains(parametersMap.get('segment'))) {
            soldToContactJSON = setExtraContactFieldsForUpdateB2B(soldToContactJSON, parametersMap);
            billToContactJSON = setExtraContactFieldsForUpdateB2B(billToContactJSON, parametersMap);
            
            if((newAccountIdentityType=='CF' && newAccountIdentityNumber.length()==11) || newAccountIdentityType =='Partita IVA'){
                newPersonTypeCode = 'J';
            }
            if(newAccountIdentityType=='CF' && newAccountIdentityNumber.length()==16){
                newPersonTypeCode = 'F';
            }
        }

        // Manage Language
        String language = (String.isNotBlank(contactBill.XC_Preferredlanguageofcontact__c)) ? contactBill.XC_Preferredlanguageofcontact__c : contactSold.XC_Preferredlanguageofcontact__c;
        language = adjustLanguage_CM(language);

        // Manage Country Code
        String countryCode;
        if(!String.isBlank(newAccountDocumentCountry)){
            countryCode = [SELECT XC_ISOCode__c FROM XC_CM_CountryISOCodeAssociation__mdt WHERE XC_Country__c =: newAccountDocumentCountry][0].XC_ISOCode__c;
        }

        
        String body = '{"billToContact":' + billToContactJSON + ',"soldToContact":' + soldToContactJSON;
        body += (String.isNotBlank(newAccountName)) ? ',"name":"'+newAccountName+'"' : '';
        body += (String.isNotBlank(newAccountIdentityType)) ? ',"IdentityType__c":"'+newAccountIdentityType+'"' : '';
        body += (String.isNotBlank(newAccountIdentityNumber)) ? ',"IdentityNumber__c":"'+newAccountIdentityNumber+'"' : '';
        body += (String.isNotBlank(newPersonTypeCode)) ? ',"PersonTypeCode__c":"'+newPersonTypeCode+'"' : '';
        body += (String.isNotBlank(countryCode)) ? ',"XC_DocumentCountry__c":"'+countryCode+'"' : '';
        body += (String.isNotBlank(isWhitelisted)) ? ',"isWhitelisted__c":"'+isWhitelisted+'"' : '';
        if(/*String.isNotBlank(newBillingAgency)  &&*/ itaLE.contains(legalEntity)  && legalEntity!='EnelXMSP' && legalEntity!='EnelXMobilityHolding'){
                //bodyMap.put('Data_Access__h',newBillingAgency);
                body += (String.isNotBlank(newBillingAgency)) ? ',"Data_Access__h":"'+newBillingAgency+'"' : '';
        }      
        body += (String.isNotBlank(newAccountDocumentReleaseDate)) ? ',"XC_NIE_expedition_date__c":"'+newAccountDocumentReleaseDate+'"' : '';
        body += (String.isNotBlank(newAccountDocumentExpirationDate)) ? ',"XC_NIE_expiration_date__c":"'+newAccountDocumentExpirationDate+'"' : '';
        //body += (String.isNotBlank(language)) ? ',"PreferredLanguage__c":"'+language+'"' : '';
        body += (String.isNotBlank(batch)) ? ',"batch":"'+batch+'"' : '';
        body += (String.isNotBlank(oldBatch)) ? ',"XC_OriginalBB__c":"'+oldBatch+'"' : '';
        body += (String.isNotBlank(commodityContractId)) ? ',"XC_CommodityContractID__c":"'+commodityContractId+'"' : '';
        body += (String.isNotBlank(commodityAccountId)) ? ',"XC_CommodityAccountId__c":"'+commodityAccountId+'"' : '';/*20220402 NicoloFodera correctly ingest CommodityBP*/
        body += (String.isNotBlank(isCommodityCustomer)) ? ',"IsCommodityCustomer__c":"'+isCommodityCustomer+'"' : '';
        body += (commodityFrequency != null) ? ',"XC_CommodityFrequency__c":"'+commodityFrequency+'"' : '';             // those fields can be blanked
        body += (otherPaymentMethodType != null) ? ',"otherPaymentMethodType__c":"'+otherPaymentMethodType+'"' : '';    // those fields can be blanked
        body += '}';
        system.debug('§Body:'+body);
        // Create Request
        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type', 'application/json');
        headerDefinitions.put('Zuora-Entity-Ids', this.entityId);
        String url = 'callout:XC_ZuoraBasePath/v1/accounts/' + zuoraAccountId;
        HttpRequest req = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);

        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'UpdateZuoraAccount';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
        HTTPResponse res = httpRWr.response;
        CreateZuoraAccountResponse returnResp = (CreateZuoraAccountResponse) JSON.deserialize(res.getBody(), CreateZuoraAccountResponse.class);
        returnResp.integrationLog = httpRWr.integrationLog.get(0);


        //add a retry logic in case of errors
        Integer maxRetry = 3;
        if(returnResp.success!='true' && returnResp.reasons[0].message.containsIgnoreCase('lock')){
        
            for(Integer i = 0; i< maxRetry;i++){
                //insert a sleep here
                XC_UTIL_RESTCallout.sleep(2000);

                XC_UTIL_RESTCallout.HttpResponseWrapper newRespWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
                HTTPResponse newRes = httpRWr.response;
                returnResp = (CreateZuoraAccountResponse) JSON.deserialize(res.getBody(), CreateZuoraAccountResponse.class);
                returnResp.integrationLog = httpRWr.integrationLog.get(0);
                if(returnResp.success.equalsIgnoreCase('true')){
                    break;
                }
            }
        }

        return returnResp;
    }


    public CreateZuoraAccountResponse createZuoraAccount(Account salesforceAccount, String hpmCreditCardPaymentMethodId,String paymentMethodType, Contact billTo, Contact soldTo){

        Set<String> types = new Set<String>{'SEPA', 'BankTransfer', 'Cash', 'CommodityBill'};
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:XC_ZuoraBasePath/v1/accounts');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+this.token);
        req.setHeader('Zuora-Entity-Ids', this.entityId);
        String autoPay = types.contains(paymentMethodType)  ? 'false' : 'true';
        String accountName = '"'+salesforceAccount.Name+'"';
        String accountHpmCreditCardPaymentMethodId =  types.contains(paymentMethodType) ? 'null':'"'+hpmCreditCardPaymentMethodId+'"';
        String accountCurrency = '"'+this.currencyIsoCode+'"';
        String accountBillCycleDay = '0';
        //String accountBillCycleDay = '1';
        //soldToContact fields
        String soldToContactJSON = generateContactObjectJSON(soldTo);

        //billToContact fieds
        String billToContactJSON = generateContactObjectJSON(billTo);

        String additionalFields = ZuoraWebserviceUtil.generateAdditionalFields('zqu__CustomAccountFields','Account', salesforceAccount);

        String body = '{'+
                '"name": '+accountName+','+
                '"crmId": "'+salesforceAccount.Id+'",'+
                '"hpmCreditCardPaymentMethodId":'+accountHpmCreditCardPaymentMethodId+','+
                '"currency": '+accountCurrency+','+
                '"billCycleDay": '+accountBillCycleDay+','+
                '"billToContact":'+billToContactJSON+','+
                '"soldToContact":'+soldToContactJSON+','+
                '"autoPay":"'+autoPay+'"'+additionalFields+
                '}';

        req.setBody(body);

        //System.debug('body -->'+body);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        return (CreateZuoraAccountResponse) JSON.deserialize(res.getBody(), CreateZuoraAccountResponse.class);
    }


    /**
    * @author Francesco Imperioli - fimperioli@deloitte.it
    * @description manage contact extra fields from bpli object fieldsets
    * @createdate 2020-03-02
    */
    public String getEnrichExtraContactFields(String contactStringObj,String bpliId){

        Map<String,Object> contactJsonMap = (Map <String,Object>) JSON.deserializeUntyped(contactStringObj);
        XC_BillingProfileLineItem__c currentBpli = (XC_BillingProfileLineItem__c) XC_UTIL_Sobject.selectAllFields(bpliId)[0];
        String legalEntity = currentBpli.XC_LegalEntity__c;
        String stream = currentBpli.XC_Segment__c;
        //getting legal entity information and build fieldset key
        XC_CM_CountryLegalEntityAssociation__mdt userLE = [SELECT ID,XC_Country__c,XC_Category__c FROM XC_CM_CountryLegalEntityAssociation__mdt WHERE XC_LegalEntity__c = :legalEntity AND XC_Category__c = :stream LIMIT 1];
        String countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
        String userLEStream = userLE.XC_Category__c;
        String fieldSetKey = 'XC_' + countryIso + '_' + userLEStream +'_' +'ZuoraContactExtraFields';


        List<XC_UTIL_FieldSet.FieldWrapper> fieldFromFieldSet = XC_UTIL_FieldSet.getFieldSetFields(fieldSetKey,'XC_BillingProfileLineItem__c');
        if(!fieldFromFieldSet.isEmpty()){
            //enrich zuora contact fields
            for(XC_UTIL_FieldSet.FieldWrapper field : fieldFromFieldSet){
                String fieldValue = String.valueOf(currentBpli.get(field.fieldName));
                contactJsonMap.put(field.fieldName,fieldValue);
            }
        }
        return JSON.Serialize(contactJsonMap);
    }


    /**
    * @author dpalamides@deloitte.it
    * @description manage contact extra fields from bpli object fieldsets
    * @createdate 2020-03-02
    */
    public String getEnrichExtraContactFieldsB2B(String contactStringObj,String bpliId){
        Map<String,Object> contactJsonMap = (Map <String,Object>) JSON.deserializeUntyped(contactStringObj);
        XC_BillingProfileLineItem__c currentBpli = (XC_BillingProfileLineItem__c) XC_UTIL_Sobject.selectAllFields(bpliId)[0];
        contactJsonMap.put('XC_PEC__c',currentBpli.XC_PEC__c);
        String stream = currentBpli.XC_Segment__c;
        String recipientCode = stream == 'B2B' ? currentBpli.XC_RecipientCodeB2B__c : currentBpli.XC_OfficeCode__c;

        contactJsonMap.put('XC_RecipientCode__c',recipientCode);

        return JSON.Serialize(contactJsonMap);
    }

    /**
    * @author dpalamides@deloitte.it
    * @createdate 2021-03-15
    */
    public String setExtraContactFieldsForUpdateB2B(String contactStringObj,Map<String,String> fields){
        Map<String,Object> contactJsonMap = (Map <String,Object>) JSON.deserializeUntyped(contactStringObj);
        
        if(fields.containsKey('newPEC')){
            contactJsonMap.put('XC_PEC__c',fields.get('newPEC'));
        }
        String recipientCode = fields.get('newRecipientCodeB2B') != null ? fields.get('newRecipientCodeB2B') : fields.get('newOfficeCode');

        contactJsonMap.put('XC_RecipientCode__c',recipientCode);

        return JSON.Serialize(contactJsonMap);
    }

    public void createSendInvoiceToCommodityLog(String accListJson){

        CreateSendInvoiceToCommodityLog wrapperRes = new CreateSendInvoiceToCommodityLog();
        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        headerDefinitions.put('Zuora-Entity-Ids', this.entityId);

        List<Account> accList = (List<Account>) JSON.deserialize(accListJson, List<Account>.class);

        List<Map<String,String>> reqDefinitionList = new List<Map<String,String>>();
        for (Account acc :accList){
            requestEditPlafond wrapperReqEditPlafond = new requestEditPlafond();
            wrapperReqEditPlafond.IDCRM = acc.Id != null ? acc.Id  : null ;
            wrapperReqEditPlafond.Scadenza =  String.valueOf(system.today().year()) +'-12-31';
            wrapperReqEditPlafond.Plafond = acc.XC_PlafondTechnical__c!=null ? String.valueOf(acc.XC_PlafondTechnical__c) :'0.0';
            wrapperReqEditPlafond.Residuo = wrapperReqEditPlafond.Plafond;

            Map<String,String> reqDefinition = new Map<String,String>();
            reqDefinition.put('IDCRM__c', wrapperReqEditPlafond.IDCRM);
            reqDefinition.put('Scadenza__c', wrapperReqEditPlafond.Scadenza);
            reqDefinition.put('Plafond__c', wrapperReqEditPlafond.Plafond);
            reqDefinition.put('Residuo__c', wrapperReqEditPlafond.Plafond);

            reqDefinitionList.add(reqDefinition);
        }
       
        String body = '{ "records": '+ JSON.serialize(reqDefinitionList) + '}';

        String url = 'callout:XC_ZuoraBasePath/objects/records/default/EsportatoriAbituali';
        HttpRequest req = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        system.debug('req mario'+req);
        //http callout

        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'createSendInvoiceToCommodityLog';
        logWrapper.insertLogging = true; 
        logWrapper.serverSystem = 'Zuora';
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
       
    }

    
    public XC_Integration_Log__c updateZuoraSubscription(Map<String, String> parametersMap) {

        // Parameter in the input map
        Map<String,Object> bodyMap = new Map<String,Object>();

        String zuoraId = parametersMap.get('subscriptionId');        
        String cigCup = parametersMap.get('XC_CigCup__c');                   
        String observaciones = parametersMap.get('XC_Observaciones__c');                    
        String additionalDescription = parametersMap.get('XC_AdditionalDescription__c');
        String determina = parametersMap.get('XC_Determina__c');                
        
        
        String body = '{';
        body += '"XC_CigCup__c":'+ (cigCup != null ? ('"' + cigCup + '"') : null);
        body += observaciones!=null ? ',"XC_Observaciones__c":"' + observaciones+ '"' : '';
        body += additionalDescription!=null ? ',"XC_AdditionalDescription__c":"' + additionalDescription+'"' : '';
        body += determina!=null ? ',"XC_Determina__c":"' + determina+'"' : '';
        body += '}'; 
        
        // Create Request
        Map<String,String> headerDefinitions = new Map<String,String>();
        headerDefinitions.put('Content-Type', 'application/json');
        headerDefinitions.put('Zuora-Entity-Ids', this.entityId);
        String url = 'callout:XC_ZuoraBasePath/v1/subscriptions/' + zuoraId;
        HttpRequest req = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);

        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'UpdateSubscriptions';
        logWrapper.insertLogging = false; 
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req, headerDefinitions, logWrapper);
        HTTPResponse res = httpRWr.response;
        
        return httpRWr.integrationLog.get(0);
    }
    /**
    * @description override zuora sequence set id if match criteria in XC_CSCS011_ZuoraSequenceSetIdOverride__c
    * @author Nicolo Fodera - nicolo.fodera@enel.com | 26-04-2022 
    * @param legalEntity  
    * @param stream
    * @param personTypeCode
    * @param currentSequenceSetId   
    * @return String , overridden sequeceSetId if match criteria in CS otherwise currentSequenceSetId
    **/ 
    public String overrideZuoraSequenceSetId(String legalEntity, String stream, String personTypeCode, String currentSequenceSetId) {
        String overriddenZuoraSequenceSetId = currentSequenceSetId;
        String orgId = UserInfo.getOrganizationId(); 
        List<XC_CS011_ZuoraSequenceSetIdOverride__c> seqSetIdOverrideConfs = [
            select id,XC_ZuoraSequenceSetIdOV__c  from XC_CS011_ZuoraSequenceSetIdOverride__c 
            where XC_OrgId__c =:orgId
            and XC_LegalEntity__c = :legalEntity
            and XC_Segment__c = :stream
            and XC_PersonTypeCode__c = :personTypeCode
        ];
        //System.debug('--->>' + legalEntity + ', ' + stream+ ', ' + personTypeCode+ ', ' +currentSequenceSetId + ', ' +orgId );
        if(!seqSetIdOverrideConfs.isEmpty()){ overriddenZuoraSequenceSetId = seqSetIdOverrideConfs[0].XC_ZuoraSequenceSetIdOV__c;} 
        return overriddenZuoraSequenceSetId;
    }
}