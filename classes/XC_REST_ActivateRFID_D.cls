/**
 * @author Federico Amici federico.amici@nttdata.com
 * @date Creation 21/12/2018
 * @date Modification 23/06/2020 - Dario Tramontin - dtramontin@deloitte.it
 * @description XC_REST_ActivateRFID_D – DAO for the XC_REST_ActivateRFID class
 */


public without sharing class XC_REST_ActivateRFID_D {
    

    /**
     * @description populates the account map
     * @param emailList list of Account's email
     * @param idNumberList list of Account's IdentityNumber
     * @param accountList list of Account's Id
     * @return the account Map
     */
    public static Map<String, String> populateAccountMap(Set<String> emailList , Set<String> idNumberList, Set<String> accountList) {
        Map<String, Id> keyAccountIdMap = new Map<String, Id>();

        String query = 'SELECT Id, RecordType.Name, IdentityNumber__c, PrimaryEmail__c FROM Account';
        
        Boolean check = false;
        if(!accountList.isEmpty()) {
            query += ' WHERE Id IN: accountList';
            check = true;
        }

        if (!emailList.isEmpty() && !check) {
            query += ' WHERE PrimaryEmail__c IN :emailList';
            check = true;
        } else if (!emailList.isEmpty()) {
            query += ' OR PrimaryEmail__c IN :emailList';
        }

        if (!idNumberList.isEmpty() && !check) {
            query += ' WHERE IdentityNumber__c IN :idNumberList';
            check = true;
        } else if (!idNumberList.isEmpty()) {
            query += ' OR IdentityNumber__c IN :idNumberList';
        }

        if(!check) {
            return keyAccountIdMap;
        }

        List<Account> accList = (List<Account>) Database.query(String.escapeSingleQuotes(query));
        List<Account> accRes = new List<Account>();
        for(Account a : accList){
            if(a.RecordType.Name == 'Residential'){
                accRes.add(a);
            }
        }
        
        if(accList.isEmpty() || !accRes.isEmpty() ) {
            accList.addAll(XC_REST_ActivateRFID_D.getListAccount(idNumberList));
        }

        for(Account acc : accList) {
            keyAccountIdMap.put(acc.Id, acc.Id);
            if(String.isNotBlank(acc.PrimaryEmail__c)) {
                keyAccountIdMap.put(acc.PrimaryEmail__c, acc.Id);
            }
            if(String.isNotBlank(acc.IdentityNumber__c)) {
                keyAccountIdMap.put(acc.IdentityNumber__c, acc.Id);
            }
        }

        return keyAccountIdMap;
    }


    /**
     * @description the method retrieves the list of accounts
     * @param accIdNumber list of Document Number
     * @return the account list
     **/
    public static List<Account> getListAccount(Set<String> accIdNumber) {
        List<Account> accList = new List<Account>();

        if(!accIdNumber.isEmpty()) {
            accList = [SELECT Id,IdentityNumber__c, PrimaryEmail__c,
                            (SELECT Id, XC_DocumentNumber__c FROM Personal_Documents__r WHERE XC_DocumentNumber__c IN : accIdNumber) 
                        FROM Account 
                        WHERE Id IN (SELECT XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentNumber__c IN : accIdNumber)];
        }

        return accList;
    }


    /**
     * @description the method retrieves cards
     * @param cardSet list of card
     * @return the cards map
     **/
    public static Map<Id, XC_RFID_Card__c> getRFIDCards(Set<String> cardSet){

        Map<Id, XC_RFID_Card__c> cardMap = new Map<Id, XC_RFID_Card__c>([SELECT XC_Account_RFID__c, XC_Card_Id__c, XC_Card_Name__c, XC_EndDate__c, XC_RFID__c, XC_Status_RFID__c, XC_UID__c 
                                                                        FROM XC_RFID_Card__c 
                                                                        WHERE XC_Card_Id__c IN :cardSet]);

        return cardMap;
    }


    /**
     * @description manage the response
     * @param mapHeader the map Header
     * @param wrResp the wr response
     * @param intLog the integration log
     **/
    public static void manageOutcomeCode(Map<String, String> mapHeader, XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp, XC_UTIL_IntegrationLog intLog) {
        
        String logError = '';
        String errorCode = '200';
        Integer counterError = 0;
        for(XC_REST_ActivateRFID_U.WrapperResponseElement wrResponseElem : wrResp.responseElement) {
            if(wrResponseElem.outcome == 'KO') {
                logError = wrResponseElem.logError;
                errorCode = (wrResponseElem.outcomeCode == 'EMOB011' || wrResponseElem.outcomeCode == 'EMOB012' ) ? '400' : wrResponseElem.outcomeCode;
                counterError++;
            }
            wrResponseElem.logError = null;
        }

        String msgResponse = JSON.serialize(wrResp, true);

        XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
        restContextResponseWrapper.res = RestContext.response;
        restContextResponseWrapper.msgResponse = msgResponse;
        restContextResponseWrapper.mapHeader = mapHeader;
        if(counterError == wrResp.responseElement.size()) {
            intLog.insertIntegRespInboundLog(errorCode, false, msgResponse, logError);
            restContextResponseWrapper.errorCode = errorCode;
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        } else {
            intLog.insertIntegRespInboundLog('200', true, msgResponse, logError);
            restContextResponseWrapper.errorCode = '200';
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        }
    }
    
}