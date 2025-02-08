/**
* @File Name          : XC_IN_QRS08_GetAsset_CO.cls
* @Description        : Class to retrieve asset for partner evnt with type change order
* @Author             : Luisana Rocco - lrocco@deloitte.it
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    08/10/2021   Luisana Rocco - lrocco@deloitte.it     Initial Version
**/
public  without sharing class XC_IN_QRS08_GetAsset_CO {

    public static final Map<String,String> ORDERSUBTYPE = new Map<String,String>{
                                                                                         'Change Ownership' =>'Change of ownership',
                                                                                         'Update MOP' => 'UpdateMoP'

    };

    public static final Map<String,String> ORDERTYPE = new Map<String,String>{
                                                                            
                                                                                         'Change of ownership' =>'ChangeOrder',
                                                                                         'UpdateMoP' => 'Change Order'
    };



    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }
    
    @InvocableMethod
    public static void executeGetAssetCO(List<InputWrapper> inputs){
        System.enqueueJob(new QueueableExecuteGetAssetCO(inputs));
    }
    
    public class QueueableExecuteGetAssetCO implements Queueable, Database.AllowsCallouts {
        
        private List<InputWrapper> inputs;
        
        public QueueableExecuteGetAssetCO(List<InputWrapper> inputs){
            this.inputs = inputs;
        }
        
        public void execute(QueueableContext qc) {
            manageGetAssetCO(inputs);
        }
        
    }


    /**
    * @description orchestrate getAsset and create queuede request child
    * @author Luisana Rocco - lrocco@deloitte.it | 04-05-2021 
    * @param inputs 
    **/
    public static void manageGetAssetCO(List<InputWrapper> inputs){
        
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
            
        
            //Retrieve Order JSON Body
            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(currentStep.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            XC_REST_Order_U.WrapperPOSTRequest wrReq = new XC_REST_Order_U.WrapperPOSTRequest();
            wrReq.Order = fullQRReqBody.Order;

            /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC [start]*/
            if(wrReq.Order.CommodityCC == null && fullQRReqBody.BillingProfile != null && fullQRReqBody.BillingProfile.size() != 0){ 
                wrReq.Order.CommodityCC = fullQRReqBody.BillingProfile[0].CommodityCC; 
            }
            /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC [end]*/   
            
            //prepare integration log  
            utilMap.put('currentStep', currentStep);
            utilMap.put('intLog', intLog);
            utilMap.put('wrReq', wrReq);
            utilMap.put('wrResp', wrResp);
            utilMap.put('operation', 'GetAssetCO');
            utilMap.put('integrationLogName', 'AsyncGetAssetCO' );

            XC_UTIL_QueuedRequestStep.populateIntegrationLogInfo(utilMap);
            
          
            utilMap.put('savePoint',sp);
            utilMap.put('commodityContractNum',wrReq.Order.CommodityContractNum);
            utilMap.put('CommodityCC', wrReq.Order.CommodityCC); /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/

            
            //get Asset by Contract Number
            List<Asset> assetList = getAsset(utilMap);
            utilMap.put('assetList', assetList);
            
            system.debug(loggingLevel.Finest, '[GET ASSET] AssetList '+ assetList);
            
            //set step KO if no asset is found 
            /*if(assetList.isEmpty()){

                XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'ERROR. ' + 'No Asset/Contract found for ContractNumb: ' + wrReq.Order.CommodityContractNum);
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError =  'INTERNAL ERROR. ' + 'No Asset/Contract found for ContractNumb: ' + wrReq.Order.CommodityContractNum;
                wrResp.Result.Message =  'INTERNAL ERROR. ' + 'No Asset/Contract found for ContractNumb: ' + wrReq.Order.CommodityContractNum;
                return;
            }*/

            //set step KO if no asset is found 
            if(assetList.isEmpty()){

                XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'ERROR. ' + 'No Asset/Contract found for ContractNumb: ' + wrReq.Order.CommodityContractNum+ ' or for CommodityCC: ' + wrReq.Order.CommodityCC); /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/
                wrResp.Result.ErrorCode = '500';
                wrResp.Result.logError =  'INTERNAL ERROR. ' + 'No Asset/Contract found for ContractNumb: ' + wrReq.Order.CommodityContractNum + ' or for CommodityCC: ' + wrReq.Order.CommodityCC; /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/
                wrResp.Result.Message =  'INTERNAL ERROR. ' + 'No Asset/Contract found for ContractNumb: ' + wrReq.Order.CommodityContractNum + ' or for CommodityCC: ' + wrReq.Order.CommodityCC; /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/
                return;
            }
            
            //retrieve configured actions
            Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt> configuredActiontMap = retrieveConfiguredAction(utilMap);
            utilMap.put('configuredActiontMap', configuredActiontMap);
            utilMap.put('currentStep', currentStep);
            manageQueuedRequestCreation(utilMap, wrResp);
            if(wrResp.result.ErrorCode == '500'){
                return;
            }
            
            List<XC_QueuedRequest__c> qrListChange = (List<XC_QueuedRequest__c>) utilMap.get('qrListChange'); 
            List<XC_QueuedRequest__c> qrListChangeOrder = (List<XC_QueuedRequest__c>) utilMap.get('qrListChangeOrder'); 
            List<XC_QueuedRequest__c> qrListDisconnect = (List<XC_QueuedRequest__c>) utilMap.get('qrListDisconnect'); 
       

            system.debug(loggingLevel.Finest, 'QRCHANGE BeforeInsert' + qrListChange);
            system.debug(loggingLevel.Finest, 'QRDIS BeforeInsert' + qrListDisconnect);
            
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
            qrListChange.addAll(qrListChangeOrder);
            
            
            List<String> recordIds = new List<String>();
            //Insert QR
            if(!qrListChange.isEmpty()){
                List<XC_UTIL_Sobject.WrapperResult> result = XC_UTIL_Sobject.insertListRecords(qrListChange);
                for(XC_UTIL_Sobject.WrapperResult res: result){
                    if(!res.success){
                        XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'INTERNAL ERROR. ' + res.errorMessage);
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
            XC_UTIL_QueuedRequestStep.setStepKO(currentStep,'INTERNAL ERROR. ' );
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
    * @description retrieve asset that has to be disconnected based on account document number and contract number
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param utilMap 
    * @return List<Asset> 
    **/
    private static List<Asset> getAsset(Map<String,Object> utilMap){

        
        String commodityContractNum = (String) utilMap.get('commodityContractNum');
        String commodityCC = (String) utilMap.get('CommodityCC'); /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/ 
        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c)utilMap.get('currentStep');
        XC_REST_Account_W.WrapperRequest accountWrReq = new XC_REST_Account_W.WrapperRequest();
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(currentStep.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        accountWrReq.Account = fullQRReqBody.Account;
        accountWrReq.BillingProfile = fullQRReqBody.BillingProfile;
        
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('wrReq');
        String recordTypeID = XC_REST_Account_ZZZ.retrieveRecordTypeID(accountWrReq, 'POST');
        Set<String> accIds = new Set<String>();


        String commodityBill = Label.XC_CL_Commodity_Bill;
        String directDebt = Label.XC_CL_DirectDebt;
        String oldAccountDNI = wrReq.Order.OldAccountDNI;
        
        if(accountWrReq.Account.AccountType == 'Residential'){
                
            Map<Id, XC_PersonalDocument__c> mapIdDocs = new Map<Id, XC_PersonalDocument__c>([SELECT XC_Account__c FROM XC_PersonalDocument__c 
                                                                                            WHERE XC_DocumentNumber__c =: wrReq.Order.OldAccountDNI  AND XC_Account__c!= null AND  XC_Account__r.RecordTypeId  =: recordTypeID]);
            
            for(XC_PersonalDocument__c personaldoc : mapIdDocs.values()){
                accIds.add(personaldoc.XC_Account__c);
            }
        }      

        String query = 'SELECT Id, XC_BillingProfile__r.NE__Account__c, (SELECT Id, AccountId, NE__ProdId__r.XC_LIC_Product_Name__c, XC_LegalEntity__c  FROM Assets__r WHERE ' + 
                        'NE__Bundle_Configuration__c = null and NE__Root_Order_Item__c = null) ' +
                        'FROM XC_BillingProfileLineItem__c ' + 
                        'WHERE ((XC_BillingProfile__r.NE__Payment__c =:commodityBill   AND (XC_BillingProfile__r.XC_CommodityContractID__c =: commodityContractNum OR XC_BillingProfile__r.XC_CommodityContractID__c =: CommodityCC) AND XC_BillingProfile__r.XC_CommodityContractID__c != null)  '+ /*20220331 NicoloFodera fix disconnect/change order italy, added OR =CommodityCC*/
                        ' OR (XC_BillingProfile__r.NE__Payment__c =:directDebt  AND XC_BillingProfile__r.NE__Iban__c =: commodityContractNum)) AND XC_BillingProfile__r.NE__Account__r.RecordTypeId =:recordTypeID '+ 
                        'AND (XC_BillingProfile__r.NE__Account__r.IdentityNumber__c =: oldAccountDNI ' ;
        
        query = (!accIds.isEmpty()) ? query + ' OR XC_BillingProfile__r.NE__Account__c  IN: accIds) order by XC_BillingProfile__r.NE__Account__c' : query + ') order by XC_BillingProfile__r.NE__Account__c';
        query = String.escapeSingleQuotes(query);
        system.debug('QRS08_GetAssetCO Query: '+ query);
        List<XC_BillingProfileLineItem__c> bpliList = (List<XC_BillingProfileLineItem__c>) Database.query(query);
        
        
        
        Set<Asset> setAsset = new Set<Asset>();
        if(bpliList.isEmpty()){
            return new List<Asset>();
        }


        String accountId = bpliList[0].XC_BillingProfile__r.NE__Account__c;
        String bpId =  bpliList[0].XC_BillingProfile__c;
        utilMap.put('billingprofileId', bpliList[0].XC_BillingProfile__c);
        utilMap.put('wrReq', wrReq);
        for(XC_BillingProfileLineItem__c bpli : bpliList){
            if(!bpli.Assets__r.isEmpty() && bpli.XC_BillingProfile__c == bpId &&  bpli.XC_BillingProfile__r.NE__Account__c == accountId){
                setAsset.addAll(bpli.Assets__r);
            }
        }
        
        List<Asset> assetList = new List<Asset>();
        assetList.addAll(setAsset);
        
        return assetList;
    }


    /**
    * @description retrieve product configuration from custom metadata
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param utilMap 
    * @return Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt> 
    **/
    private static Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt> retrieveConfiguredAction(Map<String,Object> utilMap){
        
        List<Asset> assetList = (List<Asset>) utilMap.get('assetList');
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('wrReq');

        String legalEntity =  wrReq.Order.LegalEntity;
        String orderType = wrReq.Order.OrderType;
        String orderSubtype =  wrReq.Order.OrderSubType;

        Set<String> productNames = new Set<String>();
        for(Asset ass: assetList){
            productNames.add(ass.NE__ProdId__r.XC_LIC_Product_Name__c);
        }
        
        Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt> configuredActionMap = new Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt> 
        ([  SELECT XC_VASProductName__c, XC_MaintainVas__c, XC_ChangeOwnerType__c, XC_Action__c, XC_ReasonOfCancellation__c, XC_LegalEntity__c 
            FROM XC_CM_EnergyDisconnectConfiguration__mdt 
            WHERE XC_VASProductName__c IN: productNames  and XC_LegalEntity__c =: legalEntity and 
                  XC_OrderType__c =: orderType and XC_OrderSubType__c =: orderSubtype]);// retrieve configurations for a given legalentity, orderType and orderSubType
        
        return configuredActionMap;
    }


      /**
    * @description manage child queued request creation 
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param utilMap 
    * @param wrresp 
    **/
    private static void manageQueuedRequestCreation(Map<String,Object> utilMap, XC_REST_Order_U.WrapperRes wrResp){
        
        List<Asset> assetList = (List<Asset>) utilMap.get('assetList');
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('wrReq');
        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c) utilMap.get('currentStep');
        
        List<XC_QueuedRequest__c> qrListChange = new List<XC_QueuedRequest__c>(); //UpdateMOP
        List<XC_QueuedRequest__c> qrListDisconnect = new List<XC_QueuedRequest__c>(); // Disconnection
        List<XC_QueuedRequest__c> qrListChangeOrder = new List<XC_QueuedRequest__c>(); //ChangeOrder

        utilMap.put('qrListChange', qrListChange);
        utilMap.put('qrListDisconnect', qrListDisconnect);
        utilMap.put('qrListChangeOrder', qrListChangeOrder);
        
        
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(currentStep.XC_QueuedRequest__r.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        /*List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> wrReqBP = fullQRReqBody.BillingProfile;
        //wrReqBP[0].BillingProfileID = (String) utilMap.get('billingprofileId'); // BP of the former account
        fullQRReqBody.BillingProfile = wrReqBP;*/
        wrReq.Order.BillingProfIdUpdateMop = (String) utilMap.get('billingprofileId'); // BP of the former account
        
        for(Asset ass: assetList){
            
            // prepare the new queued request child to insert
            XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
            qr.XC_ParentQueuedRequest__c = currentStep.XC_QueuedRequest__c;
            qr.XC_IntegrationId__c = fullQRReqBody.Order.IntegrationID;
            qr.XC_ClientSystem__c = currentStep.XC_QueuedRequest__r.XC_ClientSystem__c;
            qr.XC_TransactionId__c = currentStep.XC_QueuedRequest__r.XC_TransactionId__c +  '_'+ ass.Id; // add number to identify child
            qr.XC_ValidationStatus__c = currentStep.XC_QueuedRequest__r.XC_ValidationStatus__c;
            qr.XC_Reason__c = currentStep.XC_QueuedRequest__r.XC_Reason__c;

            
            wrReq.Order.AssetID = ass.Id;
            wrReq.Order.AccountID = ass.AccountId; // former accountID
            
            
            utilMap.put('newQrChild', qr);
            utilMap.put('fullQRReqBody', fullQRReqBody);
            utilMap.put('ass', ass);
            utilMap.put('wrReq', wrReq);

            Boolean matchFound = checkMatchFound(utilMap, wrResp);
            if(wrResp.result.ErrorCode == '500'){
                return;
            }
            
            if(!matchFound){//The assumption is that if a match cannot be found on the custom metadata, an UpdateMop must be performed for the asset.
                system.debug('[GET ASSET] IN NO MATCH: ' + ass.Id);
                wrReq.Order.OrderType = 'Change Order';
                wrReq.Order.OrderSubType = 'UpdateMoP';
                fullQRReqBody.Order = wrReq.Order;
                qr.XC_RequestBody__c = JSON.Serialize(fullQRReqBody, true);
                qrListChange = (List<XC_QueuedRequest__c>) utilMap.get('qrListChange');
                qrListChange.add(qr);
                utilMap.put('qrListChange', qrListChange);
                system.debug(loggingLevel.Finest, 'QRCHANGE NotMatch' + qrListChange);
            }
            
        }
       
        utilMap.put('assetList', assetList);
        
    }


    /**
    * @description check match between asset and custom metadata records
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param utilMap 
    * @param wrResp 
    * @return boolean
    **/
    private static boolean checkMatchFound(Map<String,Object> utilMap, XC_REST_Order_U.WrapperRes wrResp){

        Boolean matchFound = false;
        Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt> configuredActiontMap  = (Map<Id, XC_CM_EnergyDisconnectConfiguration__mdt>) utilMap.get('configuredActiontMap'); 
        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('wrReq');
        List<XC_QueuedRequest__c> qrListChange = (List<XC_QueuedRequest__c>) utilMap.get('qrListChange');
        List<XC_QueuedRequest__c> qrListChangeOrder = (List<XC_QueuedRequest__c>) utilMap.get('qrListChangeOrder');
        List<XC_QueuedRequest__c> qrListDisconnect = (List<XC_QueuedRequest__c>) utilMap.get('qrListDisconnect');
        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c) utilMap.get('currentStep');
        Asset ass = (Asset) utilMap.get('ass');
        XC_QueuedRequest__c qr = (XC_QueuedRequest__c) utilMap.get('newQrChild');
        XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) utilMap.get('fullQRReqBody');

        system.debug(loggingLevel.Finest, 'QRCHANGE BeforeCheckMatchFOund' + qrListChange);
        system.debug(loggingLevel.Finest, 'QRDIS BeforeCheckMatchFOund' + qrListDisconnect);

        for(XC_CM_EnergyDisconnectConfiguration__mdt configuredAction: configuredActiontMap.values()){ 
            Boolean checkConfig = checkMatchConfiguration(ass, configuredAction, utilMap);             
            if(checkConfig){

                if(configuredAction.XC_Action__c == Label.XC_CL_Configuration_TypeDisconnection){
                    wrReq.Order.OrderType = Label.XC_CL_Configuration_TypeDisconnection;
                    wrReq.Order.OrderSubType = configuredAction.XC_ReasonOfCancellation__c;
                }else{
                    wrReq.Order.OrderType = ORDERTYPE.get(ORDERSUBTYPE.get(configuredAction.XC_Action__c));
                    wrReq.Order.OrderSubType = ORDERSUBTYPE.get(configuredAction.XC_Action__c);
                }

                fullQRReqBody.Order = wrReq.Order;
                qr.XC_RequestBody__c = JSON.Serialize(fullQRReqBody, true);
                matchFound = true;
                
                if( String.isBlank(configuredAction.XC_Action__c) || String.isBlank(wrReq.Order.OrderType) || String.isBlank( wrReq.Order.OrderSubType)){ // no action is configured for this mdt row
                    system.debug('[GET ASSET] IN NO ACTION: ' + ass.Id);
                    XC_UTIL_QueuedRequestStep.setStepKO(currentStep, 'INTERNAL ERROR. No automatic action is configured for asset: ' + ass.Id); 
                    wrResp.Result.ErrorCode = '500';
                    wrResp.Result.logError = 'INTERNAL ERROR. No automatic action is configured for asset: ' + ass.Id;
                    wrResp.Result.Message = 'INTERNAL ERROR. No automatic action is configured for asset: ' + ass.Id;
                    return false;
                } else if(configuredAction.XC_Action__c == 'Update MOP'){ // UpdateMop
                    system.debug('[GET ASSET] IN UPDATE MOP: ' + ass.Id);
                    qrListChange.add(qr);
                }else if(configuredAction.XC_Action__c == Label.XC_CL_Configuration_TypeDisconnection){ // Disconnection
                    system.debug('[GET ASSET] IN DISCONNECTION: ' + ass.Id);
                    qrListDisconnect.add(qr);
                }else if(wrReq.Order.OrderType == 'ChangeOrder'){ // Change order 
                    system.debug('[GET ASSET] IN CHANGEORDER: ' + ass.Id);
                    qrListChangeOrder.add(qr);
                }
                
               
                break;
            }
        }

        system.debug(loggingLevel.Finest, 'QRCHANGEAftCheckMatchFOund' + qrListChange);
        system.debug(loggingLevel.Finest, 'QRDIS AftCheckMatchFOund' + qrListDisconnect);

        utilMap.put('qrListChange', qrListChange);
        utilMap.put('qrListChangeOrder', qrListChangeOrder);
        utilMap.put('qrListDisconnect', qrListDisconnect);
        return matchFound;
    }


    /**
    * @description check match between asset and custom metadata util
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param utilMap 
    * @param ass 
    * @param energyDisConf 
    * @return boolean
    **/
    private static boolean checkMatchConfiguration(Asset ass, XC_CM_EnergyDisconnectConfiguration__mdt energyDisConf, Map<String,Object> utilMap){

        XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('wrReq');
  
        system.debug('[GET ASSETCO] VASprodname:' + energyDisConf.XC_VASProductName__c);
        system.debug('[GET ASSETCO] AssProdname:' + ass.NE__ProdId__r.XC_LIC_Product_Name__c );
 

        if( wrReq.Order.ChangeOwnerReason == energyDisConf.XC_ChangeOwnerType__c && wrReq.Order.MaintainVas == energyDisConf.XC_MaintainVas__c 
            && energyDisConf.XC_VASProductName__c == ass.NE__ProdId__r.XC_LIC_Product_Name__c
            ){ 
            return true;
        }
        return false;
    }

}