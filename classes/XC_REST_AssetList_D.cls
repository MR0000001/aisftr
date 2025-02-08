/**
 * @author             Luisana Rocco lrocco@deloitte.it
 * @date Creation       15/02/2021
 * @date Modification   dd/mm/yyyy
 * @description         XC_REST_AssetList_D – util class for Rest Resourse XC_REST_AssetList
 */

public without sharing class XC_REST_AssetList_D {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_AssetList_D');

    /**
     * getAssetListByParams.
     *
     * @param requestParams the request params
     * @param utilMap the Map<String,Object>
     * @return the list asset
     * @description method to retrieve all asset by input parameters
     */
    public static List<Asset> getAssetListByParams(Map<String, String> requestParams, Map<String,Object> utilMap){

        List<Asset> assetList = new List<Asset>();
        XC_REST_AssetList_W.WrapperResponseGET wrRes = (XC_REST_AssetList_W.WrapperResponseGET)utilMap.get('wrRes');


        Map<Id,XC_CM_PartnerAssetConfiguration__mdt> mapPartnerConfig = new Map<Id,XC_CM_PartnerAssetConfiguration__mdt>([SELECT XC_QueryLimit__c, XC_PartnerFilter__c FROM XC_CM_PartnerAssetConfiguration__mdt WHERE XC_QueryID__c =: requestParams.get('query_id') LIMIT 1]);
        if(mapPartnerConfig.isEmpty()){
            wrRes.Result.message = 'ERROR. query_id ' + Label.XC_CL_NotFount;
            wrRes.Result.logError = 'ERROR. query_id ' + Label.XC_CL_NotFount;
            wrRes.Result.error_code = '400'; 
            return new List<Asset>();
        }

        Integer queryLimit = (Integer)(mapPartnerConfig.values()[0].XC_QueryLimit__c);
        utilMap.put('queryLimit', queryLimit);

        String query =  'SELECT Id, XC_LegalEntity__c, XC_Original_Creation_Order_Lookup__r.Name, NE__Order_Config__r.Name, ExternalId__c, Name, NE__CatalogItem__r.NE__UsageCode__c, ' + 
                        'status, PurchaseDate, XC_ContractStartDate__c, XC_AnnualRenewalDateIndex__c, XC_ContractEndDate__c, XC_DisconnectionDate__c, XC_BillingModel__c, ' +
                        'XC_PaymentMethod__c, Contact.LastName, Contact.FirstName, Account.IdentityNumber__c, XC_Address__r.Name, XC_Address__r.XC_StreetTypeText__c, XC_Address__r.XC_StreetType__c, ' +
                        'XC_Address__r.XC_Address__c, XC_Address__r.XC_StreetNumber__c, XC_Address__r.XC_PostalCode__c, XC_Address__r.XC_City__c, ' +
                        'XC_Address__r.XC_AddressProvince__c, XC_Address__r.XC_AddressCountry__c,  Contact.Phone, Contact.MobilePhone, Account.PrimaryEmail__c, Account.Account_Type__c, ' +
                        'Account.XC_Age__c, SerialNumber FROM Asset WHERE ';

        query += mapPartnerConfig.values()[0].XC_PartnerFilter__c;

        String queryToEscape ='';

        if(!String.isBlank(requestParams.get('start_date'))) { 
            DateTime startDate = DateTime.newInstanceGMT(Date.valueOf(requestParams.get('start_date')), Time.newInstance(0, 0, 0, 0));
            DateTime endDate =  DateTime.newInstanceGMT(Date.valueOf(requestParams.get('end_date')), Time.newInstance(23, 59, 59, 59)); 
            queryToEscape += ' AND (LastModifiedDate >=: startDate OR XC_AnnualRenewalDateIndex__c >=' + requestParams.get('start_date')+ ') AND (LastModifiedDate <=: endDate OR XC_AnnualRenewalDateIndex__c <=' + requestParams.get('end_date')+ ')';
        }

        if(!String.isBlank(requestParams.get('identity_number'))){
            String identityNumber = (requestParams.get('identity_number'));
            queryToEscape += ' AND Account.IdentityNumber__c =: identityNumber';
        }

        if(!String.isBlank(requestParams.get('legal_entity'))){
            String legalEntity = (requestParams.get('legal_entity'));
            queryToEscape += ' AND (XC_LegalEntity__c  =: legalEntity)';
        }

        if(!String.isBlank(requestParams.get('next_record_id'))){
            String nextRecordId = (requestParams.get('next_record_id'));
            queryToEscape += ' AND id >=: nextRecordId';
        }

        
        queryToEscape += ' order by Id LIMIT ' + queryLimit;
        

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Query AssetList: '+ query + String.escapeSingleQuotes(queryToEscape));
        System.debug(LoggingLevel.Finest, 'Query AssetList: ' + query + String.escapeSingleQuotes(queryToEscape));


        assetList = (List<Asset>) Database.query(query + String.escapeSingleQuotes(queryToEscape));
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'AssetList result: ' + assetList);
        return assetList;
    }
}