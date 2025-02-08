/**
 * The Class XC_UTIL_FSLLogistic_Mock.
 *
 * @author            : dpalamides
 * @date Creation     : 23/10/2020
 * @description       : XC_UTIL_FSLLogistic_Mock
 */
@isTest
global class XC_UTIL_FSLLogistic_Mock  implements HttpCalloutMock {
    
     global HTTPResponse respond(HTTPRequest req) { 
         HttpResponse response = new HttpResponse();
         response.setHeader('Content-Type', 'application/json');
         response.setStatusCode(200); 
         String jsonSTR = null;
         XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = (XC_UTIL_FSLLogistic.InputSelfCallout) JSON.deserialize(req.getBody(), XC_UTIL_FSLLogistic.InputSelfCallout.class);
         if(inputWrapper.operation == 'getGloviaProductMapping'){
             try{
                 Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>> resultData = new Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>>();
                 resultData = XC_UTIL_TechnicalCart.retrieveProductFromGlovia(inputWrapper);
                 
				 jsonSTR = '{"wrapperResult":{"success":false,"recordId":"","objectInfo":"","errorObjectId":"","errorMessage":"","errorfieldName":""},"success":false,"pricebookEntryRecordWrapper":{},"message":"","mapWorkOrderIdWarehouseId":{},"lstProductAvailability":[],"gloviaServiceProduct":[],"gloviaProductReference":[],"gloviaMaterialProduct":[{"type":null,"serialControlled":false,"sapType":"Material","productReference":"01t6E0000072AkIQAU","productCode":"4002496","priceBookEntries":[{"unitPrice":"100.00","priceBook":"a7v6E000000Cn12QAC","positionName":null,"positionCode":null,"Name":null,"id":"a7u6E0000004SDlQAM","currencyIsoCode":"EUR"}],"name":"Anodo elettronico","id":"a7y6E0000008cZlQAI","family":null,"description":"EUR","currencyIsoCode":null,"country":null,"averagePrice":"100.00"}],"fSLWorkOrderLineItem":null,"errorMessageList":[],"eligibleWrapper":{"success":false,"errorMessage":"","availabilityDate":null}}';
                 response.setBody(jsonSTR);
                 return response;
             }catch(Exception e){
               System.debug('Err:'+e);  
             }
         }else if(inputWrapper.operation == 'getPricebookEntryRecord'){
             try{  
                 XC_UTIL_FSLLogistic.OutputSelfCallout outputWrapper = new XC_UTIL_FSLLogistic.OutputSelfCallout();
                 List<gii__PriceBookEntry__c> priceBookEntry = [select id,giic_AccountAssignmentCategory__c,gii__ProductCode__c, giic_LineNumber__c, gii__Product__r.gii__ProductReference__c, gii__Product__c,gii__Product__r.Name, giic_CategoryPosition__c, giic_Description__c, giic_UnitMeasure__c, giic_MaterialGroup__c, giic_UnitRequisitioner__c, giic_ContractPosition__c,giic_Plant__c from gii__PriceBookEntry__c];
                 XC_UTIL_ReadGloviaInfoODA.PricebookEntryWrapper rec = new XC_UTIL_ReadGloviaInfoODA.PricebookEntryWrapper();
                 rec.product = priceBookEntry[0].gii__Product__r.gii__ProductReference__c;
                 outputWrapper.pricebookEntryRecordWrapper.put(String.valueOf(priceBookEntry[0].Id),rec); 
                 response.setBody(JSON.serialize(outputWrapper));
                 return response;
             }catch(Exception e){
               System.debug('Err:'+e);  
             }
         }
         jsonSTR = '{"wrapperResult":{"success":false,"recordId":"","objectInfo":"","errorObjectId":"","errorMessage":"","errorfieldName":""},"success":false,"pricebookEntryRecordWrapper":{},"message":"","mapWorkOrderIdWarehouseId":{},"lstProductAvailability":[],"gloviaServiceProduct":[],"gloviaProductReference":[],"gloviaMaterialProduct":[{"type":null,"serialControlled":false,"sapType":"Material","productReference":"01t6E0000072AkIQAU","productCode":"4002496","priceBookEntries":[{"unitPrice":"100.00","priceBook":"a7v6E000000Cn12QAC","positionName":null,"positionCode":null,"Name":null,"id":"a7u6E0000004SDlQAM","currencyIsoCode":"EUR"}],"name":"Anodo elettronico","id":"a7y6E0000008cZlQAI","family":null,"description":"EUR","currencyIsoCode":null,"country":null,"averagePrice":"100.00"}],"fSLWorkOrderLineItem":null,"errorMessageList":[],"eligibleWrapper":{"success":false,"errorMessage":"","availabilityDate":null}}';
         response.setBody(jsonSTR);
         return response;
      }
}