/**
* @File Name          : XC_IN_QRS08_GetAsset.cls
* @Description        :
* @Author             : Luisana Rocco - lrocco@deloitte.it
* @Group              :
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 07-07-2021
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    03/05/2021   Luisana Rocco - lrocco@deloitte.it     Initial Version
**/
public without sharing class XC_IN_QRS08_GetAsset {

    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }

    @InvocableMethod
    public static void executeGetAsset(List<InputWrapper> inputs){
        System.enqueueJob(new QueueableExecuteGetAsset(inputs));
    }

    public class QueueableExecuteGetAsset implements Queueable, Database.AllowsCallouts {

        private List<InputWrapper> inputs;

        public QueueableExecuteGetAsset(List<InputWrapper> inputs){
            this.inputs = inputs;
        }

        public void execute(QueueableContext qc) {
            manageGetAsset(inputs);
        }

    }



    /**
    * @description orchestrate getAsset and create queuede request child
    * @author Luisana Rocco - lrocco@deloitte.it | 04-05-2021
    * @param inputs
    **/
    public static void manageGetAsset(List<InputWrapper> inputs){

        Map<String,Object> utilMap = new Map<String,Object>();

        //Setting a savepoint
        Savepoint sp = Database.setSavePoint();

        //getting the full step info in order to process data
        InputWrapper iw = inputs[0];
        XC_QueuedRequestStep__c currentStep = XC_UTIL_QueuedRequestStep.getFullStepInfo(iw.stepId);
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        String logError = '';
        String messageResp = '';

        try{

            //getting account step
            Set<Integer> previousSequences = new Set<Integer> {Integer.valueOf(currentStep.XC_StepSequence__c)-1};
            Map<Id,XC_QueuedRequestStep__c> previousSteps = XC_UTIL_QueuedRequestStep.getQueuedRequestSteps(currentStep,  previousSequences);

            //Retrieve Order JSON Body
            XC_REST_Order_U.WrapperPOSTRequest wrReq = generatePostOrderBody(currentStep, previousSteps.values()[0]);

            //prepare integration log
            populateIntegrationLogInfo(currentStep, intLog,  wrReq);

            //start utilMap population
            utilMap.put('savePoint',sp);
            utilMap.put('accountId',wrReq.Order.AccountID);
            utilMap.put('commodityContractNum',wrReq.Order.CommodityContractNum);
            utilMap.put('ContractId',wrReq.Order.ContractId);
            utilMap.put('clientSystem',currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
            utilMap.put('wrReq', wrReq);
            utilMap.put('CommodityCC', wrReq.Order.CommodityCC); /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/


            system.debug('currentStep.XC_QueuedRequest__r.XC_ClientSystem__c'+currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
            system.debug('wrReq.Order.CommodityContractNum'+wrReq.Order.CommodityContractNum);
            system.debug('wrReq.Order.ContractId'+wrReq.Order.ContractId);


                //find Asset by Contract Number
            List<Asset> assetList =new List<Asset>(); //currentStep.XC_QueuedRequest__r.XC_ClientSystem__c=='CommodityRomaniaB2C' ? XC_IN_QRS09_Disconnect.getAssetInfo(utilMap,currentStep): getAsset(utilMap);
            //[ START, gaurav.tejpal@accenture.com, 25/05/2022,Enel X - BRAZIL VAS DEACTIVATION] -->
            if(currentStep.XC_QueuedRequest__r.XC_ClientSystem__c=='CommodityRomaniaB2C'){
                assetList= XC_IN_QRS09_Disconnect.getAssetInfo(utilMap,currentStep);
            }
            else if(currentStep.XC_QueuedRequest__r.XC_ClientSystem__c=='CommodityBrazilB2C'){
                assetList=!String.isBlank((String) utilMap.get('commodityContractNum'))? getAsset(utilMap) :XC_IN_QRS09_Disconnect.getAssetInfo(utilMap,currentStep);
            }
            else {
                assetList =getAsset(utilMap);
            }
            //[ END, gaurav.tejpal@accenture.com, 25/05/2022,Enel X - BRAZIL VAS DEACTIVATION] -->
           utilMap.put('assetList', assetList);

            system.debug(loggingLevel.Finest, '[GET ASSET] AssetList '+ assetList);

            //set step KO on asset Controls
            /*if(assetList.isEmpty()){
                setStepKO(currentStep,'No Asset/Contract found for ContractNumb or ContractId');
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError =  'No Asset/Contract found for ContractNumb or ContractId';
                wrResp.Result.Message =  'No Asset/Contract found for ContractNumb or ContractId';
                return;
            }*/

            //set step KO on asset Controls
            if(assetList.isEmpty()){
                setStepKO(currentStep,'No Asset/Contract found for ContractNumb: ' + wrReq.Order.CommodityContractNum + ' or for CommodityCC: ' + wrReq.Order.CommodityCC); /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError =  'No Asset/Contract found for ContractNumb: ' + wrReq.Order.CommodityContractNum + ' or for CommodityCC: ' + wrReq.Order.CommodityCC; /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/
                wrResp.Result.Message =   'No Asset/Contract found for ContractNumb: ' + wrReq.Order.CommodityContractNum + ' or for CommodityCC: ' + wrReq.Order.CommodityCC; /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/
                return;
            }
            

            //retrieve energy disconnect configuration
            Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt> energyDisconnectMap = retrieveEnergyDiscConfig(utilMap);
            utilMap.put('wrReq', wrReq);
            utilMap.put('energyDisconnectMap', energyDisconnectMap);
            utilMap.put('currentStep', currentStep);
            manageQueuedRequestCreation(utilMap, wrResp);
            if(wrResp.result.ErrorCode == '500'){
                return;
            }

            List<XC_QueuedRequest__c> qrListChange = (List<XC_QueuedRequest__c>) utilMap.get('qrListChange');
            List<XC_QueuedRequest__c> qrListDisconnect = (List<XC_QueuedRequest__c>) utilMap.get('qrListDisconnect');

            // set flag to manage the masterOfUpdateMoP and skipWait if there are no disconnection to be performed
            if(!qrListChange.isEmpty()){
                qrListChange[0].XC_MasterOfUpdateMOP__c = true;
                if(qrListDisconnect.isEmpty()){
                    for(XC_QueuedRequest__c qr: qrListChange){
                        qr.XC_SkipTheWait__c = true;
                    }
                }
            }

            qrListChange.addAll(qrListDisconnect);


            //Update asset
            List<Asset> assetListToUpdate = (List<Asset>)utilMap.get('assetList');
            List<XC_UTIL_Sobject.WrapperResult> resultAsset = XC_UTIL_Sobject.updateListRecords(assetListToUpdate);
            for(XC_UTIL_Sobject.WrapperResult res: resultAsset){
                if(!res.success){
                    setStepKO(currentStep, res.errorMessage);
                    wrResp.Result.ErrorCode = '500';
                    wrResp.Result.logError =  'INTERNAL ERROR. ' + res.errorMessage;
                    wrResp.Result.Message =  'INTERNAL ERROR. ' + res.errorMessage;
                    return;
                }
            }

            List<String> recordIds = new List<String>();
            //Insert QR
            if(!qrListChange.isEmpty()){
                List<XC_UTIL_Sobject.WrapperResult> result = XC_UTIL_Sobject.insertListRecords(qrListChange);
                for(XC_UTIL_Sobject.WrapperResult res: result){
                    if(!res.success){
                        setStepKO(currentStep, res.errorMessage);
                        wrResp.Result.ErrorCode = '500';
                        wrResp.Result.logError =  'INTERNAL ERROR. ' + res.errorMessage;
                        wrResp.Result.Message =  'INTERNAL ERROR. ' + res.errorMessage;
                        return;
                    }else{
                        recordIds.add(res.recordId);
                    }
                }

            }

            currentStep.XC_RelatedRecordsIds__c = String.Join(recordIds, ';');
            currentStep.XC_ExecutionResponse__c = 'Operation Completed Successfully. Waiting for related object execution [ '+ String.Join(recordIds, ';') + ']';
            wrResp.Result.ErrorCode = '0';
            wrResp.Result.Message = 'Operation Completed Successfully. Waiting for related object execution [ '+ String.Join(recordIds, ';') + ']';
            XC_UTIL_Sobject.updateRecord(currentStep);


        }catch(Exception e){
            logError = e.getMessage() + ' ' + e.getStackTraceString();
            setStepKO(currentStep,e.getMessage() + '' + e.getStackTraceString());
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
        }finally{
            //send callback if the status is KO
            if(currentStep.XC_Status__c==Label.XC_CL_Step_CompletedKO){
                if(!Test.isRunningTest()) {
                    Database.rollback(sp);
                }
                XC_UTIL_Sobject.updateRecord(currentStep);
                XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(currentStep);
            }

            logError = (String.isBlank(logError)) ? wrResp.Result.logError : logError;
            wrResp.Result.logError = null;
            messageResp = JSON.serialize(wrResp,true);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), messageResp, logError);
        }


    }

    /**
    * @description method to generate order body
    * @author Luisana Rocco - lrocco@deloitte.it | 04-05-2021
    * @param currentStep  the current step
    * @param previousStep the previous step
    * @return XC_REST_Order_U.WrapperPOSTRequest
    **/
    private static XC_REST_Order_U.WrapperPOSTRequest generatePostOrderBody(XC_QueuedRequestStep__c currentStep, XC_QueuedRequestStep__c previousStep){

        String requestStringValue = currentStep.XC_QueuedRequest__r.XC_RequestBody__c;
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(requestStringValue, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
        wrReq.Order = fullQRReqBody.Order;


        XC_REST_Account_W.WrapperResponse responseWrPreviousStepAccount = (XC_REST_Account_W.WrapperResponse) JSON.deserialize(previousStep.XC_ExecutionResponse__c, XC_REST_Account_W.WrapperResponse.class);
        wrReq.Order.AccountID = responseWrPreviousStepAccount.Account.AccountID;
        /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC [start]*/
        if(wrReq.Order.CommodityCC == null && fullQRReqBody.BillingProfile != null && fullQRReqBody.BillingProfile.size() != 0){ 
            wrReq.Order.CommodityCC = fullQRReqBody.BillingProfile[0].CommodityCC; 
        }
        /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC [end]*/

        return wrReq;
    }


    /**
    * @description retrieve asset that has to be disconnected based on accountid,contract number
    * @author Luisana Rocco - lrocco@deloitte.it | 04-05-2021
    * @param utilMap
    * @return List<Asset>
    **/
    private static List<Asset> getAsset(Map<String,Object> utilMap){

        String contract = String.isBlank((String) utilMap.get('commodityContractNum')) ? (String) utilMap.get('ContractId') : (String) utilMap.get('commodityContractNum');
        String commodityCC = (String) utilMap.get('CommodityCC'); /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/
        String accountId = (String) utilMap.get('accountId');

        Map<Id,XC_BillingProfileLineItem__c> mapBpli = new Map<Id, XC_BillingProfileLineItem__c>([SELECT Id,
        (SELECT Id, XC_ContractStartDate__c, XC_ContractEndDate__c,
        NE__ProdId__r.XC_LIC_Product_Name__c, XC_BillingModel__c, XC_BillingProfileLineItem__r.XC_BillingProfile__c, XC_ActivePortfolio__c
        FROM Assets__r WHERE NE__Bundle_Configuration__c = null and NE__Root_Order_Item__c = null)
        FROM XC_BillingProfileLineItem__c WHERE (XC_BillingProfile__r.XC_CommodityContractID__c =: contract OR XC_BillingProfile__r.XC_CommodityContractID__c =: CommodityCC) AND XC_BillingProfile__r.XC_CommodityContractID__c != null /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/ AND XC_BillingProfile__r.NE__Account__c =: accountId]);
        Set<Asset> setAsset = new Set<Asset>();

        for(XC_BillingProfileLineItem__c bpli : mapBpli.values()){
            if(!bpli.Assets__r.isEmpty()){
                setAsset.addAll(bpli.Assets__r);
            }
        }

        List<Asset> assetList = new List<Asset>();
        assetList.addAll(setAsset);

        return assetList;
    }


    /**
    * @description update step in KO status
    * @author Luisana Rocco - lrocco@deloitte.it | 04-05-2021
    * @param step
    * @param errorMessage
    **/
    private static void setStepKO(XC_QueuedRequestStep__c step,String errorMessage){
        step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        step.XC_ErrorMessage__c = errorMessage;
    }


    /**
    * @description populate integration log
    * @author Luisana Rocco - lrocco@deloitte.it | 18-05-2021
    * @param currentStep
    * @param intLog
    * @param wrReq
    **/
    private static void populateIntegrationLogInfo(XC_QueuedRequestStep__c currentStep, XC_UTIL_IntegrationLog intLog, XC_REST_Order_U.WrapperPOSTRequest wrReq){
        //adding headers
        Map<String,String> mapHeader = new Map<String,String>();
        mapHeader.put('ClientSystem', currentStep.XC_QueuedRequest__r.XC_ClientSystem__c);
        mapHeader.put('TransactionID', currentStep.XC_QueuedRequest__r.XC_TransactionId__c);
        mapHeader.put('DateTimeMessage', DateTime.now().format('yyyyMMddHHmmssSSS'));
        mapHeader.put('Operation', 'GetAsset');
        mapHeader.put('Functionality', 'GetAsset');
        mapHeader.put('ServerSystem', 'XCustomerB2C');


        //TODO: manage first integration log insert here
        intLog.insertIntegReqInboundLog('AsyncOrderGetAsset', JSON.serialize(wrReq,true),currentStep.XC_QueuedRequest__c);
        intLog.setHeader(mapHeader);
        intLog.setTransactionID(mapHeader.get('TransactionID'));
        intLog.setHttpMethod('POST');

        // set additional integration log info
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new  XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.accountID = wrReq.Order.accountID;
        intLog.setAdditionalInformations(logWrapper);

    }


    /**
    * @description manage child queued request creation
    * @author Luisana Rocco - lrocco@deloitte.it | 18-05-2021
    * @param utilMap
    * @param wrresp
    **/
    private static void manageQueuedRequestCreation(Map<String,Object> utilMap, XC_REST_Order_U.WrapperRes wrResp){

        List<Asset> assetList = (List<Asset>) utilMap.get('assetList');
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('wrReq');
        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c) utilMap.get('currentStep');
        Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt> energyDisconnectMap  = (Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt>) utilMap.get('energyDisconnectMap');
        List<XC_QueuedRequest__c> qrListChange = new List<XC_QueuedRequest__c>();
        List<XC_QueuedRequest__c> qrListDisconnect = new List<XC_QueuedRequest__c>();


        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(currentStep.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        /*List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wrReqBP = fullQRReqBody.BillingProfile;
        wrReqBP[0].BillingProfileID = assetList[0].XC_BillingProfileLineItem__r.XC_BillingProfile__c;
        fullQRReqBody.BillingProfile = wrReqBP;*/

        wrReq.Order.BillingProfIdUpdateMop = assetList[0].XC_BillingProfileLineItem__r.XC_BillingProfile__c; 
        
        for(Asset ass: assetList){

            Boolean matchFound = false;

            // store info from market
            ass.XC_CommodityCancellationReason__c = wrReq.Order.CommodityCancellationReason;
            ass.XC_MarketSegment__c = wrReq.Order.MarketSegment;
            ass.XC_Tariff__c = wrReq.Order.Tariff;
            ass.XC_ContractedPowerRatingFrom__c = wrReq.Order.ContractedPowerFrom;
            ass.XC_ContractedPowerRatingTo__c = wrReq.Order.ContractedPowerTo;

            // prepare the new queued request child to insert
            XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
            qr.XC_ParentQueuedRequest__c = currentStep.XC_QueuedRequest__c;
            qr.XC_IntegrationId__c = fullQRReqBody.Order.IntegrationID;
            qr.XC_ClientSystem__c = currentStep.XC_QueuedRequest__r.XC_ClientSystem__c;
            qr.XC_TransactionId__c = currentStep.XC_QueuedRequest__r.XC_TransactionId__c +  '_'+ ass.Id; // add number to identify child
            qr.XC_ValidationStatus__c = currentStep.XC_QueuedRequest__r.XC_ValidationStatus__c;
            qr.XC_Reason__c = currentStep.XC_QueuedRequest__r.XC_Reason__c;

            wrReq.Order.AssetID = ass.Id;

            System.debug('XC_ActivePortfolio__c'+(ass.XC_ActivePortfolio__c));

              //CR UPiscopo 09/11/2021 - Energy Disconnect Romania for CommodityRomaniaB2C -- BEGIN -->
			if(ass.XC_ActivePortfolio__c){
		      	System.debug('IN CONTINUE TO NEXT ASSET');

                wrReq.Order.OrderType = Label.XC_CL_Configuration_TypeDisconnection;
                wrReq.Order.OrderSubType = 'Active Portfolio Contract Disconnection';

			  	fullQRReqBody.Order = wrReq.Order;
              	qr.XC_RequestBody__c = JSON.Serialize(fullQRReqBody, true);

			  	qrListDisconnect.add(qr);
			  	continue;
		    }//<-- END

            Integer absCommVasActDate = (ass.XC_ContractStartDate__c != null) ? math.abs(wrReq.Order.CommodityContractActivationDate.daysBetween(ass.XC_ContractStartDate__c)) : 0;
            utilMap.put('absCommVasActDate', absCommVasActDate);
            for(XC_CM_EnergyDisconnectConfiguration__mdt energyDisConf: energyDisconnectMap.values()){
                Boolean checkConfig = checkMatchConfiguration(ass, energyDisConf, utilMap);
                if(checkConfig){
                    wrReq.Order.OrderType = (energyDisConf.XC_Action__c == Label.XC_CL_Configuration_TypeDisconnection) ? energyDisConf.XC_Action__c : 'Change Order';
                    wrReq.Order.OrderSubType = (energyDisConf.XC_Action__c == 'Update MOP') ? 'UpdateMoP'  : energyDisConf.XC_ReasonOfCancellation__c;
                    fullQRReqBody.Order = wrReq.Order;
                    qr.XC_RequestBody__c = JSON.Serialize(fullQRReqBody, true);
                    matchFound = true;
                    
                    if(energyDisConf.XC_Action__c == 'Update MOP'){
                        system.debug('[GET ASSET] IN CHANGE ORDER Update MOP: ' + ass.Id);
                        qrListChange.add(qr);
                    }else if(energyDisConf.XC_Action__c == Label.XC_CL_Configuration_TypeDisconnection){
                        system.debug('[GET ASSET] IN DISCONNECTION: ' + ass.Id);
                        qrListDisconnect.add(qr);
                    }else{// no action is configured for this mdt row
                        system.debug('[GET ASSET] IN NO ACTION: ' + ass.Id);
                        setStepKO(currentStep, 'INTERNAL ERROR. No automatic action is configured for asset: ' + ass.Id);
                        wrResp.Result.ErrorCode = '500';
                        wrResp.Result.logError = 'INTERNAL ERROR. No automatic action is configured for asset: ' + ass.Id;
                        wrResp.Result.Message = 'INTERNAL ERROR. No automatic action is configured for asset: ' + ass.Id;
                        return;
                    }
                    break;
                }
            }
            if(!matchFound){//The assumption is that if a match cannot be found on the custom metadata, a change order must be performed for the asset.
                system.debug('[GET ASSET] IN NO MATCH: ' + ass.Id);
                wrReq.Order.OrderType = 'Change Order';
                wrReq.Order.OrderSubType = 'UpdateMoP';
                fullQRReqBody.Order = wrReq.Order;
                qr.XC_RequestBody__c = JSON.Serialize(fullQRReqBody, true);
                qrListChange.add(qr);
            }
		}


        utilMap.put('qrListChange', qrListChange);
        utilMap.put('qrListDisconnect', qrListDisconnect);
        utilMap.put('assetList', assetList);

    }


    /**
    * @description retrieve energy disconnect confiuration from custom metadata
    * @author Luisana Rocco - lrocco@deloitte.it | 18-05-2021
    * @param utilMap
    * @return Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt>
    **/
    private static Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt> retrieveEnergyDiscConfig(Map<String,Object> utilMap){

        List<Asset> assetList = (List<Asset>) utilMap.get('assetList');
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('wrReq');

        String legalEntity =  wrReq.Order.LegalEntity;
        String orderType = wrReq.Order.OrderType;
        String orderSubtype =  wrReq.Order.OrderSubType;

        Set<String> productNames = new Set<String>();
        Set<String> billingModel = new Set<String>();
        for(Asset ass: assetList){
            productNames.add(ass.NE__ProdId__r.XC_LIC_Product_Name__c);
            billingModel.add(ass.XC_BillingModel__c);
        }

        Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt> energyDisconnectMap = new Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt>
        ([SELECT XC_AbsCommodityVasActivationDate_From__c, XC_AbsCommodityVasActivationDate_To__c,
        XC_Action__c, XC_BillingModel__c, XC_CommodityBussinesLine__c, XC_ContractedPowerRating_From__c,
        XC_ContractedPowerRating_To__c, XC_ReasonOfCancellation__c, XC_VasActivationEndDate__c,
        XC_VasActivationStartingDate__c, XC_VASProductName__c, XC_CommodityCancellationReason__c,
        XC_MarketSegment__c, XC_Tariff__c, XC_CommodityCancellationReasonToExclude__c, XC_LegalEntity__c
        FROM XC_CM_EnergyDisconnectConfiguration__mdt
        WHERE XC_VASProductName__c IN: productNames  /*AND (XC_BillingModel__c IN: (billingModel) OR XC_BillingModel__c =: 'Any')*/ and XC_LegalEntity__c =: legalEntity and
                  XC_OrderType__c =: orderType and XC_OrderSubType__c =: orderSubtype]); // retrieve configurations for a given legalentity, orderType and orderSubType

        return energyDisconnectMap;
    }


    /**
    * @description check match between asset and custom metdata
    * @author Luisana Rocco - lrocco@deloitte.it | 18-05-2021
    * @param utilMap
    * @param ass
    * @param energyDisConf
    * @return boolean
    **/
    private static boolean checkMatchConfiguration(Asset ass, XC_CM_EnergyDisconnectConfiguration__mdt energyDisConf, Map<String,Object> utilMap){
        Integer absCommVasActDate = (Integer) utilMap.get('absCommVasActDate');
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('wrReq');

        system.debug('[GET ASSET] absCommVasActDate:' + absCommVasActDate);
        system.debug('[GET ASSET] EDabsActivationFrom:' + energyDisConf.XC_AbsCommodityVasActivationDate_From__c);
        system.debug('[GET ASSET] EDabsActivationTo:' + energyDisConf.XC_AbsCommodityVasActivationDate_To__c);
        system.debug('[GET ASSET] VASprodname:' + energyDisConf.XC_VASProductName__c);
        system.debug('[GET ASSET] AssProdname:' + ass.NE__ProdId__r.XC_LIC_Product_Name__c );
        system.debug('[GET ASSET] BillingModel:' + energyDisConf.XC_BillingModel__c);
        system.debug('[GET ASSET] AssBillingModel:' + ass.XC_BillingModel__c);
        system.debug('[GET ASSET] VASStartDate:' + energyDisConf.XC_VasActivationStartingDate__c);
        system.debug('[GET ASSET] AssStartDate:' + ass.XC_ContractStartDate__c);
        system.debug('[GET ASSET] VASSEndDate:' + energyDisConf.XC_VasActivationEndDate__c);
        system.debug('[GET ASSET] AssEndDate:' + ass.XC_ContractEndDate__c);
        system.debug('[GET ASSET] CommodityBsnLine:' + wrReq.Order.CommodityBsnLine);
        system.debug('[GET ASSET] EDCommodityBsnLine:' + energyDisConf.XC_CommodityBussinesLine__c );
        system.debug('[GET ASSET] CommodityCancellationReason:' + wrReq.Order.CommodityCancellationReason);
        system.debug('[GET ASSET] EDCancellation Reason To Exclude::' + energyDisConf.XC_CommodityCancellationReasonToExclude__c );
        system.debug('[GET ASSET] EDCommodityCancellationReason:' + energyDisConf.XC_CommodityCancellationReason__c );
        system.debug('[GET ASSET] ContractedPowerFrom:' + wrReq.Order.ContractedPowerFrom);
        system.debug('[GET ASSET] EDContractedPowerFrom:' + energyDisConf.XC_ContractedPowerRating_From__c );
        system.debug('[GET ASSET] ContractedPowerTo:' + wrReq.Order.ContractedPowerTo);
        system.debug('[GET ASSET] EDContractedPowerTo:' + energyDisConf.XC_ContractedPowerRating_To__c );
        system.debug('[GET ASSET] Tariff:' + wrReq.Order.Tariff);
        system.debug('[GET ASSET] EDTariff:' + energyDisConf.XC_Tariff__c );
        system.debug('[GET ASSET] MarketSegment:' + wrReq.Order.MarketSegment);
        system.debug('[GET ASSET] EDMarketSegment:' + energyDisConf.XC_MarketSegment__c );

        List<String> reasonToExclude = new List<String>();
        //  //Mod. CV 20210707 --- Start
        if(!String.isBlank(energyDisConf.XC_CommodityCancellationReasonToExclude__c)){
            reasonToExclude = energyDisConf.XC_CommodityCancellationReasonToExclude__c.split(';');
        }
        //Mod. CV 20210707 --- End


        if(absCommVasActDate >= energyDisConf.XC_AbsCommodityVasActivationDate_From__c && absCommVasActDate <= energyDisConf.XC_AbsCommodityVasActivationDate_To__c
        && energyDisConf.XC_VASProductName__c == ass.NE__ProdId__r.XC_LIC_Product_Name__c
        && (energyDisConf.XC_BillingModel__c == ass.XC_BillingModel__c || (!String.isBlank(ass.XC_BillingModel__c) && ass.XC_BillingModel__c.containsIgnoreCase('Renting') && energyDisConf.XC_BillingModel__c.equalsIgnoreCase('Renting')) || energyDisConf.XC_BillingModel__c == 'Any')
        && ass.XC_ContractStartDate__c >= energyDisConf.XC_VasActivationStartingDate__c
        && ass.XC_ContractEndDate__c <= energyDisConf.XC_VasActivationEndDate__c
        && (wrReq.Order.CommodityBsnLine == energyDisConf.XC_CommodityBussinesLine__c || energyDisConf.XC_CommodityBussinesLine__c == 'Any')
        && wrReq.Order.ContractedPowerFrom >= energyDisConf.XC_ContractedPowerRating_From__c
        && wrReq.Order.ContractedPowerTo <= energyDisConf.XC_ContractedPowerRating_To__c
        && (!reasonToExclude.isEmpty() && !reasonToExclude.contains(wrReq.Order.CommodityCancellationReason) ||
        (reasonToExclude.isEmpty() && (wrReq.Order.CommodityCancellationReason == energyDisConf.XC_CommodityCancellationReason__c || energyDisConf.XC_CommodityCancellationReason__c == 'Any')))
        && (wrReq.Order.MarketSegment == energyDisConf.XC_MarketSegment__c || energyDisConf.XC_MarketSegment__c == 'Any')
        && (wrReq.Order.Tariff == energyDisConf.XC_Tariff__c || energyDisConf.XC_Tariff__c == 'Any')){
            return true;
        }
        return false;
    }
}