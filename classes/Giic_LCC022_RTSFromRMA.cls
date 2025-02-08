/**
* @author FirstName : PATRIZIA ARCIDIACONO
* @date Creation 31/03/2020
* @date Modification dd/mm/yyyy
* @description - 
*/
public without sharing class Giic_LCC022_RTSFromRMA {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_LCC022_RTSFromRMA');
    public static map<Id, giic_RMADispositionLine__c> mapDispLine1 = new  map<Id, giic_RMADispositionLine__c>();
      
    /**xxxx
    * @author patrizia arcidiacono  - patrizia.arcidiacono@nttdata.com
    * @date Creation 01/04/2020
    * @date Modification
    * @description // wrapper class with @AuraEnabled and {get;set;} properties 
    */
     public class RTSWrapper{
        /** @description The record id. */
        @AuraEnabled
        public String rmaId{get;set;}
        /** @description The record id. */
        @AuraEnabled
        public String POonWH{get;set;}
          /** @description The record id. */
        @AuraEnabled
        public string rows{get;set;}
          /** @description The record id. */
        @AuraEnabled
        public String POFinalWH{get;set;}
          /** @description The record id. */
        @AuraEnabled
        public String reason{get;set;}
          /** @description The record id. */
        @AuraEnabled
        public String RTSFinalWH{get;set;}
       
            /** @description The record id. */
        @AuraEnabled
        public String TOFinalWH{get;set;}
           
        /** @description The record id. */
        @AuraEnabled
        public String ShipFrom{get;set;}
         
		/** @description The record id. */
        @AuraEnabled
        public String warehouseFrom{get;set;}
        /** @description The record id. */
        @AuraEnabled
        public String warehouseAccount{get;set;}
         /** @description The record id. */
        @AuraEnabled
        public String resulTOCreation{get;set;} 
          /** @description The record id. */
        @AuraEnabled
        public String resulPOCreation{get;set;}  
           /** @description The record id. */
        @AuraEnabled 
        public map<Id,giic_RMADispositionLine__c> mapdispline{get;set;} 
               /** @description The record id. */
        @AuraEnabled 
        public map<Id,xc_address__c> mapSupplierAddress{get;set;}       
      }
   
      //public List<Id> Iddisp = new List<Id>();
     
    /**
    * @author Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com 
    *@description Retrieve data needed from RMA
    *@param rmaId string
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
     public static XC_UTIL_ResultWrapper checkWHRMa(String rmaId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = false;
        rw.resultmessage ='';
        system.debug('@@@@ RMA - recordId='+rmaId);
        gii__RMA__c objRMA = [SELECT Id,giic_Status__c,gii__warehouse__r.gii__Account__r.Id, gii__warehouse__c,gii__warehouse__r.giic_ParentWarehouse__c , gii__warehouse__r.giic_WarehouseType__c FROM gii__RMA__c WHERE id=:rmaId]; 
         system.debug('@@@@ RMA - objRMA='+objRMA);
        if(objRMA != null){
                if(objRMA.giic_Status__c =='Cancelled'){
                    rw.resultMessage ='RMA status not permit to continue operation';
            		return rw;
                }
                system.debug('@@@@ RMA - if ok=');
                rw.objectInfo = objRMA.gii__warehouse__c;
                rw.fieldName = objRMA.gii__warehouse__r.giic_WarehouseType__c;
                rw.fieldName2 = objRMA.gii__warehouse__r.giic_ParentWarehouse__c;
            	rw.fieldName3 = objRMA.gii__warehouse__r.gii__Account__r.Id	;
                rw.success = true;
                system.debug('@@@@ RMA - success:' + rw.FieldName);

        }else{
            rw.resultMessage ='Not found Ship to on RMA to continue operation';
        }
        system.debug('@@@@ return');
        return rw;

        }
    
    /**
    * @author Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com 
    *@description retrieve all disposition line from RMA
    *@param rmaId string
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
     public static XC_UTIL_ResultWrapper checkOnRmaEntity(String rmaId){
        system.debug('@@@@ rmaId:' + rmaId);
         XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        map<Id,giic_RMADispositionLine__c> idToDispositionLine = new map<Id,giic_RMADispositionLine__c>(); 
        rw.success = false;
        rw.resultmessage='';
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ getPurchaseOrderLine - recordId='+rmaId);
        List<gii__RMADetail__c> rmaLine =[Select id,gii__warehouse__r.giic_WarehouseType__c  from gii__RMADetail__c where gii__RMA__c =:rmaId];
        if(rmaLine.size() < 1){ 
          rw.resultmessage ='Not RMA Line available to continue operation';
          return rw;
        }
        set<gii__RMAReceipt__c> rmaReceipt = new set<gii__RMAReceipt__c>([Select id from gii__RMAReceipt__c where gii__RMALineDetail__c in:rmaLine]);
        if(rmaReceipt.size() < 1){  
            rw.resultmessage ='Not receipt Line available to continue operation';
            return rw;
        }     
        
        // load Data Grid Disposition and dispLine creation 
        map<Id,gii__RMADisposition__c> rmaDisp = new Map<Id, gii__RMADisposition__c>(giic_LCC022_RTSFromRMA.loadRefreshDataGrid(rmaReceipt,idToDispositionLine));
        // refresh query after insert disposition Line.
        rmaDisp = giic_LCC022_RTSFromRMA.loadRefreshDataGrid(rmaReceipt,idToDispositionLine);
        
        system.debug('@@@@ rmaDisp:' + rmaDisp);
                 
        // Pass info data table to LC to start Process RTS Managment
        // Data extraction for data table
        
        if(!rmaDisp.values().isEmpty()){
              system.debug('@@@@ full Row');
              rw.success = true;
			  rw.objectInfo = JSON.serialize(rmaDisp.values());
              List<String> reasonValue = retriveReasonValues();
              rw.fieldName4 = JSON.serialize(reasonValue);
              rw.fieldName5 = JSON.serialize(idToDispositionLine);
           
        }else{
            rw.resultmessage ='No disposition Line available in scrap location or already used for RTS';
            system.debug('@@@@ empty Row');
        } 
                
        return rw;

       }
    
    /**
    * @author Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com 
    *@description Create RTS/RTSLine 
    *@param listParam string
    *@return the x C UTI L result wrapper
    */
    public static map<Id,giic_RMADispositionLine__c> convertMap(map<Id,Object> mapDispLine){ 
    	 system.debug('@@@@ mapDispLine1:' + mapDispLine); 
         Set<Id> idRMADisp = new Set<Id>();
         
         map<Id,giic_RMADispositionLine__c> mapDispLine1 = new Map<Id, giic_RMADispositionLine__c>();
         for(string key : mapDispLine.KeySet()){
            idRMADisp.add(Key);
          }    
          map<id,giic_RMADispositionLine__c> diLine = new Map<Id,giic_RMADispositionLine__c>([select Id, giic_Quantity__c,giic_Disposition_Qty__c, giic_RMADisposition__c, 
                                                                                              giic_DispositionQuantity__c from giic_RMADispositionLine__c
                                                                                              where giic_RMADIsposition__c in: idRMADisp]);
          for(giic_RMADispositionLine__c dL: diLine.values()){
                  mapDispLine1.put(dL.giic_RMADisposition__c,dL);
           }     
          return mapDispLine1;
     }
        
         
    /**
    * @author Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com 
    *@description Create RTS/RTSLine 
    *@param listParam string
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
     public static XC_UTIL_ResultWrapper createRTS(String listParam, Map<String, String> mapDispIdToQuantity, map<Id,Object> mapDispLine1){ 
        system.debug('@@@@ START Creeat RTS');
        system.debug('@@@@ TEST - ListParam:' + listParam);
        system.debug('@@@@ mapDispLine from component:' + mapDispLine1);   
        system.debug('@@@@ map Id qty insert:' + mapDispIdToQuantity);    
        map<Id, giic_RMADispositionLine__c> mapDispLine = new Map<Id, giic_RMADispositionLine__c>();
        mapDispLine = giic_LCC022_RTSFromRMA.convertMap(mapDispLine1);
         
        system.debug('@@@@ mapDispLine from deserialize size:' + mapDispLine);   
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        List<giic_RMADispositionLine__c> lineToUpdate = new List<giic_RMADispositionLine__c>();
       
         try{
            rw.success = false;
            rw.resultmessage='';
            RTSWrapper tw = new RTSWrapper();
            
            
            //Deserialize list parameter sent from LC on tw Wrapper class
            tw =(RTSWrapper)System.JSON.deserialize(listParam,RTSWrapper.class);
            system.debug('@@@@ TEST - tw.rows:' + tw.rows);
            List<Object> itemsDisp = (List<Object>)JSON.deserializeUntyped(tw.rows);
             system.debug('@@@@ TEST - itemDisp:' + itemsDisp); 
            Set<Id> disposLineId = new Set<Id>();
            for(Object item : itemsDisp){
                  String conv = String.valueOf(item);
                  system.debug('@@@@ TEST - conv:' + conv);
                  List<String> dispId = conv.split('-');
                 system.debug('@@@@ TEST - conv.split:' + conv.split('-'));
                  system.debug('@@@@ TEST - dispId[0]:' + dispId[0]);
                  disposLineId.add(dispId[0]);
                 system.debug('@@@@ TEST - after add');
                 
            }
           
            // UPSERT DISPOSITION LINE with order quantity selected from Data Grid
            for(String key : mapDispIdToQuantity.keySet()){
                System.debug('@@@@ Upsert DispositionLine key = '+key);
                if(key!=null && mapDispLine!=null && mapDispLine.containsKey(key)){
                    system.debug('@@@@ creation rts disp line exist:' + mapDispLine.get(key).Id);
                    giic_RMADispositionLine__c rmadl = new giic_RMADispositionLine__c(id=mapDispLine.get(key).Id);
                    system.debug('@@@@ Current DispositionQUantity:' + integer.valueOf(mapDispLine.get(key).giic_Disposition_Qty__c));
                     system.debug('@@@@ Current value to update on map:' + integer.valueOf(mapDispIdToQuantity.get(key)));
                    rmadl.giic_Disposition_Qty__c=integer.valueOf(mapDispLine.get(key).giic_Disposition_Qty__c) - integer.valueOf(mapDispIdToQuantity.get(key));
                    rmadl.giic_Quantity__c = Decimal.valueOf(mapDispIdToQuantity.get(key));
                   	lineToUpdate.add(rmadl);
                }                
            }
            upsert lineToUpdate;
 		
            List<giic_RMADispositionLine__c> groupedResults =[SELECT giic_SupplierRTS__c,giic_RMADisposition__r.gii__ProductSerial__r.gii__PurchaseOrder__r.gii__Supplier__c,
                                                              		 giic_RMADisposition__r.gii__ProductSerial__r.gii__Product__r.gii__SerialControlled__c,
                                                                     giic_RMADisposition__r.gii__Product__r.gii__PrimarySupplier__c,giic_RMADisposition__r.gii__Product__c,
                                                                     giic_Quantity__c, giic_DispositionQuantity__c,giic_Disposition_Qty__c, giic_ReturnToSupplier__c
                                            						 from giic_RMADispositionLine__c where 
                                         						     giic_RMADisposition__c in:disposLineId order by giic_RMADisposition__r.gii__Product__c desc];    
            
            
            system.debug('@@@@ disposLinegroupedResultsId before merge:'+ groupedResults.size()); 
             // merge line rts
            groupedResults = mergeRTSLine(groupedResults);
             system.debug('@@@@ disposLinegroupedResultsId after merge:'+ groupedResults.size());  
            Id supplierRTSId;
            string prodId;
            integer sumQuantity=0;
            gii__ReturnToSupplier__c rTS;
            if(groupedResults.size()<1){ 
                rw.success = false;
                rw.resultMessage = 'RTS creation failed!';
                return rw;
             }
			//object Logic to insert RTS RTSLINE ****************************
            set<string> sRTSkey = new set<string>();
            string rTSkey;
            map<string,gii__ReturnToSupplier__c> mapKeyRTS=new map<string,gii__ReturnToSupplier__c>();
            map<string,list<gii__ReturnToSUpplierLine__c>> mapKeyRTSLine=new  map<string,list<gii__ReturnToSUpplierLine__c>>();
            /****************************************************************/    
			map<string, id> rTSSupplDispLine = new map<string,id>();
            string keySupplRTS;
            string newProd;
            for (giic_RMADispositionLine__c ar : groupedResults)  {
                 prodId = ar.giic_RMADisposition__r.gii__Product__c;
                if(integer.valueOf(ar.giic_Quantity__c) !=0)
					sumQuantity= integer.valueOf(ar.giic_Quantity__c); 
                else
                    sumQuantity= integer.valueOf(ar.giic_Disposition_Qty__c); 
                
                //CREATE RTS for each disposition with different supplier - merge line same product serialized/supplier sum quantity
                rTSKey = ar.giic_SupplierRTS__c;
                system.debug('@@@@ CREATE RTS @@@@');
                if(!sRTSKey.contains(rTSKey)){
                   rTS = new gii__ReturnToSupplier__c(gii__ShipFrom__c=tw.RTSFinalWH, gii__Reason__c=tw.reason, 
                                                      giic_RMA__c = tw.rmaId, gii__Supplier__c=ar.giic_SupplierRTS__c);
                   gii__ReturntoSupplierLine__c rTSLine = new gii__ReturntoSupplierLine__c();
                   
                    system.debug('@@@@ CREATE RTS LINE ON RTS @@@@'); 
                   rTSLine = new gii__ReturntoSupplierLine__c (gii__OrderQuantity__c=sumQuantity, 
                                                           gii__Product__c =prodId);
 				   newProd = prodId;
                   mapKeyRTSLine.put(rTSKey,new list<gii__ReturnToSupplierLine__c>{rTSLine});
				   mapKeyRTS.put(rTSKey, rTS);
                    
                   sRTSKey.add(rTSKey);  
                   rTSSupplDispLine.put(ar.giic_SupplierRTS__c, ar.id);
 
                }else if(sRTSKey.contains(rTSKey)){
                     //    system.debug('@@@@ AddLineRTS');
                     system.debug('@@@@ CREATE RTS Line ON RTS @@@@');
                     gii__ReturntoSupplierLine__c rTSLine = new gii__ReturntoSupplierLine__c (gii__OrderQuantity__c=sumQuantity, 
                                                          gii__Product__c =prodId); 
                         
                    mapKeyRTSLine.get(rTSKey).add(rTSLine);
                       
                    newProd = ProdId;
                } 
                  
            }
                   	
            List<gii__ReturnToSupplier__c> rTSHeader =new List<gii__ReturnToSupplier__c>();
            rTSHeader.addall(mapKeyRTS.values());
            system.debug('@@@@ mapKeyRTS:' + mapKeyRTS);
             //system.debug('@@@@ RTSHeader:' + rTSHeader);
            
                      
            //Insert RTS and RTSLINE
            Database.Insert(mapKeyRTS.values());
            list<Id> lstRTSIds=new list<Id>();
            list<gii__ReturnToSupplierLine__c> lstRTSLToInsert=new list<gii__ReturnToSupplierLine__c>();
            for(string key : mapKeyRTS.keyset()){
                    lstRTSIds.add(mapKeyRTS.get(key).Id);
                    for(gii__ReturnToSupplierLine__c objRTSL : mapKeyRTSLine.get(key)){
                        objRTSL.gii__ReturnToSupplier__c=mapKeyRTS.get(key).Id;
                        lstRTSLToInsert.add(objRTSL);
                    }
            }
            database.insert(lstRTSLToInsert);
            //system.debug('@@@@ RTS List:' + lstRTSLToInsert);
                       
            // Store reference RTS parent on disposition line  
            id rtsId;
            set<Id> SetidRTS = new set<Id>();
            for(gii__ReturnToSupplier__c rtId: mapKeyRTS.values()) SetidRTS.add(rtId.Id);
            system.debug('@@@@ SetId RTS:' + SetIdRTS);
			          
            string keyRTSL;
            string prodRTSLineOld;
            string oldIdRTS;
            list<gii__ReturnToSupplierLine__c> rtLineList = [Select id ,gii__ReturnToSupplier__c, gii__OrderQuantity__c,gii__ReturntoSupplier__r.giic_RMA__c,gii__ReturnToSupplier__r.gii__ShipFrom__c, gii__Product__c, gii__ReturnToSupplier__r.gii__Supplier__c from gii__ReturnToSupplierLine__c where gii__ReturnToSupplier__c in:SetidRTS order by gii__Product__c desc];  
            system.debug('@@@@ rtLineList:' + rtLineList.size());
            map<string,Id> mapMy = new map<string,Id>();
            list<gii__ReturnToSupplier__c> rt = [select id, gii__Supplier__c from gii__ReturnToSupplier__c where id in :SetidRTS];
            
            for(gii__ReturnToSupplier__c r: rt) mapMy.put(r.gii__Supplier__c, r.Id);
            system.debug('@@@ myMap:' + mapMy);
            system.debug('@@@ myMap groupedResults:' + groupedResults.size());
            list<giic_RMADispositionLine__c> rtSupp = [select id, giic_ReturnToSupplier__c, giic_SupplierRTS__c from giic_RMADispositionLine__c where giic_RMADisposition__c in:disposLineId];
            for (giic_RMADispositionLine__c ar : rtSupp){
                system.debug('@@@ myMap contains supplier:' + ar.giic_SupplierRTS__c);
           		if(mapMy.containsKey(ar.giic_SupplierRTS__c)){
                        system.debug('@@@ myMap contains');
                        ar.giic_ReturnToSupplier__c = mapMy.get(ar.giic_SupplierRTS__c);
                        system.debug('@@@ myMap Supplier su dispLine:' + ar.id + '- value:' + ar.giic_ReturnToSupplier__c);
                       
                    }     
            }    
            update rtSupp; 
            
            system.debug('@@@@ RTSLIne:' + lstRTSLToInsert);
            rw.resultMessage ='Return To Supplier success creation!!!';
            
            // Creation PO/POLine - Create TO/TOLine
            system.debug('@@@@ TOFinal:' + tw.TOFinalWH);
            system.debug('@@@@ POFinal:' + tw.POFinalWH);
            system.debug('@@@@ warehouseFrom:' + tw.warehouseFrom);
            
           
            //Creation PO/POLine if logics return from LC Id Warehouse to do PO
            If(tw.POFinalWH !='' && tw.POFinalWH != null){ 
                //boolean resp = POCreation(rTSHeader,tw.rmaId,tw.POFinalWH, tw.TOFinalWH, tw.warehouseFrom, disposLineId,tw.warehouseAccount, groupedResults);
                boolean resp = POCreation(tw, disposLineId, groupedResults);
               
            }
             
            //Creation TO/TOLine if logics return from LC Id Warehouse to do TO
            if(tw.TOFinalWH !='' && tw.TOFinalWH != null) {
             // Create TO 
             	rw = TOCreation(rtLineList, tw);
            }     
             
            rw.success = true;
            rw.resultMessage ='Return To Supplier success creation!!!';
            
           }catch(Exception e){
                System.debug( '@@@@ Generate RTS - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
                rw.resultMessage ='Error:' + e.getMessage();              
           }   
        return rw;

         } 
        
        /**
        * @author Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com 
        *@description Create PO/POLine and TO e TOLine from RTS from disposition RMA
        *@param recordId the record id
        *@return the x C UTI L result wrapper
        */
        //public static boolean POCreation(list<Gii__ReturnToSupplier__c> rTS,string rmaId, String POFinalWH, string TOFinalWH, string ShipFrom, set<Id> disposLineId,string warehouseAccount,List<giic_RMADispositionLine__c> groupedResults){
        public static boolean POCreation(RTSWrapper tw , set<Id> disposLineId, List<giic_RMADispositionLine__c> groupedResults){
            system.debug('@@@@ START PO Creation:');
    		system.debug('@@@@ POFinalWH:'+ tw.POFinalWH);
            system.debug('@@@@ ShipFrom:'+ tw.ShipFrom);
            system.debug('@@@@ warehouseAccount:'+ tw.warehouseAccount);
            
            boolean resp = false;
            set<Id>settProductIds = new set<Id>();
            set<Id>setSupplierIds = new set<Id>();
            
            set<string> setPOKey=new set<string>();
            map<string,gii__PurchaseOrder__c> mapKeyPO=new map<string,gii__PurchaseOrder__c>();
            map<string,list<gii__PurchaseOrderLine__c>> mapKeyPOL=new  map<string,list<gii__PurchaseOrderLine__c>>();
            
            List<gii__PurchaseOrder__c> PO = new List<gii__PurchaseOrder__c>();
            List<gii__PurchaseOrderLine__c> POL= new List<gii__PurchaseOrderLine__c>();
            List<gii__ReturnToSupplierLine__c> listRMTLine = new List<gii__ReturnToSupplierLine__c>();

            map<string,list<gii__ReturnToSupplierLine__c>> mapSupplierProductSOLs=new map<string,list<gii__ReturnToSupplierLine__c>>();
			map<string,list<gii__RMADisposition__c>> mapSupplierProductDisps=new map<string,list<gii__RMADisposition__c>>();
            map<string,integer> mapDispsOrderQuantity=new map<string,integer>();
            
            try{
                
                List<gii__RMADisposition__c> dispLineSelected = [select gii__RMAreceipt__r.gii__ProductSerial__r.Name,gii__RMAReceipt__r.gii__RMA__c ,gii__Product__r.gii__SerialControlled__c,gii__RMAReceipt__r.gii__ProductSerial__c,
                                                          gii__productSerial__c,gii__warehouse__c, gii__RMAReceipt__c, gii__ProductSerial__r.gii__PurchaseOrderReceipt__r.gii__Supplier__c,
                                                          gii__Product__r.gii__PrimarySupplier__c ,gii__Product__c , gii__DispositionQuantity__c,(SELECT id,giic_RMADisposition__c,
                                                          giic_ReturnToSupplier__c,giic_SupplierRTS__c, giic_Quantity__c,giic_DispositionQuantity__c,giic_ReturntoSupplier__r.gii__Supplier__c 
                                                          FROM RMA_Disposition_Lines__r order by createddate desc) from gii__RMADisposition__c 
                                                          where id in:disposLineId];

            	system.debug('@@@@ dispLineSelected:' + dispLineSelected.size());
                system.debug('@@@@ dispLineSelected:' + dispLineSelected);
                map<Id,Id> mRTSRelPO = new map<Id,Id>();  
               
                // map to retrieve relation product supplier on pricebook
                for(gii__RMADisposition__c dispLinePO : dispLineSelected){
                    //system.debug('@@@@ idSupplier:' + dispLinePO.RMA_Disposition_Lines__r.get(0).giic_ReturntoSupplier__r.gii__Supplier__c);
                    settProductIds.add(dispLinePO.gii__Product__c);
                    setSupplierIds.add(dispLinePO.RMA_Disposition_Lines__r.get(0).giic_SupplierRTS__c);
                                    
                    //map Supplier - IdProduct
                    string key=dispLinePO.RMA_Disposition_Lines__r.get(0).giic_SupplierRTS__c +'-' +dispLinePO.gii__Product__c ;
                    system.debug('@@@@ KeyMapProduct:'+ dispLinePO.RMA_Disposition_Lines__r.get(0).giic_SupplierRTS__c +'Key:::'+key);
                    if(!mapSupplierProductDisps.containsKey(key)){
                                mapSupplierProductDisps.put(key,new list<gii__RMADisposition__c>());
                    }    
                   
                    mapSupplierProductDisps.get(key).add(dispLinePO); 
                   
                    
                }       
                system.debug('@@@@ Lista Prodotti:' + settProductIds);
                system.debug('@@@@ Lista Supplier:' + setSupplierIds);
        		
             
                system.debug('@@@@ mapSupplierProductDisps:' + mapSupplierProductDisps);
                system.debug('@@@@ mapSupplierProductDisps size:' + mapSupplierProductDisps.size());
         
                // Retrieve Pricebook to set Pricebook mandatory on PO record creation.
                List<gii__PriceBookEntry__c> lstPBE = new  List<gii__PriceBookEntry__c>();          
                List<gii__returnToSupplierLine__c> listRTSLine = new List<gii__returnToSupplierLine__c>();
                lstPBE = [SELECT id,name,giic_Default__c,gii__Product__c,gii__Product__r.gii__PrimarySupplier__c,
                                              gii__Product__r.name,gii__PriceBook__c,gii__PriceBook__r.name,
                                              gii__PriceBook__r.giic_Contract__c,gii__PriceBook__r.giic_Contract__r.AccountId,gii__PriceBook__r.giic_Contract__r.StartDate, gii__PriceBook__r.giic_Contract__r.EndDate, gii__PriceBook__r.giic_Contract__r.Status
                                              FROM gii__PriceBookEntry__c WHERE gii__Product__c IN:settProductIds 
                                              AND gii__PriceBook__r.giic_Contract__r.AccountId<>null AND gii__PriceBook__r.giic_Contract__r.AccountId in : setSupplierIds 
                                              AND giic_Default__c=true];
                
                system.debug('@@@@ Lista Pricebook:' + lstPBE);
				system.debug('@@@@ Lista Pricebook:' + lstPBE.size());
				string keyRTSforPO ='';
                integer quantity=0;
                if(lstPBE.size()>0){
                     for(gii__PriceBookEntry__c pbEntry : lstPBE){
                            string key=pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId  + '-' + pbEntry.gii__Product__c;
                            system.debug('@@@@ key for Pricebook:'+key+' - '+mapSupplierProductDisps.containsKey(key));
                            if(mapSupplierProductDisps.containsKey(key)){
                                    string serialNum;
                                    integer i =1;
                                    system.debug('@@@@ mapSupplierProductDisps.get(key):' + mapSupplierProductDisps.get(key));
                                    for(gii__RMADisposition__c objRTL : mapSupplierProductDisps.get(key)){
                                        string prodKey =objRTL.gii__Product__c;
                                        string poKey=pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId + '-'+pbEntry.gii__PriceBook__r.name; //objRTL.gii__Product__c + '-' + 
                                        system.debug('@@@@ Key PO:' + poKey);
                                        if(objRTL.gii__Product__r.gii__SerialControlled__c){
                                                quantity= integer.valueOf(objRTL.gii__DispositionQuantity__c);
                                        }else{
                                                quantity=integer.valueOf(objRTL.RMA_Disposition_Lines__r.get(0).giic_Quantity__c); 
                                        }    
                                        system.debug('@@@@ quantity PO:' + quantity);
                                        system.debug('@@@@ setPOKey:' + setPOKey);
                                        if(!setPOKey.contains(poKey)){
                                            system.debug('@@@@ Create PO @@@@');
                                            //get Id RTS from disposition Line
                                            system.debug('@@@ id Disposition;' + objRTL.Id);
                                            gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(giic_RMA__c=objRTL.gii__RMAReceipt__r.gii__RMA__c, gii__ShipTo__c = tw.POFinalWH ,gii__RequiredDate__c = system.today(),
                                                                        giic_Status__c =System.Label.giic_PODraftStatus,gii__PriceBookName__c=pbEntry.gii__PriceBook__r.name,gii__ReturntoSupplier__c=objRTL.RMA_Disposition_Lines__r.get(0).giic_returnToSupplier__c,
                                                                        giic_PriceBookId__c=pbEntry.gii__PriceBook__c,giic_Contract__c=pbEntry.gii__PriceBook__r.giic_Contract__c,gii__DropShip__c = false,
                                                                        gii__Supplier__c=pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId);
                                           
                                            gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c();
                                            system.debug('@@@@ Create POLINE1 @@@@');
                                            string keyPS = objRTL.gii__Product__c;
                                          
                                            objPOLine.giic_ProductSerial__c= objRTL.gii__RMAreceipt__r.gii__ProductSerial__r.Name;
                                            objPOLine.giic_UnderWarranty__c =true;   
                                           	objPOLine.gii__OrderQuantity__c=quantity; 
                                            objPOLine.gii__Product__c= objRTL.gii__Product__c;
                                            mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{objPOLine});
                                            mapKeyPO.put(poKey,objPO);
                                            setPOKey.add(poKey); 
                                        }else if(setPOKey.contains(poKey)){
                                            system.debug('@@@@ Create POLINE2 @@@@');
                                            serialNum = objRTL.gii__RMAreceipt__r.gii__ProductSerial__r.Name;
                                            gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= objRTL.gii__Product__c,
                                                                                                                gii__OrderQuantity__c=quantity,
                                                                                                                giic_UnderWarranty__c =true,
                                                                                                                giic_ProductSerial__c= serialNum);
                                            mapKeyPOL.get(poKey).add(objPOLine);
                                        }

                                       
                                        
                                        
                                    }
                                    system.debug('@@@@ MapPO:' + mapKeyPO);
                                    system.debug('@@@@ MapPOL:' + mapKeyPOL); 
                              }   
                     }
                  
                    list<Id> listPOinserted = new list<Id>(); 
                    listPOinserted = Giic_PurchaseOrderUtility.insertPO(mapKeyPO,mapKeyPOL);
                }
                 resp = true;
            }catch(Exception e){
                System.debug( '@@@@ Generate Error POTO - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
                
            }       
            return resp;
        }
		

    
    @AuraEnabled
    public static List<String> retriveReasonValues() {
        System.debug('entrato in retriveReasonValues');
        return XC_UTIL_Sobject.getPicklistValues('gii__RMA__c' ,  'gii__Reason__c');
    }
 	
    /**
	* @author FirstName :Patrizia Arcidiacono - patrizia.arcidiacono@nttdata.com
    * @date Creation 07/04/2020
    * @date Modification dd/mm/yyyy
    * @description loading Data Grid and disposition line creation
    * @param rmaReceipt - set RmaReceipt
    * @return map<Id,gii__RMADisposition__c>
    */    
    private static map<Id,gii__RMADisposition__c> loadRefreshDataGrid(set<gii__RMAReceipt__c> rmaReceipt, map<Id,giic_RMADispositionLine__c> idToDispositionLine){
     
        // Query Data extraction for data table Disposition and Disposition line
        Map<Id, gii__RMADisposition__c> rmaDisp = new Map<Id, gii__RMADisposition__c> ([
            Select id,gii__ProductSerial__r.gii__PurchaseOrder__r.gii__Supplier__c,gii__Warehouse__c,Name,giic_RTSQuantity__c, gii__DispositionQuantity__c,gii__ProductSerial__c,gii__ProductSerial__r.Name,gii__RMAReceipt__c,
            gii__Product__r.Name,  gii__Product__r.gii__ProductCode__c,  gii__Product__r.giic_SKUCode__c,gii__Product__r.gii__PrimarySupplier__c, gii__Warehouse__r.Name, gii__DispositionLocation__r.Name,
            gii__DispositionLocation__r.giic_LocationType__c,(SELECT id,giic_Disposition_Qty__c,giic_RMADisposition__c,giic_Quantity__c,
                                                              giic_DispositionQuantity__c FROM RMA_Disposition_Lines__r) FROM gii__RMADisposition__c 
            where gii__RMAReceipt__c in:rmaReceipt and gii__DispositionLocation__r.giic_LocationType__c != :Label.giic_LocationTypeSales 
                                                   and gii__DispositionLocation__r.giic_LocationType__c != :Label.giic_CL_VanLocation]);
		
        //system.debug('@@@@ rmaDisp:' + rmaDisp);
		list<giic_RMADispositionLine__c> lineToInsert = new list<giic_RMADispositionLine__c>();
      
        // managment visibility disposition already sent to RTS
        for(gii__RMADisposition__c rmdis : rmaDisp.values()){
            string supplierRTSId;
            if(rmdis.gii__ProductSerial__r.gii__PurchaseOrder__r.gii__Supplier__c!=null)
                supplierRTSId= rmdis.gii__ProductSerial__r.gii__PurchaseOrder__r.gii__Supplier__c;
            else
                supplierRTSId=rmdis.gii__Product__r.gii__PrimarySupplier__c;
            system.debug('@@@@ supplierRTS:' + supplierRTSId);
            
            system.debug('@@@@ read disposition/lines');
            if(!rmdis.RMA_Disposition_Lines__r.isEmpty()){
             	idToDispositionLine.put(rmdis.Id, rmdis.RMA_Disposition_Lines__r[0]);
                if(rmdis.RMA_Disposition_Lines__r[0].giic_Disposition_Qty__c ==0){
                     system.debug('@@@ remove:' + rmdis.gii__Product__r.Name);
                     rmaDisp.remove(rmdis.Id);
                 } 
             }else{
                 system.debug('@@@@ insert disposition line:');
                    giic_RMADispositionLine__c rmadl = new giic_RMADispositionLine__c();
                    rmadl.giic_RMADisposition__c = rmdis.id;
                    rmadl.giic_Disposition_Qty__c = rmdis.gii__DispositionQuantity__c;
                    rmadl.giic_Quantity__c = rmdis.gii__DispositionQuantity__c;
                    rmadl.giic_SupplierRTS__c = supplierRTSId;
                 	idToDispositionLine.put(rmdis.Id, rmadl);
                    mapDispLine1.put(rmdis.id, rmadl);
                    lineToInsert.add(rmadl);
             }    
         } 
		
		if(lineToInsert.size()>=0) insert lineToInsert; 
        return rmaDisp;
    }
        
     /**
	* @author FirstName :Patrizia Arcidiacono - patrizia.arcidiacono@nttdata.com
    * @date Creation 07/04/2020
    * @date Modification dd/mm/yyyy
    * @description merge on list extraction line RTS grouped by product serialized for Product name related same supplier primary or if it missing,
    * same supplier related on po receipt
    * @param rmaReceipt - set RmaReceipt
    * @return map<Id,gii__RMADisposition__c>
    */    
    private static List<giic_RMADispositionLine__c> mergeRTSLine(List<giic_RMADispositionLine__c> groupedResults){
   		system.debug('@@@ merge line RTS');
       	system.debug('@@@@ size iniziale:' + groupedResults.size()); 
       
        string prod='';
        decimal sum;
        string olddsupplier='';
        string olddsupplierP='';
      
        map<Id, decimal> sProdQty = new map<id, decimal>();
        set<Id> prodList = new set<Id>();
        for(giic_RMADispositionLine__c ar: groupedResults) prodList.add(ar.giic_RMADisposition__r.gii__Product__c);
        for(id Key: prodList){
              sum=0;
              for(Integer j = 0; j < groupedResults.size(); j++){
                  if(groupedResults.get(j).giic_RMADisposition__r.gii__Product__c == key) sum = sum + groupedResults.get(j).giic_Quantity__c;
                  
              } 
              sProdQty.put(Key, sum);
        }
        system.debug('@@@@ lista quanitty da inserire:' + sProdQty); 
                
        for(Integer j = 0; j < groupedResults.size(); j++){
            if(prod==string.valueOf(groupedResults.get(j).giic_RMADisposition__r.gii__Product__c) && groupedResults.get(j).giic_RMADisposition__r.gii__ProductSerial__r.gii__Product__r.gii__SerialControlled__c) {
              if((olddsupplier!='' && olddsupplier== groupedResults.get(j).giic_RMADisposition__r.gii__ProductSerial__r.gii__PurchaseOrder__r.gii__Supplier__c) ||olddSupplierP==groupedResults.get(j).giic_RMADisposition__r.gii__Product__r.gii__PrimarySupplier__c){ 
                   system.debug('@@@ removed id:' +  groupedResults.get(j).id);
                   groupedResults.remove(j);
                   j--;
              }       
            }
                   
            olddsupplierP = groupedResults.get(j).giic_RMADisposition__r.gii__Product__r.gii__PrimarySupplier__c;
            olddsupplier =groupedResults.get(j).giic_RMADisposition__r.gii__ProductSerial__r.gii__PurchaseOrder__r.gii__Supplier__c;
			prod =string.valueOf(groupedResults.get(j).giic_RMADisposition__r.gii__Product__c); 
         }
                
        system.debug('@@@@ lista fnale2 con item rimanenti:' + groupedResults.size());
                
        Id key;
        for(Integer j = 0; j < groupedResults.size(); j++){
            key =groupedResults.get(j).giic_RMADisposition__r.gii__Product__c;  
            system.debug('####### xontains:?' + sProdQty.containsKey(Key));
            system.debug('####### xontains:?' + sProdQty.get(Key));
            if(sProdQty.containsKey(Key)){
                groupedResults.get(j).giic_Quantity__c = integer.valueOf(sProdQty.get(Key));
                update groupedResults[j];
                system.debug('####### UPDATE');
            }     
            system.debug('####### product:' + groupedResults.get(j).giic_RMADisposition__r.gii__Product__c);
            system.debug('####### qty:' + groupedResults.get(j).giic_Quantity__c);
        }   
        system.debug('@@@ lista finale modifiche;' + groupedResults);
        return groupedResults;
    }
    
      /**
	* @author FirstName :Patrizia Arcidiacono - patrizia.arcidiacono@nttdata.com
    * @date Creation 07/04/2020
    * @date Modification dd/mm/yyyy
    * @description creation TO from RTS
    * same supplier related on po receipt
    * @param rmaReceipt - set RmaReceipt
    * @return map<Id,gii__RMADisposition__c>
    */    
    private static XC_UTIL_ResultWrapper TOCreation(list<gii__ReturnToSupplierLine__c> lstRTSLToInsert, RTSWrapper tw){
   		XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        map<string,gii__TransferOrder__c> mapKeyTO=new map<string,gii__TransferOrder__c>();
        map<string,list<gii__TransferOrderLine__c>> mapKeyTOL=new  map<string,list<gii__TransferOrderLine__c>>();
        list<Id> listTOinserted = new list<Id>();
        rw.Success = true;
        system.debug('@@@@@ Start process TO Creation');
        system.debug('@@@@@ TO Final WH:' + tw.TOFinalWH);
        system.debug('@@@@@ warehouse Account ' + tw.warehouseAccount);
        system.debug('@@@@@ warehouse From ' + tw.warehouseFrom);
	    try{
        	for(gii__ReturnToSupplierLine__c rTSLineTO: lstRTSLToInsert){   
                 	// if WH RMA is different from warehouse choice will be created TO 
                 	system.debug('@@@@@ Create TO'); 
                    string toKey=tw.warehouseFrom + '-'+ tw.TOFinalWH ;//+ rTSLineTO.gii__ReturntoSupplier__r.gii__Supplier__c ;
                    system.debug('@@@@ Key TO:' + toKey); 
                    if(!mapKeyTO.containsKey(toKey)){
                       //system.debug('@@@@@ no contain'); 
                        system.debug('@@@@@ Create TO @@@@');
                        gii__TransferOrder__c objTO = new gii__TransferOrder__c(giic_Source__c=Label.giic_SourceReorderPlanning,
                                                                    giic_RMA__c=rTSLineTO.gii__returnToSupplier__r.giic_RMA__c,
                                                                    gii__Account__c=tw.warehouseAccount,
                                                                    gii__FromWarehouse__c=tw.warehouseFrom,
                                                                    gii__TransferToWarehouse__c=tw.TOFinalWH,
                                                                    gii__RequiredDate__c= system.today());
                        system.debug('@@@@@ Create TO Line1 @@@@');
                        gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(gii__Product__c=rTSLineTO.gii__Product__c,
                    	gii__Quantity__c=rTSLineTO.gii__OrderQuantity__c); 
                        mapKeyTOL.put(toKey,new list<gii__TransferOrderLine__c>{objTOLine});
                        mapKeyTO.put(toKey,objTO);
                   }else{
                          system.debug('@@@@@ Create TO Line2 @@@@'); 
                       gii__TransferOrderLine__c objTOLine = new gii__transferOrderLine__c(gii__Product__c=rTSLineTO.gii__Product__c,
                                                                                 gii__Quantity__c=rTSLineTO.gii__OrderQuantity__c);
                       mapKeyTOL.get(toKey).add(objTOLine);
                   } 
                 		
		  	}
            listTOInserted = insertTO(mapKeyTO,mapKeyTOL);
             
         }catch(Exception e){
               System.debug( '@@@@ Generate create TO - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
               rw.Success = false;
               rw.resultMessage = 'Generate TO failed!! technical Details:' + e.getMessage();
         }
         return rw;
    }
    
    
        /**
		* @author FirstName :Patrizia Arcidiacono - patrizia.arcidiacono@nttdata.com
        * @date Creation 07/04/2020
        * @date Modification dd/mm/yyyy
        * @description insert Trasnfer Order and Transfer order lines
        * @param mapTO -  Map of TransferOrder
        * @param mapTOLine - Map of TransferOrderLine
        * @return list<Id>
        */    
        public static List<Id> insertTO(map<string,gii__TransferOrder__c> mapTO,map<string,list<gii__TransferOrderLine__c>> mapTOLine){
			list<Id> lstTOIds=new list<Id>();
            try{
                system.debug('@@@@ insert TO');
                system.debug('@@@@ map TO:' + mapTO);
                system.debug('@@@@ map TOLine:' + mapTOLine);
                Database.Insert(mapTO.values());

                list<gii__TransferOrderLine__c> lstTOLToInsert=new list<gii__TransferOrderLine__c>();
                for(string key : mapTO.keyset()){
                    lstTOIds.add(mapTO.get(key).Id);
                    for(gii__TransferOrderLine__c objTOL : mapTOLine.get(key)){
                        objTOL.gii__TransferOrder__c=mapTO.get(key).Id;
                        lstTOLToInsert.add(objTOL);
                    }
                }
                database.insert(lstTOLToInsert);
                system.debug('@@@@ insert:' + lstTOLToInsert);
			}catch(Exception e){
               System.debug( '@@@@ Generate create TO - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
                
            }
            return lstTOIds;
            
    	}
    
    /* @author Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com 
    *@description Retrieve address Supplier
    *@param poId string
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
     public static XC_UTIL_ResultWrapper searchAddressSupplier(String poId){
        system.debug('@@@@@ searchAddressSupplier:' + poId); 
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        try{
 	       rw.success = false;
    	   rw.resultMessage='No List Addresses found!';
           rw.objectInfo ='';
      
        	id idSupplier = [SELECT gii__supplier__c from gii__PurchaseOrder__c where id =:poId].gii__Supplier__c;
            rw.fieldName=  [SELECT gii__supplier__r.Name from gii__PurchaseOrder__c where id =:poId].gii__Supplier__r.Name;
            system.debug('@@@@ supplier:' + rw.fieldName);
        	Map<Id, xc_Address__c> mapAddress = new Map<Id, xc_address__c> ([select id, XC_account__r.Name, XC_FullAddress__c, XC_AddressProvince__c, XC_AddressCountry__c, XC_PostalCode__c, XC_City__c 
                                                                         from XC_Address__c where XC_Account__c =:idSupplier]); 
       
        	if(!mapAddress.values().isEmpty()){
            	rw.success = true;
        		rw.objectInfo= JSON.serialize(mapAddress.values());
                system.debug('@@@@ lista:' + rw.objectInfo);
                
              
            }
                
            
		}catch(Exception e){
               System.debug( '@@@@ Generate create TO - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
               rw.resultMessage = 'Error: Search list Addresses !:' + e.getMessage();
         }
         return rw;
        }
    
     /* @author Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com 
    *@description save Address supplier on PO to send 4PL
    *@param poId string
	*@param addressId string
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
     public static XC_UTIL_ResultWrapper saveAddressOnPo(String poId, string addressId){
        system.debug('@@@@@ save address on address:' + addressId); 
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        try{
 	       rw.success = false;
    	   rw.resultMessage='';
           rw.objectInfo ='';
      
           gii__purchaseorder__c objPo = [SELECT giic_ShipFromAddress__c,giic_ShipFromProvince__c,giic_ShipFromZipCode__c,giic_ShipFromCity__c,giic_ShipFromCountry__c from gii__PurchaseOrder__c where id =:poId];
            system.debug('@@@@ po:' + objPo);
           XC_Address__c objAddress =  [SELECT XC_account__r.name, XC_FullAddress__c, XC_AddressProvince__c, XC_AddressCountry__c, XC_PostalCode__c, XC_City__c from xc_address__c where id =:addressId];
           system.debug('@@@@ supplier:' + objAddress);
           objPo.giic_ShipFromName__c = objAddress.XC_account__r.name;
           objPo.giic_ShipFromProvince__c = objAddress.XC_AddressProvince__c;
           objPo.giic_ShipFromAddress__c = objAddress.XC_FullAddress__c;
           objPo.giic_ShipFromZipCode__c = objAddress.XC_PostalCode__c;
           objPo.giic_ShipFromCity__c = objAddress.XC_City__c;
           objPo.giic_ShipFromCountry__c = objAddress.XC_AddressCountry__c;
           update objPo;
           rw.success=true;
           rw.resultMessage ='Save address success!!!';
           	
		}catch(Exception e){
               System.debug( '@@@@ Generate update PO - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
               rw.resultMessage = 'Error: Save address failed !:' + e.getMessage();
         }
         return rw;
        }
    
  }