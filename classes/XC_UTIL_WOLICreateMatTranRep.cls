public without sharing class XC_UTIL_WOLICreateMatTranRep {

    public static XC_UTIL_ResultWrapper createMTR(List<WorkOrderLineItem> woliList){
	
		XC_UTIL_ResultWrapper resWrapper = new  XC_UTIL_ResultWrapper();
		
			try{
            XC_UTIL_FSLLogistic.InputSelfCallout wrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
            wrapper.listWOLI = woliList;
            wrapper.operation = 'createMaterialTranspGloviaB2B';
            XC_UTIL_FSLLogistic.OutputSelfCallout response = XC_UTIL_FSLLogistic.selfCalloutGlovia(wrapper);
			
			resWrapper.success = response.success;
            resWrapper.resultMessage = response.message;
        }
        catch(Exception e){
            System.debug( '@@@@ XC_UTIL_TehcnicalCart - generateTechnicalItems - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }
        return resWrapper;
	
	}


	public static List<XC_UTIL_Sobject.WrapperResult> createMaterialTranRep(List<WorkOrderLineItem> listNew){
       
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = new List<XC_UTIL_Sobject.WrapperResult>();
        List <XC_UTIL_ResultWrapper> responseRMAList = new List<XC_UTIL_ResultWrapper>();
        XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
        List <WorkOrderLineItem> woliToUpdate = new List <WorkOrderLineItem>();
		/*List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = new List<XC_UTIL_Sobject.WrapperResult>();

        XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
        List<String> listPartnerIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_AccountId__c');
        if(listPartnerIds.isEmpty()){
            wrapperResult.success = false;
            wrapperResult.errorMessage = 'XC_UTIL_WOLICreateRMA - No Assigned Partner related to WOLI.';
            wrapperResultList.add(wrapperResult);
            return wrapperResultList;
        }*/
		
		List<Id> listWOLIIds = XC_UTIL_Sobject.getIds(listNew);
		Map<Id, WorkOrderLineItem> mapWOLI = getWorkOrderLineItem(listWOLIIds);
		
		
		
		 Map<Id, List<XC_ProductConsumed__c>> mapWOLIConsumedToReturn = new Map<Id, List<XC_ProductConsumed__c>>();
        List<String> product2 = new List<String>();
        if(!mapWOLI.values().isEmpty()){
            for(Id woliId : mapWOLI.keySet()){
                for (XC_ProductConsumed__c pr : mapWOLI.get(woliId).Products_Consumed__r){
                    product2.add(pr.XC_Product2Id__C);
                }
            }
		            if(product2.isEmpty()){
                wrapperResult.success = false;
                wrapperResult.errorMessage = 'XC_UTIL_WOLICreateMaterialTranRep - No Required Product to precess.';
                wrapperResultList.add(wrapperResult);
                return wrapperResultList;
            }	
			
			Map<Id,gii__Product2Add__c> prGloviaMap =  getGloviaProduct(product2);
			 if(prGloviaMap.values().isEmpty()){
                wrapperResult.success = false;
                wrapperResult.errorMessage = 'XC_UTIL_WOLICreateMaterialTranRep - No Product Reference to precess.';
                wrapperResultList.add(wrapperResult);
                return wrapperResultList;
            }
			
			Map<Id,gii__Product2Add__c> product2ToGlovia = getProduct2ToGlovia(prGloviaMap.values());
            List<WorkOrderLineItem> woliNewList = new List<WorkOrderLineItem>();
            //list<WorkOrderLineItem> woliToUpdate = new list<WorkOrderLineItem>();
            for(WorkOrderLineItem woli : mapWOLI.values()){
			List<Giic_CommonWrapper.MediaMobileWrapper> linesNew = getMTR(woli, product2ToGlovia);
			
			WorkOrderLineItem woNew = new WorkOrderLineItem();
            woNew.Id = woli.id;
            woNew.Status = 'Completed';
            responseRMAList =  Giic_ProductReference_UTIL.updateAveragePrice(linesNew);
            woliToUpdate.add(woNew);
            }
			
			
        }
        	
		for(XC_UTIL_ResultWrapper  responseRMA: responseRMAList){
		if(responseRMA.Success != null && responseRMA.success){ 
            wrapperResult.success = true;	
                //wrapperResultList = XC_UTIL_Sobject.updateListRecords(woliNewList);		
            } else {
                wrapperResult.success = false;
               
                wrapperResultList.add(wrapperResult);
            }
        }
        if( wrapperResult.success == true){
         update woliToUpdate;
        }
        else{
            wrapperResult.success = false;
            wrapperResult.errorMessage = 'XC_UTIL_WOLICreateMaterialTranRep - No Work Order to precess.';
            wrapperResultList.add(wrapperResult);
            return wrapperResultList;
        }
    
        return wrapperResultList;
		
	}
	
	
	
	
	
	
	
	private static Map<Id, WorkOrderLineItem> getWorkOrderLineItem(List<Id> listWOLIIds){
		
		Map<Id, WorkOrderLineItem> mapWOLI = new Map<Id, WorkOrderLineItem>(
		[SELECT Id,workOrderId, CurrencyIsoCode,workOrder.WorkOrderNumber,
        (select id,XC_RepairCost__c,XC_TransportCost__c,XC_Product2Id__r.ProductCode,CurrencyIsoCode
        from Products_Consumed__r)
        FROM WorkOrderLineItem
        WHERE Id IN: listWOLIIds]
		);
		return mapWOLI;
	}
	
	
	 private static  Map<Id,gii__Product2Add__c> getGloviaProduct(List<String> product2){
        Map<Id,gii__Product2Add__c> prGloviaMap = new Map<Id,gii__Product2Add__c>([
                SELECT Id, gii__ProductReference__c,gii__SerialControlled__c
                FROM gii__Product2Add__c
                WHERE gii__ProductReference__c IN : product2]
        );
        return prGloviaMap;
    }
	
	
	
	 private static  Map<Id,gii__Product2Add__c> getProduct2ToGlovia(List<gii__Product2Add__c> prGloviaMap){
        Map<Id,gii__Product2Add__c> product2ToGlovia =  new  Map<Id,gii__Product2Add__c>();
        if(!prGloviaMap.isEmpty()){
            for(gii__Product2Add__c pr : prGloviaMap){
                product2ToGlovia.put(pr.gii__ProductReference__c, pr);
            }
        }
        return product2ToGlovia;
    }
	
	
	 private static List<Giic_CommonWrapper.MediaMobileWrapper> getMTR( WorkOrderLineItem woli, Map<Id,gii__Product2Add__c> product2ToGlovia ){  				
		 List<Giic_CommonWrapper.MediaMobileWrapper> lines = new List<Giic_CommonWrapper.MediaMobileWrapper>(); 												 
			for(XC_ProductConsumed__c pc :  woli.Products_Consumed__r){
				Giic_CommonWrapper.MediaMobileWrapper obj = new Giic_CommonWrapper.MediaMobileWrapper();  															
				obj.price = pc.XC_RepairCost__c + pc.XC_TransportCost__c;  																							
				obj.productCode = pc.XC_Product2Id__r.ProductCode;
				obj.inCurrency = pc.CurrencyIsoCode;																												
				lines.add(obj);																																		
			}
		 return lines;
	 }

}