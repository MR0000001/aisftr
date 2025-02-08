/**
 *
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       08/05/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         XC_REST_Order_VVV – Util for Rest Resourse to  Create/Update/Read an Order/Order Item/Order Item Attribute
 * 
*/ 

public without sharing class XC_REST_Order_VVV {

     /**
    * @param orderItems - List<NE__OrderItem__c>
    * @return the map with AssetID as key and Asset as value
    * @description create AssetMap
    */
    public static Map<Id, Asset> createAssetMap(List<NE__OrderItem__c> orderItems){
        
        Map<Id, Asset> idAssetMap = new Map<Id, Asset>();
        List<Id> assetIds = new List<Id>();
        List<Asset> assetList = new List<Asset>();
        
        for (NE__OrderItem__c oi :  OrderItems){
            if(!oi.Assets__r.isEmpty()){
                assetList.addall(oi.Assets__r);
            }
        }
        if (!assetList.isEmpty()){
            assetIds = XC_UTIL_Sobject.getIds(assetList);
            idAssetMap = XC_REST_Order_U_D.getAssetHistoryAsset(assetIds);
        }
        return idAssetMap;
    }


    /**
    * @param ordItemList - List<XC_UTIL_Order.OrderItemWrapper> 
    * @param ordItemIds - Set<id>
    * @param ordItemAttrIds - Set<id>
    * @description  get ids
    */
    public static void getIDs(List<XC_UTIL_Order.OrderItemWrapper> ordItemList, Set<id> ordItemIds, Set<id> ordItemAttrIds){
        for(XC_UTIL_Order.OrderItemWrapper ordItem: ordItemList){
            ordItemIds.add(ordItem.OrderItemID);
            if(ordItem.Attribute != null){
                for(XC_UTIL_Order.WrapperAttribute ordItemAttr: ordItem.Attribute){
                    ordItemAttrIds.add(ordItemAttr.AttributeID);
                }
            }
        }
    }
    

    /**
    * @param request - RestRequest
    * @param orders - List<NE__Order__c>
    * @param wrResp - XC_REST_Order_U.WrapperGetResponse
    * @description validate GET request 
    */
    public static void validateGETRequest(RestRequest request , List<NE__Order__c> orders, XC_REST_Order_U.WrapperGetResponse wrResp){
        
        XC_UTIL_Integration.WrapperResult headerResult = XC_UTIL_Integration.validateHeader(request.headers);
        if(headerResult.errorFlag){
            wrResp.Result.Message = 'ERROR. ' + headerResult.errorMessage;
            wrResp.Result.ErrorCode = '400';
            wrResp.Order = null;
            return;
        }
        
        if (!String.isBlank(request.params.get('OrderID'))){
            List<String> orderIDs = request.params.get('OrderID').split(',');
            Orders.addall(XC_REST_Order_U_D.getOrderByIdList(OrderIDs)); 

        } else if(!String.isBlank(request.params.get('AccountID'))) {
            String startDate = '';
            String endDate = '';

            if(!String.isBlank(request.params.get('StartDate')) && !String.isBlank(request.params.get('EndDate'))) {
                startDate = request.params.get('StartDate') + ' 00:00:00';
                endDate = request.params.get('EndDate') + ' 23:59:59';
                if(!XC_UTIL_RESTInbound.checkDate(startDate)) {
                    wrResp.Result.Message = Label.XC_CL_FormatEndDate;
                    wrResp.Result.ErrorCode = '400';
                    wrResp.Order = null;
                    return;
                } else if(!XC_UTIL_RESTInbound.checkDate(endDate)) {
                    wrResp.Result.Message = Label.XC_CL_FormatEndDate;
                    wrResp.Result.ErrorCode = '400';
                    wrResp.Order = null;
                    return;
                }

            } else if(request.headers.get('Operation') == 'Read') {
                wrResp.Result.Message = Label.XC_CL_SeachAccountId;
                wrResp.Result.ErrorCode = '400';
                wrResp.Order = null;
                return;
            }

            Map<String, String> mapUtil = new Map<String, String>{  'AccountID'=> request.params.get('AccountID'),
                                                                    'startDate' => startDate,
                                                                    'endDate'=> endDate,
                                                                    'recordType' => request.params.get('RecordType')
                                                                };     
                            
            Orders.addall(XC_REST_Order_U_D.getOrderByAccount(mapUtil));

        } else if(!String.isBlank(request.params.get('OpportunityID'))&&!String.isBlank(request.params.get('RecordType'))) {
            Orders.addall(XC_REST_Order_U_D.getOrderByOpportunity(request.params.get('OpportunityID'), request.params.get('RecordType')));

        } else if(!String.isBlank(request.params.get('OpportunityID'))) { 
            Orders.addall(XC_REST_Order_U_D.getOrderByOpportunity(request.params.get('OpportunityID')));   

        }
         
    }


    /**
    * @param o - NE__Order__c
    * @param wrOrd - XC_UTIL_Order.OrderIFWrapper
    * @description populate order fields
    */
    public static void populateOrderFields(NE__Order__c o, XC_UTIL_Order.OrderIFWrapper wrOrd){


        if(o.XC_Cancellation_Date__c!= null){
            wrOrd.CancellationDate = String.valueOf(o.XC_Cancellation_Date__c);
        }

        if(o.NE__One_Time_Fee_Total__c != null){
            wrOrd.TotalOneTimeFee = String.valueOf(o.NE__One_Time_Fee_Total__c);
        }

        if(o.NE__Recurring_Charge_Total__c != null){
            wrOrd.TotalRecurringCharge = String.valueOf(o.NE__Recurring_Charge_Total__c);
        }

        if(o.B2WZC__ZStart_Date__c != null){
            wrOrd.StartDate = String.valueOf(o.B2WZC__ZStart_Date__c);
        }

    }


    /**
    * @param utilMap - Map<String,Object>
    * @description populate document fields
    */
    public static void populateDocumentFields(Map<String,Object> utilMap){

        NE__OrderItem__c oi = (NE__OrderItem__c ) utilMap.get('oi');
        Map<Id, List<String>> mapOrderitemDocument = (Map<Id, List<String>>) utilMap.get('mapOrderitemDocument');
        XC_UTIL_Order.OrderIFWrapper wrOrd  = (XC_UTIL_Order.OrderIFWrapper) utilMap.get('wrOrd');

        //to be verified
        if(mapOrderitemDocument.containsKey(oi.Id)) {
            for (String doc : mapOrderitemDocument.get(oi.Id)){
                XC_UTIL_Order.DocumentWrapper wrDoc = new XC_UTIL_Order.DocumentWrapper();
                wrDoc.DocumentType = doc;
                wrOrd.Document.add(wrDoc);
            }
        }
    }


    /**
    * @param oi - NE__OrderItem__c
    * @param wrOi -  XC_UTIL_Order.OrderItemWrapper 
    * @param idAssetMap - Map<Id, Asset>
    * @description populate asset fields 
    */
    public static void populateAssetFields(NE__OrderItem__c oi, XC_UTIL_Order.OrderItemWrapper wrOi, Map<Id, Asset> idAssetMap){
        if(!oi.Assets__r.isEmpty()){
            wrOi.Asset = new List<XC_UTIL_Order.WrapperAsset>();
            for(Asset asset: oi.Assets__r){
                XC_UTIL_Order.WrapperAsset wrAsset = new XC_UTIL_Order.WrapperAsset();
                wrAsset.AssetID = asset.Id;
                wrAsset.AssetName = asset.Name;
                if(!idAssetMap.get(asset.Id).Histories.isEmpty()){
                    wrAsset.History = new List<XC_UTIL_Order.WrapperAssetHistory>();
                    for (AssetHistory assHistory: idAssetMap.get(asset.Id).Histories){
                        XC_UTIL_Order.WrapperAssetHistory wrAssetHistory = new XC_UTIL_Order.WrapperAssetHistory();
                        wrAssetHistory.AssetStatus = (String) assHistory.NewValue;
                        wrAssetHistory.StatusDate  = assHistory.CreatedDate;
                        wrAsset.History.add(wrAssetHistory);
                    }
                }
                wrOi.Asset.add(wrAsset);
            }
        }
    }


    /**
    * @param oi - NE__OrderItem__c
    * @param wrOi -  XC_UTIL_Order.OrderItemWrapper 
    * @description populate order item discount fields 
    */
    public static void populateOiDiscountFields(NE__OrderItem__c oi, XC_UTIL_Order.OrderItemWrapper wrOi){
        if(!oi.NE__Order_Item_Discount__r.isEmpty()){
            wrOi.OrderItemDiscount = new List<XC_UTIL_Order.WrapperDiscount>();
            for(NE__Order_Item_Discount__c oiDiscount: oi.NE__Order_Item_Discount__r){
                XC_UTIL_Order.WrapperDiscount wrOiDiscount = new XC_UTIL_Order.WrapperDiscount();
                wrOiDiscount.OrderItemDiscountID = oiDiscount.Id;
                wrOiDiscount.Name = oiDiscount.Name; 
                wrOiDiscount.OrderItemID = oiDiscount.NE__Order_Item__c;          
                wrOiDiscount.AssetUpdateKey = oiDiscount.NE__Asset_update_key__c;        
                wrOiDiscount.Code = oiDiscount.NE__Code__c;                  
                wrOiDiscount.DiscountItem = oiDiscount.NE__Discount_Item__c;          
                wrOiDiscount.EndDate = oiDiscount.NE__End_Date__c;               
                wrOiDiscount.OneTimePercentage = oiDiscount.NE__One_Time_Percentage__c;     
                wrOiDiscount.OneTimePrice = oiDiscount.NE__One_Time_Price__c;         
                wrOiDiscount.OneTimeValue = oiDiscount.NE__One_Time_Value__c;          
                wrOiDiscount.Reason = oiDiscount.NE__Reason__c;              
                wrOiDiscount.RecurringPercentage = oiDiscount.NE__Recurring_Percentage__c;    
                wrOiDiscount.RecurringPrice = oiDiscount.NE__Recurring_Price__c;       
                wrOiDiscount.RecurringValue = oiDiscount.NE__Recurring_Value__c;        
                wrOiDiscount.Sequence = oiDiscount.NE__Sequence__c;         
                wrOiDiscount.StartDate = oiDiscount.NE__Start_Date__c;             
                wrOiDiscount.Status = oiDiscount.NE__Status__c;    
                wrOiDiscount.Type = oiDiscount.NE__Type__c;
                wrOi.OrderItemDiscount.add(wrOiDiscount);
            }
        }
    }



    /**
    * @param oi - NE__OrderItem__c
    * @param wrOi -  XC_UTIL_Order.OrderItemWrapper 
    * @description populate orderItem fields 
    */ 
    public static void populateOrdItemAttrFields(NE__OrderItem__c oi, XC_UTIL_Order.OrderItemWrapper wrOi){

        if(!oi.NE__Order_Item_Attributes__r.isEmpty()){
            wrOi.Attribute = new List<XC_UTIL_Order.WrapperAttribute>();
            for (NE__Order_Item_Attribute__c oia : oi.NE__Order_Item_Attributes__r){
                XC_UTIL_Order.WrapperAttribute wrOIA = new XC_UTIL_Order.WrapperAttribute();
                wrOIA.AttributeID = OIA.Id;
                wrOIA.Name = OIA.Name;
                wrOIA.Value = OIA.Ne__Value__c;
                wrOIA.OldValue = OIA.NE__Old_Value__c;
                wrOIA.ProductFamilyPropertyID = OIA.NE__FamPropId__c;
                wrOIA.Deleted = OIA.IsDeleted;
                wrOIA.FamPropExtId = OIA.NE__FamPropExtId__c;  
                wrOIA.DeveloperName = OIA.XC_DeveloperName__c;        
                wrOi.Attribute.add(wrOIA);
            }
        }
    }


    /**
    * @param ordItem - NE__OrderItem__c
    * @param wrOi -  XC_UTIL_Order.OrderItemWrapper 
    * @description populate orderItem fields 
    */ 
    public static void  populateProvisioningSteps(NE__OrderItem__c ordItem, XC_UTIL_Order.OrderItemWrapper wrOi){

        if(!ordItem.Provisioning_Steps__r.isEmpty()){
            //wrOi.ActualProvisioninStep = ordItem.Provisioning_Steps__r[0].XC_StepLabel__c;
            /*if(ordItem.Provisioning_Steps__r.size()>1){
                wrOi.ProvisioningModelSteps = ordItem.Provisioning_Steps__r[1].XC_StepLabel__c;
            }
            for(Integer i=2; i<(ordItem.Provisioning_Steps__r).size();  i++){
                wrOi.ProvisioningModelSteps += ', ' + ordItem.Provisioning_Steps__r[i].XC_StepLabel__c;
            }*/

            wrOi.ProvisioningModelSteps = ordItem.Provisioning_Steps__r[0].XC_StepLabel__c;
            wrOi.ActualProvisioninStep = (ordItem.Provisioning_Steps__r[0].XC_Status__c == 'In Progress') ? ordItem.Provisioning_Steps__r[0].XC_StepLabel__c : null;
            for(Integer i=1; i<(ordItem.Provisioning_Steps__r).size();  i++){
                wrOi.ProvisioningModelSteps += ', ' + ordItem.Provisioning_Steps__r[i].XC_StepLabel__c;
                wrOi.ActualProvisioninStep = (ordItem.Provisioning_Steps__r[i].XC_Status__c == 'In Progress') ? ordItem.Provisioning_Steps__r[i].XC_StepLabel__c :  wrOi.ActualProvisioninStep;
            }
            if(wrOi.ActualProvisioninStep == null){
                wrOi.ActualProvisioninStep = ordItem.Provisioning_Steps__r[(ordItem.Provisioning_Steps__r).size()-1].XC_StepLabel__c;
            }
            //[ BEGIN, deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added mapping and conditions for new tag]
             if(wrOi.ActualProvisioningStepStatus == null){
                wrOi.ActualProvisioningStepStatus = ordItem.Provisioning_Steps__r[(ordItem.Provisioning_Steps__r).size()-1].XC_Status__c;
            }
            //[ END, deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added mapping and conditions for new tag]
        }
        
    }  
    /**
    * @param a - Account
    * @param accountwrp -  XC_UTIL_Order.AccountWrapper 
    * @description populate account fields 
    * @author mario.a.giordano@accenture.com
    * @createDate 30112021
    */
    
    public static void populateAccountFields(Account a,XC_UTIL_Order.AccountWrapper   accountwrp){
        
        if(null != a.XC_LastName__c){
            accountwrp.LastName = a.XC_LastName__c ;
        }
        if( null != a.XC_FirstName__c){
            accountwrp.FirstName = a.XC_FirstName__c ;
        }
        if( null != String.valueOf(a.XC_BirthDate__c)){
            accountwrp.BirthDate = String.valueOf(a.XC_BirthDate__c) ;
        }
        if( null != String.valueOf(a.XC_Energy_Community__c)){
            accountwrp.Energy_Community = String.valueOf(a.XC_Energy_Community__c) ;
        }
        if( null != a.XC_Community_Typology__c){
            accountwrp.Community_Tipology = a.XC_Community_Typology__c ;
        }
        if( null != a.XC_Community_Code__c){
            accountwrp.Community_Code = a.XC_Community_Code__c ;
        }
        if( null != a.XC_GSE_Code__c){
            accountwrp.GSE_Code = a.XC_GSE_Code__c ;
        }
        if( null != a.XC_Community_Members_Number__c ){
            accountwrp.Community_Members_Number = a.XC_Community_Members_Number__c ;
        }
        if(null != String.valueOf(a.XC_Community_GSE_Approval_Date__c)){
            accountwrp.Community_GSE_Approval_Date = String.valueOf(a.XC_Community_GSE_Approval_Date__c) ;
        }
        //[ BEGIN, minal.mahavir.patil@accenture.com, 06/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ]
        if( null != a.XC_Energy_Community_Foundation_date__c){
           accountwrp.Energy_Community_Foundation_date = String.valueOf(a.XC_Energy_Community_Foundation_date__c) ;
        }
        //[ END, minal.mahavir.patil@accenture.com, 06/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ]
    }

    public static void populateAccountChildFields(Account ac, XC_UTIL_Order.AccountChildWrapper accountchildwrp){
    
        if(null != ac.XC_LastName__c){
            accountchildwrp.LastName = ac.XC_LastName__c ;
        }
        if( null != ac.XC_FirstName__c){
            accountchildwrp.FirstName = ac.XC_FirstName__c ;
        }
        if( null != ac.XC_Member_Typology__c){
            accountchildwrp.MemberTypology = ac.XC_Member_Typology__c;
        }
        if( null != ac.ParentId){
            accountchildwrp.ParentId = ac.ParentId;
        }
        if( null != ac.XC_CustomerNumber_EnelEnergia__c){
            accountchildwrp.CustomerNumberEnelEnergia = ac.XC_CustomerNumber_EnelEnergia__c;
        }
        if( null != String.valueOf(ac.XC_BirthDate__c)){
            accountchildwrp.BirthDate = String.valueOf(ac.XC_BirthDate__c) ;
        }
        //[ BEGIN, minal.mahavir.patil@accenture.com, 06/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ]
        if( null != ac.XC_Una_tantum_member_fee__c ){
            accountchildwrp.Una_tantum_member_fee = ac.XC_Una_tantum_member_fee__c ;
        }
        if( null != ac.XC_Annual_member_fee__c ){
            accountchildwrp.Annual_member_fee = ac.XC_Annual_member_fee__c ;
        }
        if( null != ac.XC_Annual_membership_fee_due_date__c ){
            accountchildwrp.Annual_membership_fee_due_date = String.valueOf(ac.XC_Annual_membership_fee_due_date__c) ;
        }
        if( null != ac.XC_Fix_part_sharing_monthly__c ){
            accountchildwrp.Fix_part_sharing_monthly = ac.XC_Fix_part_sharing_monthly__c ;
        }
        if( null != ac.XC_MISE_incentive__c ){
            accountchildwrp.MISE_incentive = ac.XC_MISE_incentive__c ;
        }
        if( null != ac.XC_Arera_incentive__c ){
            accountchildwrp.Arera_incentive = ac.XC_Arera_incentive__c ;
        }
        if( null != ac.XC_Local_price_incentive__c ){
            accountchildwrp.Local_price_incentive = ac.XC_Local_price_incentive__c ;
        }
        //[ END, minal.mahavir.patil@accenture.com, 06/01/2022, Enel X - NR2260 - Energy Communities, ENEL X - r12 ] 
        /*[ BEGIN, arjun.raoh@accenture.com, 02/05/2022, NR2453 - Comunità Energetiche
        if(null != ac.XC_Refund_Method__c) {
            accountchildwrp.refundMethod = ac.XC_Refund_Method__c;
        }
        [ END, arjun.raoh@accenture.com, 02/05/2022, NR2453 - Comunità Energetiche*/        
    }
    /**
    * @param mapUtil - Map<String,Object>
    * @description method to populate billingProfile fields on OrderItem
    */
    /*public static void updateOrdItemBillingProfile (Map<String,Object> mapUtil){

        Map<NE__OrderItem__c, Id> oiBpMap = ( Map<NE__OrderItem__c, Id>) mapUtil.get('oiBpMap');
        Map<NE__OrderItem__c, NE__OrderItem__c> oiClonedOi  = (Map<NE__OrderItem__c, NE__OrderItem__c>) mapUtil.get('oiClonedOi');
        XC_REST_Order_U.WrapperRes wr = (XC_REST_Order_U.WrapperRes) mapUtil.get('wr');
        Map<Id,NE__Billing_Profile__c> bpMap = ( Map<Id,NE__Billing_Profile__c>) mapUtil.get('bpMap');

        Map<NE__OrderItem__c, Id> oiBpMapnew = new Map<NE__OrderItem__c, Id>();
        oiBpMapnew.putAll(oiBpMap);
        Map<NE__OrderItem__c, NE__OrderItem__c> oiClonedOiNew = new Map<NE__OrderItem__c, NE__OrderItem__c>();
        oiClonedOiNew.putall(oiClonedOi);
        List<NE__OrderItem__c> ordItemToUpdate = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oiToUpdate : oiClonedOiNew.keySet()){
            String billingProfID = oiBpMapnew.get(oiToUpdate);
            NE__OrderItem__c ordItemCloned = oiClonedOiNew.get(oiToUpdate);
            ordItemCloned.XC_PaymentMethod__c = bpMap.get(oiBpMapnew.get(oiToUpdate)).NE__Payment__c;
            ordItemCloned.NE__BillingProfId__c = billingProfID; 
            oiToUpdate.XC_PaymentMethod__c = bpMap.get(oiBpMapnew.get(oiToUpdate)).NE__Payment__c;
            oiToUpdate.NE__BillingProfId__c = billingProfID; 
            ordItemToUpdate.add(oiToUpdate);
            ordItemToUpdate.add(ordItemCloned);
        }
        List<XC_UTIL_Sobject.WrapperResult> updateOi =  XC_UTIL_SObject.updateListRecords(ordItemToUpdate);
        for(XC_UTIL_Sobject.WrapperResult updateResult : updateOi){
            if(!updateResult.success){
                wr.Result.ErrorCode = '500';
                wr.Result.Message = 'INTERNAL ERROR';
                wr.Result.LogError = 'INTERNAL ERROR: ' + updateResult.errorMessage;
                return;
            }
        }
    }*/


}