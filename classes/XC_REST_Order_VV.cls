/**
 *
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       30/04/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         XC_REST_Order_VV – Util for Rest Resourse to  Create/Update/Read an Order/Order Item/Order Item Attribute
 * 
 */


public without sharing class XC_REST_Order_VV {
         
    /**
    * @param  mapUtil - Map<String,Object>
    * @description  manage OrderItemAttribute
    */
    public static void manageItemAttribute(Map<String,Object> mapUtil){

        List<NE__Order_Item_Attribute__c> itemAttrToInsert = (List<NE__Order_Item_Attribute__c>) mapUtil.get('itemAttrToInsert');
        Map<String, NE__Order_Item_Attribute__c> mapIdordItemAttr = (Map<String, NE__Order_Item_Attribute__c>) mapUtil.get('mapIdordItemAttr');
        XC_REST_Order_U.WrapperRes wr = (XC_REST_Order_U.WrapperRes) mapUtil.get('wr');
        //List<XC_UTIL_Sobject.WrapperResult> wrResOIA = (List<XC_UTIL_Sobject.WrapperResult>) mapUtil.get('wrResOIA');
        //List<NE__Order_Item_Attribute__c> itemAttrToClone = (List<NE__Order_Item_Attribute__c>) mapUtil.get('itemAttrToClone');
        
        if(!itemAttrToInsert.isEmpty()){
            //itemAttrToInsert.addAll(itemAttrToClone);
            //wrResOIA.addAll(XC_UTIL_Sobject.insertListRecords(itemAttrToInsert));
            
            List<XC_UTIL_Sobject.WrapperResult> insertedOrderItemsAttr = XC_UTIL_SObject.insertListRecords(itemAttrToInsert);
            for(XC_UTIL_Sobject.WrapperResult insertResult : insertedOrderItemsAttr){
                if(!insertResult.success){
                    wr.Result.ErrorCode = '500';
                    wr.Result.Message = 'INTERNAL ERROR';
                    wr.Result.logError = 'INTERNAL ERROR ' + insertResult.errorMessage;
                    return;
                }
            }

            mapIdordItemAttr.putAll(XC_REST_Order_V.populateMapIdOrdItemAttr(itemAttrToInsert));

            
            /*for(NE__Order_Item_Attribute__c oiaOpty : itemAttrToInsert) {
                for(NE__Order_Item_Attribute__c oiaOrder : itemAttrToClone) {
                    if(oiaOpty.Name == oiaOrder.Name) {
                        oiaOrder.NE__AttrEnterpriseId__c = oiaOpty.Id;
                    }
                }
            }
            XC_UTIL_Sobject.updateListRecords(itemAttrToClone);*/
        }
    }

    
    /**
    * @param orderID - String
    * @description  manage Compliance
    */
    /*public static void manageCompliance(String orderID){ // TO BE DELETED

        /*XC_UTIL_ResultWrapper resultWrapper = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(orderID);
        if(resultWrapper.success && resultWrapper.executeNextStep){
            XC_UTIL_ResultWrapper result = XC_LCC099_NextStepOrderToProvisioning.implementSecondNextStep(orderID);
            if(result.success && result.executeNextStep) {
                XC_LCC099_NextStepOrderToProvisioning.implementThirdNextStep(orderID);
            }
        }
        //XC_UTIL_NextStepOrderToProvisioning.firstNextStep(orderID);
    }*/


    /**
    * @param mapUtil - Map<String,Object>
    * @description  populate OIA List to be inserted
    */
    public static void populateOIAList(Map<String,Object> mapUtil){

		List<XC_UTIL_Order.OrderItemWrapper> orderItemList = (List<XC_UTIL_Order.OrderItemWrapper>) mapUtil.get('orderItemList');
        Map<List<XC_UTIL_Order.WrapperAttribute>, NE__OrderItem__c> mapOIAOrdItem = (Map<List<XC_UTIL_Order.WrapperAttribute>, NE__OrderItem__c>) mapUtil.get('mapOIAOrdItem');
        List<NE__Order_Item_Attribute__c> itemAttrToInsert = (List<NE__Order_Item_Attribute__c>) mapUtil.get('itemAttrToInsert');
        //List<NE__Order_Item_Attribute__c> itemAttrToClone = (List<NE__Order_Item_Attribute__c>) mapUtil.get('itemAttrToClone');
        //Map<NE__OrderItem__c, NE__OrderItem__c> oiClonedOi = new Map<NE__OrderItem__c, NE__OrderItem__c>();
        //oiClonedOi.putall((Map<NE__OrderItem__c, NE__OrderItem__c>) mapUtil.get('oiClonedOi'));
        Set<String> prodFamIds = new Set<String>();
      
        for(XC_UTIL_Order.OrderItemWrapper orderItem : orderItemList){
            if(orderItem.Attribute != null && orderItem.Attribute.size()>0){
                String oiId = mapOIAOrdItem.get(orderItem.Attribute).id;
                //system.debug('test oiId: '+oiId);
                //system.debug('test mapOIAOrdItem: '+mapOIAOrdItem);
                /*List<NE__OrderItem__c> test = new List<NE__OrderItem__c>();
                test.addAll(oiClonedOi.keySet());
                system.debug('test oiClonedOi: '+test[0].id);
                //system.debug('test oiClonedOi: '+test[1].id);
                String oiIdCloned = oiClonedOi.get(mapOIAOrdItem.get(orderItem.Attribute)).Id;*/
                for(XC_UTIL_Order.WrapperAttribute wrAttr: orderItem.Attribute){
                    NE__Order_Item_Attribute__c itemAttr = XC_UTIL_Order.createOrdItemAttrFromWrapper(wrAttr, OIid);
                    itemAttrToInsert.add(itemAttr);
                    /*NE__Order_Item_Attribute__c cloned = itemAttr.clone(false, true, false,false);
                    cloned.NE__Order_Item__c = oiIdCloned;
                    itemAttrToClone.add(cloned);*/
                    prodFamIds.add(wrAttr.ProductFamilyPropertyID);
                }
            }
        }

        Map<Id,NE__ProductFamilyProperty__c> pfpMap = new Map<Id,NE__ProductFamilyProperty__c>([
            SELECT id, NE__FamilyPropertyCode__c FROM NE__ProductFamilyProperty__c WHERE Id IN: prodFamIds
        ]);

        for(NE__Order_Item_Attribute__c oia:itemAttrToInsert){
            oia.NE__FamPropExtId__c = pfpMap.get(oia.NE__FamPropId__c).NE__FamilyPropertyCode__c;
        }

    }
    

    /**
    * @param mapUtil - Map<String,Object>
    * @description check OrderItemAttributeResult and populate the response
    */
    /*public static void checkOIAResAndPopulateResponse(Map<String,Object> mapUtil){

        List<XC_UTIL_Sobject.WrapperResult> wrResOIA = (List<XC_UTIL_Sobject.WrapperResult>) mapUtil.get('wrResOIA');
        XC_UTIL_Order.OrderItemWrapper orItemWR = (XC_UTIL_Order.OrderItemWrapper) mapUtil.get('orItemWR');
        XC_REST_Order_U.WrapperRes wr = (XC_REST_Order_U.WrapperRes) mapUtil.get('wr');
        Map<String, NE__Order_Item_Attribute__c> mapIdordItemAttr = (Map<String, NE__Order_Item_Attribute__c>) mapUtil.get('mapIdordItemAttr');
        List<NE__Order_Item_Attribute__c> itemAttrToClone = (List<NE__Order_Item_Attribute__c>)  mapUtil.get('itemAttrToClone');
        if(!wrResOIA.isEmpty()){
            List<Id> ordItemAttrIds =  XC_UTIL_SObject.getIds(itemAttrToClone);
            orItemWR.Attribute = new List<XC_UTIL_Order.WrapperAttribute>();
            for(XC_UTIL_Sobject.WrapperResult result: wrResOIA){   
                if(!result.success){
                    wr.Result.ErrorCode = '500';
                    wr.Result.Message = 'INTERNAL ERROR ';
                    wr.Result.LogError = 'INTERNAL ERROR ' + result.errorMessage;
                    wr.Order = null;
                    return;
                }else if(mapIdordItemAttr.get(result.recordId).NE__Order_Item__c == orItemWR.OrderItemID && ordItemAttrIds.contains(result.recordId)){
                    XC_UTIL_Order.WrapperAttribute orItemAttrWR = new XC_UTIL_Order.WrapperAttribute();
                    orItemAttrWR.AttributeID = mapIdordItemAttr.get(result.recordId).id;
                    orItemAttrWR.Name = mapIdordItemAttr.get(result.recordId).Name;
                    orItemAttrWR.Value = mapIdordItemAttr.get(result.recordId).NE__Value__c;
                    orItemWR.Attribute.add(orItemAttrWR);
                } 
            }
            if(orItemWR.Attribute.isEmpty()){
                orItemWR.Attribute = null;
            }
        } 
    }

    
    /**
    * @param utilMap - Map<String,Object>
    * @description  manage OrderItemAttribute
    */
    public static void manageOrdItemAttr(Map<String,Object> utilMap){

        XC_UTIL_Order.OrderItemWrapper orderItem = (XC_UTIL_Order.OrderItemWrapper) utilMap.get('orderItemWr');
        XC_REST_Order_U.WrapperRes wr = (XC_REST_Order_U.WrapperRes) utilMap.get('wr');
        Map<String, List<NE__Order_Item_Attribute__c>> mapOrdItemOIA = (Map<String, List<NE__Order_Item_Attribute__c>>) utilMap.get('mapOrdItemOIA');
        XC_UTIL_Order.OrderItemWrapper orderItemWrRes = (XC_UTIL_Order.OrderItemWrapper) utilMap.get('orderItemWrRes');
        List<NE__Order_Item_Attribute__c> oiaToUpdate  = (List<NE__Order_Item_Attribute__c>) utilMap.get('oiaToUpdate');


        if(orderItem.Attribute != null && !mapOrdItemOIA.containsKey(orderItem.OrderItemID)){
            wr.Result.ErrorCode = '400';
            wr.Result.Message = 'ERROR. Attribute.AttributeID ' + orderItem.Attribute[0].AttributeID +' of OrderItem.OrderItemID '+ orderItem.orderItemID + ' not found';
            wr.Order = null;
            return;
        }
        
        if(orderItem.Attribute != null){
            Map<String, NE__Order_Item_Attribute__c> mapIdOrdItemAttr =  new Map<String, NE__Order_Item_Attribute__c>();
            List<NE__Order_Item_Attribute__c> oiaList = new List<NE__Order_Item_Attribute__c>();
            mapIdOrdItemAttr = XC_REST_Order_V.populateMapIdOrdItemAttr(mapOrdItemOIA.get(orderItem.OrderItemID));
            orderItemWrRes.Attribute = new List<XC_UTIL_Order.WrapperAttribute>();
            for(XC_UTIL_Order.WrapperAttribute wrAttr: orderItem.Attribute){
                if(!mapIdOrdItemAttr.containskey(wrAttr.AttributeID)){
                    wr.Result.ErrorCode = '400';
                    wr.Result.Message = 'ERROR. Attribute.AttributeID ' + wrAttr.AttributeID +' of OrderItem.OrderItemID '+ orderItem.orderItemID + ' not found';
                    wr.Order = null;
                    return;
                }else{
                    XC_UTIL_Order.WrapperAttribute orItemAttrWR = new XC_UTIL_Order.WrapperAttribute();
                    orItemAttrWR.AttributeID = wrAttr.AttributeID;
                    orderItemWrRes.Attribute.add(orItemAttrWR);
                    populateOiAttribute(mapIdOrdItemAttr, wrAttr);
                    OIAList.add(mapIdOrdItemAttr.get(wrAttr.AttributeID));
                }
            }
            OIAToUpdate.addall(OIAList);
        }
    } 


    /**
    * @param mapIdOrdItemAttr - Map<String, NE__Order_Item_Attribute__c>
    * @param wrAttr - XC_UTIL_Order.WrapperAttribute
    * @description update OrderItemAttribute fields
    */
    public static void populateOiAttribute(Map<String, NE__Order_Item_Attribute__c> mapIdOrdItemAttr, XC_UTIL_Order.WrapperAttribute wrAttr){
        
        if(mapIdOrdItemAttr.get(wrAttr.AttributeID).NE__Value__c != null){
            mapIdOrdItemAttr.get(wrAttr.AttributeID).NE__Old_Value__c = mapIdOrdItemAttr.get(wrAttr.AttributeID).NE__Value__c; 
        }
        Map<String,Object> utilMapAttr = new Map<String,Object>{
                                                'Name' => wrAttr.Name,
                                                'NE__Value__c' => wrAttr.Value, 
                                                'NE__FamPropId__c' => wrAttr.ProductFamilyPropertyID
                                                };

        for(String key : utilMapAttr.keySet()){
            if(utilMapAttr.get(key)!= null){
                mapIdOrdItemAttr.get(wrAttr.AttributeID).put(key, utilMapAttr.get(key));
            }
        }
    }
                   

    /**
    * @param orders - List<NE__Order__c>
    * @param mapOrderitemDocument - Map<Id, List<String>>
    * @param header - Map<String,String> 
    * @description  manage compliance verification
    */
    public static void manageComplianceVerification(List<NE__Order__c> orders, Map<Id, List<String>> mapOrderitemDocument, Map<String,String> header){
        if(header.get('Operation') == 'VerificationCompliance' && (orders[0].XC_Status__c == Label.XC_CL_Configuration_OrderToBeValidated || orders[0].XC_Status__c == 'In Progress') && (Label.XC_CL_Configuration_TypeInOrder).equals(orders[0].NE__Type__c) && String.isBlank(orders[0].XC_Compliance_Approval__c)){
            Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> mapOrderitemCompliance1 = XC_UTIL_ComplianceMaster.getDocumentComplianceMaster(Label.XC_CL_Compliance_C1, Orders[0].Id);
            List<Id> confItemIdList = new List<Id>();
            List<NE__OrderItem__c> confItemListToUpdate = new List<NE__OrderItem__c>();
            for(Id orderItemId : mapOrderitemCompliance1.keySet()) {
                if(mapOrderitemCompliance1.get(orderItemId).check) {
                    confItemIdList.add(orderItemId);
                }
            }
            if(!confItemIdList.isEmpty()){
                mapOrderitemDocument.putall(XC_UTIL_DocumentComplianceMaster.getDocumentComplianceMaster(Label.XC_CL_Compliance_C1, confItemIdList));
            }           
        }
    }

}