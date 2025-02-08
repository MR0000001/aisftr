/**
* @author FSL Team - marco.rosa@nttdata.com
* @date Creation 05/06/2020
* @description  – XC_UTIL_FSLLogistic  - Util class to call Glovia services 
*/ 

public without sharing class XC_UTIL_FSLLogistic {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_FSLLogistic');

    /** @description InputSelfCallout */
    public class InputSelfCallout {
        public String operation = '';
        public List<WorkOrder> listWorkOrder = new List<WorkOrder>();
        public ID recordID;
        public List<String> sapTypeFilters = new List<String>();
        public String workOrderId;
        public String zipCode;
        public String workTypeId;
        public String currentUserPartnerId;
        public String legalEntity;
        public String productCategory;
        public String userType = '';
        public List<String> productReferenceId = new List<String>();
        public Boolean applyCoverageFilterInBooking = false;

        public List<ProductRequired> listProductRequired = new List<ProductRequired>();
        public List<ParamGetGloviaProductReference> prGlovia = new List<ParamGetGloviaProductReference>();
        public XC_UTIL_TechnicalCart.paramToGloviaSO wrapperToGloviaSO;
        public List<Giic_GoodsIssueSO.SalesOrder> wrapperToGloviaGoodIssueSO;
        public List<WorkOrderLineItem> listWOLI;
        public String warehouse;
        public String woliRT;
        public Map<String,String> searchFilters;
        public List<String> priceBookentryId = new List<String>(); 
        public List<String> warehouseIdList = new List<String>();

        public WorkOrder inputWorkOrder = new WorkOrder();

    }

    /**
    * @author Patrizia Arcidiacono -
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description // wrapper class with @AuraEnabled and {get;set;} properties
    */
    public class ParamGetGloviaProductReference{

        public String Id;
        /** @description The contract id. */
        public string productReferenceId;
        /** @description The contract id. */


    }

    /** @description OutputSelfCallout */
    public class OutputSelfCallout {
        public String message = '';
        public Boolean success = false;
        //START FOR OUTPUT createSalesOrderFromConfig
        public List<String> errorMessageList = new List<String>();
        public String fSLWorkOrderLineItem;
        public List<Giic_CommonWrapper.ProductAvailability> lstProductAvailability = new List<Giic_CommonWrapper.ProductAvailability>();
        //END FOR OUTPUT createSalesOrderFromConfig
        //START FOR OUTPUT createSalesOrder
        public XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
        //END FOR OUTPUT creatfeSalesOrder
        //START FOR OUTPUT checkAvailability
        public XC_UTIL_EligibleServiceResource.EligibleWrapper eligibleWrapper = new XC_UTIL_EligibleServiceResource.EligibleWrapper();
        //END FOR OUTPUT checkAvailability
        //START FOR OUTPUT getGloviaProductMapping
        public List<GloviaProduct> gloviaMaterialProduct = new List<GloviaProduct>();
        public List<GloviaProduct> gloviaServiceProduct = new List<GloviaProduct>();
        public List<GloviaProduct> gloviaProductReference = new List<GloviaProduct>();
        public Map<Id, Id>         mapWorkOrderIdWarehouseId = new Map<Id, Id>();
        public Map<String,XC_UTIL_ReadGloviaInfoODA.PricebookEntryWrapper>  pricebookEntryRecordWrapper = new Map<String,XC_UTIL_ReadGloviaInfoODA.PricebookEntryWrapper>();
        public Map<String,WarehouseWrapper> warehouseWrappers = new Map<String,WarehouseWrapper>();
        public XC_UTIL_ResultWrapper resultWrapperUtil = new XC_UTIL_ResultWrapper();
        //END FOR OUTPUT getGloviaProductMapping
    }

    /** @description GloviaProduct */
    public class GloviaProduct{
        public String id;
        public String productReference;
        public String name;
        public String sapType;
        public String type;
        public String averagePrice;
        public String currencyIsoCode;
        public Boolean serialControlled;
        public String productCode;
        public String country;
        public String family;
        public String description;
        public List<GloviaPriceBookEntry> priceBookEntries = new List<GloviaPriceBookEntry>();
    }

    /** @description GloviaPriceBookEntry */
    public class GloviaPriceBookEntry{
        public String id;
        public String Name;
        public String priceBook;
        public String unitPrice;
        public String currencyIsoCode;
        public String positionCode;
        public String positionName;
    }

    public class WarehouseWrapper{
        public String recordId;
        public String warehouseCode;
        public String warehouseName;
        public String provinceCoverage;
        public String legalEntity;
        
        public String wareHouseCity;
        public String wareHouseCountry;
        public String wareHouseStateProvince;
        public String wareHouseStreet;
        public String wareHouseZipPostalCode;

    }

    /**
    * @description 
    * @author FSL Team - marco.rosa@nttdata.com
    * @param  orderID - ID 
    * @return giic_CommonWrapper.OrderResponse 
    **/
    public static giic_CommonWrapper.OrderResponse createSalesOrderFromConfig(ID orderID){
        InputSelfCallout wrapper = new InputSelfCallout();
        wrapper.recordID = orderID;
        wrapper.operation = 'createSalesOrderFromConfig';
        List<UserPackageLicense> listUser = new List<UserPackageLicense>([
            SELECT UserId 
            FROM UserPackageLicense 
            WHERE PackageLicense.NamespacePrefix = 'gii' AND UserId = :UserInfo.getUserId()
        ]);
        giic_CommonWrapper.OrderResponse responseWrapper = new giic_CommonWrapper.OrderResponse();
        if(!listUser.isEmpty() && !Test.isRunningTest()) {
            responseWrapper = XC_UTIL_WOCreateSalesOrder.createSalesOrderFromConfig(orderID);
        } else {
            OutputSelfCallout response = calloutGlovia(wrapper);
            responseWrapper.errorMessages = response.errorMessageList;
            responseWrapper.lstProductAvailability = response.lstProductAvailability;
        }
        return responseWrapper;
    }

    /**
    * @description 
    * @author FSL Team - marco.rosa@nttdata.com
    * @param  listNew - List<WorkOrder>
    * @return XC_UTIL_Sobject.WrapperResult 
    **/
    public static XC_UTIL_Sobject.WrapperResult createSalesOrder(List<WorkOrder> listNew){
        XC_UTIL_Sobject.WrapperResult responseWrapper = new XC_UTIL_Sobject.WrapperResult();
        InputSelfCallout wrapper = new InputSelfCallout();
        wrapper.listWorkOrder = listNew;
        wrapper.operation = 'createSalesOrder';
        XC_UTIL_Sobject.WrapperResult wrResult = new XC_UTIL_Sobject.WrapperResult();
        if(checkIntegrationUser() && !Test.isRunningTest()) {
            wrResult = XC_UTIL_WOCreateSalesOrder.createSalesOrder(listNew);
        } else {
            wrResult = calloutGlovia(wrapper).wrapperResult;
        }
        return wrResult;
    }

    /**
    * @description 
    * @author FSL Team - salvatore.scarpato@nttdata.com
    * @param  listNew - List<WorkOrder>
    * @return XC_UTIL_Sobject.WrapperResult 
    **/
    public static XC_UTIL_Sobject.WrapperResult cancelSalesOrder(WorkOrder wo){
        XC_UTIL_Sobject.WrapperResult responseWrapper = new XC_UTIL_Sobject.WrapperResult();
        InputSelfCallout wrapper = new InputSelfCallout();
        wrapper.inputWorkOrder = wo;
        wrapper.operation = 'cancelSalesOrder';
        XC_UTIL_Sobject.WrapperResult wrResult = new XC_UTIL_Sobject.WrapperResult();
        if(checkIntegrationUser() && !Test.isRunningTest()) {
            wrResult = XC_UTIL_WOCreateSalesOrder.cancelSalesOrder(wo);
        } else {
            wrResult = calloutGlovia(wrapper).wrapperResult;
        }
        return wrResult;
    }

    /**
    * @description
    * @author FSL Team - marco.rosa@nttdata.com
    * @param woID - ID
    * @return XC_UTIL_Sobject.WrapperResult
    **/
    public static XC_UTIL_Sobject.WrapperResult createSalesOrderDelivery(Id woID){
        InputSelfCallout wrapper = new InputSelfCallout();
        wrapper.recordID = woID;
        wrapper.operation = 'createSalesOrderDelivery';       
        XC_UTIL_Sobject.WrapperResult wrResult = new XC_UTIL_Sobject.WrapperResult();
        if(checkIntegrationUser() && !Test.isRunningTest()) {
            wrResult = XC_UTIL_WOCreateSalesOrder.createSalesOrderDelivery(woID);
        } else {
            wrResult = calloutGlovia(wrapper).wrapperResult;
        }
        return wrResult;
    }

    /**
    * @description 
    * @author FSL Team - marco.rosa@nttdata.com
    * @param workOrderId - String
    * @param zipCode - String
    * @param workTypeId - String
    * @param currentUserPartnerId - String
    * @return XC_UTIL_EligibleServiceResource.EligibleWrapper
    **/
    public static XC_UTIL_EligibleServiceResource.EligibleWrapper checkAvailability(String workOrderId, String zipCode, String workTypeId, String currentUserPartnerId){
        XC_UTIL_EligibleServiceResource.EligibleWrapper eligibleWrapper = new XC_UTIL_EligibleServiceResource.EligibleWrapper();
        InputSelfCallout wrapper = new InputSelfCallout();
        wrapper.workOrderId = workOrderId;
        wrapper.zipCode = zipCode;
        wrapper.workTypeId = workTypeId;
        wrapper.currentUserPartnerId = currentUserPartnerId;
        wrapper.operation = 'checkAvailability';
        List<WorkOrder> listWo = new List<WorkOrder>([
            SELECT Id, XC_ApplyCoverageFilterInBooking__c
            FROM WorkOrder
            WHERE Id = :workOrderId
        ]);
        wrapper.applyCoverageFilterInBooking = listWo[0].XC_ApplyCoverageFilterInBooking__c;
        OutputSelfCallout response = calloutGlovia(wrapper);
        eligibleWrapper = response.eligibleWrapper;
        return eligibleWrapper;
    }

    /**
    * @description 
    * @author FSL Team - salvatore.agrillo@nttdata.com
    * @param workOrder - WorkOrder
    * @param zipCode - String
    * @param workTypeId - String
    * @param currentUserPartnerId - String
    * @return XC_UTIL_EligibleServiceResource.EligibleWrapper
    **/
    public static XC_UTIL_EligibleServiceResource.EligibleWrapper checkAvailability(WorkOrder workOrder, String zipCode, String workTypeId, String currentUserPartnerId){
        XC_UTIL_EligibleServiceResource.EligibleWrapper eligibleWrapper = new XC_UTIL_EligibleServiceResource.EligibleWrapper();
        InputSelfCallout wrapper = new InputSelfCallout();
        wrapper.workOrderId = workOrder.Id;
        wrapper.zipCode = zipCode;
        wrapper.workTypeId = workTypeId;
        wrapper.currentUserPartnerId = currentUserPartnerId;
        wrapper.operation = 'checkAvailability';
        wrapper.applyCoverageFilterInBooking = workOrder.XC_ApplyCoverageFilterInBooking__c;
        List<UserPackageLicense> listUser = new List<UserPackageLicense>([
            SELECT UserId 
            FROM UserPackageLicense 
            WHERE PackageLicense.NamespacePrefix = 'gii' AND UserId = :UserInfo.getUserId()
        ]);
        if(!listUser.isEmpty() && !Test.isRunningTest()) {
            eligibleWrapper = XC_UTIL_EligibleServiceResource.checkAvailability(wrapper.workOrderId, wrapper.zipCode, wrapper.workTypeId, wrapper.currentUserPartnerId, wrapper.applyCoverageFilterInBooking);
        } else {
            OutputSelfCallout response = calloutGlovia(wrapper);
            eligibleWrapper = response.eligibleWrapper;
        }
        return eligibleWrapper;
    }

    /**
    * @description 
    * @author FSL Team - marco.rosa@nttdata.com
    * @param workOrderId - String
    * @param zipCode - String
    * @param workTypeId - String
    * @return XC_UTIL_EligibleServiceResource.EligibleWrapper
    **/
    public static XC_UTIL_EligibleServiceResource.EligibleWrapper checkAvailability(String workOrderId, String zipCode, String workTypeId){
        return checkAvailability(workOrderId, zipCode, workTypeId, '');
    }

    private static XC_UTIL_Sobject.WrapperResult getResponseWrapperResult (OutputSelfCallout response){
        XC_UTIL_Sobject.WrapperResult responseWrapper = new XC_UTIL_Sobject.WrapperResult();
        responseWrapper = response.wrapperResult;
        return responseWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 04/06/2020
     * @description Method to call Glovia with self callout
     * @param inputWrapper - InputSelfCallout
     * @return OutputSelfCallout
    */  
    public static OutputSelfCallout selfCalloutGlovia(InputSelfCallout inputWrapper) { 
        // Manage token:
        HttpRequest reqTok = XC_UTIL_RESTCallout.getTokenRequest();
        Http http = new Http();
        HttpResponse resTok = new HttpResponse();
        Map<String, Object> accessMap = new Map<String, Object>();
        if(!Test.isRunningTest()) {
            resTok = http.send(reqTok);
            accessMap = (Map<String, Object>) JSON.deserializeUntyped(resTok.getBody());
        }

        // Manage Endpoint:
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ userType ' + inputWrapper.userType);
        if((inputWrapper.woliRT!=null && (inputWrapper.woliRT.contains('B2B') || inputWrapper.woliRT.contains('B2G'))) || (inputWrapper.listWOLI != null && !inputWrapper.listWOLI.isEmpty()) || (inputWrapper.userType != '' && !inputWrapper.userType.equals('Standard'))) {
            endpoint = endpoint.contains(Label.XC_CL_PRODCommunityOrgURL) ? endpoint + '/partnercommunity' : endpoint;
        }
        endpoint += '/services/apexrest/v1/FSLLogistic';

        // Send request http:
        String tok = String.valueOf(accessMap.containsKey('access_token') ? accessMap.get('access_token') : '');
        EncodingUtil.urlEncode(endpoint,'UTF-8');
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + tok); 
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        system.debug('set Body '+JSON.serialize(inputWrapper));
        req.setBody(EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
        req.setTimeout(30000);
        System.debug('@@@@ ' + req.getEndpoint());
        HTTPResponse res = new HttpResponse();
        if(!Test.isRunningTest()) {
            res = http.send(req);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Response Body -> ' + res.getBody());

        // Parse response:
        OutputSelfCallout outputWrapper = new OutputSelfCallout();
        if(res.getStatusCode() == 200) {
            System.debug('#### res.GetBody--> '+res.getBody());
            try{
                outputWrapper = (OutputSelfCallout) JSON.deserialize(res.getBody(), OutputSelfCallout.class);
            }catch(Exception e){
                String escapedBody = res.getBody().replace('""','"').replace(':",',':"",').replace(':"}',':""}').replace('" ',' ');
                System.debug(escapedBody);
                outputWrapper = (OutputSelfCallout) JSON.deserialize(escapedBody, OutputSelfCallout.class);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Output Wrapper -> ' + outputWrapper);
            } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error Self Callout with status code '+res.getStatusCode());
        }
        return outputWrapper;
    }

    /**
     * @author FSL Team - marco.rosa@nttdata.com - salvatore.agrillo@nttdata.com - salvatore.scarpato@nttdata.com
     * @date 25/01/2021
     * @description Method to call Glovia 
     * @param inputWrapper - InputSelfCallout
     * @return OutputSelfCallout
    */  
    public static OutputSelfCallout calloutGlovia(InputSelfCallout inputWrapper) { 
        // Send request http:
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:XC_FSLLogistic/services/apexrest/v1/FSLLogistic');
        req.setMethod('POST');
        req.setBody(EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
        req.setTimeout(30000);
        System.debug('@@@@ ' + req.getEndpoint());
        HTTPResponse res = new HttpResponse();
        if(!Test.isRunningTest()) {
            res = http.send(req);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Response Body -> ' + res.getBody());

        // Parse response:
        OutputSelfCallout outputWrapper = new OutputSelfCallout();
        if(res.getStatusCode() == 200) {
            System.debug('#### res.GetBody--> '+res.getBody());
            try{
                outputWrapper = (OutputSelfCallout) JSON.deserialize(res.getBody(), OutputSelfCallout.class);
            }catch(Exception e){
                String escapedBody = res.getBody().replace('""','"').replace(':",',':"",').replace(':"}',':""}').replace('" ',' ');
                System.debug(escapedBody);
                outputWrapper = (OutputSelfCallout) JSON.deserialize(escapedBody, OutputSelfCallout.class);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Output Wrapper -> ' + outputWrapper);
            } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error Self Callout with status code '+res.getStatusCode());
        }
        return outputWrapper;
    }

    /**
     * @author FSL Team - salvatore.agrillo@nttdata.com
     * @date 27/01/2021
     * @description Method to check if current user is Integration User
     * @return Boolean
    */  
    public static Boolean checkIntegrationUser() { 
        String org = URL.getSalesforceBaseUrl().toExternalForm();
        XC_CS002_AccessToken__c accessToken;
        if((String.valueOf(org)).contains(Label.XC_DevOrgURL)) {
            accessToken = XC_CS002_AccessToken__c.getValues('DevCredential');
        } else if((String.valueOf(org)).contains(Label.XC_CIOrgURL)) {
            accessToken = XC_CS002_AccessToken__c.getValues('CICredential');
        } else if((String.valueOf(org)).contains(Label.XC_UATOrgURL) || (String.valueOf(org)).contains(Label.XC_UATComOrg)) {
            accessToken = XC_CS002_AccessToken__c.getValues('UATCredential');
        } else if((String.valueOf(org)).contains(Label.XC_CL_PRODOrgURL) || (String.valueOf(org)).contains(Label.XC_CL_PRODCommunityOrgURL)) {
            accessToken = XC_CS002_AccessToken__c.getValues('PRODCredential');
        } else if((String.valueOf(org)).contains(Label.XC_DevB2BOrgURL)){
            accessToken = XC_CS002_AccessToken__c.getValues('DevCredentialB2B');            
        } else if((String.valueOf(org)).contains('exdevhub')) {
            accessToken = XC_CS002_AccessToken__c.getValues('DevHubCredential');     
        }
        return (accessToken != null && UserInfo.getUserName() == accessToken.XC_User__c);
    }

}