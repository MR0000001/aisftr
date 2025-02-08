/**
* @File Name          : XC_IN_QRS13_ChangeOrder_U.cls
* @Description        : util class for XC_IN_QRS13_ChangeOrder.cls
* @Author             : Federica Acerra f.acerra@accenture.com 
**/

public class XC_IN_QRS13_ChangeOrder_U {
    
    /**
    * @description method to create Case
    * @author Federica Acerra f.acerra@accenture.com
    * @param Map<String,Object> utilMap 
    **/
    public static Case manageCaseCreation(Map<String,Object> utilMap,List<String> caseSettingNames){
        //initializing case triplet USE TECHNICAL CASE
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(caseSettingNames[0]);
        system.debug('caseMDT : '+caseMDT);

        Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
        system.debug('caseMDT : Case '+c);
        c.Subject = String.valueOf(utilMap.get('stepId'));
        c.AssetId = String.valueOf(utilMap.get('assetId'));
        c.AccountId = String.valueOf(utilMap.get('accountId'));
        c.XC_LegalEntity__c = String.valueOf(utilMap.get('XC_LegalEntity__c'));
        c.XC_Segment__c = String.valueOf(utilMap.get('segment'));
        return c;
    }

    /**
     * @author Federica Acerra f.acerra@accenture.com
     * @param wrReq the wrapper request
     * @param wrResp the wrapper response
     * @description method to manage update
     */

    public static void manageUpdate(XC_REST_Order_U.WrapperPOSTRequest wrReq, XC_REST_Order_U.WrapperRes wrResp, Map<String,Object> utilMap) {
       system.debug('manageUpdate: ');
        Asset asset = XC_REST_MobilityOrder_D.searchAsset(String.valueOf(utilMap.get('assetId')));
        system.debug('manageUpdate: asset : '+asset);
        if(asset == null) {
            wrResp.Result.Message = Label.XC_CL_AssetNotFound;
            wrResp.Result.logError = 'ERROR. Asset not found';
            wrResp.Result.ErrorCode = '400';
            return;

        } else if(asset.Status != 'Inactive') {
            changeOrder(wrReq, wrResp, utilMap, asset);

        } else {
            wrResp.Result.Message = Label.XC_CL_AssetStatus + asset.Status + '\'';
            wrResp.Result.logError = 'ERROR. Asset Status is not correct \'' + asset.Status + '\'';
            wrResp.Result.ErrorCode = '400';
        } 
    }

    /**
    * ChangeOrder.
    * @author Federica Acerra f.acerra@accenture.com
    * @param wrReq the wrapper request
    * @param wrResp the wrapper response
    * @description method to change order
    */
    public static void changeOrder(XC_REST_Order_U.WrapperPOSTRequest wrReq, XC_REST_Order_U.WrapperRes wrResp, Map<String,Object> utilMap,Asset asset){      
        system.debug('changeOrder: utilMap '+utilMap.get('currentStep'));
        String transactionId = wrResp.Result.Message;
        wrResp.Result.Message = null;

        List<NE__Catalog_Item__c> catalogItems = searchCatalogItem(wrReq);
        if(null==catalogItems || catalogItems.isEmpty()){
            wrResp.Result.Message = 'ERROR. CatalogItemID' + Label.XC_CL_NotFount;
            wrResp.Result.logError = 'ERROR. CatalogItemID not found';
            wrResp.Result.ErrorCode = '400';
            return; 
        }else{
            NE__Catalog_Item__c prod = catalogItems[0];
            system.debug('changeOrder: prod '+prod);
            if(String.isNotBlank(String.valueOf(utilMap.get('accountId')))) {
                Account acc = XC_REST_MobilityOrder_D.searchAccount(String.valueOf(utilMap.get('accountId')));
                system.debug('changeOrder:  acc: '+acc);
                if(acc == null){
                    wrResp.Result.Message = Label.XC_CL_AccountNotFound;
                    wrResp.Result.logError = 'ERROR. Account not found';
                    wrResp.Result.ErrorCode = '400';
                    return;
                }
            } else {
                wrReq.Order.AccountID = asset.Contact.AccountId;
            }

            Map<String, String> infosOffer = new Map<String, String>{'assetId' => asset.id,
                                                                    'categoryId' => prod.NE__Catalog_Category_Name__c,
                                                                    'catalogId' => prod.NE__Catalog_Id__c,
                                                                    'catalogItemId' => prod.Id,
                                                                    'qty' => (String.valueOf(wrReq.Order.OrderItem[0].Quantity)),
                                                                    'XC_eMobTransactionId__c' =>  (String) utilMap.get('TransactionID'),
                                                                    'billingProfLineItemId' => asset.XC_BillingProfileLineItem__c,
                                                                    'billingProfId' => asset.XC_BillingProfileLineItem__r.XC_BillingProfile__c,
                                                                    //'paymentMethod' => asset.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c,
                                                                    'paymentMethod' =>'Commodity Bill',
                                                                    'xcProvince' => asset.NE__Order_Config__r.NE__OptyId__r.XC_Province__c,
                                                                    'XC_LegalEntity__c' => (String) utilMap.get('XC_LegalEntity__c'),
                                                                    'XC_DeliveryAddress__c' =>  asset.XC_Address__c,
                                                                    'XC_InstallationAddress__c' => asset.XC_Address__c,
                                                                    'ContactId' => asset.ContactId,
                                                                    'clientSystem' =>  (String) utilMap.get('ClientSystem'),
                                                                    'OrderType' =>  (String) utilMap.get('OrderType'),
                                                                    'NE__AccountId__c' =>  String.valueOf(utilMap.get('accountId')),
                                                                    'OrderSubType' =>  (String) utilMap.get('OrderSubType'),
                                                                    'orderSubtype' =>  (String) utilMap.get('OrderSubType'),
                                                                    'orderItemList' => JSON.serialize(wrReq.Order.OrderItem),
                                                                    'ChannelCommodity' => 'Partner',
                                                                    'currentStep' =>  JSON.serialize((XC_QueuedRequestStep__c) utilMap.get('currentStep')),
                                                                    'XC_CaseId__c' =>  String.valueOf( utilMap.get('changeOrderCaseId')),
                                                                    'XC_VASContractExtID__c' =>  String.valueOf(utilMap.get('XC_VASContractExtID__c')),
                                                                    'XC_VASContractNumber__c' =>  String.valueOf( utilMap.get('XC_VASContractNumber__c'))
                                                                    };
           
            changeOffer(infosOffer);

        }

        wrResp.Result.Message = 'Operation completed successfully';
        wrResp.Result.ErrorCode = '0';
    }

