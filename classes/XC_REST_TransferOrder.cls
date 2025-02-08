/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 30/08/2019
* @description Class of future methods for asynchronous calls about Transfer Order
*/
public without sharing class XC_REST_TransferOrder { 
    
    // INNER QUEABLE CLASS CREATE TO ON 3PL
    public class callSendCreateTO3PLQueuable implements Queueable, Database.AllowsCallouts{
        List<Id> recordIDs = new List<Id>() ;
        
        public callSendCreateTO3PLQueuable(List<Id> recordIDs){
            this.recordIDs = recordIDs;
        }
        
        public void execute(QueueableContext context) {
            sendCreateTransferOrder3PL(this.recordIDs);
        }
    }
      /**
    * @author Roberta Porrega - roberta.porrega@nttdata.com 
    * @date Creation 30/08/2019
    * @description method for sending a Purchase Order to SAP Procurement System
    * @param recordID is the Id of the Object
    */  
    public static void callSendCreateTransferOrder3PL(List<Id> recordIDs){ 
          System.enqueueJob(new callSendCreateTO3PLQueuable(recordIDs));    
    }
    
    /**
     * sendCreateTransferOrder3PL
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @date Creation 30/08/2019
     * @description method for sending a Transfer Order to 3PL System
     * @param recordID is the Id of the Object
     */ 
 //   @future(callout=true)
    public static void sendCreateTransferOrder3PL(List<Id> recordID){ //
        List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c>();
        /* NR1923 add in the query new field for4PL */
        //giic_PartnerGRGIF__c,giic_ShipFromAddress__c,giic_ShipFromProvince__c,giic_ShipFromZipCode__c,giic_ShipFromCity__c,giic_ShipFromCountry__c,gii__FromWarehouse__r.gii__Account__r.name
    
        List<gii__TransferOrder__c> trasferOrderList = new List<gii__TransferOrder__c>([SELECT Id,giic_LegalEntity__c, gii__Account__r.Name ,gii__FromWarehouse__r.giic_WarehouseCode__c,
                                                                                        gii__TransferToWarehouse__r.giic_WarehouseCode__c,gii__OrderDate__c,gii__RequiredDate__c,
                                                                                        gii__ShipToZipPostalCode__c,gii__ShipToStreet__c,gii__ShipToState__c,gii__ShipToName__c,
                                                                                        gii__ShipToCity__c,gii__ShipToCountry__c,Name,giic_status__c,giic_TransferOrderType__c,
                                                                                        gii__Account__r.Phone,gii__Account__r.PrimaryEmail__c, gii__FromWarehouse__r.giic_WarehouseType__c,
                                                                                        gii__FromWarehouse__r.giic_ServerSystem__c,
                                                                                        gii__FromWarehouse__r.giic_ParentWarehouse__r.giic_ServerSystem__c,
                                                                                        gii__TransferToWarehouse__r.giic_WarehouseType__c,
                                                                                        gii__TransferToWarehouse__r.giic_ServerSystem__c,
                                                                                        giic_PartnerGRGIF__c,gii__FromWarehouse__r.gii__Account__r.name,
                                                                                        giic_ShipFromAddress__c,giic_ShipFromProvince__c,giic_ShipFromZipCode__c,giic_ShipFromCity__c,giic_ShipFromCountry__c,
                                                                                        gii__Account__r.XC_AccountPhonePrefix__c, gii__Account__r.XC_AccountPhone__c, gii__Account__r.XC_MainPhonePrefix__c, gii__Account__r.XC_AccountMainPhone__c, // NR2415
                                                                                        (SELECT ID, gii__Quantity__c,gii__Product__r.gii__ProductReference__r.Name,
                                                                                         gii__Product__r.gii__ProductCode__c ,gii__RequiredDate__c,Name,
                                                                                         gii__Product__r.giic_EANReference__c,gii__Product__r.giic_SKUCode__c
                                                                                         FROM gii__TransferOrderLines__r)  
                                                                                         FROM gii__TransferOrder__c 
                                                                                         WHERE Id IN :recordID]);
        
        
        for(gii__TransferOrder__c trasferOrder : trasferOrderList){
            String serverSystem;
   
            /*giic_ConsoleIntegrationLP__c cs = giic_ConsoleIntegrationLP__c.getvalues(trasferOrder.giic_LegalEntity__c);
            system.debug('@@@@ cs:'+cs);
            if(cs!=null){if(cs.giic_ActiveConfiguration__c) {system.debug('@@@@ CS ' + cs);serverSystem = cs.giic_SendTO__c ;system.debug('@@@@ sendPO :' + cs.giic_SendTO__c );}}*/

			//NR2097
			List<giic_ConsoleIntegrationLP__c> CSList = new List<giic_ConsoleIntegrationLP__c>();
			List<giic_ConsoleIntegrationLP__c> CS_CI = giic_ConsoleIntegrationLP__c.getAll().values();
		
			for (giic_ConsoleIntegrationLP__c CSett : CS_CI) {if ((CSett.giic_LegalEntity__c == trasferOrder.giic_LegalEntity__c)&&(CSett.giic_ActiveConfiguration__c==TRUE)) {CSList.add(CSett);}}
			 if (CSList.size()>0) {
				if (CSList.size()==1) {serverSystem = CSList[0].giic_SendTO__c;}
                else {
					for (giic_ConsoleIntegrationLP__c C : CSList) {if (trasferOrder.gii__FromWarehouse__r.giic_ServerSystem__c==C.giic_TOWH__c) {serverSystem = C.giic_TOWH__c;}}
					if (serverSystem==null) {for (giic_ConsoleIntegrationLP__c C : CSList) {if (trasferOrder.gii__TransferToWarehouse__r.giic_ServerSystem__c==C.giic_TOWH__c) {serverSystem = C.giic_TOWH__c;}}}
					if (serverSystem==null) {for (giic_ConsoleIntegrationLP__c C : CSList) {if (C.giic_Default__c == TRUE) {serverSystem = C.giic_TOWH__c;}}}
				}
			 }            
            
            if (serverSystem == null) {
	            if(trasferOrder.gii__FromWarehouse__r.giic_WarehouseType__c == 'Central'){
    	            serverSystem = trasferOrder.gii__FromWarehouse__r.giic_ServerSystem__c; 
        	    }
            
            	if(trasferOrder.gii__TransferToWarehouse__r.giic_WarehouseType__c == 'Central' && serverSystem == null ){
                	serverSystem = trasferOrder.gii__TransferToWarehouse__r.giic_ServerSystem__c; 
            	}
           		if(trasferOrder.gii__FromWarehouse__r.giic_WarehouseType__c == 'Local' && serverSystem == null ){
                	serverSystem = trasferOrder.gii__FromWarehouse__r.giic_ParentWarehouse__r.giic_ServerSystem__c; 
            	}
            	if(serverSystem == null ){
                
                	populateErrorLogList(trasferOrder, errorLogList);
               
                	continue; 
            	}
            }
            XC_REST_TransferOrder_Inbound_U.RequestWrapper requestWR = new XC_REST_TransferOrder_Inbound_U.RequestWrapper();
            XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper transferWR = new XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper(); 
            List<XC_REST_TransferOrder_Inbound_U.ItemsWrapper> transfeItemWR = new List<XC_REST_TransferOrder_Inbound_U.ItemsWrapper>();
            /* NR1923 */
            List<XC_REST_TransferOrder_Inbound_U.addressWrapper> lstToAddr = new List<XC_REST_TransferOrder_Inbound_U.addressWrapper>();
            XC_REST_TransferOrder_Inbound_U.addressWrapper toAddr = new  XC_REST_TransferOrder_Inbound_U.addressWrapper();
            //end NR1923
              
            transferWR.account_name = trasferOrder.gii__Account__r.Name ;
            transferWR.from_warehouse_code = trasferOrder.gii__FromWarehouse__r.giic_WarehouseCode__c ;
            transferWR.to_warehouse_code = trasferOrder.gii__TransferToWarehouse__r.giic_WarehouseCode__c;
            transferWR.order_date = trasferOrder.gii__OrderDate__c;
            transferWR.required_date =  trasferOrder.gii__RequiredDate__c;
            transferWR.ship_postal_code =  trasferOrder.gii__ShipToZipPostalCode__c;
            transferWR.ship_street = trasferOrder.gii__ShipToStreet__c;
            transferWR.ship_state = trasferOrder.gii__ShipToState__c;
            transferWR.ship_name = trasferOrder.gii__ShipToName__c;
            transferWR.ship_country = trasferOrder.gii__ShipToCountry__c;
            transferWR.ship_city = trasferOrder.gii__ShipToCity__c;
            transferWR.to_id = trasferOrder.ID;
            transferWR.to_number =  trasferOrder.Name;
            transferWR.status  =  trasferOrder.giic_status__c;
            transferWR.transfer_order_type =  trasferOrder.giic_TransferOrderType__c;
            transferWR.ship_email =  trasferOrder.gii__Account__r.PrimaryEmail__c;
            //transferWR.ship_primary_phone =  trasferOrder.gii__Account__r.Phone;
            /** start NR2415 */
            String primaryPhonePrefix = trasferOrder.gii__Account__r.XC_AccountPhonePrefix__c != null ? trasferOrder.gii__Account__r.XC_AccountPhonePrefix__c : '';
            String primaryPhone = trasferOrder.gii__Account__r.XC_AccountPhone__c != null ? trasferOrder.gii__Account__r.XC_AccountPhone__c : '';
            String secondaryPhonePrefix = trasferOrder.gii__Account__r.XC_MainPhonePrefix__c != null ? trasferOrder.gii__Account__r.XC_MainPhonePrefix__c : '';
            String secondaryPhone = trasferOrder.gii__Account__r.XC_AccountMainPhone__c != null ? trasferOrder.gii__Account__r.XC_AccountMainPhone__c : '';
            transferWR.ship_primary_phone = primaryPhonePrefix + primaryPhone;
            transferWR.ship_secondary_phone = secondaryPhonePrefix + secondaryPhone;
            /** end NR2415 */

            /** start NR1923 */
            transferWR.Partner_GI_GR_Required = trasferOrder.giic_PartnerGRGIF__c;
            toAddr.Ship_from_name = trasferOrder.gii__FromWarehouse__r.gii__Account__r.name;
            toAddr.Ship_from_address= trasferOrder.giic_ShipFromAddress__c;
            toAddr.Ship_from_Province =trasferOrder.giic_ShipFromProvince__c;
            toAddr.Ship_from_zip_code=trasferOrder.giic_ShipFromZipCode__c;
            toAddr.Ship_from_City= trasferOrder.giic_ShipFromCity__c;
            toAddr.Ship_from_Country= trasferOrder.giic_ShipFromCountry__c;
            lstToAddr.add(toAddr);
            transferWR.ship_from= lstToAddr;
             /** end  NR1923 */  
            
            // transferWR.ship_secondary_phone  =  trasferOrder[0].
            for(gii__TransferOrderLine__c tol : trasferOrder.gii__TransferOrderLines__r ){
                XC_REST_TransferOrder_Inbound_U.ItemsWrapper tolWR = new XC_REST_TransferOrder_Inbound_U.ItemsWrapper();
                tolWR.quantity = (Integer)tol.gii__Quantity__c;
                tolWR.description = tol.gii__Product__r.gii__ProductReference__r.Name;
                tolWR.product_code = tol.gii__Product__r.gii__ProductCode__c  ;
                tolWR.required_date = tol.gii__RequiredDate__c;
                tolWR.tol_id = tol.Id; 
                tolWR.tol_number = tol.Name; 
                tolWR.ean_code = tol.gii__Product__r.giic_EANReference__c;
                tolWR.sku_code = tol.gii__Product__r.giic_SKUCode__c;
                transfeItemWR.add(tolWR);
            }  
            
            transferWR.items = transfeItemWR;
            requestWR.transfer_order = transferWR;
            
            XC_REST_TransferOrder_Inbound_U.ResponseWrapper response = createTransferOrderOutbound(requestWR,serverSystem );
            if(response.result!= null && response.result.error_code == '0'){
                trasferOrder.giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess; 
            }else{
                trasferOrder.giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
                giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                errorLog.Name = Label.giic_ErrorLogIntegration;
                errorLog.giic_TransferOrder__c = trasferOrder.Id;
                errorLog.giic_Process__c = 'Integration 3PL';//Label.giic_ErrorLogIntegration;
                String message = response.result != null ? response.result.message : 'Error Integration';
                errorLog.giic_ErrorDescription__c = serverSystem + '   Integration Error:  ' +  message;  
                errorLogList.add(errorLog);
            }   
        } 
        XC_UTIL_Sobject.insertListRecords(errorLogList); 
        XC_UTIL_Sobject.updateListRecords(trasferOrderList);
        
    }

    /**
     * createTransferOrderOutbound
     * @author Simone Trenta - strenta@deloitte.it
     * @date Creation 17/02/2020
     * @description method for sending a Transfer Order 
     * @param requestWrapper the request
     * @param serverSystem the server system (LogisticPartner, Redsla, Sirkus)
     * @return the response
     */ 
    public static XC_REST_TransferOrder_Inbound_U.ResponseWrapper createTransferOrderOutbound(XC_REST_TransferOrder_Inbound_U.RequestWrapper requestWrapper, String serverSystem){
        XC_REST_TransferOrder_Inbound_U.ResponseWrapper result = new XC_REST_TransferOrder_Inbound_U.ResponseWrapper();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('TransferOrder'); 
        if(isActiveInterface.activeInterface){

            String url = isActiveInterface.url;
           
            String body = JSON.serialize(requestWrapper, true);
            System.debug('[TransferOrderOutbound] request body -> ' + body); 
     
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'TransferOrder', serverSystem);

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            System.debug('[TransferOrderOutbound] request -> ' + request);

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'TransferOrder');

            System.debug('[TransferOrderOutbound] response -> ' + response);

            /********************* Parse response ********************************************/
            System.debug('[TransferOrderOutbound] response body -> ' + response.getBody());
    
            try {
                result = (XC_REST_TransferOrder_Inbound_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_TransferOrder_Inbound_U.ResponseWrapper.class);

            } catch(Exception e){
                XC_UTIL_Debug.debug(true, 'Error: '+e);

            }
          
        } else {
            result.result.message = 'Inactive Interface';
            result.result.error_code = '500';

        }

        System.debug('[TransferOrderOutbound] result -> ' + result);

        return result;
    }
    
    
    public static void populateErrorLogList(gii__TransferOrder__c trasferOrder,List<giic_ErrorLog__c> errorLogList){
                trasferOrder.giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure;
                giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                errorLog.Name = Label.giic_ErrorLogIntegration;
                errorLog.giic_TransferOrder__c = trasferOrder.Id;
                errorLog.giic_Process__c = 'Integration 3PL';//Label.giic_ErrorLogIntegration;
                String message = 'Integration Server System is not defined';
                errorLog.giic_ErrorDescription__c = 'Integration Error:  ' +  message;  
                errorLogList.add(errorLog);
    }

}