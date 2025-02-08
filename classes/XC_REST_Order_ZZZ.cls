/**
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       11/06/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         XC_REST_Order_ZZZ – Util for Validate to Create/Update/Read an Order
 * 
 */
public without sharing class XC_REST_Order_ZZZ {

    /**
    * @param orderItemList - List<XC_UTIL_Order.OrderItemWrapper> 
    * @param wr - XC_REST_Order_U.WrapperRes
    * @param accList - List<Account>
    * @return the map
    * @description method to check if billingProfile exists
    */
    public static Map<Id,NE__Billing_Profile__c> checkBillingProfile(List<XC_UTIL_Order.OrderItemWrapper> orderItemList, XC_REST_Order_U.WrapperRes wr, List<Account> accList, String legalEntity){ 
        
        Map<Id,NE__Billing_Profile__c> bpMap = new Map<Id, NE__Billing_Profile__c>();  
        List<Id> billingProfileIds = new List<Id>();
        for(XC_UTIL_Order.OrderItemWrapper orderItem : orderItemList){
            if(!String.isBlank(orderItem.BillingProfileID)){
                billingProfileIds.add(orderItem.BillingProfileID); 
            }
        }
        if(billingProfileIds.isEmpty()){
            return bpMap;
        }
        bpMap = new Map<Id, NE__Billing_Profile__c> ([SELECT Id, NE__Payment__c, NE__Account__c, XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, NE__Expiration__c,  NE__Expiration_Year__c, XC_SepaMandate__c,XC_SepaMandateDate__c, XC_InvoiceDeliveryPref__c,  XC_InvoicePreferredLanguage__c, NE__Iban__c, XC_CommodityContractID__c, XC_PayPalUsername__c, (SELECT id, XC_BillingAddress__c, XC_SoldToAddress__c, XC_BillToContactId__c, XC_SoldToContactId__c, XC_BillingProfileName__c, XC_ExternalKey__c, XC_BillToAddress__c, XC_PEC__c, XC_RecipientCode__c, XC_BillToContactId__r.Email   FROM Billing_Profile_Line_Items__r WHERE XC_LegalEntity__c =: legalEntity) FROM NE__Billing_Profile__c WHERE Id IN: billingProfileIds AND NE__Account__c IN: accList]);
          
        for(Id idList : billingProfileIds){
            if(!bpMap.containsKey(idList)){
                wr.Result.ErrorCode = '400';
                wr.Result.Message = Label.XC_CL_BillingProfileId + ' '+ idList + ' ' + Label.XC_CL_NotFount;
                wr.Result.LogError = 'INTERNAL ERROR: Billing profile Id '+ idList + ' not found' + billingProfileIds + ' ' + accList;
            } 
        }
        
        return bpMap;
    }


    /**
    * @param postRequest - XC_REST_Order_U.WrapperPOSTRequest
    * @param wr - XC_REST_Order_U.WrapperRes
    * @param accList - List<Account>
    * @description method to create a new opportunity related to the configuration
    */
    public static Opportunity createOpportunity (XC_REST_Order_U.WrapperPOSTRequest postRequest, XC_REST_Order_U.WrapperRes wr, List<Account> accList){
               
        String catalogItemID = postRequest.Order.OrderItem[0].CatalogItemID;

        String addressId;
        if(!String.isBlank(postRequest.Order.InstallationAddress)){
            addressId = postRequest.Order.InstallationAddress;
        /*}else if(!String.isBlank(postRequest.Order.InstallationAddressData)){
            for(XC_Address__c a : accList[0].Addresses__r){
                if(a.XC_InstallationAddress__c){
                    addressId = a.Id;
                }
            }*/
        }else if(!accList[0].Addresses__r.isEmpty()){
            addressId = accList[0].Addresses__r[0].Id;
        }

        // to be modified
        Opportunity opp = new Opportunity(  
            AccountId = accList[0].id,
            XC_Contact__c = (!accList[0].Contacts.isEmpty()) ? accList[0].Contacts[0].Id : null,
            StageName = 'Draft',
            Name = 'Opportunity ',
            XC_LegalEntity__c = postRequest.Order.LegalEntity,
            CloseDate = System.today().addDays(30),
            XC_Address__c = addressId,
            XC_ReceivingChannel__c = 'Web',
            XC_CampaignPlatform__c = postRequest.Order.CampaignPlatform,
            XC_CampaignProduct__c = postRequest.Order.CampaignProduct,
            XC_CampaignCode__c = postRequest.Order.CampaignCode,
            XC_ConventionCode__c = postRequest.Order.ConventionCode,
            XC_Ecid__c = postRequest.Order.ECID
            //XC_CompanyCode__c = postRequest.Order.Account.CompanyCode,
            //XC_CostCenter__c = postRequest.Order.Account.CostCenter  
        );

        if(!String.isBlank(postRequest.Order.ContractID)){
            opp.XC_ElectricContract__c = postRequest.Order.ContractID; 
            opp.XC_GasContract__c = postRequest.Order.ContractID; 
        }


        XC_UTIL_Sobject.WrapperResult insertResult = XC_UTIL_Sobject.insertRecord(opp);
        if(!insertResult.success){
            wr.Result.Message = 'INTERNAL ERROR: ' + insertResult.errorMessage;
            wr.Result.ErrorCode = '500';
            wr.Order = null;
            wr.Result.logError = 'INTERNAL ERROR: ' + insertResult.errorMessage;
            return null;
        }
        return opp;
    }


    /**
    * @param postRequest - XC_REST_Order_U.WrapperPOSTRequest
    * @param wr - XC_REST_Order_U.WrapperRes
    * @param accList - List<Account>
    * @description method to update an  opportunity related to the configuration
    */
    public static void updateOpportunity (XC_REST_Order_U.WrapperPOSTRequest postRequest, XC_REST_Order_U.WrapperRes wr, List<Account> accList){
        
        Map<String, String> opportunityParameters = new Map<String, String>{'XC_CampaignPlatform__c' => postRequest.Order.CampaignPlatform,
                                                                            'XC_CampaignProduct__c' => postRequest.Order.CampaignProduct,
                                                                            'XC_CampaignCode__c' => postRequest.Order.CampaignCode,
                                                                            'XC_ConventionCode__c' => postRequest.Order.ConventionCode,
                                                                            'XC_Ecid__c' => postRequest.Order.ECID
                                                                            };
        
        Map<Id,Opportunity> mapidOpp = new Map<Id,Opportunity>();
        for(Opportunity opp : accList[0].Opportunities){
            mapidOpp.put(opp.id,opp);
        }

        Opportunity opportunityToUpdate = new Opportunity();
        Boolean isToUpdate = false; 
        for(String field : opportunityParameters.keySet()) {
            if(!String.isBlank(opportunityParameters.get(field)) && String.isBlank((String)(mapidOpp.get(postRequest.Order.OpportunityID)).get(field))) {
                opportunityToUpdate.put(field, opportunityParameters.get(field));
                isToUpdate = true; 
            }
        }

        if(isToUpdate){
            opportunityToUpdate.Id = postRequest.Order.OpportunityID;
            XC_UTIL_Sobject.WrapperResult insertResult = XC_UTIL_Sobject.updateRecord(opportunityToUpdate);
            if(!insertResult.success){
                wr.Result.Message = 'INTERNAL ERROR: ' + insertResult.errorMessage;
                wr.Result.ErrorCode = '500';
                wr.Order = null;
                wr.Result.logError = 'INTERNAL ERROR: ' + insertResult.errorMessage;
                return;
            }
        }
    }


    /**
    * @param mapUtil - Map<String,Object>
    * @description populate response POST
    */ 
    public static void populateResponse(Map<String,Object> mapUtil){


        XC_REST_Order_U.WrapperRes wr = (XC_REST_Order_U.WrapperRes) mapUtil.get('wr');
        Id orderID = (Id)mapUtil.get('orderId');
        XC_REST_Order_U.WrapperPOSTRequest postRequest = (XC_REST_Order_U.WrapperPOSTRequest) mapUtil.get('postRequest');

        if(postRequest.order.orderItem != null && !postRequest.order.orderItem.isEmpty()){
            Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>( [SELECT NE__CatalogItem__c, NE__Qty__c, NE__ProdId__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, 
                                                                                (SELECT id, Name, NE__Value__c FROM NE__Order_Item_Attributes__r) 
                                                                                FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderID]);
    
            if(!orderItemMap.isEmpty()){
                wr.Order.OrderItem = new List<XC_UTIL_Order.OrderItemWrapper>();
                for(NE__OrderItem__c ordItem : orderItemMap.values()){
                    XC_UTIL_Order.OrderItemWrapper orItemWR = new XC_UTIL_Order.OrderItemWrapper();
                    orItemWR.OrderItemID = ordItem.id;
                    orItemWR.CatalogItemID = ordItem.NE__CatalogItem__c;
                    orItemWR.Quantity = ordItem.NE__Qty__c;
                    orItemWR.ProdID = ordItem.NE__ProdId__c;
                    orItemWR.ParentOrderItemID = ordItem.NE__Parent_Order_Item__c;
                    orItemWR.BundleConfiguration = ordItem.NE__Bundle_Configuration__c;
                    wr.Order.OrderItem.add(orItemWR);
                    if(!ordItem.NE__Order_Item_Attributes__r.isEmpty()){
                        orItemWR.Attribute = new List<XC_UTIL_Order.WrapperAttribute>();
                        for(NE__Order_Item_Attribute__c oiAttr : ordItem.NE__Order_Item_Attributes__r){
                            XC_UTIL_Order.WrapperAttribute orItemAttrWR = new XC_UTIL_Order.WrapperAttribute();
                            orItemAttrWR.AttributeID = oiAttr.id;
                            orItemAttrWR.Name = oiAttr.Name;
                            orItemAttrWR.Value = oiAttr.NE__Value__c;
                            orItemWR.Attribute.add(orItemAttrWR);
                        }
                    }
                }
            }
        }
        
    }


    /**
    * @param Map<String, Object> mapOrder
    * @param wr the wr
    * @description check external financing values
    */
    public static void checkExternalFinancing(Map<String, Object> mapOrder, XC_REST_Order_U.WrapperRes wr){
        
        Map<Id,NE__Order__c> ordMap = (Map<Id,NE__Order__c>) mapOrder.get('ordMap');
        XC_REST_Order_U.WrapperPUTRequest putRequest = (XC_REST_Order_U.WrapperPUTRequest) mapOrder.get('wrReq');

        Boolean externalFinancingFound = false; 
        if(putRequest.Order.StartProvisioning != null && putRequest.Order.StartProvisioning){
            
            if(putRequest.Order.OrderItem != null){
                for(XC_UTIL_Order.OrderItemWrapper orderItem : putRequest.Order.OrderItem){
                    if(orderItem.PaymentType == Label.XC_CL_Payment_ExternalFinancing){
                        externalFinancingFound = true;
                        break;
                    }
                }
            }
            
            if(!externalFinancingFound){
                for(NE__OrderItem__c orderItem : ordMap.values()[0].NE__Order_Items__r) {
                    if(orderItem.XC_PaymentMethod__c == Label.XC_CL_Payment_ExternalFinancing) {
                        externalFinancingFound = true;
                        break;
                    }
                }
            }

            if(externalFinancingFound && !XC_LCC099_NextStepOrderToProvisioning.checkFieldsForExternalFinancing(putRequest.Order.OrderID, ordMap)){
                wr.Result.Message = 'INTERNAL ERROR: ' +  Label.XC_CL_ExternalFinancingNotApproved;
                wr.Result.logError = 'INTERNAL ERROR: ' +  Label.XC_CL_ExternalFinancingNotApproved;
                wr.Result.ErrorCode = '500';
                wr.Order = null;
                return;
            }
        }

    }


    /**
    * @param Map<String, Object> mapOrder
    * @param wr the wr
    * @description method to manage order, orderItem and orderItemAttribute
    */
    public static void manageUpdateOrder(Map<String, Object> mapOrder,XC_REST_Order_U.WrapperRes wr){

        Map<String, List<NE__Order_Item_Attribute__c>> mapOrdItemOIA=(Map<String, List<NE__Order_Item_Attribute__c>>) mapOrder.get('mapOrdItemIdOIA');
        XC_REST_Order_U.WrapperPUTRequest putRequest=(XC_REST_Order_U.WrapperPUTRequest) mapOrder.get('wrReq');
        String clientSystem = (String) mapOrder.get('clientSystem');
        String recordTypeOrder= (String) mapOrder.get('recordTypeOrder');
        
        List<NE__OrderItem__c> orderItemListToUpdate = new List<NE__OrderItem__c>();
        List<NE__Order_Item_Attribute__c> oiaToUpdate = new List<NE__Order_Item_Attribute__c>();

        wr.Order = new XC_UTIL_Order.OrderIFWrapper();
        wr.Order.OrderID = putRequest.Order.OrderID;

        NE__Order__c orderToUpdate = populateOrder(putRequest.Order, (String)mapOrder.get('practiceStatus'));


        if(clientSystem == 'E-Commerce' && recordTypeOrder =='Quote' && !String.isBlank(putRequest.Order.OrderStatus) && putRequest.Order.OrderStatus == Label.XC_CL_Configuration_QuoteAccepted){
            orderToUpdate.XC_SignedByExternal__c = 'Web';
        }

        if(putRequest.Order.OrderItem != null) {
            List<Id> billprofs = new List<Id>();
            for(XC_UTIL_Order.OrderItemWrapper orderItem : putRequest.Order.OrderItem){
                if(!String.isBlank(orderItem.BillingProfileID)){
                    billprofs.add(orderItem.BillingProfileID);
                }
            }

   
            List<String> legals = new List<String>();
            String billAddrOrder = '';
            String soldAddrOrder = '';
            Map<Id,NE__Billing_Profile__c> blpMapTemp = new Map<Id,NE__Billing_Profile__c>();
            if(!billprofs.isEmpty()){
                Map<Id,NE__Order__c> ordMap = new Map<Id,NE__Order__c>([SELECT id, NE__OptyId__r.XC_LegalEntity__c, XC_BillingAddress__c, XC_InstallationAddress__c, XC_DeliveryAddress__c FROM NE__Order__c WHERE id =: wr.Order.OrderID]);
                for(NE__Order__c o:ordMap.values()){
                    if(!String.isBlank(o.NE__OptyId__r.XC_LegalEntity__c)){
                        legals.add(o.NE__OptyId__r.XC_LegalEntity__c);
                    }
                }
                if(!legals.isEmpty()){
                    blpMapTemp = new Map<Id,NE__Billing_Profile__c>([SELECT id,XC_CommodityContractID__c, NE__Payment__c, NE__Account__c, XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, NE__Expiration__c,  NE__Expiration_Year__c, XC_SepaMandate__c,XC_SepaMandateDate__c, XC_InvoiceDeliveryPref__c,  XC_InvoicePreferredLanguage__c, NE__Iban__c,XC_PayPalUsername__c,   (SELECT id, XC_BillingAddress__c, XC_SoldToAddress__c, XC_BillingProfile__c, XC_BillingProfile__r.NE__Payment__c, XC_BillToContactId__c, XC_SoldToContactId__c, XC_BillingProfileName__c, XC_ExternalKey__c, XC_BillToAddress__c, XC_PEC__c, XC_RecipientCode__c, XC_BillToContactId__r.Email   FROM Billing_Profile_Line_Items__r WHERE XC_LegalEntity__c in: legals) FROM NE__Billing_Profile__c WHERE Id in: billprofs]);
                 
                    
                }
                billAddrOrder = ordMap.values()[0].XC_DeliveryAddress__c;
                soldAddrOrder = ordMap.values()[0].XC_InstallationAddress__c; 
            }

            Map<Id,XC_REST_Order_V.BillingItemCreationWrapper> bpCreationMap = new Map<Id,XC_REST_Order_V.BillingItemCreationWrapper>();
            Set<Id> bpliToSend = new Set<Id>();
            Map<Id,XC_BillingProfileLineItem__c> bpliMap = new Map<Id,XC_BillingProfileLineItem__c>();
            Map<Id,Account> accMap = new Map<Id,Account>();

            for(XC_UTIL_Order.OrderItemWrapper orderItem : putRequest.Order.OrderItem){

                if(!String.isBlank(orderItem.BillingProfileID)){
                    boolean founbbpli = false;

                    for(XC_BillingProfileLineItem__c blp : blpMapTemp.get(orderItem.BillingProfileID).Billing_Profile_Line_Items__r){
                        
                        system.debug('asd0: '+billAddrOrder+' - '+blp.XC_BillToAddress__c+' - '+soldAddrOrder+' - '+blp.XC_SoldToAddress__c);
                        if(billAddrOrder==blp.XC_BillToAddress__c&&soldAddrOrder==blp.XC_SoldToAddress__c){

                            orderItem.BillingProfileLineItemID = blp.id;
                            if(String.isBlank(orderItem.PaymentType)){
                                orderItem.PaymentType = blp.XC_BillingProfile__r.NE__Payment__c;
                            }
                            founbbpli = true;
                            break;

                        } else if(String.isBlank(orderItem.BillingProfileLineItemID)){
                            continue;
                        }        
                     
                    }

                    if(!founbbpli){
                        XC_REST_Order_V.BillingItemCreationWrapper bw = new XC_REST_Order_V.BillingItemCreationWrapper();
                        bw.billingProfile = blpMapTemp.get(orderItem.BillingProfileID);
                        bw.billingAddress = billAddrOrder;
                        bw.soldToAddress = soldAddrOrder; 
                        bw.legalEntity = legals[0];
                        bw.pec = blpMapTemp.get(orderItem.BillingProfileID).Billing_Profile_Line_Items__r[0].XC_PEC__c;
                        bw.recipientCode = blpMapTemp.get(orderItem.BillingProfileID).Billing_Profile_Line_Items__r[0].XC_RecipientCode__c;
                        bw.invoicePreferredLanguage = blpMapTemp.get(orderItem.BillingProfileID).XC_InvoicePreferredLanguage__c;
                        bw.invoiceDeliveryPref = (!String.isBlank(blpMapTemp.get(orderItem.BillingProfileID).XC_InvoiceDeliveryPref__c) && blpMapTemp.get(orderItem.BillingProfileID).XC_InvoiceDeliveryPref__c.containsIgnoreCase('Smart')) ? Label.XC_CL_BpliInvoiceDeliveryPref : blpMapTemp.get(orderItem.BillingProfileID).XC_InvoiceDeliveryPref__c;
                        bpCreationMap.put(orderItem.BillingProfileID, bw);
    
                        if(String.isBlank(orderItem.PaymentType)){
                            orderItem.PaymentType = blpMapTemp.get(orderItem.BillingProfileID).Billing_Profile_Line_Items__r[0].XC_BillingProfile__r.NE__Payment__c;
                        }
                    }                  

                }
                
                NE__OrderItem__c objorderItem = XC_UTIL_Order.createOrderItemFromOrder(putRequest.Order.AccountID, orderToUpdate.id, orderItem);
                ObjorderItem.id = orderItem.OrderItemID;
                orderItemListToUpdate.add(ObjorderItem);

                XC_UTIL_Order.OrderItemWrapper orderItemWrRes = new XC_UTIL_Order.OrderItemWrapper();
                orderItemWrRes.OrderItemID = orderItem.OrderItemID;

                Map<String,Object> utilMap = new Map<String,Object>{
                                                                    'orderItemWr' => orderItem,
                                                                    'wr' => wr, 
                                                                    'mapOrdItemOIA' => mapOrdItemOIA,
                                                                    'orderItemWrRes' => orderItemWrRes,
                                                                    'oiaToUpdate'=> oiaToUpdate
                                                                    };
                XC_REST_Order_VV.manageOrdItemAttr(utilMap);
                if(wr.Result.ErrorCode == '400'){
                    wr.Order = null;
                    return;
                }

                wr.Order.OrderItem.add(orderItemWrRes);
            }

            if(!bpCreationMap.values().isEmpty()){       
                bpliMap = XC_REST_Order_V.createBPLI(bpCreationMap); 
                accMap = XC_REST_Order_V.getAccountInfo(blpMapTemp.values());
                
                for(NE__OrderItem__c oi : orderItemListToUpdate){ 
                    if(bpCreationMap.get(oi.NE__BillingProfId__c)!=null&&String.isBlank(oi.XC_BillingProfileLineItem__c)){
                        oi.XC_BillingProfileLineItem__c = bpliMap.get(oi.NE__BillingProfId__c).id;
                        bpliToSend.add(oi.NE__BillingProfId__c);
                        system.debug('asd3: '+oi.XC_BillingProfileLineItem__c);
                    }
                }

            }

            for(Id bp : bpliToSend){
                XC_REST_Order_V.sendBPLI(blpMapTemp.get(bp),accMap.get(bp),bpliMap.get(bp));
            }
        }
        
        List<XC_UTIL_Sobject.WrapperResult> result = new List<XC_UTIL_Sobject.WrapperResult>();
        result.add(XC_UTIL_SObject.updateRecord(orderToUpdate));

        System.debug('orderItem to update####' + orderItemListToUpdate);
        if(!orderItemListToUpdate.isEmpty()){
            result.addall(XC_UTIL_SObject.updateListRecords(orderItemListToUpdate));
        }
        
        if(!OIAToUpdate.isEmpty()){
            result.addall(XC_UTIL_Sobject.updateListRecords(OIAToUpdate));
        }

        for(XC_UTIL_Sobject.WrapperResult res: result){
            if(!res.success){
                wr.Result.Message = 'INTERNAL ERROR: ' + res.errorMessage;
                wr.Result.ErrorCode = '500';
                wr.Order = null;
                wr.Result.logError = 'INTERNAL ERROR: ' + res.errorMessage;
                return;
            }
        }
    }


    /**
    * @param orderToUpdate - NE__Order__c
    * @param orderReq - XC_UTIL_Order.OrderIFWrapper
    * @param practiceStatus - String
    * @description method to populate Order from wrapper requestu
    */
    public static NE__Order__c populateOrder(XC_UTIL_Order.OrderIFWrapper orderReq, String oldPracticeStatus){

        NE__Order__c orderToUpdate = new NE__Order__c();

        String practiceStatus = (!String.isBlank(orderReq.PracticeStatus)) ? orderReq.PracticeStatus : oldPracticeStatus;
        orderToUpdate = XC_UTIL_Order.createOrder(orderReq);
        orderToUpdate.id = orderReq.OrderID;
        if(!String.isBlank(practiceStatus)){
            orderToUpdate.XC_WaitForCommodity__c = (practiceStatus == Label.XC_CL_Configuration_Approved) ? Label.XC_CL_ComplianceVerificationStatus_StatusOK : Label.XC_CL_KO;
        }

        return orderToUpdate;
    }


    /**
    * @param objectId to convert -String 
    * @param wresp - XC_REST_Order_U.WrapperRes
    * @param recordTypeName - String
    * @description method to generate Order from Order (OptyToQuote and QuoteToOrder)
    */
    public static void orderToOrder(Map<String,Object> utilMap, XC_REST_Order_U.WrapperRes wresp, String recordTypeName){

        XC_REST_Order_U.WrapperPUTRequest putRequest = (XC_REST_Order_U.WrapperPUTRequest) utilMap.get('wrReq');
        XC_REST_Order_U.WrapperPOSTRequest postRequest = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('postRequest');


        String objectId = '';
        if(putRequest == null){
            objectId = (String) utilMap.get('optyId');
        }else{
            objectId = putRequest.Order.OrderID; 
        }
        
        // Check voucher
        XC_UTIL_ResultWrapper wrResult = XC_LCC044_OptyCheckBeforeNextStep.checkVoucherUtilization(objectId);
        if(!wrResult.success){
            wresp.Result.Message = 'INTERNAL ERROR: ' + wrResult.resultMessage;
            wresp.Result.ErrorCode = '500';
            wresp.Order = null;
            wresp.Result.logError = 'INTERNAL ERROR: ' + wrResult.resultMessage;
            return;
        }

        Integer beforeDataMapTime = Limits.getCpuTime();
        System.Debug('CHECK CPU USE BEFORE DATAMAP:::: ' + beforeDataMapTime);

        NE.DataMap.DataMapRequest dReq = new NE.DataMap.DataMapRequest();
        dReq.mapName = 'Order2Order';
        dReq.sourceId = objectId;
        NE.DataMap mp = new NE.DataMap();
        NE.DataMap.DataMapResponse dResp = mp.callDataMap(dReq);

        

        if(dresp.ErrorCode != '0'){
            wresp.Result.Message = dResp.errorMessage;
            wresp.Result.ErrorCode = '500';
            wresp.Order = null;
            wresp.Result.logError = 'INTERNAL ERROR: B2W Error ' + dResp.errorMessage;
            return;
        }

        
        wresp.Order.OrderID = dResp.ParentId; 
        utilMap.put('orderID', dResp.ParentId);
        System.enqueueJob(new updateBit2winConfig (dResp.ParentId, recordTypeName, utilMap));

        Integer afterDataMapTime = Limits.getCpuTime();
        System.Debug('CHECK CPU USE AFTER DATAMAP:::: ' + afterDataMapTime  + ' EXECUTIONTIME ' + (afterDataMapTime-beforeDataMapTime));

    }


    /**
    * @param String parentId
    * @param XC_REST_Order_U.WrapperRes wresp
    * @param recordTypeName - String
    * @description method to generate Order from Quote
    */
    /*public static void updateBit2winConfiguration(String parentId, XC_REST_Order_U.WrapperRes wresp, String recordTypeName){
        
        NE__Order__c orderToUpdate;
        if(recordTypeName == 'Order'){
            orderToUpdate = new NE__Order__c(ID= parentId, NE__OrderStatus__c ='Pending', RecordTypeId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId(), XC_Status__c='In Progress' );
        }else if(recordTypeName == 'Quote'){
            orderToUpdate = new NE__Order__c(ID= parentId, NE__OrderStatus__c ='Active', RecordTypeId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId(), XC_Status__c='Draft' );
        }
        
        System.debug('order to update####' + orderToUpdate);
        XC_UTIL_Sobject.WrapperResult res = new XC_UTIL_Sobject.WrapperResult();
        res= XC_UTIL_SObject.updateRecord(orderToUpdate);
        
        if(!res.success){
            wresp.Result.Message = 'INTERNAL ERROR';
            wresp.Result.ErrorCode = '500';
            wresp.Order = null;
            wresp.Result.logError = 'INTERNAL ERROR: ' + res.errorMessage;
            return;
        }
        wresp.Order.OrderID = parentId; 

    }*/

    
    public class updateBit2winConfig implements Queueable, Database.AllowsCallouts {
    
        String parentId = '';
        String recordTypeName = '';
        Map<String,Object> utilMap; 


        public updateBit2winConfig(String parentId, String recordTypeName, Map<String,Object> utilMap) {
            this.parentId = parentId;
            this.recordTypeName = recordTypeName;
            this.utilMap = utilMap; 
        }
        

        public void execute(QueueableContext context) {

            NE__Order__c orderToUpdate;
            if(recordTypeName == 'Order'){
                orderToUpdate = new NE__Order__c(ID= parentId, NE__OrderStatus__c ='Pending', RecordTypeId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId(), XC_Status__c='In Progress');
            }else if(recordTypeName == 'Quote'){
                orderToUpdate = new NE__Order__c(ID= parentId, NE__OrderStatus__c ='Active', RecordTypeId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId(), XC_Status__c='Draft');
            }
            
            System.debug('order to update####' + orderToUpdate);
            XC_UTIL_Sobject.WrapperResult res = new XC_UTIL_Sobject.WrapperResult();
            res = XC_UTIL_SObject.updateRecord(orderToUpdate);

            if(!res.success){ 
				Integer errorDescrLen = Schema.SObjectType.NE__Order__c.fields.XC_ErrorDescription__c.getLength();
                NE__Order__c orderToUpdateErr = new NE__Order__c(ID = parentId, XC_ErrorDescription__c = ((res.errorMessage.length()> errorDescrLen)? res.errorMessage.substring(0, errorDescrLen - 1) : res.errorMessage));
                XC_UTIL_SObject.updateRecord(orderToUpdateErr);
                return;
            }   

            XC_REST_Order_U.WrapperPUTRequest putRequest = (XC_REST_Order_U.WrapperPUTRequest) utilMap.get('wrReq');
            XC_REST_Order_U.WrapperPOSTRequest postRequest = (XC_REST_Order_U.WrapperPOSTRequest) utilMap.get('postRequest');
            

            if(putRequest == null){ // Post request management
                if(recordTypeName == 'Order'){
                    // start manage conga wF
                    //Map<Id,NE__OrderItem__c> orderItemList = new Map<Id,NE__OrderItem__c>([SELECT Id, XC_CongaDynamicAPI__c, NE__Bundle_Configuration__c, XC_BillingModel__c, NE__ProdName__c FROM NE__OrderItem__c WHERE NE__OrderId__c =: ParentId]);
                    String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('NE__OrderItem__c');
                    query += String.escapeSingleQuotes(' FROM NE__OrderItem__c WHERE NE__OrderId__c = :ParentId');
                    List<NE__OrderItem__c> orderItemList = Database.query(query); 
                    Map<Id,NE__OrderItem__c> orderItemToUpdate = new Map<Id,NE__OrderItem__c>();

                    for(NE__OrderItem__c oi : orderItemList){
                        if(!String.isBlank(oi.XC_CongaDynamicAPI__c) &&  oi.XC_CongaDynamicAPI__c.equalsIgnoreCase('Yes')){
                            oi.XC_CongaDynamicAPI__c = '';
                            orderItemToUpdate.put(oi.id, oi);
                        }
                        
                    }
                    if(!orderItemToUpdate.isEmpty()){
                        XC_UTIL_SObject.updateListRecords(orderItemToUpdate.values());
                        XC_TR_ConfigurationItem_U_StartCongaWF.onInsert(orderItemToUpdate.values());
                    }
                    
                    // end manage conga WF
                    if(!Test.isRunningTest() && postRequest.Order.StartProvisioning == true){ 
                        XC_REST_Order_ZZZ.manageCompliance(utilMap, null, postRequest); 
                    }
                }
                // XC_REST_Order_ZZZ.manageCompliance(utilMap, null, postRequest); 
                
            }else { // Put request management 
                if(!Test.isRunningTest() && recordTypeName == 'Order' && putRequest.Order.StartProvisioning == true){ 
                    XC_REST_Order_ZZZ.manageCompliance(utilMap, putRequest, null); 
                }
            }
            
        }
    }

    /**
    * @param mapOrder - String
    * @param putReq - XC_REST_Order_U.WrapperPUTRequest
    * @param postRequest - XC_REST_Order_U.WrapperPOSTRequest
    * @description  manage Compliance
    */
    public static void manageCompliance (Map<String,Object> mapOrder, XC_REST_Order_U.WrapperPUTRequest putReq, XC_REST_Order_U.WrapperPOSTRequest postRequest){

        String orderID = (String)mapOrder.get('orderID');
        Boolean skipCompliance;
        Boolean startProvisioning; 

        if(putReq != null){
            skipCompliance = (putReq.Order.skipCompliance != null) ? putReq.Order.skipCompliance : false;
            startProvisioning = (putReq.Order.startProvisioning != null) ? putReq.Order.startProvisioning : false;
        }else{
            skipCompliance = (postRequest.Order.skipCompliance != null) ? postRequest.Order.skipCompliance : false;
            startProvisioning = (postRequest.Order.startProvisioning != null) ? postRequest.Order.startProvisioning : false;
        }
        
        
        if(startProvisioning && !skipCompliance){
            //if(mapOrder.get('complianceStatus')=='OK'){
                XC_UTIL_NextStepOrderToProvisioning.firstNextStep(orderID);
            //}
        }else if(startProvisioning && skipCompliance){
            XC_UTIL_ResultWrapper resultWrapper = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(orderID);
            if(resultWrapper.success && resultWrapper.executeNextStep && !Test.isRunningTest()) {
                XC_UTIL_ResultWrapper resultWrapperChangeInProv = new XC_UTIL_ResultWrapper();
                XC_LCC099_NextStepOrderToProvisioning.manageChangeInProvisioning(orderID, resultWrapperChangeInProv);
                if(resultWrapperChangeInProv.success && resultWrapperChangeInProv.executeNextStep && !Test.isRunningTest()) {
                    System.enqueueJob(new XC_UTIL_NextStepOrderToProvisioning.ThirdNextStepQueue(orderID)); 
                }
            }
        } else if(!startProvisioning && !skipCompliance){
            XC_UTIL_ResultWrapper resultWrapper = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(orderID);
            if(resultWrapper.success && resultWrapper.executeNextStep && !Test.isRunningTest()) {
                System.enqueueJob(new SecondNextStepQueue(orderID));
            }
        }

    }


    /** @description Queue for second step */
    @TestVisible
    public class SecondNextStepQueue implements Queueable {
        
        String configurationId = '';

        /**
         * @description Costructor
         * @param configurationId - String
         */
        public SecondNextStepQueue(String configurationId) {
            this.configurationId = configurationId;
        }
        
        /**
         * @description Execute Queuable
         * @param context - QueueableContext
         */
        public void execute(QueueableContext context) {
            XC_UTIL_ResultWrapper resultWrapper = XC_LCC099_NextStepOrderToProvisioning.implementSecondNextStep(configurationId);
        }
    }
}