    /**
     * ChangeOffer.
     * @author Federica Acerra f.acerra@accenture.com
     * @param infos the infos map
     * @description method to create order b2w
     */
    public static void changeOffer(Map<String, String> infos){
        system.debug('changeOffer infos: '+infos);
        Map<Id, XC_CS004_Bit2WinCredentials__c> b2wMap = new Map<Id, XC_CS004_Bit2WinCredentials__c>([SELECT XC_ServerURL__c, XC_ClientId__c, XC_OrganizationId__c, XC_EngineVersion__c FROM XC_CS004_Bit2WinCredentials__c WHERE XC_Country__c = 'SPAIN']);
        List<XC_CS004_Bit2WinCredentials__c> b2wCred = b2wMap.values();
        if(b2wCred.isEmpty()) {
            return;
        }
        infos.put('ServerURL', b2wCred[0].XC_ServerURL__c);
        infos.put('ClientId', b2wCred[0].XC_ClientId__c);
        infos.put('OrganizationId', b2wCred[0].XC_OrganizationId__c);
        infos.put('EngineVersion', b2wCred[0].XC_EngineVersion__c);

        Map<Id, XC_CS005_Bit2WinChangeAPI__c> b2wChangeMap = new Map<Id, XC_CS005_Bit2WinChangeAPI__c>([SELECT XC_Password__c, XC_PasswordToken__c, XC_ServerURL__c, XC_UserToken__c FROM XC_CS005_Bit2WinChangeAPI__c WHERE XC_Country__c = 'SPAIN']);
        List<XC_CS005_Bit2WinChangeAPI__c> b2wChangeCred = b2wChangeMap.values();
        if(b2wChangeCred.isEmpty()) {
            return;
        }
        infos.put('ServerURL_Change', b2wChangeCred[0].XC_ServerURL__c);
        infos.put('Password', b2wChangeCred[0].XC_Password__c);
        infos.put('PasswordToken', b2wChangeCred[0].XC_PasswordToken__c);
        infos.put('UserToken', b2wChangeCred[0].XC_UserToken__c);

        for(String key : infos.keySet()) {
            if(String.isBlank(infos.get(key))) {
                String rem = infos.remove(key);
            }
        }
        String rec = infos.remove('RecordTypeId');

        if(!Test.isRunningTest()) {
            XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);
            System.enqueueJob(changeAPI);
        }
    }

    


    /**
    * SearchCatalogItem.
    *
    * @param wrReq 
    * @return the list of the catalog item
    * @description method to get list  of the Catalog Item from ProdID
    */
    public static List<NE__Catalog_Item__c> searchCatalogItem(XC_REST_Order_U.WrapperPOSTRequest wrReq){
        List<NE__Catalog_Item__c> catalogItems;
        Set<String> ProdIDSet = new Set<String>();
        if(null!=wrReq.Order && null!=wrReq.Order.OrderItem && !wrReq.Order.OrderItem.isEmpty()){
            for(XC_UTIL_Order.OrderItemWrapper orderItem : wrReq.Order.OrderItem){
                if(!String.isBlank(orderItem.ProdID)){
                    ProdIDSet.add(orderItem.ProdID);
                }
            }
        }

        if(!ProdIDSet.isEmpty() && ProdIDSet != null){
            String query ='SELECT Id, XC_LIC_Catalog_Item_Name__c, NE__ProductId__c, NE__Catalog_Category_Name__c, NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, NE__Catalog_Id__c, NE__Engine_Code__c, XC_Skip_Payment_Method__c, CurrencyIsoCode ' +
                            'FROM NE__Catalog_Item__c WHERE NE__UsageCode__c IN: ProdIDSet';

            catalogItems = Database.query(String.escapeSingleQuotes(query));
        }
        return catalogItems;
    }


    /**
    * @description populate wrapper response 
    * @author Federica Acerra f.acerra@accenture.com 
    * @param Map<String,Object> utilMap 
    **/
    public static void populateWrRes(Map<String,Object> utilMap){ 
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) utilMap.get('wrResp');
        wrResp.Result.ErrorCode = '500';
        wrResp.Result.logError = 'ERROR. ' + (String)utilMap.get('ErrorMessage');
        wrResp.Result.Message = 'ERROR. ' + (String)utilMap.get('ErrorMessage');
    
    }


}