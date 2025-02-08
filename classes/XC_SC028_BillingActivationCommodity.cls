/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 17/03/2020
 * @description XC_SC028_BillingActivationCommodity - Batch to activate Billing Profile Commodity
 */

public without sharing class XC_SC028_BillingActivationCommodity implements Schedulable, Database.Batchable<sObject>,Database.AllowsCallouts {

    private final static Boolean DEBUGACTIVE = true;//XC_UTIL_Debug.isActive('XC_SC028_BillingActivationCommodity');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC028_BillingActivationCommodity(),25);
    }

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start batch XC_SC028_BillingActivationCommodity');
        String statusBillingProfile = Label.XC_CL_Payment_CommodityBill;
        String paymentType = Label.XC_CL_BillingStatus_StatusActivation;
        List<String> legalEntityList =  new List<String>{Label.XC_CL_LegalEntity_Italy,Label.XC_CL_LegalEntity_EnelXMobilityItalia,Label.XC_CL_LegalEntity_EnelXMobilityHolding};
        return Database.getQueryLocator(
            'SELECT Id,Name, XC_CommodityContractID__c, XC_Segment__c, ' +
                '(SELECT Id, XC_Segment__c, XC_DocumentType__c,XC_LegalEntity__c,XC_DocumentNumber__c,XC_ZuoraId__c,XC_BillToContactId__c,XC_BillToAddress__c,XC_SoldToAddress__c,XC_SoldToContactId__c,XC_DocumentCountry__c FROM Billing_Profile_Line_Items__r WHERE XC_LegalEntity__c IN :legalEntityList) ' +
                ' FROM NE__Billing_Profile__c ' +
                ' WHERE NE__Payment__c = :statusBillingProfile AND XC_Status__c = :paymentType AND XC_SkipBatch__c = false'
        );
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<NE__Billing_Profile__c> scope){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Execute batch XC_SC028_BillingActivationCommodity');
        List<NE__Billing_Profile__c> listBillProfileToUpdate = new List<NE__Billing_Profile__c>();
        List<XC_BillingProfileLineItem__c> listBillProfileItemToUpdate = new List<XC_BillingProfileLineItem__c>();
        List<XC_Integration_Log__c> integrationLogsContract = new List<XC_Integration_Log__c >();
        List<XC_Integration_Log__c> integrationLogsUpdateZuoraAccount= new List<XC_Integration_Log__c >(); /*20220402 NicoloFodera improve logging info*/
        
        for(NE__Billing_Profile__c billingProfile : scope) {

            System.Debug('BILLING PROFILE CONSIDERED::: ' + billingProfile.Name);

            List<Map<String, Object>> listResponse = new List<Map<String, Object>>();
            // Retrieve Contract Status:
            for(XC_BillingProfileLineItem__c item : billingProfile.Billing_Profile_Line_Items__r) {
                XC_REST_Contract_Outbound.ContractOutboudCallInputData inputWrapper = new XC_REST_Contract_Outbound.ContractOutboudCallInputData();
                inputWrapper.identityNumber = item.XC_DocumentNumber__c;
                inputWrapper.identityType = item.XC_DocumentType__c == 'CF' || item.XC_DocumentType__c.equalsIgnoreCase('Codice Fiscale') ? 'Codice%20Fiscale' : item.XC_DocumentType__c.equalsIgnoreCase('Partita IVA') ? 'Partita%20IVA' : item.XC_DocumentType__c;
                inputWrapper.pos = '';
                inputWrapper.country = item.XC_DocumentCountry__c;
                inputWrapper.insertLoggin = false;
                // Call to get contract (simulated response for coverage test):
                XC_REST_Contract_Outbound.ContractOutboudCallOutputData outputWrapper = new XC_REST_Contract_Outbound.ContractOutboudCallOutputData();
                if(Test.isRunningTest()) {
                    outputWrapper.fieldsData = new Map<String,Object>();
                    outputWrapper.integrationLog = new List<XC_Integration_Log__c>();
                    Map<String, Object> tempMap = new Map<String, Object>();
                    tempMap.put('ContractNumber', 'Test');
                    tempMap.put('AccountID', 'TestAccID');/*20220402 NicoloFodera correctly ingest CommodityBP*/
                    tempMap.put('Status', '01');
                    tempMap.put('AddressData', billingProfile.XC_CommodityContractID__c+'_TEST');
                    outputWrapper.fieldsData.put('Contract', new List<Map<String, Object>>{tempMap});
                } else {
                    outputWrapper = XC_REST_Contract_Outbound.callToGetContract(inputWrapper);
                    /*20220402 NicoloFodera improve logging info [start]*/
                    for(XC_Integration_Log__c  log : outputWrapper.integrationLog){
                        log.XC_BillingProfile__c = billingProfile.id;
                        log.XC_BillingProfileLineItem__c = item.id;
                    }
                    /*20220402 NicoloFodera improve logging info [end]*/
                    integrationLogsContract.addAll(outputWrapper.integrationLog);
                }

                if(outputWrapper.fieldsData.containsKey('Contract')){
                    List<Object> listMapContract = (List<Object>) outputWrapper.fieldsData.get('Contract');
                    for(Object mapContractObj : listMapContract) {
                        Map<String,Object> mapContract = (Map<String,Object>) mapContractObj;
                        listResponse.add(mapContract);
                    }
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ List response -> ' + listResponse);

            // Check Billing Profile Status:
            //Boolean checked = false;/*20220402 NicoloFodera review multiple bpli management: USELESS*/
            for(Map<String, Object> response : listResponse) {
                String contractNumber = String.valueOf(response.get('ContractNumber'));
                String contractStatus = String.valueOf(response.get('Status'));
                String commodityBP = String.valueOf(response.get('AccountID')); /*20220402 NicoloFodera correctly ingest CommodityBP*/
                String podNumber = String.valueOf(response.get('AddressData')).split('_')[0];
                //check on contracts and BPLIS to UPDATE
                if(podNumber == billingProfile.XC_CommodityContractID__c) {

                    //if contract is action update BPLI and Zuora Customer Account
                    System.Debug('POD CONTRACT FOUND::: ' + response + 'BPID:: ' + billingProfile.Id);

                    if(String.isNotBlank(contractNumber) && contractNumber!=null && contractNumber!='null' && String.isNotBlank(commodityBP) && commodityBP!=null && commodityBP!='null') { /*20220402 NicoloFodera correctly ingest CommodityBP, added && String.isNotBlank(commodityBP) && commodityBP!=null && commodityBP!='null'*/

                        /*20220402 NicoloFodera review multiple bpli management [start]*/
                        //Boolean zuoraSuccessResponse = false;
                        Integer zuoraSuccessResponsesCount = 0;
                        /*20220402 NicoloFodera review multiple bpli management [end]*/
                        
                        billingProfile.XC_Status__c = Label.XC_CL_BillingProfileActive;
                        billingProfile.XC_CommodityContractID__c = contractNumber;
                        billingProfile.XC_SAPBusinessPartner__c = commodityBP; /*20220402 NicoloFodera correctly ingest CommodityBP*/
                        for(XC_BillingProfileLineItem__c item : billingProfile.Billing_Profile_Line_Items__r) {
                            Boolean zuoraSuccessResponse = false;  /*20220402  NicoloFodera review multiple bpli management, moved declaration here [end]*/
                            Map<String,String> zuoraParamsMap = new Map<String,String>();
                            zuoraParamsMap.put('zuoraAccountId',item.XC_ZuoraId__c);
                            zuoraParamsMap.put('billToId',item.XC_BillToContactId__c);
                            zuoraParamsMap.put('soldToId',item.XC_SoldToContactId__c);
                            zuoraParamsMap.put('soldAddrId',item.XC_SoldToAddress__c);
                            zuoraParamsMap.put('billAddrId',item.XC_BillToAddress__c);
                            zuoraParamsMap.put('legalEntity',item.XC_LegalEntity__c);
                            zuoraParamsMap.put('commodityContractId',contractNumber);
                            zuoraParamsMap.put('commodityAccountId',commodityBP);  /*20220402 NicoloFodera correctly ingest CommodityBP*/


                            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(item.XC_LegalEntity__c, item.XC_Segment__c);
                            ZuoraWebservice zws = new ZuoraWebservice(entityName);
                            ZuoraWebservice.CreateZuoraAccountResponse updateAccountResp = new ZuoraWebservice.CreateZuoraAccountResponse();
                            if(!Test.isRunningTest()) {
                                updateAccountResp = zws.updateZuoraAccount(zuoraParamsMap);
                            } else {
                                updateAccountResp.success = 'true';
                            }
                            zuoraSuccessResponse = Boolean.valueOf(updateAccountResp.success);
                            /*20220402 NicoloFodera improve logging info [start]*/ 
                            if(updateAccountResp.integrationLog != null){
                                updateAccountResp.integrationLog.XC_BillingProfileLineItem__c = item.id;
                                integrationLogsUpdateZuoraAccount.add(updateAccountResp.integrationLog);
                            }
                            /*20220402 NicoloFodera improve logging info [end]*/ 
                            if(zuoraSuccessResponse){
                                zuoraSuccessResponsesCount++; /*20220402 NicoloFodera review multiple bpli management*/
                                item.XC_Status__c = Label.XC_CL_BillingProfileActive;
                                listBillProfileItemToUpdate.add(item);
                            }
                            //break; /*20220402 NicoloFodera review multiple bpli management; why break? what if you have more than one bpli under the the bp? Commented break*/
                        }

                        if(zuoraSuccessResponsesCount == billingProfile.Billing_Profile_Line_Items__r.size() ){ ///*20220402 NicoloFodera review multiple bpli management; all responses success
                            listBillProfileToUpdate.add(billingProfile);
                        }
                    }
                    //checked = true; /*20220402 NicoloFodera review multiple bpli management: USELESS*/
                    break;
                }
            }

            //if(checked) {  /*20220402 NicoloFodera review multiple bpli management: USELESS, it will continue anyway at this point!*/
            //    continue;
            //}

        }

        // DML operations:
        XC_UTIL_Sobject.updateListRecords(listBillProfileToUpdate, false);
        XC_UTIL_Sobject.updateListRecords(listBillProfileItemToUpdate, false);

        //Specifying logs
        for(XC_Integration_Log__c log : integrationLogsContract){
            log.XC_Log_IntegrationName__c = 'ContractPollingBatchEE';
        }

        XC_UTIL_Sobject.insertListRecords(integrationLogsContract,false);
        XC_UTIL_Sobject.insertListRecords(integrationLogsUpdateZuoraAccount,false); /*20220402 NicoloFodera improve logging info*/ 

    }    

    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End batch XC_SC028_BillingActivationCommodity');
    }    

}