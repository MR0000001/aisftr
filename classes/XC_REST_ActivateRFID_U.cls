/**
 * @author Federico Amici federico.amici@nttdata.com
 * @date Creation 21/12/2018
 * @date Modification 23/06/2020 - Dario Tramontin - dtramontin@deloitte.it
 * @description XC_REST_ActivateRFID – Rest resource
 */


public with sharing class XC_REST_ActivateRFID_U {

    /**
     * @description The Class WrapperRFIDRequest.
     */
    public class WrapperRFIDRequest {
        
        /** The request element. */
        public List<XC_REST_ActivateRFID_U.WrapperRequestElement> requestElement;
    }

    /**
     * @description The Class WrapperRequestElement.
     */
    public class WrapperRequestElement {
        
        /** The account info. */
        public XC_UTIL_Account.AccountIFWrapper accountInfo;
        
        /** The card. */
        public XC_REST_ActivateRFID_U.WrapperSfaCard card;
    }

    /**
     * @description The Class WrapperRFIDResponse.
     */
    public class WrapperRFIDResponse {

        /** The list of response element. */
        public List<XC_REST_ActivateRFID_U.WrapperResponseElement> responseElement = new List<XC_REST_ActivateRFID_U.WrapperResponseElement>();

    }

    /**
     * @description The Class WrapperRequestElement.
     */
    public class WrapperResponseElement{

        /** The outcome. */
        public String outcome;

        /** The outcome code. */
        public String outcomeCode;
        
        /** The outcome description. */
        public String outcomeDescription;

        /** The outcome description. */
        public String logError;
        
        /** The Sfa card. */
        public WrapperSfaCard SfaCard;     
        
        /**
         * @description Instantiates a new wrapper RFID response.
         */
        public WrapperResponseElement() {
            SfaCard = new WrapperSfaCard();
        }
    }
	
    /**
     * @description The Class WrapperSfaCard.
     */
    public class WrapperSfaCard{
        
        /** The Account ID. */
        public String AccountID;        
        
        /** The Card ID. */
        public String CardID;
        
        /** The Card name. */
        public String CardName;
        
        /** The End validity date. */
        public String EndValidityDate;
        
        /** The rfid. */
        public String rfid;
        
        /** The status. */
        public String status;
        
        /** The uid. */
        public String uid;
        
        /** The RFID card */
        public XC_RFID_Card__c cardRFID;
        
        /**
         * @description Instantiates a new wrapper sfa card.
         */
        public WrapperSfaCard (){
            AccountID = null;
            CardID = null;
            CardName = null; 
            EndValidityDate = null; 
            RFID = null;
            Status = null;
            UID = null;
        }
    }


    /**
     * @description Validate request.
     * @param mapHeader the map header
     * @param wrReq the wr req
     * @return the x C UTI L integration. wrapper result
     */
    public static XC_UTIL_Integration.WrapperResult validateRequest(Map<String, String> mapHeader, List<WrapperRequestElement> wrRequest) {	
        XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult; 
        }

        if(mapHeader.get('Functionality') != 'ActivateRechargeCard') {
            validateResult.errorMessage = 'ERROR. ' + Label.XC_CL_Error_FunctionalityValue;
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(wrRequest == null || wrRequest.isEmpty()) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' requestElement';
            validateResult.errorFlag = true;
            return validateResult;
        }

        Integer i = 1;
        for(WrapperRequestElement wrReq : wrRequest) {

            validateResult = validateRequestAccount(wrReq.accountInfo, i);
            if(validateResult.errorFlag) {
                return validateResult; 
            }
            
            validateResult = validateRequestRFID(wrReq.card, i);
            if(validateResult.errorFlag) {
                return validateResult; 
            }

            i++;
        }
        
        return validateResult;
    }


    /**
     * @description Validate request account.
     * @param acc the acc
     * @param i the counter
     * @return the x C UTI L integration. wrapper result
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestAccount(XC_UTIL_Account.AccountIFWrapper acc, Integer i) {

        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        if(acc==null) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' accountInfo in the ' + i + '-th requestElement';
            validateResult.errorFlag = true;
            return validateResult;
        }
		if (String.isBlank(acc.Country)) { 
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' accountInfo.Country in the ' + i + '-th requestElement';
            validateResult.errorFlag = true;
            return validateResult;
        }     
       	if ((String.isBlank(acc.AccountID)) && (String.isBlank(acc.PrimaryEmail)) && (String.isBlank(acc.IdentityNumber))) { 
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' accountInfo.AccountID, accountInfo.PrimaryEmail or accountInfo.IdentityNumber in the ' + i + '-th requestElement';
            validateResult.errorFlag = true;
            return validateResult;
        }   
        
        return validateResult;
    }


    /**
     * @description Validate request RFID.
     * @param card the card
     * @param i the counter
     * @return the x C UTI L integration. wrapper result
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestRFID(WrapperSfaCard card, Integer i) {

        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        if(card==null) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField+' Card in the ' + i + '-th requestElement';
            validateResult.errorFlag = true;
            return validateResult;
        }
        if (String.isBlank(card.CardID)){
            validateResult.errorMessage = Label.XC_CL_MandatoryField+' Card.CardID in the ' + i + '-th requestElement';
            validateResult.errorFlag = true;
            return validateResult;
        }
        
        return validateResult;
    }


    /**
     * @description Manage cards.
     * @param wrReq the request
     * @param wrResp the response
     */
    public static void manageActivateCards(WrapperRFIDRequest wrReq, WrapperRFIDResponse wrResp){
        String logError = ''; 
        Set<String> cardSet = new Set<String>();
        Set<String> accountIdSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Set<String> identityNumberSet = new Set<String>();
        for(XC_REST_ActivateRFID_U.WrapperRequestElement wrElement : wrReq.requestElement ){
            cardSet.add(wrElement.card.CardID);
            if(String.isNotBlank(wrElement.accountInfo.AccountID)) {
                accountIdSet.add(wrElement.accountInfo.AccountID);
            }
            if(String.isNotBlank(wrElement.accountInfo.PrimaryEmail)) {
            	emailSet.add(wrElement.accountInfo.PrimaryEmail);
            }
            if(String.isNotBlank(wrElement.accountInfo.IdentityNumber)) {
            	identityNumberSet.add(wrElement.accountInfo.IdentityNumber);
            }
        }

        Map<String,String> keyAccountIdMap = XC_REST_ActivateRFID_D.populateAccountMap(emailSet, identityNumberSet, accountIdSet);
  
        if(!checkRFIDAccessibility(wrResp)) {
            return;
        }

        Map<Id, XC_RFID_Card__c> mapRFID = XC_REST_ActivateRFID_D.getRFIDCards(cardSet);

        Map<String, XC_RFID_Card__c> cardsMap = new  Map<String, XC_RFID_Card__c>();
        for(XC_RFID_Card__c c : mapRFID.values()) {
            cardsMap.put(c.XC_Card_Id__c, c);
        }

        List<XC_RFID_Card__c> listRFID = new List<XC_RFID_Card__c>();
        Map<String, Integer> cardCounterMap = new Map<String, Integer>();
        Integer i = 0;
        
        for(WrapperRequestElement wrElement : wrReq.requestElement ){
            WrapperResponseElement wrRespElem = new WrapperResponseElement();

            Map<String, String> parameters = new Map<String, String>{'card' => wrElement.card.CardID,
                                                                    'AccountID' => wrElement.accountInfo.AccountID,
                                                                    'PrimaryEmail' => wrElement.accountInfo.PrimaryEmail,
                                                                    'IdentityNumber' => wrElement.accountInfo.IdentityNumber,
                                                                    'cardsMap' => JSON.serialize(cardsMap),
                                                                    'keyAccountIdMap' => JSON.serialize(keyAccountIdMap)};
                               
            manageListRFIDResult(parameters, wrRespElem);

            if(wrRespElem.SfaCard != null && wrRespElem.SfaCard.cardRFID != null) {
                listRFID.add(wrRespElem.SfaCard.cardRFID);
                cardCounterMap.put(wrRespElem.SfaCard.cardRFID.Id, i);
                wrRespElem.SfaCard.cardRFID = null;
            }

            wrResp.responseElement.add(wrRespElem);
            i++;
        }

        if(!listRFID.isEmpty()) {
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = XC_UTIL_DML.updateRecords(listRFID, false); 
            System.debug('cardCounter: '+ cardCounterMap);
            System.debug('wrapperResult: '+ wrapperResultList);
            for(XC_UTIL_Sobject.WrapperResult  wrapperResult : wrapperResultList){
                if(!wrapperResult.success){
                    wrResp.responseElement[cardCounterMap.get(wrapperResult.errorObjectId)].outcome = 'KO';
                    wrResp.responseElement[cardCounterMap.get(wrapperResult.errorObjectId)].outcomeDescription = 'INTERNAL ERROR';
                    wrResp.responseElement[cardCounterMap.get(wrapperResult.errorObjectId)].outcomeCode = '500';  
                    wrResp.responseElement[cardCounterMap.get(wrapperResult.errorObjectId)].logError = 'INTERNAL ERROR: ' + wrapperResult.errorMessage;
                }
            }
        }

    }


    /**
     * @description check RFID Accessibility.
     * @param wrResp the response
     */
    private static Boolean checkRFIDAccessibility(XC_REST_ActivateRFID_U.WrapperRFIDResponse wrResp) {

        if(!Schema.sObjectType.XC_RFID_Card__c.isAccessible()){
            XC_REST_ActivateRFID_U.WrapperResponseElement wrElementResp = new XC_REST_ActivateRFID_U.WrapperResponseElement();
            wrElementResp.outcome = 'KO';
            wrElementResp.outcomeDescription = 'INTERNAL ERROR';
            wrElementResp.outcomeCode = '500';
            wrElementResp.logError ='INTERNAL ERROR: XC_RFID_Card__c is not Accessible';
            wrResp.responseElement.add(wrElementResp);
            return false;
        }

        return true;
    }


    /**
     * @description manages the rfid list result
     * @param listRFID the RFID list
     * @param wrResp the response wrapper
     * @param accountId the list of account id
     */
    public static void manageListRFIDResult(Map<String, String> parameters,  XC_REST_ActivateRFID_U.WrapperResponseElement wrElementResp) {

        String card = parameters.get('card');
        String accountId = parameters.get('AccountID');
        String primaryEmail = parameters.get('PrimaryEmail');
        String identityNumber = parameters.get('IdentityNumber');

        Map<String, Id> keyAccountIdMap = (Map<String, Id>) JSON.deserialize(parameters.get('keyAccountIdMap'), Map<String, Id>.class);
        String foundAccountID = '';
        if(String.isNotBlank(accountId)) {
            foundAccountID = keyAccountIdMap.get(accountId);
        } else if(String.isNotBlank(primaryEmail)) {
            foundAccountID = keyAccountIdMap.get(primaryEmail);
        } else if(String.isNotBlank(identityNumber)) {
            foundAccountID = keyAccountIdMap.get(identityNumber);
        }

        if(String.isBlank(foundAccountId)) {
            wrElementResp.outcome = 'KO';
            wrElementResp.outcomeDescription = Label.XC_CL_Account_NotValid;
            wrElementResp.outcomeCode = 'EMOB002';
            wrElementResp.logError = wrElementResp.outcomeDescription;
            wrElementResp.SfaCard.CardId = card;
            return;
        }   

        Map<String, XC_RFID_Card__c> cardsMap = (Map<String, XC_RFID_Card__c>) JSON.deserialize(parameters.get('cardsMap'), Map<String, XC_RFID_Card__c>.class);

        if(cardsMap.containsKey(card)) {
            XC_RFID_Card__c rfidCard = cardsMap.get(card);

            // First case : Card Status is STORED and Account Lookup is Empty
            if(rfidCard.XC_Status_RFID__c == Label.XC_CL_RFID_Stored && String.isBlank(rfidCard.XC_Account_RFID__c)) {                    
                rfidCard.XC_Status_RFID__c = Label.XC_CL_RFID_Active;
                rfidCard.XC_Account_RFID__c = foundAccountID;
                wrElementResp.outcome = 'OK';
                wrElementResp.outcomeDescription = 'Success: Card is active';
                wrElementResp.outcomeCode = 'EMOB010';
                wrElementResp.SfaCard.AccountID = foundAccountID;
                wrElementResp.SfaCard.CardId = rfidCard.XC_Card_Id__c;
                wrElementResp.SfaCard.CardName = rfidCard.XC_Card_Name__c;
                wrElementResp.SfaCard.EndValidityDate = String.valueOf(rfidCard.XC_EndDate__c);
                wrElementResp.SfaCard.RFID = rfidCard.XC_RFID__c;
                wrElementResp.SfaCard.Status = rfidCard.XC_Status_RFID__c;
                wrElementResp.SfaCard.UID = rfidCard.XC_UID__c;
                wrElementResp.SfaCard.cardRFID = rfidCard;

            // Second case : Card Status is ACTIVE and Account Lookup is NOT Empty
            } else if (rfidCard.XC_Status_RFID__c == Label.XC_CL_RFID_Active && rfidCard.XC_Account_RFID__c == foundAccountID) {
                wrElementResp.outcome = 'OK';
                wrElementResp.outcomeDescription = 'Success: Card is active';
                wrElementResp.outcomeCode = 'EMOB010';
                wrElementResp.SfaCard.AccountID = foundAccountID;
                wrElementResp.SfaCard.CardId = rfidCard.XC_Card_Id__c;
                wrElementResp.SfaCard.CardName = rfidCard.XC_Card_Name__c;
                wrElementResp.SfaCard.EndValidityDate = String.valueOf(rfidCard.XC_EndDate__c);
                wrElementResp.SfaCard.RFID = rfidCard.XC_RFID__c;
                wrElementResp.SfaCard.Status = rfidCard.XC_Status_RFID__c;
                wrElementResp.SfaCard.UID = rfidCard.XC_UID__c;
                //wrElementResp.SfaCard.cardRFID = rfidCard;
                
            // Third case : Card Status is ACTIVE and Account Lookup is NOT Empty but is not equal to primary account
            }else if (rfidCard.XC_Status_RFID__c == Label.XC_CL_RFID_Active && rfidCard.XC_Account_RFID__c != foundAccountID) {                    
                wrElementResp.outcome = 'KO';
                wrElementResp.outcomeDescription = Label.XC_CL_Account_NotValid;
                wrElementResp.outcomeCode = 'EMOB011';  
                wrElementResp.SfaCard = null;
            }

        } else {
            wrElementResp.outcome = 'KO';
            wrElementResp.outcomeDescription = 'Card not valid';
            wrElementResp.outcomeCode = 'EMOB012';
            wrElementResp.SfaCard.CardID = card;
            wrElementResp.SfaCard.AccountID = foundAccountID;
        }

        System.debug('wrElementResp:' + wrElementResp);
    }

}