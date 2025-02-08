/**
* @author FirstName : Shubee Tyagi-Shubee.Tyagi@fujitsu.com
* @date Creation 22/08/2019
* @date Modification 10/09/2019
* @description Giic_POReceiptCreationApi – This class will be used for PO Receipt and PO Receipt Line
*/
public without sharing class Giic_POReceiptCreationApi {
    /**
* @author FirstName : Shubee Tyagi-Shubee.Tyagi@fujitsu.com
* @date 22/08/2019
* @description createPOReceiptandLine- To create PO Receipt
* @param  List of type Giic_POReceiptCreationApi.PurchaseOrderHeader 
*/ 
    private final static Boolean DEBUGACTIVE = true;
    //DEBUGACTIVE= XC_UTIL_Debug.isActive('Giic_POReceiptCreationApi');
    Public static Giic_POReceiptCreationApi.POReceiptResponse createPOReceiptandLine(List<Giic_POReceiptCreationApi.PurchaseOrderHeader> listPurchaseOrderHeader) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN createPOReceiptandLine'); 
        Giic_POReceiptCreationApi.ParamsWrapper params=  new Giic_POReceiptCreationApi.ParamsWrapper();
        List<Id> listPols = new List<Id>();
        Savepoint sp = Database.setSavepoint();
        params.listPurchaseOrderHeader = listPurchaseOrderHeader;
        for(Giic_POReceiptCreationApi.PurchaseOrderHeader objPO : listPurchaseOrderHeader){
            params.pOID.add(objPO.purchaseOrderId);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'params.pOID'+params.pOID);
            for(Giic_POReceiptCreationApi.PurchaseOrderLine pol : objPO.PurchaseOrderLinelist){
                listPols.add(pol.PurchaseOrderLineId);}}
        params.mapPurchaseOrderLines=new map<id,gii__PurchaseOrderLine__c>([SELECT id,gii__PurchaseOrder__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Product__r.gii__LotControlled__c,
                                                                            gii__PurchaseOrder__r.gii__OrderStatus__c,gii__LineStatus__c,gii__OrderQuantity__c 
                                                                            FROM gii__PurchaseOrderLine__c
                                                                            WHERE Id IN:listPols]);
        params=checkPOandPOL(params);
        if(params.response.isSuccess == false){
            Database.rollback(sp);
            setPOStatus(params.pOID);
            params.errorLogsList=createErrorLogs(params);
            Giic_ErrorLogsUtility.insertErrorLogs(params.errorLogsList);
            return params.response;
        }
        params=createPOReceiptandLineHelper(listPurchaseOrderHeader,params);
        params=saveReceipt(params);
        if(params.response.isSuccess == false){
            Database.rollback(sp);
            setPOStatus(params.pOID);
            Giic_ErrorLogsUtility.insertErrorLogs(params.errorLogsList);
            return params.response;
        }
        params=createPOReceiptLine(params);
        if(params.response.isSuccess == false){
            Database.rollback(sp);
            setPOStatus(params.pOID);
            Giic_ErrorLogsUtility.insertErrorLogs(params.errorLogsList);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'response'+params.response);
            return params.response;
        }
        
        setPOReceiptStatus(params.purchaseOrderReceiptId);
        return params.response; }
    /**
* @author FirstName : Shubee Tyagi-Shubee.Tyagi@fujitsu.com
* @date 22/08/2019
* @description createPOReceiptandLineHelper- To create PO Receipt
* @param  List of type Giic_POReceiptCreationApi.PurchaseOrderHeader, Object of Giic_POReceiptCreationApi.ParamsWrapper, Map of Purchase Order Line
*/ Public static Giic_POReceiptCreationApi.ParamsWrapper createPOReceiptandLineHelper(List<Giic_POReceiptCreationApi.PurchaseOrderHeader> listPurchaseOrderHeader,Giic_POReceiptCreationApi.ParamsWrapper params){
    XC_UTIL_Debug.debug(DEBUGACTIVE,'IN createPOReceiptandLineHelper'); 
    for(Giic_POReceiptCreationApi.PurchaseOrderHeader objPO : listPurchaseOrderHeader){
        gii__PurchaseOrderReceipt__c poReceipt = new gii__PurchaseOrderReceipt__c();
        poReceipt.gii__PurchaseOrder__c = objPO.PurchaseOrderId; //Purchase order id which is required.
        poReceipt.gii__ReceiptDate__c   = (objPO.receiptDate!=null) ? objPO.receiptDate : System.today();  //Receipt Date which is required. 
        poReceipt.giic_DeliveryDate__c   = objPO.deliveryDate;

        if(objPO.qualityNoteRequire != null){
            poReceipt.XC_Quality_Check__c = objPO.qualityNoteRequire;
            
        }
        System.debug('Quality check --> ' + objPO.qualityNoteRequire);
      
        if(objPO.qualityNote != ''){
            poReceipt.giic_NoteQualityCheck__c = objPO.qualityNote;
            
        }
        System.debug('Quality check Note --> ' + objPO.qualityNote);

        if(objPO.qualityCheckFail != null){
            poReceipt.giic_QualityCheckKONOEMFlag__c = objPO.qualityCheckFail;
        }
        System.debug('Quality check Fail --> ' + objPO.qualityCheckFail);

        if(objPO.arrivalMaterial != null){

            poReceipt.giic_MaterialReceiptDate__c = Date.valueOf(objPO.arrivalMaterial);
            
        }
        
        System.debug('Quality check material date --> ' + objPO.arrivalMaterial);
        
        System.debug('DELIVERYID ='+objPO.deliveryId);
        poReceipt.giic_DeliveryDocumentID__c   = objPO.deliveryId;
        poReceipt.giic_TargetSystem__c= System.Label.giic_TargetSystemGlovia;
        for(Giic_POReceiptCreationApi.PurchaseOrderLine pol : objPO.PurchaseOrderLinelist){
            params.mapPOLIdandqty.put(pol.PurchaseOrderLineId,pol.receiptQuantity);
            if(pol.assignedSerials != null && !pol.assignedSerials.isEmpty()){
                for(Giic_POReceiptCreationApi.AssignedSerial assignedSerial : pol.assignedSerials){
                    Id polId=pol.purchaseOrderLineId;
                    params.mapProductSerial.put(assignedSerial.SerialNumber,new gii__ProductSerial__c(Name=assignedSerial.SerialNumber,gii__Product__c=params.mapPurchaseOrderLines.get(polId).gii__Product__c));
                    params.productRequireSerialListMap.put(pol.PurchaseOrderLineId,pol.AssignedSerials);
                } } 
            if(pol.assignedLots != null && !pol.assignedLots.isEmpty()){
                for(Giic_POReceiptCreationApi.AssignedLot assignedLot : pol.assignedLots){
                    Id polId=pol.purchaseOrderLineId;
                    params.mapProductLot.put(assignedLot.LotNumber,new gii__ProductLot__c(Name=assignedLot.LotNumber,gii__Product__c=params.mapPurchaseOrderLines.get(polId).gii__Product__c));
                    params.productRequireLotListMap.put(pol.PurchaseOrderLineId,pol.assignedLots);
                } 
            }
        
        }
        params.listPurchaseOrderReceipt.add(poReceipt);
    }
    return params;
}
    /**
* @author FirstName : Shubee Tyagi-Shubee.Tyagi@fujitsu.com
* @date 22/08/2019
* @description saveReceipt- To Save PO Receipt
* @param Object of Giic_POReceiptCreationApi.ParamsWrapper
*/  
    public static Giic_POReceiptCreationApi.ParamsWrapper saveReceipt( Giic_POReceiptCreationApi.ParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN saveReceipt'); 
        List<Giic_POReceiptCreationApi.ErrorList> errorlst;
        errorlst = params.response.errorList != null ? params.response.errorList : new List<Giic_POReceiptCreationApi.ErrorList>();
        if(!params.listPurchaseOrderReceipt.isEmpty()){
            Savepoint sp = Database.setSavepoint();
			insert params.mapProductSerial.values();
            insert params.mapProductLot.values();
            DataBase.SaveResult[] result = Database.Insert(params.listPurchaseOrderReceipt, false);
            for (Database.SaveResult sr:result) {
                if (sr.isSuccess()) {
                    params.purchaseOrderReceiptId.add(sr.getId()); 
                    params.listPurchaseOrderReceipt.clear();
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'params.purchaseOrderReceiptId'+params.purchaseOrderReceiptId);
                }else{
                    Database.Error err = sr.getErrors()[0];
                    Giic_POReceiptCreationApi.ErrorList error = new Giic_POReceiptCreationApi.ErrorList();
                    error.errorMsg=err.getMessage();
                    errorlst.add(error);
                    params.response.IsSuccess = false;
                    params.response.errorList = errorlst; 
                    Database.rollback(sp);
                } 
            }
            for(Integer count=0;count<params.listPurchaseOrderReceipt.size();count++ ){
                List<String> lstError= new List<String>();
                if(params.listPurchaseOrderReceipt[count].id == null){
                    //params.lstPOtoUpdate.add(params.listPurchaseOrderReceipt[count].gii__PurchaseOrder__c);
                    String errorMsg=result[count].getErrors()[0].getMessage();
                    lstError.add(errorMsg);
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'errorMsg:::'+errorMsg);
                    params.errorLogsList.addAll(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper('Purchase Order Receipt',new map<string,object>{'giic_PurchaseOrder__c'=>params.listPurchaseOrderReceipt[count].gii__PurchaseOrder__c},
                                                                                                                               'Purchase Order Receipt Creation',string.join(lstError,'\'n\''))));
                }
            }
            
        }
        
        return params;}
    
    /**
* @author FirstName : Shubee Tyagi-Shubee.Tyagi@fujitsu.com
* @date 22/08/2019
* @description createPOReceiptLine- To create PO Receipt Line
* @param Object of Giic_POReceiptCreationApi.ParamsWrapper
*/  Public static Giic_POReceiptCreationApi.ParamsWrapper createPOReceiptLine( Giic_POReceiptCreationApi.ParamsWrapper params){
   
    XC_UTIL_Debug.debug(DEBUGACTIVE,'IN createPOReceiptLine'); 
    Map<Id,gii__PurchaseOrderReceipt__c> mapPOIdandReceiptId = new Map<Id,gii__PurchaseOrderReceipt__c>();
    List<gii__PurchaseOrderReceipt__c> porlist= new List<gii__PurchaseOrderReceipt__c>([SELECT id,gii__PurchaseOrder__c,gii__PurchaseOrder__r.gii__ShipTo__c,
                                                                                        gii__PurchaseOrder__r.gii__ShipTo__r.gii__DefaultIssueLocation__c, gii__PurchaseOrder__r.gii__ShipTo__r.gii__DefaultReceivingLocation__c
                                                                                        FROM gii__PurchaseOrderReceipt__c 
                                                                                        WHERE ID IN:params.purchaseOrderReceiptId]);
     
    XC_UTIL_Debug.debug(DEBUGACTIVE,'porlist'+porlist);
    if(!porlist.isEmpty()){
        for(gii__PurchaseOrderReceipt__c objpoReceipt : porlist){
            mapPOIdandReceiptId.put(objpoReceipt.gii__PurchaseOrder__c, objpoReceipt);
        }
    }
    XC_UTIL_Debug.debug(DEBUGACTIVE,'mapPOIdandReceiptId'+mapPOIdandReceiptId);
    XC_UTIL_Debug.debug(DEBUGACTIVE,'productRequireSerialListMap'+params.productRequireSerialListMap);
    XC_UTIL_Debug.debug(DEBUGACTIVE,'listPOL'+params.mapPurchaseOrderLines);
    // Craete Purchase Order Receipt Line
    params.listpoReceiptLine=createPOReceiptLineHelper(params,mapPOIdandReceiptId,porlist);
    params=saveReceiptLine(params);
    return params; 
}
    /**
* @author FirstName : Shubee Tyagi-Shubee.Tyagi@fujitsu.com  
* @date 22/08/2019
* @description createPOReceiptLineHelper- To create PO Receipt Line
* @param Object of Giic_POReceiptCreationApi.ParamsWrapper,Map of PO Id and Receipt , List of Purchase Order Receipt
*/  
    Public static List<gii__PurchaseOrderReceiptLine__c> createPOReceiptLineHelper( Giic_POReceiptCreationApi.ParamsWrapper params,Map<Id,gii__PurchaseOrderReceipt__c> mapPOIdandReceiptId,List<gii__PurchaseOrderReceipt__c> porlist){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN createPOReceiptLineHelper'); 
        for(gii__PurchaseOrderLine__c objPOL : params.mapPurchaseOrderLines.values()){
            System.debug('entrato in createPOReceiptLineHelper');
            if(objPOL.gii__Product__c!=null && objPOL.gii__Product__r.gii__SerialControlled__c){
                 System.debug('in if serial'); 
                    for(Giic_POReceiptCreationApi.AssignedSerial assignedSerial : params.productRequireSerialListMap.get(objPOL.Id)){
                        gii__PurchaseOrderReceiptLine__c poReceiptLine = new gii__PurchaseOrderReceiptLine__c();
                        poReceiptLine.gii__PurchaseOrderReceipt__c = mapPOIdandReceiptId.get(objPOL.gii__PurchaseOrder__c).Id;
                        poReceiptLine.gii__PurchaseOrderLine__c = objPOL.Id;
                        poReceiptLine.gii__BuyingUMReceivedQuantity__c = 1.0; // (Buying UM)
                        poReceiptLine.gii__Location__c = mapPOIdandReceiptId.get(objPOL.gii__PurchaseOrder__c).gii__PurchaseOrder__r.gii__ShipTo__r.gii__DefaultReceivingLocation__c;
                        poReceiptLine.gii__ProductSerial__c=params.mapProductSerial.get(assignedSerial.SerialNumber).id;
                        params.listpoReceiptLine.add(poReceiptLine);
                    } 
            }else if(objPOL.gii__Product__c!=null && objPOL.gii__Product__r.gii__LotControlled__c){
                System.debug('in if lot'); 
                for(Giic_POReceiptCreationApi.AssignedLot assignedLot : params.productRequireLotListMap.get(objPOL.Id)){
                    gii__PurchaseOrderReceiptLine__c poReceiptLine = new gii__PurchaseOrderReceiptLine__c();
                    poReceiptLine.gii__PurchaseOrderReceipt__c = mapPOIdandReceiptId.get(objPOL.gii__PurchaseOrder__c).Id;
                    poReceiptLine.gii__PurchaseOrderLine__c = objPOL.Id;
                    poReceiptLine.gii__BuyingUMReceivedQuantity__c = assignedLot.LotQuantity;  // (Buying UM)
                    poReceiptLine.gii__Location__c = mapPOIdandReceiptId.get(objPOL.gii__PurchaseOrder__c).gii__PurchaseOrder__r.gii__ShipTo__r.gii__DefaultReceivingLocation__c; 
                    poReceiptLine.gii__ProductLot__c=params.mapProductLot.get(assignedLot.LotNumber).id;
                    params.listpoReceiptLine.add(poReceiptLine);
                }  
            }else{
                System.debug('in else');
                gii__PurchaseOrderReceiptLine__c poReceiptLine = new gii__PurchaseOrderReceiptLine__c();
                poReceiptLine.gii__PurchaseOrderReceipt__c = mapPOIdandReceiptId.get(objPOL.gii__PurchaseOrder__c).Id;
                poReceiptLine.gii__PurchaseOrderLine__c = objPOL.Id;
                poReceiptLine.gii__BuyingUMReceivedQuantity__c = params.mapPOLIdandqty.get(objPOL.Id);// (Buying UM)
                poReceiptLine.gii__Location__c=mapPOIdandReceiptId.get(objPOL.gii__PurchaseOrder__c).gii__PurchaseOrder__r.gii__ShipTo__r.gii__DefaultReceivingLocation__c;
                System.debug('poReceiptLine = '+poReceiptLine);
                params.listpoReceiptLine.add(poReceiptLine);
            }  
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN params.listpoReceiptLine = '+params.listpoReceiptLine); 
        return params.listpoReceiptLine; }
    /**
* @author FirstName : Shubee Tyagi-Shubee.Tyagi@fujitsu.com
* @date 22/08/2019
* @description saveReceiptLine- To Save PO Receipt Line
* @param List<gii__PurchaseOrderReceiptLine__c> listpoReceiptLine
*/  
    public static  Giic_POReceiptCreationApi.ParamsWrapper saveReceiptLine(  Giic_POReceiptCreationApi.ParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN saveReceiptLine = '); 
        Giic_POReceiptCreationApi.POReceiptResponse response = new Giic_POReceiptCreationApi.POReceiptResponse();
        List<Giic_POReceiptCreationApi.ErrorList> errorList;
        List<Id>poToUpdateId= new List<Id>();
        errorList = params.response.errorList != null ? params.response.errorList : new List<Giic_POReceiptCreationApi.ErrorList>();
        if (params.listpoReceiptLine.size() > 0) {
            DataBase.SaveResult[] result = Database.Insert(params.listpoReceiptLine, false);
            for (Database.SaveResult sr:result) {
                if (sr.isSuccess()) {
                    params.response.IsSuccess = true;}
                else {
                    Database.Error err = sr.getErrors()[0];
                    Giic_POReceiptCreationApi.ErrorList error = new Giic_POReceiptCreationApi.ErrorList();
                    error.errorMsg=err.getMessage();
                    errorList.add(error);
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'errorList'+errorList);
                    params.response.IsSuccess = false;
                    params.response.errorList = errorList; } } 
            for(Integer count=0;count<params.listpoReceiptLine.size();count++ ){
                List<String> lstError= new List<String>();
                if(params.listpoReceiptLine[count].id == null){
                    // poToUpdateId.add(params.listpoReceiptLine[count].gii__PurchaseOrderLine__c);
                    String errorMsg=result[count].getErrors()[0].getMessage();
                    lstError.add(errorMsg);
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'errorMsg:::'+errorMsg);
                    params.errorLogsList.addAll(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper('Purchase Order Receipt',new map<string,object>{'giic_PurchaseOrderLine__c'=>params.listpoReceiptLine[count].gii__PurchaseOrderLine__c},
                                                                                                                               'Purchase Order Receipt Line  Creation',string.join(lstError,'\'n\''))));
                }
            }
            
            //map<id,gii__PurchaseOrderLine__c> mapPOLines=new map<id,gii__PurchaseOrderLine__c>([SELECT id,gii__PurchaseOrder__c FROM gii__PurchaseOrderLine__c WHERE Id=:poToUpdateId]);
            //params.lstPOtoUpdate.addAll(mapPOLines.keySet());
            
        }
        return params;}
    /**
* @author FirstName : Shubee Tyagi-Shubee.Tyagi@fujitsu.com
* @date 22/08/2019
* @description setPOStatus- To Change the status of PO 
* @param List of Purchase Order Ids
*/ 
    public static void setPOStatus(List<Id> poIds){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN setPOStatus  '); 
        List<gii__PurchaseOrder__c> lstPOR= new List<gii__PurchaseOrder__c>( [SELECT Id,Name,giic_IntegrationStatus__c,giic_IntegrationOperation__c,	giic_MultiTargetSystem__c 
                                                                              FROM gii__PurchaseOrder__c
                                                                              WHERE  Id=:poIds]);
        
        for(gii__PurchaseOrder__c objPOR:lstPOR){
            objPOR.giic_IntegrationStatus__c=System.Label.giic_IntegrationStatusFailure;
            objPOR.giic_IntegrationOperation__c='Update';
        }
        if(Schema.sObjectType.gii__PurchaseOrderReceipt__c.isUpdateable()){update lstPOR;}
    }
    /**
* @author FirstName : Shubee Tyagi-Shubee.Tyagi@fujitsu.com
* @date 22/08/2019
* @description setPOReceiptStatus- To Change the status of PO Receipt
* @param Set of Purchase Order Receipt Ids
*/ 
    public static void setPOReceiptStatus(Set<Id> porIds){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN setPOReceiptStatus  '); 
        List<gii__PurchaseOrderReceipt__c> lstPOR= new List<gii__PurchaseOrderReceipt__c>( [SELECT Id,Name,giic_IntegrationStatus__c,giic_IntegrationOperation__c,	
                                                                                            gii__TotalPurchaseOrderReceiptLines__c,giic_TargetSystem__c 
                                                                                            FROM gii__PurchaseOrderReceipt__c 
                                                                                            WHERE  Id=:porIds]);
        for(gii__PurchaseOrderReceipt__c objPOR:lstPOR){
            objPOR.giic_IntegrationStatus__c=System.Label.giic_IntegrationStatusSuccess;
            objPOR.giic_IntegrationOperation__c=System.Label.giic_IntegrationOperationCreate;
            objPOR.giic_TargetSystem__c=System.Label.giic_TargetSystemGlovia;
        }
        if(Schema.sObjectType.gii__PurchaseOrderReceipt__c.isUpdateable()){update lstPOR;}
    }
    /**
* @author FirstName : Shubee Tyagi-Shubee.Tyagi@fujitsu.com
* @date 22/08/2019
* @description createErrorLogs- To create error in case of PO Receipt and Receipt Line creation
* @param Object of Giic_POReceiptCreationApi.ParamsWrapper,List of Purchase Order Id
*/ 
    public static list<giic_ErrorLog__c>  createErrorLogs(Giic_POReceiptCreationApi.ParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN createErrorLogs  '); 
        List<string> errorsTmplst = new List<String>();
        for(Giic_POReceiptCreationApi.ErrorList objError : params.response.errorList){
            String error=objError.errorMsg;
            errorsTmplst.add(error);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'pOID'+params.pOID);
        if(!errorsTmplst.isEmpty() && !params.pOID.isEmpty() ){
            params.errorLogsList.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper('Purchase Order Receipt',new map<string,object>{'giic_PurchaseOrder__c'=>params.pOID[0]},
                                                                                                                       'Purchase Order Receipt Creation',string.join(errorsTmplst,'\'n\''))));
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.errorLogsList =  '+params.errorLogsList); 
        return params.errorLogsList;
    }
    /**
* @author FirstName : Shubee Tyagi-Shubee.Tyagi@fujitsu.com
* @date 22/08/2019
* @description createErrorLogs- To create error in case of PO Receipt and Receipt Line creation
* @param Object of Giic_POReceiptCreationApi.ParamsWrapper,List of Purchase Order Id
*/ 
    public static Giic_POReceiptCreationApi.ParamsWrapper  checkPOandPOL( Giic_POReceiptCreationApi.ParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN checkPOandPOL  '); 
        List<Giic_POReceiptCreationApi.ErrorList> errorList;
        errorList = params.response.errorList != null ? params.response.errorList : new List<Giic_POReceiptCreationApi.ErrorList>();
        for(gii__PurchaseOrderLine__c objPOL:params.mapPurchaseOrderLines.values()){
            if(objPOL.gii__PurchaseOrder__r.gii__OrderStatus__c==System.Label.giic_StatusClosed || objPOL.gii__LineStatus__c==System.Label.giic_Received){
                Giic_POReceiptCreationApi.ErrorList error = new Giic_POReceiptCreationApi.ErrorList();
                error.errorMsg=System.Label.giic_IntegrationPOReceiptError;
                errorList.add(error);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'errorList'+errorList);
                params.response.errorList=errorList;
                params.response.IsSuccess = false;
            }
            if(objPOL.gii__Product__r.gii__SerialControlled__c){
                system.debug('@@@@ dentro seial contrlled');
                for(PurchaseOrderHeader purchaseOrderHeader : params.listPurchaseOrderHeader){
                    for(PurchaseOrderLine pol : purchaseOrderHeader.purchaseOrderLinelist){ 
                        if(objPOL.id == pol.purchaseOrderLineId && (pol.assignedSerials == null || pol.assignedSerials.isEmpty())){ 
                            Giic_POReceiptCreationApi.ErrorList error = new Giic_POReceiptCreationApi.ErrorList();
                            error.errorMsg= 'Missing serials number';
                            errorList.add(error);
                            XC_UTIL_Debug.debug(DEBUGACTIVE,'errorList'+errorList);
                            params.response.errorList=errorList;
                            params.response.IsSuccess = false;
                        }
                    }
                }
            }else if(objPOL.gii__Product__r.gii__LotControlled__c){
                system.debug('@@@@ dentro lot contrlled');
                for(PurchaseOrderHeader purchaseOrderHeader : params.listPurchaseOrderHeader){
                    for(PurchaseOrderLine pol : purchaseOrderHeader.purchaseOrderLinelist){ 
                        if(objPOL.id == pol.purchaseOrderLineId && (pol.assignedLots == null || pol.assignedLots.isEmpty())){  
                            Giic_POReceiptCreationApi.ErrorList error = new Giic_POReceiptCreationApi.ErrorList();
                            error.errorMsg= 'Missing lots number';
                            errorList.add(error);
                            XC_UTIL_Debug.debug(DEBUGACTIVE,'errorList'+errorList);
                            params.response.errorList=errorList;
                            params.response.IsSuccess = false;
                        }
                    }
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'END checkPOandPOL  '+params); 
        return params;
    }
    /**
* @author FirstName : Shubee Tyagi
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description Giic_POReceiptCreationApi – Wrapper class for Purchase Order
*/   
    Public class PurchaseOrderHeader {
        Public Id purchaseOrderId{
            get;
            set;
        }
        Public String deliveryId{
            get;
            set;
        }
        Public Date deliveryDate{
            get;
            set;
        }
        Public Date receiptDate{
            get;
            set;
        }
        Public List<Giic_POReceiptCreationApi.PurchaseOrderLine> purchaseOrderLinelist{
            get;
            set;
        }
        public Boolean qualityNoteRequire{
            get;
            set;
        }
        public Boolean qualityCheckFail{
            get;
            set;
        }
        public Date arrivalMaterial{
            get;
            set;
        }
        public String qualityNote{
            get;
            set;
        }
    }
    /**
* @author FirstName : Shubee Tyagi
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description Giic_POReceiptCreationApi – Wrapper class for Purchase Order Line
*/   
    Public class PurchaseOrderLine {
        Public Id purchaseOrderLineId{
            get;
            set;
        }
        Public Decimal receiptQuantity{
            get;
            set;
        }
        Public List<Giic_POReceiptCreationApi.AssignedSerial> assignedSerials{
            get;
            set;
        }
          Public List<Giic_POReceiptCreationApi.AssignedLot> assignedLots{
            get;
            set;
        }
    }
    /**
* @author FirstName : Shubee Tyagi
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description Giic_POReceiptCreationApi – Wrapper class for Assigned Serials
*/   
    Public class AssignedSerial{
        Public String serialNumber{
            get;
            set;
        }}
    
    
    Public class AssignedLot{
        Public String LotNumber{
            get;
            set;
        }
        Public Integer LotQuantity{
            get;
            set; 
        }
    }
    
    
    Public class POReceiptResponse{
        Public Boolean isSuccess{
            get;
            set;
        }
        Public List<ErrorList> errorList{
            get;
            set;
        }}
    
    
    Public class ErrorList {
        Public String errorMsg{
            get;
            set;
        }}
    
    /**
* @author FirstName : Shubee Tyagi
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description Giic_POReceiptCreationApi – Wrapper class for Prameter list
*/
    public class ParamsWrapper{
        Public Set<Id> purchaseOrderReceiptId = new Set<Id>();
        Public Map<Id,List<Giic_POReceiptCreationApi.AssignedSerial>> productRequireSerialListMap= new  Map<Id,List<Giic_POReceiptCreationApi.AssignedSerial>>();
        Public map<string,gii__ProductSerial__c> mapProductSerial= new map<string,gii__ProductSerial__c>();
        Public Map<Id,Decimal> mapPOLIdandqty= new Map<Id,Decimal>();
        Public List<Id> pOID = new List<Id>();
        Public List<gii__PurchaseOrderReceipt__c> listPurchaseOrderReceipt = new List<gii__PurchaseOrderReceipt__c>();
        Public List<gii__PurchaseOrderReceiptLine__c> listpoReceiptLine = new List<gii__PurchaseOrderReceiptLine__c>();
        Public Giic_POReceiptCreationApi.POReceiptResponse response = new Giic_POReceiptCreationApi.POReceiptResponse();
        Public  list<giic_ErrorLog__c> errorLogsList = new list<giic_ErrorLog__c>();
        Public map<id,gii__PurchaseOrderLine__c> mapPurchaseOrderLines;
        Public Set<Id> lstPOtoUpdate= new Set<Id>();
        List<Giic_POReceiptCreationApi.PurchaseOrderHeader> listPurchaseOrderHeader = new List<Giic_POReceiptCreationApi.PurchaseOrderHeader>();
        Public Map<Id,List<Giic_POReceiptCreationApi.AssignedLot>> productRequireLotListMap= new  Map<Id,List<Giic_POReceiptCreationApi.AssignedLot>>();
        Public map<string,gii__ProductLot__c> mapProductLot= new map<string,gii__ProductLot__c>();
    }
}