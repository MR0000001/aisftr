/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/


@isTest
public with sharing class XC_REST_BillingPreview_Inbound_TEST {
    static testMethod void test1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c order=XC_DF_Order.createOrder('Configuration');
        List<NE__OrderItem__c> itemList = [SELECT id,NE__CatalogItem__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :order.id];
        test.startTest();
        System.RestContext.request = generateGETRequest(order, itemList[0]);
        XC_REST_BillingPreview_Inbound.doPost();
        test.stopTest();
    }



    private static RestRequest generateGETRequest(NE__Order__c order, NE__OrderItem__c orderITEM){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();

        request.httpMethod = 'POST';
        request.requestURI = '/v1/CalculateBillingPreview_SF';

        /* if(operation!='err_header'){
             request = addHeader(request);
         }*/
        request = addHeader(request);

        XC_REST_BillingPreview_Inbound_U.BillingPreviewWrapper rqw = new XC_REST_BillingPreview_Inbound_U.BillingPreviewWrapper();
        rqw.configurationItem= orderITEM.id;
        system.debug('jsonMap'+' '+JSON.serialize(rqw,true));
        system.debug('blob Json'+' '+Blob.valueOf(JSON.serialize(rqw,true)));
        request.requestBody =Blob.valueOf(JSON.serialize(rqw,true));

        return request;
    }


    private static RestRequest addHeader(RestRequest request){
        request.addHeader('TransactionID', 'AXYZ');
        request.addHeader('DateTimeMessage', '20181207103900000');
        request.addHeader('Operation', 'AXYZ');
        request.addHeader('Functionality', 'AXYZ');
        request.addHeader('ClientSystem', 'AXYZ');
        request.addHeader('ServerSystem', 'AXYZ');
        request.addHeader('debugMode', 'AXYZ');
        // request.addHeader('Connection','AXYZ');
        return request;
    }




}