public without sharing class Giic_LCC026_CreatePOFromContract {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_LCC026_CreatePOFromContract');
    
    @AuraEnabled
    public static XC_UTIL_ResultWrapper retrieveInitialInfo(String contractId){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN retrieveInitialInfo' ); 
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        Contract c = [SELECT Id, XC_Type__c, XC_LegalEntity__c, ContractNumber,AccountId,(select Id FROM Glovia_Price_Books__r) FROM Contract where Id =:  contractId];
        String contractType = c.XC_Type__c;
        if(c.Glovia_Price_Books__r.isEmpty()){
            rw.success = false;
            rw.resultMessage = 'No priceBook found!';
        }
        
        if(contractType!=null && contractType.substring(0,3) == 'ZCC'){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ found closed contract' ); 
            rw.success = true;
            rw.legalEntity = c.XC_LegalEntity__c;
            rw.fieldName2 = c.Glovia_Price_Books__r[0].Id;
            rw.fieldName = c.ContractNumber;
            rw.objectInfo = JSON.serialize(c);
        }else{
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ No closed Contract found' ); 
            rw.success = false;
            rw.resultMessage = 'This Contract is not a Closed Contract!';
            return rw;
            
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ END retrieveInitialInfo' ); 
        
        return rw;
        
    }
    
    @AuraEnabled
    public static XC_UTIL_ResultWrapper validatePurchaseOrder(String contractObject, String warehouseId, String priceBookId){
    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN validatePurchaseOrder' ); 
    List<gii__PurchaseOrder__c> poToInsert = new List<gii__PurchaseOrder__c>();
    List<gii__PurchaseOrderLine__c> poLineToInsert = new List<gii__PurchaseOrderLine__c>();
    
    XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();    
    rw.success = true;
    
    Map<String, Object> contractMap = (Map<String, Object>)JSON.deserializeUntyped(contractObject);  
    System.debug('warehouseId = '+warehouseId);
    System.debug('contractMap = '+contractMap);
    System.debug('priceBookId = '+priceBookId);
    map<Id,gii__PriceBookEntry__c> pbeMap = new map<Id,gii__PriceBookEntry__c>([SELECT Id,Name,gii__Product__c,giic_Quantity__c FROM gii__PriceBookEntry__c 
                                                                                WHERE gii__PriceBook__c =:priceBookId 
                                                                                AND gii__Product__r.gii__ProductReference__r.XC_SapType__c ='Material' ]);
        List<gii__PriceBookEntry__c> validPBE = new List<gii__PriceBookEntry__c>();
        
        for(gii__PriceBookEntry__c pbe :  pbeMap.values()){
            Integer qnty = Integer.valueOf(pbe.giic_Quantity__c);
            if(qnty!=null && qnty!=0){
                validPBE.add(pbe);
            }
        }
        if(validPBE.isEmpty()){
            rw.success = false;
            rw.resultMessage = 'No priceBook Entry found!';
        }else{
            rw.fieldName5 = JSON.serialize(validPBE.size());
            
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ END validatePurchaseOrder' );
        return rw;
        
    }
        
        
        
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createPurchaseOrder(String contractObject, String warehouseId, String priceBookId){
    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ IN createPurchaseOrder' );
    List<gii__PurchaseOrder__c> poToInsert = new List<gii__PurchaseOrder__c>();
    List<gii__PurchaseOrderLine__c> poLineToInsert = new List<gii__PurchaseOrderLine__c>();
    Savepoint sp = Database.setSavepoint();	
    XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();    
    rw.success = true;
    rw.resultMessage = 'Purchase Order correctly created!';
    Map<String, Object> contractMap = (Map<String, Object>)JSON.deserializeUntyped(contractObject);  
    System.debug('warehouseId = '+warehouseId);
    System.debug('contractMap = '+contractMap);
    System.debug('priceBookId = '+priceBookId);
    map<Id,gii__PriceBookEntry__c> pbeMap = new map<Id,gii__PriceBookEntry__c>([SELECT Id,Name,gii__Product__c,giic_Quantity__c FROM gii__PriceBookEntry__c 
                                                                                  WHERE gii__PriceBook__c =:priceBookId
                                                                               AND gii__Product__r.gii__ProductReference__r.XC_SapType__c ='Material']);
        
        
        
        
    String currentContractId = String.valueOf(contractMap.get('Id'));
    String currentPoId;
    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ currentContractId = '+currentContractId );
    gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(giic_Source__c=Label.giic_SourceReorderPlanning,
                                                            giic_Contract__c = currentContractId,
                                                            gii__Supplier__c = String.valueOf(contractMap.get('AccountId')),
                                                            gii__ShipTo__c = warehouseId,
                                                            gii__OrderDate__c = system.today(),
                                                            gii__Approved__c=false,
                                                            gii__DropShip__c = false,
                                                            gii__RequiredDate__c = system.today(),
                                                            giic_PriceBookId__c=priceBookId);
        poToInsert.add(objPO);
        
        List<XC_UTIL_ResultWrapper> rwList = XC_UTIL_Glovia.insertRecords(poToInsert);
        Boolean errorFoundOnPOLine = false;
        if(rwList[0].success){
            rw.recordId = rwList[0].recordId;
            currentPoId = rwList[0].recordId;
            for(gii__PriceBookEntry__c pbe :  pbeMap.values()){
                Integer qnty = Integer.valueOf(pbe.giic_Quantity__c);
                
                System.debug('PO recordId = '+rwList[0].recordId);
                if(qnty!=null && qnty!=0){
                	gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= pbe.gii__Product__c,gii__OrderQuantity__c =qnty,gii__PurchaseOrder__c=rwList[0].recordId  );
                	poLineToInsert.add(objPOLine);
                }
            }
            
            rwList = XC_UTIL_Glovia.insertRecords(poLineToInsert);
            for(XC_UTIL_ResultWrapper r : rwList){
                if(!r.success){
                    errorFoundOnPOLine = true;
                    Database.rollback(sp); 
                    return r;
                }
            }
        }else{
            rw.success = false;
            rw.resultMessage = rwList[0].resultMessage;
            return rw;
        }
        
        if(!errorFoundOnPOLine){
            Contract c = new Contract(Id=currentContractId , Status = 'Ended');
            update c;
            if(currentPoId!=null){
            	gii__PurchaseOrder__c po = new gii__PurchaseOrder__c(Id = currentPoId, giic_ForClosedContract__c = true);
            	update po;
            }
            
        }



     XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ END createPurchaseOrder' );
        return rw;
        
    }
	
    

}