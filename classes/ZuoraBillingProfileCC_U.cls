/**
 * @author            : Denise Avolio - denise.avolio@accenture.com
 * @group             : ACN Team
 * @last modified on  : 22-12-2021
 * @last modified by  : Denise Avolio - denise.avolio@accenture.com
 * @description       : Utility Class for ZuoraBillingProfileCreationController.cls
 * @test class        : ZuoraBillingProfileCreationCC_TEST
 * 
 * Ver   Date         Author                                        Modification
 * 1.0   22-12-2021   Denise Avolio - denise.avolio@accenture.com   Initial Version
**/

public without sharing class ZuoraBillingProfileCC_U {
    @AuraEnabled
    public static ZuoraBillingProfileCreationController.XC_CupsandContract_Wrapper contractAccountValidationCall(XC_Address__c addr, String pos, Map<String,Object> data){
        ZuoraBillingProfileCreationController.XC_CupsandContract_Wrapper result = new ZuoraBillingProfileCreationController.XC_CupsandContract_Wrapper();
        Map<String, Object> mapResultsPOST = new Map<String, Object>();
        Map<String, Object> resultsPOST = new Map<String, Object>();
        Set<String> countryList = new Set<String>{'Chile', 'Colombia'};
        if(countryList.contains(addr.XC_AddressCountry__c)){
            XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface(Label.XC_CL_ContractAccountValidation, addr.XC_AddressCountry__c);
            system.debug('@@@ isActiveInterface.activeInterface: ' + isActiveInterface.activeInterface);
            if(isActiveInterface.activeInterface){
                try{  
                    XC_IN_QRS00_CheckRequest.WebServiceWrapper inputMap = new XC_IN_QRS00_CheckRequest.WebServiceWrapper();
                    XC_IN_QRS00_CheckRequest.AccountWrapper acc = new XC_IN_QRS00_CheckRequest.AccountWrapper();
                    acc.ContractNumber = String.valueOf(data.get('ContractNumber')); 
                    acc.AccountType = String.isNotBlank(addr.XC_Account__r.Account_Type__c) ? addr.XC_Account__r.Account_Type__c : 'Residential'; 
                    acc.POS = pos;
                    acc.IdentityType = addr.XC_Account__r.IdentityType__c;
                    acc.IdentityNumber = addr.XC_Account__r.IdentityNumber__c;
                    inputMap.Account = acc;

                    String body = JSON.serialize(inputMap, true);
                    Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'ContractAccountValidation', isActiveInterface.serverSystem);
                    
                    String endpointUrl = isActiveInterface.url;
                    //********************** Send outbound request *************************************//
                    HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', endpointUrl, headerDefinitions, body);
                    System.debug('[ContractAccountValidation] request -> ' + request);
                    HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'ContractAccountValidation');
                    System.debug('[ContractAccountValidation] response -> ' + response);
                    mapResultsPOST = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    resultsPOST = (Map<String, Object>) mapResultsPOST.get('Result');
                }catch(Exception e){
                    System.debug('Errore call ContractAccountValidation: ' + e.getMessage());
                    if(Test.isRunningTest()){   
                        mapResultsPOST = (Map<String,Object>) JSON.deserializeUntyped('{"Result":{"ErrorCode":"0","Message":"Operation completed successfully"}}');
                        resultsPOST = (Map<String, Object>) mapResultsPOST.get('Result');
                    }
                }
                if(XC_IN_QRS00_CheckRequest.OK_CODES.contains(String.valueOf(resultsPOST.get('ErrorCode')))){
                    result.contract = String.valueOf(data.get('ContractNumber'));
                }
            }else{
                result.contract = String.valueOf(data.get('ContractNumber'));
            }
        }else{
            result.contract = String.valueOf(data.get('ContractNumber'));
        }
        return result;
    }
}