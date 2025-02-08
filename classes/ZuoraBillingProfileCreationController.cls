/**
* @author Monica Cutillo monicaa.cutillo@nttdata.com & Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com
* @date Creation 13/12/2018
* @description XC_LCC059_ZuoraPaymentPage – component to create Billing Profiles of an Accounts
*/

public without sharing class ZuoraBillingProfileCreationController {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('ZuoraBillingProfileCreation');

    public class XC_ContactAddress_Wrapper {
        @AuraEnabled
        public Contact c ;
        @AuraEnabled
        public String addressId = '';
    }

    public class XC_ContactGasELuz_Wrapper {
        @AuraEnabled
        public List<Map<String,String>> listContract;
        @AuraEnabled
        public String gasCUP = '';
        @AuraEnabled
        public String electricCUP = '';
    }

    public class XC_CupsandContract_Wrapper {
        @AuraEnabled
        public List<String> cups ;
        @AuraEnabled
        public List<String> cupsLight ;
        @AuraEnabled
        public List<String> cupsGas ;
        @AuraEnabled
        public String contract = '';
        @AuraEnabled
        public Boolean isB2B = false;
        @AuraEnabled
        public String commodityAccountId ='';
         //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
         @AuraEnabled
         public string commodityCustomerName='';        
         @AuraEnabled
         public string commodityIdentityNumber='';  
         //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
    }

    public class XC_SohoDocumentWrapper {

        @AuraEnabled
        public String docCountry;
        @AuraEnabled
        public String identityType;
        @AuraEnabled
        public String identityNumber;
        @AuraEnabled
        public Date NIEExpirationdate;
        @AuraEnabled
        public Date NIEExpeditionDate;

    }

    public class InputRollbackWrapper {
        @AuraEnabled
        public String billingProfileLineItemId;
        @AuraEnabled
        public String billingProfileId;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public Boolean doRollback;
    }
    
    @AuraEnabled
    public static void updateSalesforceAccount(String accountId, String mapValuesJSON){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapValuesJSON -->'+mapValuesJSON);
        Id accId = Id.valueOf(accountId);
        String sObjName = accId.getSObjectType().getDescribe().getName();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'For account -->'+accountId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'For object -->'+sObjName);
        If(sObjName == 'NE__Billing_Profile__c'){
            NE__Billing_Profile__c billingProf = [SELECT Id, NE__Account__c FROM NE__Billing_Profile__c WHERE Id =: accountId LIMIT 1];
            accountId = billingProf.NE__Account__c;
        }
        if(sObjName == 'NE__Order__c'){
             NE__Order__c ord = [select id, NE__AccountId__c from NE__Order__c where id =:accountId LIMIT 1];
            accountId = ord.NE__AccountId__c;
         }
        Account acc = [SELECT Id FROM Account where Id =: accountId][0];
        Map<String, Object> mapValues = (Map<String, Object>)JSON.deserializeUntyped(mapValuesJSON);
        for(String key: mapValues.keySet() ){
            acc.put(key, mapValues.get(key));
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'List account -->'+acc);
        XC_UTIL_DML.updateRecords(new List<Account>{acc});

    }

    @AuraEnabled
    public static void updateAccountDoxeeLanguage(String accountId, String value){
        Account acc = [SELECT PreferredLanguage__c FROM Account where Id =: accountId][0];
        acc.PreferredLanguage__c = value;
        XC_UTIL_DML.updateRecords(new List<Account>{acc});
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Account updated in updateAccountDoxeeLanguage');
    }


    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to retrieve cups ele
     * @param addressId
     * @param documentNumber
     *@return XC_CupsandContract_Wrapper
    */
    @AuraEnabled
    //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - START 
    public static XC_CupsandContract_Wrapper retrieveCups(String addressId , String documentNumber, String segmentofCountry){
    //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - END 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In retrieveCups');
        /*String contractID = '';
        Map<Id,XC_Address__c> listAddMap = new Map<Id,XC_Address__c>([
            SELECT Id,XC_GasCUPS__c,XC_ElectricCUPS__c, XC_AddressCountry__c
              FROM XC_Address__c 
             WHERE Id =:addressId LIMIT 1
        ]);
        
        XC_Address__c addr = listAddMap.values()[0];*/
        XC_CupsandContract_Wrapper returnWrapper = new XC_CupsandContract_Wrapper();
        XC_Address__c addr = retrieveAddresData(addressId);
        Map<String,Object> callResult = new Map<String,Object>(); 
        List<XC_Integration_Log__c> intLogGetContract= new List<XC_Integration_Log__c>();     
        XC_REST_Contract_Outbound.ContractOutboudCallInputData callData = new XC_REST_Contract_Outbound.ContractOutboudCallInputData();
        if(addr.XC_ElectricCUPS__c!=null && String.isBlank(addr.XC_GasCUPS__c)){
            returnWrapper.cups = new List<String> {addr.XC_ElectricCUPS__c};
            returnWrapper.cupsLight = new List<String> {addr.XC_ElectricCUPS__c};
            //[DeAv 21/12/2021 TPB: adjustment to invoke WebService START]           
            callData.identityNumber = '';
            callData.pos = addr.XC_ElectricCUPS__c;
            callData.country = addr.XC_AddressCountry__c;
            callData.insertLoggin = false;
            //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - START
            System.debug('ALC segmentofCountry: '+segmentofCountry);
            callData.segment = segmentofCountry;
            //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - END
            XC_REST_Contract_Outbound.ContractOutboudCallOutputData responseGET = XC_REST_Contract_Outbound.callToGetContract(callData);
            callResult = responseGET.fieldsData;
            intLogGetContract = responseGET.integrationLog;
            //Map<String,Object> callResult = XC_REST_Contract_Outbound.calltogetcontract('', addr.XC_ElectricCUPS__c,addr.XC_AddressCountry__c );
            //[DeAv 21/12/2021 TPB: adjustment to invoke WebService END]
            if(callResult != null && !callResult.isEmpty() && callResult.get('Contract') != null && ((List<Object>)callResult.get('Contract'))[0] != null){
                Object contractValues = ((List<Object>)callResult.get('Contract'))[0];
                Map<String,Object> m = (map<String,Object>)contractValues;
                //[DeAv 21/12/2021 TPB: call WS contractAccountValidation START]
                if(m!=null && m.get('ContractNumber') != null){
                    returnWrapper = ZuoraBillingProfileCC_U.contractAccountValidationCall(addr, addr.XC_ElectricCUPS__c, m);
                    returnWrapper.cups = new List<String> {addr.XC_ElectricCUPS__c};
                    returnWrapper.cupsLight = new List<String> {addr.XC_ElectricCUPS__c};
                    //returnWrapper.contract = String.valueOf(m.get('ContractNumber'));
                     //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
                     if(callData!=null && !string.isBlank(callData.country) && callData.country=='Brazil' && addr!=null && addr.XC_Account__r!=null && addr.XC_Account__r.XC_Segment__c=='B2C' && ( m.get('commodityCustomerName')!=null || m.get('commodityIdentityNumber')!=null))
                     {
                        returnWrapper.commodityCustomerName =string.valueOf(m.get('commodityCustomerName'));
                        returnWrapper.commodityIdentityNumber =string.valueOf(m.get('commodityIdentityNumber'));
                     }
                     //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->                                                                                  
                }
                //[DeAv 21/12/2021 TPB: call WS contractAccountValidation END]
            }
        }else if(addr.XC_GasCUPS__c!=null && String.isBlank(addr.XC_ElectricCUPS__c)){
            returnWrapper.cups = new List<String> {addr.XC_GasCUPS__c};
            returnWrapper.cupsGas = new List<String> {addr.XC_GasCUPS__c};
            //[DeAv 21/12/2021 TPB: adjustment to invoke WebService START]
            callData.identityNumber = '';
            callData.pos = addr.XC_GasCUPS__c;
            callData.country = addr.XC_AddressCountry__c;
            callData.insertLoggin = false;
            //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - START
            callData.segment = segmentofCountry;
            //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - END
            XC_REST_Contract_Outbound.ContractOutboudCallOutputData responseGET = XC_REST_Contract_Outbound.callToGetContract(callData);
            callResult = responseGET.fieldsData;
            intLogGetContract = responseGET.integrationLog;
            //Map<String,Object> callResult = XC_REST_Contract_Outbound.calltogetcontract('', addr.XC_GasCUPS__c, addr.XC_AddressCountry__c);
            //[DeAv 21/12/2021 TPB: adjustment to invoke WebService END]
            if(callResult != null && !callResult.isEmpty() && callResult.get('Contract')!=null){
                Object contractValues = ((List<Object>)callResult.get('Contract'))[0];
                Map<String,Object> m = (map<String,Object>)contractValues;
                //[DeAv 21/12/2021 TPB: call WS contractAccountValidation START]
                if(m!=null && m.get('ContractNumber') != null){
                    returnWrapper = ZuoraBillingProfileCC_U.contractAccountValidationCall(addr, addr.XC_GasCUPS__c, m);
                    returnWrapper.cups = new List<String> {addr.XC_GasCUPS__c};
                    returnWrapper.cupsGas = new List<String> {addr.XC_GasCUPS__c};
                    //returnWrapper.contract = String.valueOf(m.get('ContractNumber'));
                     //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
                     if(callData!=null && !string.isBlank(callData.country) && callData.country=='Brazil' && addr!=null && addr.XC_Account__r!=null && addr.XC_Account__r.XC_Segment__c=='B2C' && ( m.get('commodityCustomerName')!=null || m.get('commodityIdentityNumber')!=null))
                     {
                        returnWrapper.commodityCustomerName =string.valueOf(m.get('commodityCustomerName'));
                        returnWrapper.commodityIdentityNumber =string.valueOf(m.get('commodityIdentityNumber'));
                     }
                     //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->                                                                                  
                }
                //[DeAv 21/12/2021 TPB: call WS contractAccountValidation END]
            }
        }else if(String.isNotBlank(addr.XC_ElectricCUPS__c) && String.isNotBlank(addr.XC_GasCUPS__c)){
            returnWrapper.cups = new List<String> {addr.XC_ElectricCUPS__c,addr.XC_GasCUPS__c};
            returnWrapper.cupsLight = new List<String> {addr.XC_ElectricCUPS__c};
            returnWrapper.cupsGas = new List<String> {addr.XC_GasCUPS__c};
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ returnWrapper -> ' + returnWrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Exit from retrieveCups');
        //[DeAv 21/12/2021 TPB: adjustment to invoke WebService START]
        if(intLogGetContract != null && !intLogGetContract.isEmpty()){
            insert intLogGetContract; 
        }
        //[DeAv 21/12/2021 TPB: adjustment to invoke WebService END]
        //14-02-2022 alag@deloitte.es Add Segment to distinguish B2B values - START
        if(segmentofCountry!=null && !segmentofCountry.contains('B2B')){
            returnWrapper.isB2B = true;
        }
        //14-02-2022 alag@deloitte.es Add Segment to distinguish B2B values - END
        return returnWrapper;
    }
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to retrieve cups ele
     * @param addressId
     * @param documentNumber
     *@return XC_CupsandContract_Wrapper
    */
    @AuraEnabled
    public static XC_CupsandContract_Wrapper retrieveCupsByDocAccountAndPOD(String addressId , String documentNumber){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In retrieveCupsByDocAccountAndPOD');
        XC_CupsandContract_Wrapper returnWrapper = new XC_CupsandContract_Wrapper();
        XC_Address__c addr = retrieveAddresData(addressId);
        if(addr.XC_ElectricCUPS__c!=null && String.isBlank(addr.XC_GasCUPS__c)){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Electric CUPS not null');
            returnWrapper.cups = new List<String> {addr.XC_ElectricCUPS__c};
            returnWrapper.cupsLight = new List<String> {addr.XC_ElectricCUPS__c};
            Map<String,Object> callResult;
            //if(!Test.isRunningTest()) {
                callResult = XC_REST_Contract_Outbound.calltogetcontract(addr.XC_Account__r.IdentityNumber__c , addr.XC_Account__r.IdentityType__c, addr.XC_ElectricCUPS__c,addr.XC_AddressCountry__c );
            //}
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ callResult' + callResult);
            if(callResult != null && !callResult.isEmpty() && callResult.get('Contract') != null && ((List<Object>)callResult.get('Contract'))[0] != null){
                Object contractValues = ((List<Object>)callResult.get('Contract'))[0];
                Map<String,Object> m = (map<String,Object>)contractValues;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'contractValues='+m);
                if(m!=null){
                    returnWrapper.contract = String.valueOf(m.get('ContractNumber'));
                    returnWrapper.commodityAccountId = m.get('AccountID')!= null ? String.valueOf(m.get('AccountID')) : '';
                }
            }
        }else if(addr.XC_GasCUPS__c!=null && String.isBlank(addr.XC_ElectricCUPS__c)){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Gas CUPS not null');
            returnWrapper.cups = new List<String> {addr.XC_GasCUPS__c};
            returnWrapper.cupsGas = new List<String> {addr.XC_GasCUPS__c};
            Map<String,Object> callResult;
            //if(!Test.isRunningTest()) {
                callResult = XC_REST_Contract_Outbound.calltogetcontract('', addr.XC_GasCUPS__c, addr.XC_AddressCountry__c);
            //}
            if(callResult != null && !callResult.isEmpty() && callResult.get('Contract')!=null){
                Object contractValues = ((List<Object>)callResult.get('Contract'))[0];
                Map<String,Object> m = (map<String,Object>)contractValues;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'contractValues='+m);
                if(m!=null  ){
                    returnWrapper.contract = String.valueOf(m.get('ContractNumber'));
                    returnWrapper.commodityAccountId = m.get('AccountID')!= null ? String.valueOf(m.get('AccountID')) : '';
                }
            }
        }else if(String.isNotBlank(addr.XC_ElectricCUPS__c) && String.isNotBlank(addr.XC_GasCUPS__c)){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Electric and gas CUPS not null');
            returnWrapper.cups = new List<String> {addr.XC_ElectricCUPS__c,addr.XC_GasCUPS__c};
            returnWrapper.cupsLight = new List<String> {addr.XC_ElectricCUPS__c};
            returnWrapper.cupsGas = new List<String> {addr.XC_GasCUPS__c};
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Exit from retrieveCupsByDocAccountAndPOD');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ returnWrapper -> ' + returnWrapper);
        return returnWrapper;
    }
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Method to retrieve cups ele
     * @param pos the POS number
     * @param addressId the addressId
     *@return XC_CupsandContract_Wrapper
    */
    @AuraEnabled
    //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - START
    public static XC_CupsandContract_Wrapper getContractByPOS(String pos, String addressId, String segmentofCountry){
    //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - END 
        XC_Address__c addr = retrieveAddresData(addressId);
        XC_CupsandContract_Wrapper result = new XC_CupsandContract_Wrapper();

        //[DeAv 21/12/2021 TPB: adjustment to invoke WebService START]
        Map<String,Object> callResult = new Map<String,Object>(); 
        List<XC_Integration_Log__c> intLogGetContract= new List<XC_Integration_Log__c>();     
        XC_REST_Contract_Outbound.ContractOutboudCallInputData callData = new XC_REST_Contract_Outbound.ContractOutboudCallInputData();
        callData.identityNumber = '';
        callData.pos = pos;
        callData.country = addr.XC_AddressCountry__c;
        callData.insertLoggin = false;
        //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - START
        callData.segment = segmentofCountry;
        //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - END
        XC_REST_Contract_Outbound.ContractOutboudCallOutputData responseGET = XC_REST_Contract_Outbound.callToGetContract(callData);
        callResult = responseGET.fieldsData;
        intLogGetContract = responseGET.integrationLog;
        //Map<String,Object> callResult = XC_REST_Contract_Outbound.calltogetcontract('', pos, addr.XC_AddressCountry__c);
        //[DeAv 21/12/2021 TPB: adjustment to invoke WebService END]
        system.debug('@@@ callResult: ' + callResult);
        system.debug('@@@ callResult.getContract: ' + callResult.get('Contract'));
        if(callResult != null && callResult.get('Contract') != null && ((List<Object>)callResult.get('Contract'))[0] != null){
            Object contractValues = ((List<Object>)callResult.get('Contract'))[0];
            Map<String,Object> data = (map<String,Object>)contractValues;
            system.debug('@@@ data: ' + data);
            system.debug('@@@ data.getContractNumber: ' + data.get('ContractNumber'));
            if(data!=null && data.get('ContractNumber') != null){
                //result.contract = String.valueOf(data.get('ContractNumber'));
                result = ZuoraBillingProfileCC_U.contractAccountValidationCall(addr, pos, data); //[DeAv 21/12/2021 TPB: call WS contractAccountValidation]
            }
        }
        //[DeAv 21/12/2021 TPB: adjustment to invoke WebService START]
        if(intLogGetContract != null && !intLogGetContract.isEmpty()){
            insert intLogGetContract; 
        }
        //[DeAv 21/12/2021 TPB: adjustment to invoke WebService END]
        return result;
    }
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Method to retrieve cups ele
     * @param pos the POS number
     * @param addressId the addressId
     *@return XC_CupsandContract_Wrapper
    */
    @AuraEnabled
    public static XC_CupsandContract_Wrapper getContractByPOSAndAccountDoc(String pos, String addressId){
        XC_Address__c addr = retrieveAddresData(addressId);
        XC_CupsandContract_Wrapper result = new XC_CupsandContract_Wrapper();
        Map<String,Object> callResult = XC_REST_Contract_Outbound.calltogetcontract(addr.XC_Account__r.IdentityNumber__c, addr.XC_Account__r.IdentityType__c, pos, addr.XC_AddressCountry__c);
        if(callResult != null && callResult.get('Contract') != null && ((List<Object>)callResult.get('Contract'))[0] != null){
            Object contractValues = ((List<Object>)callResult.get('Contract'))[0];
            Map<String,Object> data = (map<String,Object>)contractValues;
            if(data!=null && data.get('ContractNumber') != null){
                result.contract = String.valueOf(data.get('ContractNumber'));
            }
        }
        return result;
    }
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description retrieveAddresData from id
     * @param addressId
     *@return the XC_Address__c
    */
    private static XC_Address__c retrieveAddresData(String addressId){
        Map<Id,XC_Address__c> listAddMap = new Map<Id,XC_Address__c>([
            SELECT Id,XC_GasCUPS__c,XC_ElectricCUPS__c, XC_AddressCountry__c, XC_Account__r.IdentityType__c, XC_Account__r.IdentityNumber__c, XC_Account__r.Account_Type__c, //[DeAv 21/12/2021 added XC_Account__r.Account_Type__c]
            XC_Account__r.XC_Segment__c  // gaurav.tejpal@accenture.com  added XC_Segment__c 
            FROM XC_Address__c 
             WHERE Id =:addressId LIMIT 1
        ]);
        return listAddMap.values()[0];
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description retrievePersonalDocument
     * @param personalDocuments personal Documents 
     *@return List<Map<String,String>> 
    */
    private static List<Map<String,String>> retrievePersonalDocument(List<XC_PersonalDocument__c> personalDocuments){
        List<Map<String,String>> personalDocumentsList = new List<Map<String,String>>();
        for(XC_PersonalDocument__c doc : personalDocuments){
            Map<String,String> docMap = new Map<String,String>();
            docMap.put('key' , doc.Id);
            docMap.put('value' , doc.XC_DocumentType__c + ' - '+ doc.XC_DocumentNumber__c);
            personalDocumentsList.add(docMap);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@Personal Document List ' +personalDocumentsList);
        return personalDocumentsList;
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method for retrieve data for init component page
     * @param accountId
     * @param objectName
     *@return String
    */
    @AuraEnabled
    public static String initPaymentPage(String accountId, String objectName){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Init initPaymentPage');
        Map<String,Object> mapResult = new Map<String,Object>();
        String stream = '';
        Set<String> itaLE = new Set<String>{'EnelXItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMSP','EnelXMobility','Cogenio','EnelXMobilityItalia','EnelXMobilityHolding'};
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ itaLE  -> ' + itaLE );
        if(objectName == 'NE__Billing_Profile__c'){
            NE__Billing_Profile__c billignProf = [SELECT Id, XC_Segment__c, NE__Account__c, XC_LegalEntity__c, XC_SepaMandate__c, XC_SepaMandateDate__c, NE__Payment__c, XC_Token__c,
                                                    NE__Card_Type__c, NE__Card_Number__c, NE__Expiration__c, NE__Expiration_Year__c, XC_PayPalUsername__c, NE__Iban__c, XC_CommodityContractID__c,
                                                    NE__Account__r.XC_DocumentCountry__c, NE__Account__r.IdentityType__c, NE__Account__r.IdentityNumber__c
                                                    FROM NE__Billing_Profile__c
                                                    WHERE Id =: accountId LIMIT 1];
            System.debug('billignProf: ' + billignProf);
            accountId = billignProf.NE__Account__c;
            stream = billignProf.XC_Segment__c;
            mapResult.put('legalEntity', billignProf.XC_LegalEntity__c);
            mapResult.put('docCountry', billignProf.NE__Account__r.XC_DocumentCountry__c);
            mapResult.put('docNif', billignProf.NE__Account__r.IdentityType__c);
            mapResult.put('docNumber', billignProf.NE__Account__r.IdentityNumber__c);
            mapResult.put('paymentType', billignProf.NE__Payment__c);
            mapResult.put('payment', billignProf.NE__Payment__c);
            mapResult.put('paymentMethodCategory', getPaymentCategoryDependency(billignProf.NE__Payment__c));
            mapResult.put('sepaMandate', billignProf.XC_SepaMandate__c);
            mapResult.put('mandateDate', billignProf.XC_SepaMandateDate__c);
            mapResult.put('debtorCode', billignProf.XC_Token__c);
            mapResult.put('creditCardLastFourNumber', (String.isNotBlank(billignProf.NE__Card_Number__c)) ? billignProf.NE__Card_Number__c.substring(12) : null);
            // mapResult.put('creditCardHolder', '');
            mapResult.put('expirationMonth', billignProf.NE__Expiration__c);
            mapResult.put('expirationYear', billignProf.NE__Expiration_Year__c);
            mapResult.put('payPalUsername', billignProf.XC_PayPalUsername__c);
            mapResult.put('iban', billignProf.NE__Iban__c);
            mapResult.put('contractId', billignProf.XC_CommodityContractID__c);

            if(String.isNotBlank(billignProf.NE__Card_Type__c)) {
                Map<String,String> creditCardType = new Map<String, String> {'MASTERCARD' => 'MasterCard', 
                                                                            'VISA' => 'Visa',
                                                                            'DISCOVER' => 'Discover',
                                                                            'AMEX' => 'AmericanExpress',
                                                                            'PAYPAL' => 'PayPal'};
                mapResult.put('creditCardType', creditCardType.get(billignProf.NE__Card_Type__c.toUpperCase()));
            }
        }

        List<Map<String,String>> countries = XC_UTIL_Country.retriveCountryPicklistValues();
        mapResult.put('countries', countries);


        if(!mapResult.containsKey('legalEntity') || mapResult.get('legalEntity')==null){
            mapResult.put('legalEntity',XC_UTIL_User.getLegalEntityFromUser());
        }

        List<Map<String,String>> pods = getPodOfAccountPicklist(accountId);
        mapResult.put('billingAddresses', pods);
        List<Map<String,String>> soldAddress = getSoldAddressofAccountPicklist(accountId,false);
        mapResult.put('soldAddresses', soldAddress);
        List<String> cups;
        mapResult.put('cups', cups);
        List<Map<String,String>> doxeeLanguages = XC_UTIL_Account.getDoxeeLanguagesPicklist();
        mapResult.put('doxeeLanguages',doxeeLanguages);
        String recordTypeName='';
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapResult -> ' + mapResult);
        if(objectName == 'Account'){
            Account a = [SELECT id, XC_Segment__c,XC_CommodityCustomerName__c,XC_CommodityIdentityNumber__c, XC_SplitPayment__c, XC_RecordTypeDeveloperName__c, XC_NIE_expiration_date__c, XC_NIE_expedition_date__c, XC_DocumentCountry__c, IdentityType__c, IdentityNumber__c, XC_PEC_Email__c,PrimaryEmail__c,//START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract, Added new fields CommodityCustomerName__c,CommodityIdentityNumber__c in select
                            (SELECT id, XC_DocumentType__c, XC_DocumentNumber__c FROM Personal_Documents__r)
                        FROM Account 
                        WHERE Id =:accountId limit 1];
            recordTypeName = a.XC_RecordTypeDeveloperName__c;
            stream = a.XC_Segment__c;
            if((stream == 'B2B' || stream == 'B2G') && itaLE.contains(String.valueOf(mapResult.get('legalEntity')))){
                if(a.XC_PEC_Email__c){
                    mapResult.put('pec',a.PrimaryEmail__c);
                }
            }
             //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
            if(stream == 'B2C' && a!=null && !string.isBlank(a.XC_DocumentCountry__c) && a.XC_DocumentCountry__c=='Brazil')
            {
                  mapResult.put('commodityCustomerName',a.XC_CommodityCustomerName__c);
                  mapResult.put('commodityIdentityNumber',a.XC_CommodityIdentityNumber__c);
            }
             //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->

            if(recordTypeName == 'XC_GLO_Account_Residential' && !a.Personal_Documents__r.isEmpty()){
               mapResult.put('listPersonalDocument', retrievePersonalDocument(a.Personal_Documents__r)); 
            }else if(recordTypeName == 'XC_GLO_Account_Soho' || recordTypeName == 'XC_GLO_B2B' || recordTypeName == 'XC_GLO_B2G'){
                XC_SohoDocumentWrapper docWrap = new XC_SohoDocumentWrapper();
                docWrap.docCountry = a.XC_DocumentCountry__c;
                docWrap.identityType = a.IdentityType__c;
                docWrap.identityNumber = a.IdentityNumber__c;
                docWrap.NIEExpeditionDate = a.XC_NIE_expedition_date__c;
                docWrap.NIEExpirationdate = a.XC_NIE_expiration_date__c;

                mapResult.put('sohoDocument',docWrap);
            }

            mapResult.put('splitPayment',a.XC_SplitPayment__c ? 'Yes' : 'No');
            mapResult.put('sepaMandateValues',getSepaMandatePickList());
        }
        List<Map<String,String>> contacts = new List<Map<String,String>>();
        //Set<String> itaLE = new Set<String>{'EnelXItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMobility','Cogenio'};
        //[begin gs, 26/07/2022, INC000089161770]
        //if((stream == 'B2B' || stream == 'B2G') && itaLE.contains(String.valueOf(mapResult.get('legalEntity')))){
        if(stream == 'B2B' || stream == 'B2G'){
        //[end gs, 26/07/2022, INC000089161770]
            contacts = XC_UTIL_Account.getContactsOfAccountRelationPicklist(accountId);
            mapResult.put('isB2BG', stream);

        }else {
            contacts = XC_UTIL_Account.getContactsOfAccountPicklist(accountId);
        }
        mapResult.put('billingContacts', contacts);
        mapResult.put('soldContacts', contacts);

        List<Map<String,String>> taxExempt = getTaxExemptPickList();
        mapResult.put('taxExempt', '');
        mapResult.put('taxExemptOpts',taxExempt);
        List<Map<String,String>> invoiceDeliveryPreferencesPick = getinvoiceDeliveryPreferencesPickList(XC_UTIL_User.getLegalEntityFromUser());
        mapResult.put('invoiceDeliveryPreferencesPick',invoiceDeliveryPreferencesPick);
        mapResult.put('recordTypeName', recordTypeName);
        mapResult.put('isB2BLE',checkB2BStream(stream));
        mapResult.put('stream',stream);
        mapResult.put('showContactExtraFields',retrieveContactExtraFields(stream, mapResult.get('legalEntity'), mapResult.get('sohoDocument')));
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapResult -> ' + mapResult);
        //CR NR0939 - MC 20200909
        Map<String, XC_CM_LegalEntity_Configuration__mdt> leMapping = 
            XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(new Set<String>{(String)mapResult.get('legalEntity')}, new Set<String>{stream});
        if(leMapping.get(mapResult.get('legalEntity')+stream) != null){
            mapResult.put('getContractBy', leMapping.get(mapResult.get('legalEntity')+stream).XC_GetContractBy__c);
        }

        /*XC_UTIL_Debug.debug(DEBUGACTIVE, 'initPaimentPage mapResult='+mapResult);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'delivery mapResult='+mapResult.get('invoiceDeliveryPreferencesPick'));
        for(String o : mapResult.keySet()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'oo'+o);
        }*/

        return JSON.serialize(mapResult);
    }




    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to retrieve ADDRESS
     * @param addressId

     *@return List<Map<String,String>>
    */
    private static List<Map<String,String>> getPodOfAccountPicklist(String accountId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In getPodOfAccountPicklist');
        if(!Schema.sObjectType.XC_Address__c.isAccessible()){
            return new List<Map<String,String>>();
        }
        List<XC_Address__c> address = [
                SELECT Id, XC_StreetType__c, XC_StreetTypeText__c, XC_City__c, XC_Address__c, XC_BillingAddress__c, XC_PostalCode__c, XC_InstallationAddress__c, XC_StreetNumber__c, XC_AddressCountry__c
                FROM XC_Address__c
                WHERE XC_Account__c = :accountId and CreatedById != '0051i000002EpBCAA0'
        ];
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ address -> ' + address );
        List<Map<String,String>> results = new List<Map<String,String>>();
        for(XC_Address__c a : address){
            if(a.XC_BillingAddress__c){
                String addressString = a.XC_Address__c + ', '+ a.XC_StreetNumber__c + ', '+ a.XC_City__c+ ', '+ a.XC_PostalCode__c + ', '+ a.XC_AddressCountry__c;
                Map<String,String> row = new Map<String,String>();
                row.put('key',a.Id);
                row.put('value', addressString);
                results.add(row);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ results -> ' + results);
        return results;
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to retrieve soldAddress
     * @param accountId
     * @param isCommodity
     *@return List<Map<String,String>>
    */
    @AuraEnabled
    public static List<Map<String,String>> getSoldAddressofAccountPicklist(String accountId, Boolean isCommodity){
        List<XC_Address__c> address = new List<XC_Address__c>();
        if(isCommodity){
            address = [SELECT Id, XC_StreetType__c, XC_StreetTypeText__c, XC_AddressCountry__c,XC_City__c,XC_Address__c,XC_DeliveryAddress__c,XC_BillingAddress__c,XC_PostalCode__c ,XC_InstallationAddress__c, XC_StreetNumber__c FROM  XC_Address__c WHERE XC_Account__c = :accountId  AND CreatedById != '0051i000002EpBCAA0'  AND (XC_GasCUPS__c!=null OR XC_ElectricCUPS__c!=null) ];
        }
        else{
            address = [SELECT Id, XC_StreetType__c, XC_StreetTypeText__c, XC_AddressCountry__c,XC_City__c,XC_Address__c,XC_DeliveryAddress__c,XC_BillingAddress__c,XC_PostalCode__c ,XC_InstallationAddress__c, XC_StreetNumber__c FROM  XC_Address__c WHERE XC_Account__c = :accountId  AND CreatedById != '0051i000002EpBCAA0' ];
        }

        List<Map<String,String>> results = new List<Map<String,String>>();
        for(XC_Address__c a : address){
            if(a.XC_DeliveryAddress__c){
                String addressString = a.XC_Address__c + ', '+ a.XC_StreetNumber__c + ', '+ a.XC_City__c+ ', '+ a.XC_PostalCode__c + ', '+ a.XC_AddressCountry__c;
                Map<String,String> row = new Map<String,String>();
                row.put('key',a.Id);
                row.put('value', addressString);
                results.add(row);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ results -> ' + results);
        return results;
    }


    @AuraEnabled
    public static String linkPaymentMethodToAccount(String zuoraAccountId, String paymentMethodId, String entityName){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In linkPaymentMethodToAccount');
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        ZuoraWebservice.LinkPaymentMethodToAccountResponse resp = zws.linkPaymentMethodToAccount(zuoraAccountId, paymentMethodId);
        return JSON.serialize(resp);
    }


    /* @AuraEnabled
     public static String createUnlinkedZuoraAccount(String account, String billingContact, String soldContact, String entityName){
         Contact billTo = (Contact) JSON.deserialize(billingContact, Contact.class);
         Contact soldTo = (Contact) JSON.deserialize(soldContact, Contact.class);
         Account salesforceAccount = (Account) JSON.deserialize(account, Account.class);
         ZuoraWebservice zws = new ZuoraWebservice(entityName);
         ZuoraWebservice.CreateZuoraAccountResponse resp = zws.createUnlinkedZuoraAccount(salesforceAccount, billTo, soldTo);
         return JSON.serialize(resp);
     }*/

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to Create Billing Profile And Bpli
     * @param billTo
     * @param soldTo
     * @param billAddress
     * @param soldAddress
     * @param info
     *@return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createBillingProfile(String billTo, String soldTo, String billAddress, String soldAddress, String info){
        Map<String, Object> optionsMap = (Map<String, Object>)JSON.deserializeUntyped(info);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In createBillingProfile con '+optionsMap);

        String legalEntity = String.valueOf(optionsMap.get('legal'));
        String cardNumber = '';
        String subNumber = '';
        if(optionsMap.containsKey('cardNumber')){
            cardNumber = String.valueOf(optionsMap.get('cardNumber'));
            subNumber ='  ****-****-****-'+cardNumber.substring(12);
        }

        String month = '';
        if(optionsMap.containsKey('month')){
            month = String.valueOf(optionsMap.get('month'));
        }

        String year = '';
        if(optionsMap.containsKey('year')){
            year = String.valueOf(optionsMap.get('year'));
            year = year.substring(2);
        }

        String lang = '';
        if(optionsMap.containsKey('lang')){
            lang = String.valueOf(optionsMap.get('lang'));
        }

        String accountNumber = '';
        if(optionsMap.containsKey('accountNumber')){
            accountNumber = String.valueOf(optionsMap.get('accountNumber'));
        }

        String bic = '';
        if(optionsMap.containsKey('bic')){
            bic = String.valueOf(optionsMap.get('bic'));
        }

        String contractId = '';
        if(optionsMap.containsKey('contractId')){
            contractId = String.valueOf(optionsMap.get('contractId'));
        }

        /*20220402 NicoloFodera correctly ingest CommodityBP [start]*/
        String commodityBP = '';
        if(optionsMap.containsKey('commodityAccountId')){
            commodityBP = String.valueOf(optionsMap.get('commodityAccountId'));
        }
        /*20220402 NicoloFodera correctly ingest CommodityBP [end]*/

        String contractType = '';
        if(optionsMap.containsKey('contractType')){
            String ctype= String.valueOf(optionsMap.get('contractType'));
            contractType = ctype == '01' ? 'ELECTRIC' : ctype == '02' ? 'GAS' : ctype == 'ELE' ? 'ELECTRIC' : 'GAS';
        }

        String cupsId = '';
        if(optionsMap.containsKey('cupsId')){
            cupsId = String.valueOf(optionsMap.get('cupsId'));
        }

        String interactionId = '';
        if(optionsMap.containsKey('interactionId')){
            interactionId = String.valueOf(optionsMap.get('interactionId'));
        }

        String siaToken ='';
        if(optionsMap.containsKey('siaPayment')){
            String siaTokenToParse = String.valueOf(optionsMap.get('siaPayment'));
            if(siaTokenToParse != 'createZuoraCustomer'){
                Map<String, Object> siaTokenMap = (Map<String, Object>)JSON.deserializeUntyped(siaTokenToParse);
                siaToken = String.valueOf(siaTokenMap.get('debtorCode'));
            }
        }

        String invoiceDel = '';
        if(optionsMap.containsKey('invoiceDel')){
            invoiceDel = String.valueOf(optionsMap.get('invoiceDel'));
        }
        String paymentTerm = '';
        if (optionsMap.containsKey('paymentTerm')) {
            paymentTerm = String.valueOf(optionsMap.get('paymentTerm'));
        }
        String taxExempt = '';
        if (optionsMap.containsKey('taxInfo')) {
            taxExempt = String.valueOf(optionsMap.get('taxInfo'));
        }

        String docNum = '';
        String docType = '';
        String docCountry = '';
        if(optionsMap.containsKey('docNif')){
            docType = String.valueOf(optionsMap.get('docNif'));
        }

        if(optionsMap.containsKey('docNumber')){
            docNum = String.valueOf(optionsMap.get('docNumber'));
        }

        if(optionsMap.containsKey('docCountry')){
            docCountry = String.valueOf(optionsMap.get('docCountry'));
        }

        //External financing information
        String financialInstitute = '';
        String otherFinancialInstitute = '';
        if(optionsMap.containsKey('financialInstitute')){
            financialInstitute = String.valueOf(optionsMap.get('financialInstitute'));
        }

        if(optionsMap.containsKey('otherFinancialInstitute')){
            otherFinancialInstitute = String.valueOf(optionsMap.get('otherFinancialInstitute'));
        }

        String contractStatus = 'Active';
        if(optionsMap.containsKey('commodityContractStatus')){
            contractStatus = String.valueOf(optionsMap.get('commodityContractStatus'));
        }

        Boolean fromBillingProfile = false;
        if(optionsMap.containsKey('fromBillingProfile')){
            fromBillingProfile = Boolean.valueOf(optionsMap.get('fromBillingProfile'));
        }

        //[Deav 21/12/2021 TPB: populate TPBCode for BillingProfileLineItem START]
        String ordId = String.valueOf(optionsMap.get('ordId'));
        List<NE__Order_Item_Attribute__c> orderItemAttList = new List<NE__Order_Item_Attribute__c>();
        String tpbCode = '';
        Boolean updateOrderAddress = false;
        if(!String.isBlank(ordId)){
            orderItemAttList= [SELECT Id, NE__Value__c, NE__Order_Item__r.NE__OrderId__r.NE__Type__c, NE__Order_Item__r.NE__OrderId__r.XC_Subtype__c
                               FROM NE__Order_Item_Attribute__c
                               WHERE Name = 'Partner Code' and  NE__Order_Item__r.NE__OrderId__c =: ordId LIMIT 1];
        }
        system.debug('@@@ orderItemAttList size: ' + orderItemAttList.size());
        if(!orderItemAttList.isEmpty()){
            tpbCode = orderItemAttList.get(0).NE__Value__c;
            List<XC_ThirdPartyConfiguration__c> tpbConfList = new List<XC_ThirdPartyConfiguration__c>([SELECT id
                                                                                                   FROM XC_ThirdPartyConfiguration__c 
                                                                                                   WHERE XC_TPBCode__c =: tpbCode]);
            if(tpbConfList.isEmpty()){
                tpbCode = '';
            }
            if(!String.isBlank(tpbCode) && 'ChangeOrder'.equalsIgnoreCase(orderItemAttList.get(0).NE__Order_Item__r.NE__OrderId__r.NE__Type__c) && 'Change Billing Profile'.equalsIgnoreCase(orderItemAttList.get(0).NE__Order_Item__r.NE__OrderId__r.XC_Subtype__c)){
                updateOrderAddress = true;
            }            
        }
        system.debug('@@@ tpbCode: ' + tpbCode);
        //[Deav 21/12/2021 TPB: populate TPBCode for BillingProfileLineItem END]

        String totalName;
        String paymentMethod = String.valueOf(optionsMap.get('paymentMethodType'));
        // String bpliSearchKey = getTranslatedBPLIPaymentSearchKey(paymentMethod);
        String billingStatus = 'Sent To Zuora';
        String mandateType;

        if(paymentMethod=='CreditCard'){
            paymentMethod = 'Credit Card';
            totalName = billingName(paymentMethod, subNumber);

        } else if(paymentMethod=='Commodity Bill'){
            paymentMethod = 'Commodity Bill';
            totalName = billingName(paymentMethod, contractId);
            if(contractStatus!='Active'){
                billingStatus = 'Waiting External Activation';
            }

        } else if(paymentMethod=='Direct Debt'){
            paymentMethod = 'Direct Debt';
            totalName = billingName(paymentMethod, accountNumber);
            mandateType = String.valueOf(optionsMap.get('sepaMandateType'));

            //check autoactivation base on LE
            List<XC_CM_LegalEntity_Configuration__mdt> currentConfiguration = [SELECT XC_LegalEntity__c,XC_DisableSDDAutoActive__c 
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c = :legalEntity AND XC_OrgId__c = :UserInfo.getOrganizationId() LIMIT 1];

            if(!currentConfiguration.isEmpty() && currentConfiguration[0].XC_DisableSDDAutoActive__c){
                billingStatus = 'Waiting External Activation';
            }

        } else if(paymentMethod=='Barcode'){
            paymentMethod = 'Barcode';
            totalName = paymentMethod;

        } else if(paymentMethod=='Bank Transfer'){
            paymentMethod = 'Bank Transfer';
            totalName = paymentMethod;

        } else if(paymentMethod=='Credit Card'){
            paymentMethod = 'Credit Card';
            totalName = paymentMethod;
            billingStatus = (fromBillingProfile) ? 'Sent To Zuora' : 'Draft';
        }else{
            totalName = paymentMethod;
        }

        //electronic invoice management IT - Adoption - F.I. 2020-03-04
        String PEC = optionsMap.containsKey('pec') ? String.valueOf(optionsMap.get('pec')) : '';
        String recipientCode = optionsMap.containsKey('recipientCode') ? String.valueOf(optionsMap.get('recipientCode')) : '';

        String billingProfileId;
        Boolean isExixtingBP = false;
        if(optionsMap.containsKey('billingProfileId') && String.isNotBlank(String.valueOf(optionsMap.get('billingProfileId')))){
            isExixtingBP = true;
            billingProfileId = String.valueOf(optionsMap.get('billingProfileId'));
            NE__Billing_Profile__c bp = [SELECT Id, Name, NE__Payment__c, XC_CommodityContractID__c, NE__Card_Type__c, XC_PayPalUsername__c, NE__Card_Number__c, NE__Expiration__c, NE__Expiration_Year__c, NE__Iban__c
                                        FROM NE__Billing_Profile__c
                                        WHERE Id =:billingProfileId LIMIT 1];
            totalName = bp.Name;

            if(bp.NE__Payment__c == 'Commodity Bill' && String.isBlank(bp.XC_CommodityContractID__c) ||
                (bp.NE__Payment__c == 'Credit Card' && String.isBlank(bp.NE__Card_Type__c)) ||
                (bp.NE__Payment__c == 'Credit Card' && bp.NE__Card_Type__c == 'PayPal' && String.isBlank(bp.XC_PayPalUsername__c)) ||
                (bp.NE__Payment__c == 'Credit Card' && bp.NE__Card_Type__c != 'PayPal' && (String.isBlank(bp.NE__Card_Number__c) || String.isBlank(bp.NE__Expiration__c) || String.isBlank(bp.NE__Expiration_Year__c))) ||
                (bp.NE__Payment__c == 'Direct Debt' && String.isBlank(bp.NE__Iban__c))) {
                    XC_UTIL_ResultWrapper wrNew = new XC_UTIL_ResultWrapper();
                    wrNew.success = false;
                    wrNew.resultMessage = Label.XC_CL_BillingProfile_MissingRequiredFields;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrNew -> ' + wrNew);
                    return wrNew;
            }
        }

        if(!fromBillingProfile){
            NE__Billing_Profile__c billingProfile = new NE__Billing_Profile__c(
                    Name = totalName, NE__Payment__c = paymentMethod, NE__Account__c = String.valueOf(optionsMap.get('accountId')),
                    NE__Card_Number__c = cardNumber, NE__Expiration__c = month, NE__Expiration_Year__c = year,
                    NE__Iban__c = accountNumber, XC_CommodityContractID__c = contractId, XC_CommodityCupsID__c = cupsId,
                    XC_BIC__c = bic,XC_Status__c = billingStatus, XC_SAPBusinessPartner__c = commodityBP /*20220402 NicoloFodera correctly ingest CommodityBP, added XC_SAPBusinessPartner__c = commodityBP */
            );

            if(String.isNotBlank(mandateType)){
                billingProfile.XC_MandateType__c = mandateType;
            }
            if(String.isNotBlank(invoiceDel)){
                billingProfile.XC_InvoiceDeliveryPref__c = invoiceDel;
            }

            if(String.isNotBlank(taxExempt)){
                billingProfile.XC_TaxExemption__c = taxExempt;
            }

            if(paymentMethod == 'Direct Debt' || paymentMethod == 'External Financing'){
                billingProfile.XC_LegalEntity__c = legalEntity;
            }

            if(String.isNotBlank(contractType)){
                billingProfile.XC_CommodityContractType__c = contractType;
            }
            
            if(String.isNotBlank(paymentTerm)){
                billingProfile.XC_PaymentTerm__c = paymentTerm;
            }

            if(paymentMethod == 'External Financing'){
                if(String.isNotBlank(financialInstitute)){
                    billingProfile.XC_FinancialInstitute__c = financialInstitute;
                }
    
                if(String.isNotBlank(otherFinancialInstitute)){
                    billingProfile.XC_OtherFinancialInstitute__c = otherFinancialInstitute;
                }
            }

            XC_UTIL_Sobject.WrapperResult w = XC_UTIL_Sobject.insertRecord(billingProfile);
            if(!w.success){
                XC_UTIL_ResultWrapper wrNew = new XC_UTIL_ResultWrapper();
                wrNew.success = false;
                wrNew.resultMessage = Label.XC_CL_BillingProfile_ErrorInsert +w.errorMessage;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrNew -> ' + wrNew);
                return wrNew;
            }
            billingProfileId = billingProfile.Id;

        }

        Contact cBillTo = (Contact) JSON.deserialize(billTo, Contact.class);
        Contact cSoldTo = (Contact) JSON.deserialize(soldTo, Contact.class);
        XC_BillingProfileLineItem__c billingProfileLineItem = new XC_BillingProfileLineItem__c(
                XC_BillingProfile__c = billingProfileId, XC_BillingProfileCopy__c = billingProfileId,
                XC_BillToAddress__c = billAddress, XC_SoldToAddress__c = soldAddress,
                XC_BillToContactId__c = cBillTo.Id, XC_SoldToContactId__c = cSoldTo.Id,
                XC_LegalEntity__c = legalEntity, XC_BillingProfileName__c = totalName,
                XC_DocumentType__c = docType,XC_DocumentNumber__c = docNum,XC_DocumentCountry__c = docCountry,
                XC_Status__c = billingStatus,
                XC_InvoicePreferredLanguage__c = lang, 
                XC_InvoiceDeliveryPreference__c = (invoiceDel==Label.XC_CL_BpliInvoiceDeliveryPrefSmInvoice) ? Label.XC_CL_BpliInvoiceDeliveryPref : invoiceDel
        );
        if(String.isNotBlank(PEC)){
            billingProfileLineItem.XC_PEC__c = PEC;
        }

        String isB2BG = '';
        if(optionsMap.containsKey('isB2BG')){
            isB2BG = String.valueOf(optionsMap.get('isB2BG'));
        }

        if(String.isNotBlank(recipientCode) && isB2BG == 'B2B'){
            billingProfileLineItem.XC_RecipientCodeB2B__c = recipientCode;
        } else if(String.isNotBlank(recipientCode) && isB2BG == 'B2G'){
            billingProfileLineItem.XC_OfficeCode__c = recipientCode;
        }else if(String.isNotBlank(recipientCode)){
            billingProfileLineItem.XC_RecipientCode__c = recipientCode;
        }

        //[Deav 21/12/2021 TPB: populate TPBCode for BillingProfileLineItem START]
        if(!String.isBlank(tpbCode)){
            billingProfileLineItem.XC_TPBCode__c = tpbCode;
        }
        //[Deav 21/12/2021 TPB: populate TPBCode for BillingProfileLineItem END]

        XC_UTIL_Sobject.WrapperResult wBPLI = XC_UTIL_Sobject.insertRecord(billingProfileLineItem);
        XC_UTIL_ResultWrapper wrNew;
        //XC_UTIL_ResultWrapper wrNew = new XC_UTIL_ResultWrapper(XC_UTIL_Sobject.insertRecord(billingProfileLineItem));
        if(!wBPLI.success){
            wrNew = new XC_UTIL_ResultWrapper();
            wrNew.success = false;
            wrNew.resultMessage = Label.XC_CL_BillingProfileLineItem_ErrorInsert + ' ' + wBPLI.errorMessage;
            wrNew.typeMessage = 'BPLI error';
            InputRollbackWrapper inputRollback =  new InputRollbackWrapper();
            inputRollback.billingProfileLineItemId = null;
            inputRollback.billingProfileId = billingProfileId;
            inputRollback.errorMessage = wBPLI.errorMessage;
            inputRollback.doRollback = !isExixtingBP; // true;
            rollbackForErrorBPLI(inputRollback);
            return wrNew;
        } else {
            wrNew = new XC_UTIL_ResultWrapper(wBPLI);
            wrNew.success = true;
            //[Deav 21/12/2021 TPB: populate TPBCode for BillingProfileLineItem START]
            if(updateOrderAddress){
                NE__Order__c ord = [SELECT Id, XC_DeliveryAddress__c
                                    FROM NE__Order__c
                                    WHERE Id =: ordId];
                ord.XC_DeliveryAddress__c = soldAddress;
                update ord;
            }
            //[Deav 21/12/2021 TPB: populate TPBCode for BillingProfileLineItem END]
        }
        if(billingProfileId!=null){
            NE__Billing_Profile__c bp = [
                    SELECT id, XC_SepaMandate__c, XC_SepaMandateDate__c
                    FROM NE__Billing_Profile__c
                    WHERE Id=: billingProfileId
            ];

            wrNew.objectInfo = JSON.serialize(bp);
            wrNew.fieldName = billingProfileId; // invertiti il 06/08/2019
            wrNew.fieldName2 = cSoldTo.id;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrNew -> ' + wrNew);
        System.debug('eleni ' + wrNew);
        System.debug('eleni ' + wBPLI);
        return wrNew;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Method to call Sia and manage Operation after call
    * @param contactId
    * @param lang
    * @param paymentMethod
    * @param billingProfileId

    *@return XC_UTIL_ResultWrapper
   */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper manageOperationBeforeCallSia(String contactId, String lang, String paymentMethod, String billingProfileId){
        XC_UTIL_ResultWrapper wrNew = new XC_UTIL_ResultWrapper();

        Map<id,NE__Billing_Profile__c> bprofMap = new Map<id,NE__Billing_Profile__c>([
                SELECT Id, XC_Token__c, XC_MandateType__c, NE__Iban__c, XC_SepaMandate__c, XC_SepaMandateDate__c,
                (SELECT Id FROM Billing_Profile_Line_Items__r)
                FROM NE__Billing_Profile__c
                WHERE id=: billingProfileId
        ]);
        NE__Billing_Profile__c bprof = bprofMap.values()[0];

        XC_REST_PaymentMethodSIA.ResultWrapper restWr = new XC_REST_PaymentMethodSIA.ResultWrapper();
        if(paymentMethod=='Credit Card'){
            restWr = callSIAForCreditCard(contactId, bprof);

            if(restWr.paymentMethodSIA!=''&&restWr.success){
                Map<String,Object> siaValues = (Map<String,Object>)JSON.deserializeUntyped(restWr.paymentMethodSIA);
                bprof.XC_Token__c = String.valueOf(siaValues.get('debtorCode'));
                wrNew.objectInfo = restWr.paymentMethodSIA;
                wrNew.success = true;

            } else {
                wrNew.resultMessage = restWr.errorMessage;
                wrNew.success = false;
            }

        }else if(paymentMethod=='Direct Debt'){
            XC_REST_PaymentMethodSIA_U.ResponseWrapper res = callSIAForSEPA(contactId, bprof);

            if(String.isNotBlank(res.debtorCode)){
                bprof.XC_Token__c = res.debtorCode;
                bprof.XC_CreateMandate__c = true;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'fino a qui');
                XC_UTIL_Sobject.updateRecord(bprof);
                wrNew.objectInfo = JSON.serialize(res, true);
                wrNew.success = true;

            } else {
                wrNew.objectInfo = JSON.serialize(res, true);
                wrNew.resultMessage = restWr.errorMessage;
                wrNew.success = true;

                //DELETE BP AND BPLI
                delete bprofMap.values()[0];
                delete bprofMap.values()[0].Billing_Profile_Line_Items__r;

            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrNew -> ' + wrNew);
        return wrNew;
    }

    /**
    * @description call SIA and manage deletion of BP in case of error, with option
    * @author Francesco Imperioli - fimperioli@deloitte.it | 09-21-2020 
    * @param contactId 
    * @param lang 
    * @param paymentMethod 
    * @param billingProfileId 
    * @param manageDelete 
    * @return XC_UTIL_ResultWrapper 
    **/
    public static XC_UTIL_ResultWrapper manageOperationBeforeCallSiaWithOption(String contactId, String lang, String paymentMethod, String billingProfileId,Boolean manageDelete){

        XC_UTIL_ResultWrapper wrNew = new XC_UTIL_ResultWrapper();

        Map<id,NE__Billing_Profile__c> bprofMap = new Map<id,NE__Billing_Profile__c>([
                SELECT Id, XC_Token__c, XC_MandateType__c, NE__Iban__c, XC_SepaMandate__c, XC_SepaMandateDate__c,
                (SELECT Id FROM Billing_Profile_Line_Items__r)
                FROM NE__Billing_Profile__c
                WHERE id=: billingProfileId
        ]);
        NE__Billing_Profile__c bprof = bprofMap.values()[0];

        XC_REST_PaymentMethodSIA.ResultWrapper restWr = new XC_REST_PaymentMethodSIA.ResultWrapper();
        if(paymentMethod=='Credit Card'){
            restWr = callSIAForCreditCard(contactId, bprof);

            if(restWr.paymentMethodSIA!=''&&restWr.success){
                Map<String,Object> siaValues = (Map<String,Object>)JSON.deserializeUntyped(restWr.paymentMethodSIA);
                bprof.XC_Token__c = String.valueOf(siaValues.get('debtorCode'));
                wrNew.objectInfo = restWr.paymentMethodSIA;
                wrNew.success = true;

            } else {
                wrNew.resultMessage = restWr.errorMessage;
                wrNew.success = false;
            }

        }else if(paymentMethod=='Direct Debt'){
            XC_REST_PaymentMethodSIA_U.ResponseWrapper res = callSIAForSEPA(contactId, bprof);

            if(String.isNotBlank(res.debtorCode)){
                bprof.XC_Token__c = res.debtorCode;
                bprof.XC_CreateMandate__c = true;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'fino a qui');
                XC_UTIL_Sobject.updateRecord(bprof);
                wrNew.objectInfo = JSON.serialize(res, true);
                wrNew.success = true;

            } else{

                wrNew.objectInfo = JSON.serialize(res, true);
                wrNew.resultMessage = restWr.errorMessage;
                wrNew.success = true;

                //DELETE BP AND BPLI
                if(manageDelete){
                    delete bprofMap.values()[0];
                    delete bprofMap.values()[0].Billing_Profile_Line_Items__r;
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrNew -> ' + wrNew );
        return wrNew;

    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Method to concatenate Name
    * @param paymentMethod
    * @param paymentString
    *@return String
   */
    public static String billingName (String paymentMethod, String paymentString){
        return paymentMethod+' - '+paymentString;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description New Method to create Zuora Customer Account
    * @param account
    * @param billingContact
    * @param soldContact
    * @param entityName
    * @param options
    * @param billingProfLineItemId
    * @param zuoraPayment
    *@return String
   */
  @AuraEnabled
  public static String createUnlinkedZuoraAccount(String account, String billingContact, String soldContact, String entityName, String options, String billingProfLineItemId, String zuoraPayment){
        return createUnlinkedZuoraAccount(account, billingContact, soldContact, entityName, options, billingProfLineItemId, zuoraPayment, false);
  }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description New Method to create Zuora Customer Account
    * @param account
    * @param billingContact
    * @param soldContact
    * @param entityName
    * @param options
    * @param billingProfLineItemId
    * @param zuoraPayment
    * @param doRollback
    *@return String
   */
    @AuraEnabled
    public static String createUnlinkedZuoraAccount(String account, String billingContact, String soldContact, String entityName, String options, String billingProfLineItemId, String zuoraPayment, Boolean doRollback){
        Contact billTo = (Contact) JSON.deserialize(billingContact, Contact.class);
        Contact soldTo = (Contact) JSON.deserialize(soldContact, Contact.class);
        Account salesforceAccount = (Account) JSON.deserialize(account, Account.class);
        //Inizio GDB 10/01/2020
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(zuoraPayment);
        String dc = String.valueOf(m.get('docCountry'));
        if(!String.isblank(dc)){
            List<XC_CM_CountryISOCodeAssociation__mdt> countryCode = [SELECT XC_ISOCode__c FROM XC_CM_CountryISOCodeAssociation__mdt WHERE XC_Country__c =: dc];
            m.put('countryCode' , countryCode[0].XC_ISOCode__c);
            zuoraPayment = JSON.serialize(m);
        }
        //Fine GDB 10/01/2020
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        String stream = salesforceAccount.XC_Segment__c;
        if(String.isBlank(stream)) {
            stream = [SELECT XC_Segment__c FROM Account WHERE Id =: salesforceAccount.Id].XC_Segment__c;
            salesforceAccount.XC_Segment__c = stream;
        }

        //if (entityName.contains('B2B')){
        if (checkB2BStream(stream)){
            ZuoraWebservice.CreateZuoraAccountResponse resp = zws.createUnlinkedZuoraAccountB2B(salesforceAccount, billTo, soldTo, options,billingProfLineItemId,zuoraPayment);
            return JSON.serialize(resp);
        }

        ZuoraWebservice.CreateZuoraAccountResponse resp = zws.createUnlinkedZuoraAccount(salesforceAccount, billTo, soldTo, options,billingProfLineItemId,zuoraPayment);
        if(resp.success.toLowerCase() != 'true') {
            rollbackForError(billingProfLineItemId, resp.reasons[0].code + ' - ' + resp.reasons[0].message, doRollback, (Boolean) m.get('fromBillingProfile'));
        }
        return JSON.serialize(resp);
    }

    @AuraEnabled
    public static String createZuoraAccount(String account, String paymentMethodId,String paymentMethodType, String billingContact, String soldContact, String entityName){
        Contact billTo = (Contact) JSON.deserialize(billingContact, Contact.class);
        Contact soldTo = (Contact) JSON.deserialize(soldContact, Contact.class);
        Account salesforceAccount = (Account) JSON.deserialize(account, Account.class);
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        ZuoraWebservice.CreateZuoraAccountResponse resp = zws.createZuoraAccount(salesforceAccount, paymentMethodId, paymentMethodType, billTo, soldTo);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In resp ' + resp);
        return JSON.serialize(resp);
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Method to retriveContactsForZuora component
    * @param accountId
    * @param mapValues
    * @return String
    */
    @AuraEnabled
    public static String retriveContactsForZuora(String accountId, String mapValues){
        XC_ContactAddress_Wrapper wr1 = new XC_ContactAddress_Wrapper();
        XC_ContactAddress_Wrapper wr2 = new XC_ContactAddress_Wrapper();
        Map<String,Object> resultMap = new Map<String,Object>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'MapValues in retriveContactsForZuora = '+mapValues);
        Map<String,Object> values = (Map<String,Object>)JSON.deserializeUntyped(mapValues);
        String legalEntity = (String)values.get('legal');
        Account acc = prepareAccountForZuora(accountId);
        //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
        if(acc!=null && acc.XC_Country__c.equalsIgnoreCase('Brazil') && acc.XC_Segment__c.equalsIgnoreCase('B2C'))
        {
            Account acc1=new Account (Id = accountId, XC_CommodityCustomerName__c = (String)values.get('commodityCustomerName'), XC_CommodityIdentityNumber__c=(String)values.get('commodityIdentityNumber'));
            XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            update acc1;
            XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            resultMap.put('commodityCustomerName',acc1.XC_CommodityCustomerName__c);
            resultMap.put('commodityIdentityNumber',acc1.XC_CommodityIdentityNumber__c);
        }
        //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
        wr1 = prepareContactForZuora((String)values.get('soldContact'),(String)values.get('billingAddress'), legalEntity);
        wr2 = prepareContactForZuora((String)values.get('soldContact'),(String)values.get('soldAddress'), legalEntity);
        Contact billTo = wr1.c;
        Contact soldTo = wr2.c;
        String billAddress = wr1.addressId;
        String soldAddress = wr2.addressId;
        //String entityName = XC_UTIL_Integration_U.getEntityName(legalEntity);
        String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, acc.XC_Segment__c);
        resultMap.put('billTo',billTo);
        resultMap.put('soldTo',soldTo);
        resultMap.put('billAddress',billAddress);
        resultMap.put('soldAddress',soldAddress);
        resultMap.put('account',acc);
        resultMap.put('entityName',entityName);
        System.debug('entityName'+entityName);
        System.debug(resultMap.get('billTo'));
        Map<String, XC_CM_LegalEntity_Configuration__mdt> leMapping = XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(new Set<String>{legalEntity}, new Set<String>{acc.XC_Segment__c});
        if(leMapping.get(legalEntity+acc.XC_Segment__c)!=null) {
            resultMap.put('ZuoraSequenceSetId', leMapping.get(legalEntity+acc.XC_Segment__c).XC_ZuoraSequenceSetId__c);

            // VAT GROUP TYPE SEQUENCE SET
            if(acc.XC_VatGroupType__c != null && acc.XC_VatGroupType__c.equalsIgnoreCase('Gruppo IVA Enel')) {
                resultMap.put('VatGroupSequenceSetId', leMapping.get(legalEntity+acc.XC_Segment__c).XC_VatGroup_SequenceSet__c);
            }
        }        
        
            /*String paymentMethodId = (String)values.get('payment');
        Map<String,String> hostedPageValue = setHostedPageId(paymentMethodId);
        ZuoraWebservice zws = new ZuoraWebservice(hostedPageValue.get('entityName'));
        String params =  generateParams(zws, hostedPageValue.get('hostedPageId'));
        resultMap.put('params',params);*/
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In resultMap ' + resultMap);
        return JSON.serialize(resultMap);
    }

    @AuraEnabled
    public static String generateParamsFromPaymentMethodType(String accountId, String paymentMethodType){
        Map<String, String> hpls = getHostedPageLiteSettings(accountId, paymentMethodType);
        return generateParams(hpls.get('hostedPageId'), hpls.get('entityName'));
    }

    /*@AuraEnabled
    public static String generateParamsFromPaymentMethodType(String paymentMethodType){
        Map<String, String> hpls = getHostedPageLiteSettings(paymentMethodType);
        return generateParams(hpls.get('hostedPageId'), hpls.get('entityName'));
    }*/

    private static String generateParams(String hostedPageId, String entityName){
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        ZuoraWebservice.GenerateRSASignatureResponse res =  zws.generateRSASignature(hostedPageId);
        String jsonString = '{"id":"'+hostedPageId+'", "style":"inline", "submitEnabled":"true", "url":"https://sandbox.eu.zuora.com/apps/PublicHostedPageLite.do","signature": "'+res.signature+'","token": "'+res.token+'","tenantId": "'+res.tenantId+'", "key": "'+res.key+'","entityName": "'+entityName+'"}';
        return  jsonString;
    }

    private static Map<String, String> getHostedPageLiteSettings(String accountId, String paymentMethodType){
        if(!Schema.sObjectType.Account.isAccessible()){
            return new Map<String, String>();
        }

        List<Account> accounts = [Select XC_Country__c from Account WHERE Id =: accountId];

        Map<String, String> returnMap = new Map<String, String>();
        if(accounts.size() > 0 ){
            String entityName = '%'+accounts[0].XC_Country__c+'%';
            String name =   'z%'+paymentMethodType+'_Zuora';

            if(Schema.sObjectType.zqu__HostedPageLiteSetting__c.isAccessible()){
                List<zqu__HostedPageLiteSetting__c>  hostedPageLiteSettings = [select zqu__PageId__c, zqu__BillingEntity__r.zqu__EntityName__c from zqu__HostedPageLiteSetting__c where zqu__BillingEntity__r.zqu__EntityName__c like :entityName and Name like :name];
                if(hostedPageLiteSettings.size() > 0){
                    returnMap.put('hostedPageId', hostedPageLiteSettings[0].zqu__PageId__c);
                    returnMap.put('entityName', hostedPageLiteSettings[0].zqu__BillingEntity__r.zqu__EntityName__c);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In returnMap -> ' + returnMap);
        return returnMap;
    }

    /*private static Map<String, String> getHostedPageLiteSettings(String paymentMethodType){
        Map<String, String> returnMap = new Map<String, String>();
        String paymentMethodTypeConcat = 'z'+paymentMethodType+'_Zuora';
        List<zqu__HostedPageLiteSetting__c>  hostedPageLiteSettings = [select zqu__PageId__c, zqu__BillingEntity__r.zqu__EntityName__c from zqu__HostedPageLiteSetting__c where Name = :paymentMethodTypeConcat];
        if(hostedPageLiteSettings.size() > 0){
            returnMap.put('hostedPageId', hostedPageLiteSettings[0].zqu__PageId__c);
            returnMap.put('entityName', hostedPageLiteSettings[0].zqu__BillingEntity__r.zqu__EntityName__c);
        }
        return returnMap;
    }*/

    @AuraEnabled
    public static Boolean isCreditCardAlreadyInserted(String accountId, String maskNumber, String creditCardType){
        if(Schema.sObjectType.Zuora__PaymentMethod__c.isAccessible()){
            List<Zuora__PaymentMethod__c> paymentMethods =  [select Id from Zuora__PaymentMethod__c where Zuora__BillingAccount__r.Zuora__Account__c = :accountId and Zuora__CreditCardMaskNumber__c = :maskNumber and Zuora__CreditCardType__c = :creditCardType];
            if(paymentMethods.size()>0){
                return true;
            }
        }
        return false;
    }

    @AuraEnabled
    public static Boolean isSEPAAlreadyInserted(String accountId, String bankTransferAccountNumber){
        List<Zuora__PaymentMethod__c> paymentMethods =  [select Id from Zuora__PaymentMethod__c where Zuora__BillingAccount__r.Zuora__Account__c = :accountId and Zuora__BankTransferAccountNumber__c =:bankTransferAccountNumber];
        if(paymentMethods.size()>0){
            return true;
        }
        return false;
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to prepare Account For Zuora
     * @param accountId

     * @return Account
     */
     
    
    Private static Account prepareAccountForZuora(String accountId){
        Id accId = Id.valueOf(accountId);
        String sObjName = accId.getSObjectType().getDescribe().getName();
        If(sObjName == 'NE__Billing_Profile__c'){
            NE__Billing_Profile__c billingProf = [SELECT Id, NE__Account__c FROM NE__Billing_Profile__c WHERE Id =: accountId LIMIT 1];
            accountId = billingProf.NE__Account__c;
        }
        String fields = ZuoraWebserviceUtil.generateFieldsToQueryFromFieldSet('zqu__CustomAccountFields','Account');
        return (Account)Database.query('SELECT id, Name, XC_Segment__c, XC_SectorOfTheCompany__c, XC_Giro__c, XC_EnelXSupply__c , XC_TipoDeRegimen__c, XC_ObligacionesDelContribuyente__c, IdentityNumber__c, CurrencyIsoCode, XC_Country__c, XC_SohoType__c, XC_TradingPartner__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c, XC_IdentityNumber2__c, XC_DocumentType2__c, XC_BillingAgency__c, XC_BillingAgency__r.Name '+fields+' FROM Account where Id=:accountId')[0];
        
        //return [SELECT id, Name, CurrencyIsoCode, Country__c FROM Account where Id=:accountId][0];
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Method to prepare fake Contact For Zuora
    * @param contactId
    * @param addressId
    * @param legalEntity
    * @return XC_ContactAddress_Wrapper
     */
    public static XC_ContactAddress_Wrapper prepareContactForZuora(String contactId, String addressId, String legalEntity){
        XC_ContactAddress_Wrapper wr = new  XC_ContactAddress_Wrapper();

        if(!Schema.sObjectType.Contact.isAccessible()){
            return null;
        }
        List<Contact> contacts = [SELECT Id, Country__c, FirstName, LastName, Account.Name, XC_Preferredlanguageofcontact__c, Fax, MailingState, Email, Phone, MobilePhone, zqu__County__c, XC_Municipality__c FROM Contact WHERE Id =: contactId]; 
        List<XC_Address__c> address = [SELECT Id, XC_Municipality__c , XC_StreetTypeText__c, XC_StreetType__c, XC_FullAddress__c, XC_AddressProvince__c, XC_AddressCountry__c, XC_Stair__c, XC_Door__c, XC_Floor__c, XC_City__c, XC_Address__c, XC_DeliveryAddress__c, XC_BillingAddress__c, XC_PostalCode__c , XC_InstallationAddress__c, XC_StreetNumber__c, XC_AddressValidated__c FROM XC_Address__c WHERE Id =: addressId ];

        Contact contact = contacts[0];
        XC_Address__c a = address[0];
        Boolean hasNumber = a.XC_AddressCountry__c == 'Colombia' && String.isNotBlank(a.XC_Address__c) && String.isNotBlank(a.XC_StreetNumber__c) && a.XC_Address__c.contains(a.XC_StreetNumber__c);
        if(hasNumber){
            a.XC_Address__c = a.XC_Address__c.remove(' '+a.XC_StreetNumber__c);
        }
        
        Boolean concatenateFields;
        if(String.isNotBlank(legalEntity)) {
            concatenateFields = /*legalEntity == 'EndesaX' ||*/ legalEntity == 'EnelDistribucion' || legalEntity == 'EnelX' || legalEntity == 'Codensa';
        } else {
            concatenateFields = /*a.XC_AddressCountry__c == 'Spain' ||*/ a.XC_AddressCountry__c == 'Chile' || a.XC_AddressCountry__c == 'Colombia';
        }
        
        contact.MailingStreet = concatenateFields ? a.XC_Address__c+' '+a.XC_StreetNumber__c+' '+a.XC_PostalCode__c : a.XC_Address__c;
        contact.MailingStreet = (a.XC_AddressValidated__c && String.isNotBlank(a.XC_StreetTypeText__c) && !contact.MailingStreet.startsWithIgnoreCase(a.XC_StreetTypeText__c)) ? a.XC_StreetTypeText__c+' '+contact.MailingStreet : contact.MailingStreet;
        contact.MailingCity = a.XC_City__c;
        contact.MailingCountry = a.XC_AddressCountry__c;
        contact.MailingState = a.XC_AddressProvince__c;
        contact.MailingPostalCode = a.XC_PostalCode__c;
        contact.XC_Door__c = a.XC_Door__c;
        contact.XC_Floor__c = a.XC_Floor__c;
        contact.XC_Stair__c = a.XC_Stair__c;
        contact.XC_StreetNumber__c = a.XC_StreetNumber__c;
        //JJP - ENELx - 5/11/2021 - Start
        //NR2014 - AddInformationToInvoicesIssuedFromDTE_v2
        /*if (contact.Country__c.toLowerCase() == 'chile'){*/ contact.XC_Municipality__c = a.XC_Municipality__c;/*}*/
		//JJP - ENELx - 5/11/2021 - End
        System.debug('JJP' + contact.XC_Municipality__c);
        
        if(String.isBlank(contact.FirstName)) {
            contact.FirstName = contact.Account.Name;
        }

        wr.c = contact;
        if(!address.isEmpty()){
            wr.addressId = address[0].Id;
        }
        return wr;
    }

    @AuraEnabled
    public static String createPaymentMethod(String paymentMethod, String entityName){
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        ZuoraWebservice.CreatePaymentMethodResponse resp = zws.createPaymentMethod(paymentMethod);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In resp -> ' + resp);
        return JSON.serialize(resp);
    }

    @AuraEnabled
    public static Map<String,Object> linkAccountToExternalPaymentMethod(String accountId, String externalPaymentMethodType, String entityName){
        return ZuoraWebservice.linkAccountToExternalPaymentMethod(accountId,externalPaymentMethodType,entityName);
    }

    /**
    * @author Simone Trenta - strenta@deloitte.it
    * @description Method to call sia web Service
    * @param contactId the contact or account id
    * @param bp the billing profile
    * @return XC_REST_PaymentMethodSIA.ResultWrapper
    */
    public static XC_REST_PaymentMethodSIA.ResultWrapper callSIAForCreditCardAsynchronous(String contactId, NE__Billing_Profile__c bp){
        XC_REST_PaymentMethodSIA.ResultWrapper resultWr = new XC_REST_PaymentMethodSIA.ResultWrapper();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in callSIAForCreditCard');

        Contact c = getContactFields(contactId);
        if(c==null){
            resultWr.success = false;
            return resultWr;
        }

        if(String.isBlank(c.Email)){
            resultWr.success = false;
            resultWr.errorMessage = Label.XC_CL_Contact_NoEmail;
            return resultWr;
        }

        ID jobID = System.enqueueJob(new SiaCallbackCC(c, bp, resultWr));

        return resultWr;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Method to call sia web Service
    * @param contactId the contact or account id
    * @param bp the billing profile
    * @return XC_REST_PaymentMethodSIA.ResultWrapper
     */
    public static XC_REST_PaymentMethodSIA.ResultWrapper callSIAForCreditCard(String contactId, NE__Billing_Profile__c bp){
        XC_REST_PaymentMethodSIA.ResultWrapper resultWr = new XC_REST_PaymentMethodSIA.ResultWrapper();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in callSIAForCreditCard');

        Contact c = getContactFields(contactId);
        if(c==null){
            resultWr.success = false;
            return resultWr;
        }

        if(String.isBlank(c.Email)){
            resultWr.success = false;
            resultWr.errorMessage = Label.XC_CL_Contact_NoEmail;
            return resultWr;
        }

        resultWr = XC_REST_PaymentMethodSIA.callForCreditCard(createReqWrapperCC(bp, c), c.Id, bp.Id);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'siaValues ='+resultWr);

        Map<String,Object> siaValues = new Map<String,Object>();
        //if(resultWr.paymentMethodSIA!=''){
        if(String.isNotBlank(resultWr.paymentMethodSIA)){
            siaValues = (Map<String,Object>)JSON.deserializeUntyped(resultWr.paymentMethodSIA);
        } else {
            return resultWr;
        }

        List<Map<String,Object>> customerInteractions = new List<Map<String,Object>>();
        customerInteractions.add(createValueMap(c, String.valueOf(siaValues.get('redirectUrl')), bp.Id));

        List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.manageCustomerInteractionInsert(customerInteractions);
        resultWr.interactionRecordId = '';
        if(results!=null && results[0]!=null){
            resultWr.interactionRecordId = results[0].recordId;
        }

        return resultWr;

    }

    /**
    * @author Simone Trenta - strenta@deloitte.it
    * @description Method to call sia web Service
    * @param contactId
    * @param bp the billing profile
    * @return XC_REST_PaymentMethodSIA_U.ResponseWrapper
     */
    public static XC_REST_PaymentMethodSIA_U.ResponseWrapper callSIAForSEPA(String contactId, NE__Billing_Profile__c bp){
        XC_REST_PaymentMethodSIA_U.ResponseWrapper resultWr = new XC_REST_PaymentMethodSIA_U.ResponseWrapper();
        XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA requestWr = new XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA();

        Contact c = getContactFields(contactId);
        if(c==null){
            return resultWr;
        }

        requestWr = createReqWrapperSDD(bp, c);

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'req for sepa: '+requestWr);

        resultWr = XC_REST_PaymentMethodSIA.callForSEPA(requestWr);

        return resultWr;
    }

    /**
    * @author Simone Trenta - strenta@deloitte.it
    * @description Method to call sia web Service
    * @param contactId
    * @param bp the billing profile
    * @return XC_REST_PaymentMethodSIA_U.ResponseWrapper
     */
    public static XC_REST_PaymentMethodSIA_U.ResponseWrapper callSIAForSEPAAsynchronous(String contactId, NE__Billing_Profile__c bp){
        XC_REST_PaymentMethodSIA_U.ResponseWrapper resultWr = new XC_REST_PaymentMethodSIA_U.ResponseWrapper();
        XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA requestWr = new XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA();

        Contact c = getContactFields(contactId);
        if(c==null){
            return resultWr;
        }

        requestWr = createReqWrapperSDD(bp, c);

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'req for sepa: '+requestWr);

        ID jobID = System.enqueueJob(new SiaCallbackSDD(requestWr, bp));

        return resultWr;
    }

    /**
    * @author Francesco Imperioli - fimperioli@deloitte.it
    * @description Method to call sia web Service for Debtor cade and manages asynchronous zuora data creation
    * @param contactId
    * @param bp the billing profile
    * @return XC_REST_PaymentMethodSIA_U.ResponseWrapper
     */
    public static XC_REST_PaymentMethodSIA_U.ResponseWrapper callSIAForSEPAAsynchronous(String contactId, NE__Billing_Profile__c bp,Map<String,String> zuoraOptionsMap){
        XC_REST_PaymentMethodSIA_U.ResponseWrapper resultWr = new XC_REST_PaymentMethodSIA_U.ResponseWrapper();
        XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA requestWr = new XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA();

        Contact c = getContactFields(contactId);
        if(c==null){
            return resultWr;
        }

        requestWr = createReqWrapperSDD(bp, c);

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'req for sepa: '+requestWr);

        ID jobID = System.enqueueJob(new SiaCallbackSDD(requestWr,bp,zuoraOptionsMap));

        return resultWr;
    }

    /**
   * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
   * @description Method to createValueMap for customet Interaction
   * @param c
   * @param docUrl
   * @return Map<String,Object>
    */
    private static Map<String,Object> createValueMap(Contact c, String docUrl, String billingProfileId){
        Map<String,Object> data = new Map<String,Object>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Contact IN createValueMap ='+c);
        data.put('sent', false);
        data.put('billingProfileId', billingProfileId);
        data.put('skipComunication', false);
        data.put('email',  c.Email);
        data.put('fullName',c.Name);
        data.put('contactId',c.Id);
        data.put('legalEntity', c.XC_MainLegalEntity__c);
        data.put('customerType', 'SIA_Redirect_URL');
        data.put('docURL', docUrl);
        data.put('accountId', c.AccountId);
        data.put('preferredlanguage', c.XC_Preferredlanguageofcontact__c);
        return data;
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to prepare init Page For Order
     * @param accountId
     * @param objectName
     * @param orderId
     * @return String
     */
    @AuraEnabled
    public static String initPaymentPageForOrder(String accountId, String objectName, String orderId) {
        return initPaymentPageForOrder(accountId, objectName, orderId, null);
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to prepare init Page For Order
     * @param accountId
     * @param objectName
     * @param orderId
     * @param billingProfileId
     * @return String
     */
    @AuraEnabled
    public static String initPaymentPageForOrder(String accountId, String objectName, String orderId, String billingProfileId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In initPaymentPageForOrder con accountId = '+accountId+ ' e orderId = '+orderId);
        Map<String,Object> mapResult = new Map<String,Object>();

        Set<String> itaLE = new Set<String>{'EnelXItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMobility','Cogenio','EnelXMobilityItalia','EnelXMobilityHolding'};

        String stream = '';
        if(objectName == 'NE__Order__c'){
            NE__Order__c  a = [select id, NE__AccountId__r.Id, NE__AccountId__r.XC_PEC_Email__c, NE__AccountId__r.PrimaryEmail__c, XC_Segment__c, XC_LegalEntity__c from NE__Order__c  WHERE NE__AccountId__r.id =: accountId LIMIT 1];
            accountId = a.NE__AccountId__r.id;
            stream = a.XC_Segment__c;
            if((stream == 'B2B' || stream == 'B2G') && itaLE.contains(String.valueOf(a.XC_LegalEntity__c))){
                if(a.NE__AccountId__r.XC_PEC_Email__c){
                    mapResult.put('pec',a.NE__AccountId__r.PrimaryEmail__c);
                }
                
            }
        }
        //BEGIN - [TP - 2021.11.30 - TPB change order address]
        NE__Order__c ord;
        Boolean changeAddress = false;
        if(String.isNotBlank(orderId))
        {
            List<NE__Order__c> orders = [SELECT Id, XC_Segment__c, XC_LegalEntity__c, NE__Type__c, XC_Subtype__c, NE__OptyId__r.XC_LegalEntity__c, (SELECT Id FROM NE__Assets__r WHERE ParentId = null) FROM NE__Order__c WHERE Id=: orderId];

            if(!orders.isEmpty())
            {
                ord = orders[0];
                if((ord.XC_Segment__c == 'B2B' || ord.XC_Segment__c == 'B2G') && ord.XC_LegalEntity__c != null ){
                    mapResult.put('legalEntity', ord.XC_LegalEntity__c);
                }
                else if((ord.XC_Segment__c == 'B2C') && String.isNotBlank(ord.NE__OptyId__r.XC_LegalEntity__c)) {
                    List<User> listCurrUser = new List<User>([SELECT Id, XC_LegalEntities__c, XC_LegalEntity__c FROM User WHERE Id = :UserInfo.getUserId()]);
                    if(!listCurrUser.isEmpty()) {
                        List<String> listPossibleLegalEntities = new List<String>();
                        if(String.isNotBlank(listCurrUser[0].XC_LegalEntities__c)) {
                            listPossibleLegalEntities.addAll(listCurrUser[0].XC_LegalEntities__c.split(';'));
                        }
                        if(String.isNotBlank(listCurrUser[0].XC_LegalEntity__c)) {
                            listPossibleLegalEntities.add(listCurrUser[0].XC_LegalEntity__c);
                        }
                        if(listPossibleLegalEntities.contains(ord.NE__OptyId__r.XC_LegalEntity__c)) {
                            mapResult.put('legalEntity', ord.NE__OptyId__r.XC_LegalEntity__c);
                        }
                    }
                }
            }

            if(ord != null && ord.NE__Type__c == 'ChangeOrder' && ord.XC_Subtype__c == 'Change Billing Profile' && ord.NE__Assets__r != null && !ord.NE__Assets__r.isEmpty())
            {
                List<Id> assetIds = new List<Id>();
                for(Asset ass : ord.NE__Assets__r) assetIds.add(ass.Id);
                List<NE__AssetItemAttribute__c> assetItemattr = [SELECT Id FROM NE__AssetItemAttribute__c WHERE NE__Asset__c in :assetIds AND NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c ='Third Party'];
                changeAddress = !assetItemattr.isEmpty();
            }
        }
        //END - [TP - 2021.11.30 - TPB change order address]
        // if(orderId != null && orderId != ''){
        //     NE__Order__c  a = [select id,  XC_Segment__c, XC_LegalEntity__c from NE__Order__c  WHERE id =: orderId LIMIT 1];
        //         if((a.XC_Segment__c == 'B2B' || a.XC_Segment__c == 'B2G') && a.XC_LegalEntity__c != null ){
        //             mapResult.put('legalEntity',a.XC_LegalEntity__c);
        //         }
        // }

        List<Map<String,String>> countries = XC_UTIL_Country.retriveCountryPicklistValues();
        mapResult.put('countries', countries);

        List<Map<String,String>> contacts = getContactFromOrder(orderId);
        mapResult.put('billingContacts', contacts);
        mapResult.put('soldContacts', contacts);
        if(!mapResult.containsKey('legalEntity')){
            mapResult.put('legalEntity',XC_UTIL_User.getLegalEntityFromUser());
        }
        
        List<Map<String,String>> pods = getPodOfAccountPicklist(accountId);
        mapResult.put('billingAddresses', pods);

        XC_ContactGasELuz_Wrapper cwr = getContractPicklist(orderId);
        List<Map<String,String>> contracts = cwr.listContract;
        mapResult.put('contracts', contracts);
        mapResult.put('gasCUP',  cwr.gasCUP);
        mapResult.put('electricCUP',  cwr.electricCUP);

        List<Map<String,String>> soldAddress = getAddressFromOrder(orderId);
        //BEGIN - [TP - 2021.11.30 - TPB change order address]
        if(changeAddress) soldAddress.addAll(pods);
        mapResult.put('soldAddressesDisabled', !changeAddress);
        //END - [TP - 2021.11.30 - TPB change order address]
        mapResult.put('soldAddresses', soldAddress);
        List<String> cups;
        mapResult.put('cups', cups);
        List<Map<String,String>> doxeeLanguages = XC_UTIL_Account.getDoxeeLanguagesPicklist();
        mapResult.put('doxeeLanguages',doxeeLanguages);
        mapResult.put('sepaMandateValues',getSepaMandatePickList());
        String recordTypeName = '';
        
        if(objectName == 'Account'){
            Account a = [SELECT Id, XC_RecordTypeDeveloperName__c, XC_Segment__c, XC_PEC_Email__c, PrimaryEmail__c, XC_SplitPayment__c, XC_NIE_expiration_date__c, XC_NIE_expedition_date__c, XC_DocumentCountry__c, IdentityType__c, IdentityNumber__c,
                            (SELECT id, XC_DocumentType__c, XC_DocumentNumber__c FROM Personal_Documents__r)
                        FROM Account
                        WHERE id =:accountId limit 1];
            recordTypeName = a.XC_RecordTypeDeveloperName__c;
            stream = a.XC_Segment__c;
            if((stream == 'B2B' || stream == 'B2G') && itaLE.contains(String.valueOf(mapResult.get('legalEntity')))){
                if(a.XC_PEC_Email__c){
                    mapResult.put('pec',a.PrimaryEmail__c);
                }
            }

            if(recordTypeName == 'XC_GLO_Account_Residential' && !a.Personal_Documents__r.isEmpty()){
                mapResult.put('listPersonalDocument', retrievePersonalDocument(a.Personal_Documents__r));
            }else if(recordTypeName == 'XC_GLO_Account_Soho' || recordTypeName == 'XC_GLO_B2B' || recordTypeName == 'XC_GLO_B2G' || recordTypeName == 'XC_GLO_Account_Condominium'){
                XC_SohoDocumentWrapper docWrap = new XC_SohoDocumentWrapper();
                docWrap.docCountry = a.XC_DocumentCountry__c;
                docWrap.identityType = a.IdentityType__c;
                docWrap.identityNumber = a.IdentityNumber__c;
                docWrap.NIEExpeditionDate = a.XC_NIE_expedition_date__c;
                docWrap.NIEExpirationdate = a.XC_NIE_expiration_date__c;

                mapResult.put('sohoDocument',docWrap);
            }

            mapResult.put('splitPayment',a.XC_SplitPayment__c ? 'Yes' : 'No');

        } else if (objectName == 'NE__Order__c' || objectName == 'NE__Billing_Profile__c' ){
            Account a = [SELECT id, XC_RecordTypeDeveloperName__c, XC_Segment__c, XC_SplitPayment__c, XC_NIE_expiration_date__c, XC_NIE_expedition_date__c, XC_DocumentCountry__c, IdentityType__c, IdentityNumber__c, 
                            (SELECT id, XC_DocumentType__c, XC_DocumentNumber__c FROM Personal_Documents__r)
                        FROM Account 
                        WHERE Id =:accountId limit 1];
            recordTypeName = a.XC_RecordTypeDeveloperName__c;
            stream = a.XC_Segment__c;

            if(recordTypeName == 'XC_GLO_Account_Residential' && !a.Personal_Documents__r.isEmpty()){
                mapResult.put('listPersonalDocument', retrievePersonalDocument(a.Personal_Documents__r));
            }else if(recordTypeName == 'XC_GLO_Account_Soho' || recordTypeName == 'XC_GLO_B2B' || recordTypeName == 'XC_GLO_B2G' ){
                XC_SohoDocumentWrapper docWrap = new XC_SohoDocumentWrapper();
                docWrap.docCountry = a.XC_DocumentCountry__c;
                docWrap.identityType = a.IdentityType__c;
                docWrap.identityNumber = a.IdentityNumber__c;
                docWrap.NIEExpeditionDate = a.XC_NIE_expedition_date__c;
                docWrap.NIEExpirationdate = a.XC_NIE_expiration_date__c;

                mapResult.put('sohoDocument',docWrap);
            }

            mapResult.put('splitPayment',a.XC_SplitPayment__c ? 'Yes' : 'No');
        }

        if(String.isNotBlank(billingProfileId)) {
            Map<Id, NE__Billing_Profile__c> billignProfMap = new Map<Id, NE__Billing_Profile__c>([SELECT Id, XC_Segment__c, NE__Account__c, XC_LegalEntity__c, XC_SepaMandate__c, XC_SepaMandateDate__c,
                                                                                                        NE__Payment__c, XC_Token__c, NE__Card_Type__c, NE__Card_Number__c, NE__Expiration__c,
                                                                                                        NE__Expiration_Year__c, XC_PayPalUsername__c, NE__Iban__c, XC_CommodityContractID__c,
                                                                                                        NE__Account__r.XC_DocumentCountry__c, NE__Account__r.IdentityType__c, NE__Account__r.IdentityNumber__c
                                                                                                    FROM NE__Billing_Profile__c
                                                                                                    WHERE Id =: billingProfileId]);
            NE__Billing_Profile__c billignProf = billignProfMap.get(billingProfileId);
            accountId = billignProf.NE__Account__c;
            stream = billignProf.XC_Segment__c;
            mapResult.put('paymentType', billignProf.NE__Payment__c);
            mapResult.put('payment', billignProf.NE__Payment__c);
            mapResult.put('paymentMethodCategory', getPaymentCategoryDependency(billignProf.NE__Payment__c));
            mapResult.put('sepaMandate', billignProf.XC_SepaMandate__c);
            mapResult.put('mandateDate', billignProf.XC_SepaMandateDate__c);
            mapResult.put('debtorCode', billignProf.XC_Token__c);
            mapResult.put('creditCardLastFourNumber', (String.isNotBlank(billignProf.NE__Card_Number__c)) ? billignProf.NE__Card_Number__c.substring(12) : null);
            // mapResult.put('creditCardHolder', '');
            mapResult.put('expirationMonth', billignProf.NE__Expiration__c);
            mapResult.put('expirationYear', billignProf.NE__Expiration_Year__c);
            mapResult.put('payPalUsername', billignProf.XC_PayPalUsername__c);
            mapResult.put('iban', billignProf.NE__Iban__c);
            mapResult.put('contractId', billignProf.XC_CommodityContractID__c);

            if(String.isNotBlank(billignProf.NE__Card_Type__c)) {
                Map<String,String> creditCardType = new Map<String, String> {'MASTERCARD' => 'MasterCard', 
                                                                            'VISA' => 'Visa',
                                                                            'DISCOVER' => 'Discover',
                                                                            'AMEX' => 'AmericanExpress',
                                                                            'PAYPAL' => 'PayPal'};
                mapResult.put('creditCardType', creditCardType.get(billignProf.NE__Card_Type__c.toUpperCase()));
            }
        }

        mapResult.put('recordTypeName', recordTypeName);
        List<Map<String,String>> taxExempt = getTaxExemptPickList();
        List<Map<String,String>> invoiceDeliveryPreferencesPick = getinvoiceDeliveryPreferencesPickList(XC_UTIL_User.getLegalEntityFromUser());
        mapResult.put('taxExempt', '');
        mapResult.put('taxExemptOpts', taxExempt);
        mapResult.put('invoiceDeliveryPreferencesPick', invoiceDeliveryPreferencesPick);
        mapResult.put('isB2BLE', checkB2BStream(stream));
        mapResult.put('stream', stream);
        mapResult.put('showContactExtraFields', retrieveContactExtraFields(stream, mapResult.get('legalEntity'), mapResult.get('sohoDocument')));

        //Set<String> itaLE = new Set<String>{'EnelXItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMobility','Cogenio'};
        if((stream == 'B2B' || stream == 'B2G') && itaLE.contains(String.valueOf(mapResult.get('legalEntity')))){
            mapResult.put('isB2BG', stream);
        }
        
        //CR NR0939 - MC 20200909
        Map<String, XC_CM_LegalEntity_Configuration__mdt> leMapping = 
            XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(new Set<String>{(String)mapResult.get('legalEntity')}, new Set<String>{stream});
        if(leMapping.get(mapResult.get('legalEntity')+stream) != null){
            mapResult.put('getContractBy', leMapping.get(mapResult.get('legalEntity')+stream).XC_GetContractBy__c);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@TaxExmpt'+ taxExempt);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@invoiceDeliveryPreferencesPick'+ invoiceDeliveryPreferencesPick);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'initPaimentPage mapResult='+mapResult.get('invoiceDeliveryPreferencesPick'));
        return JSON.serialize(mapResult);
    }


    /**
   * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
   * @description Method to getContactFromOrder
   * @param orderId
   * @return List<Map<String,String>>
    */
    private static List<Map<String,String>> getContactFromOrder(String orderId){
        List<NE__Order__c> orders = [SELECT id, Name, NE__OptyId__r.XC_Contact__r.id , NE__OptyId__r.XC_Contact__r.Name,NE__OptyId__r.XC_Contact__r.Email,NE__OptyId__r.XC_Contact__r.XC_PrimaryContact__c,XC_ChangedContact__c,XC_ChangedContact__r.Email,XC_ChangedContact__r.XC_PrimaryContact__c,XC_ChangedContact__r.Name FROM NE__Order__c WHERE id =:orderId limit 1];
        List<Map<String,String>> results = new List<Map<String,String>>();

        for(NE__Order__c o : orders){
            Map<String,String> row = new Map<String,String>();

            if(String.isNotBlank(o.XC_ChangedContact__c)){  
                row.put('key', o.XC_ChangedContact__c );
                row.put('value',o.XC_ChangedContact__r.Name);
                if(String.isNotBlank(o.XC_ChangedContact__r.Email)) {
                    row.put('email',o.XC_ChangedContact__r.Email);
                    row.put('primary',String.valueOf(o.XC_ChangedContact__r.XC_PrimaryContact__c));
                }
            }else{   
                row.put('key', o.NE__OptyId__r.XC_Contact__r.id );
                row.put('value', o.NE__OptyId__r.XC_Contact__r.Name);
                if(String.isNotBlank(o.NE__OptyId__r.XC_Contact__r.Email)) {
                    row.put('email',o.NE__OptyId__r.XC_Contact__r.Email);
                    row.put('primary',String.valueOf(o.NE__OptyId__r.XC_Contact__r.XC_PrimaryContact__c));
                }
            }

            results.add(row);
        }

        return results;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Method to get Address From Order
    * @param orderId
    * @return List<Map<String,String>>
     */
    private static List<Map<String,String>> getAddressFromOrder(String orderId){
        List<NE__Order__c> orders = [SELECT id, Name, NE__OptyId__r.XC_Address__r.id,XC_ChangedContact__c,
                                     NE__OptyId__r.XC_Address__r.Name, NE__OptyId__r.XC_Address__r.XC_FullAddress__c,XC_InstallationAddress__r.Name,XC_InstallationAddress__c FROM NE__Order__c WHERE id =:orderId limit 1];
        List<Map<String,String>> results = new List<Map<String,String>>();
        for(NE__Order__c o : orders){
            Map<String,String> row = new Map<String,String>();
            if(String.isNotBlank(o.XC_ChangedContact__c)){
                row.put('key',o.XC_InstallationAddress__c);
                row.put('value',o.XC_InstallationAddress__r.Name);
            }else{
                row.put('key', o.NE__OptyId__r.XC_Address__r.id);
                row.put('value', o.NE__OptyId__r.XC_Address__r.Name);
            }
            results.add(row);
        }

        return results;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Method to getContractPicklist Values
    * @param orderId
    * @return XC_ContactGasELuz_Wrapper
     */
    private static XC_ContactGasELuz_Wrapper getContractPicklist(String orderId){
        XC_ContactGasELuz_Wrapper cwr = new XC_ContactGasELuz_Wrapper();
        List<NE__Order__c> orders = [SELECT id, Name, NE__OptyId__r.XC_ElectricContract__c , NE__OptyId__r.XC_GasContract__c, NE__OptyId__r.XC_ElectricCUPS__c, NE__OptyId__r.XC_GasCUPS__c FROM NE__Order__c WHERE id =:orderId limit 1];
        List<Map<String,String>> results = new List<Map<String,String>>();
        for(NE__Order__c o : orders){
            if(o.NE__OptyId__r.XC_GasContract__c!=null){
                Map<String,String> row = new Map<String,String>();
                row.put('key', o.NE__OptyId__r.XC_GasContract__c);
                row.put('value',  Label.XC_CL_ContractTypeGAS+' - '+o.NE__OptyId__r.XC_GasContract__c);
                results.add(row);
            }

            if(o.NE__OptyId__r.XC_ElectricContract__c!=null){
                Map<String,String> row2 = new Map<String,String>();
                row2.put('key', o.NE__OptyId__r.XC_ElectricContract__c);
                row2.put('value',  Label.XC_CL_ContractTypeLUZ+' - '+o.NE__OptyId__r.XC_ElectricContract__c);
                results.add(row2);
            }

            cwr.gasCUP = o.NE__OptyId__r.XC_GasCUPS__c;
            cwr.electricCUP= o.NE__OptyId__r.XC_ElectricCUPS__c;
        }
        cwr.listContract = results;

        return cwr;
    }

    private static XC_REST_PaymentMethodSIA_U.requestWrapper createReqWrapperCC(NE__Billing_Profile__c billingProfile, Contact contact){
        XC_REST_PaymentMethodSIA_U.requestWrapper requestWr = new XC_REST_PaymentMethodSIA_U.requestWrapper();
        requestWr.email = contact.Email;
        requestWr.typeX = billingProfile.XC_MandateType__c;

        if(String.isBlank(billingProfile.XC_MandateType__c)){
            requestWr.typeX = 'ONE_SHOT';
        }

        /*
        if(billingProfile.XC_MandateType__c==null || billingProfile.XC_MandateType__c=='One Time'){
            requestWr.typeX= 'ONE_SHOT';

        } else if(billingProfile.XC_MandateType__c=='Recurring'){
            requestWr.typeX= 'RECURRING';
        }
        */

        //adding address info to manage different payment gateways via payment hub
        List<XC_BillingProfileLineItem__c> currentBPLIs = [SELECT Id,
        XC_SoldToAddress__c,
        XC_SoldToAddress__r.XC_FullAddress__c,
        XC_SoldToAddress__r.XC_PostalCode__c,
        XC_SoldToAddress__r.XC_AddressProvince__c,
        XC_SoldToAddress__r.XC_StreetTypeText__c,
        XC_SoldToAddress__r.XC_City__c,
        XC_LegalEntity__c
        FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c = :billingProfile.Id ORDER BY CreatedDate DESC LIMIT 1];

        if(!currentBPLIs.isEmpty()){

            XC_BillingProfileLineItem__c currentBpli = currentBPLIs[0];
            String countryISOCode = XC_UTIL_Country.getISOCodeByLegalEntity(currentBpli.XC_LegalEntity__c)!=null ? XC_UTIL_Country.getISOCodeByLegalEntity(currentBpli.XC_LegalEntity__c).XC_ISOCode__c : '';

            //added address fields for CC also
            String addressString = String.isNotBlank(currentBpli.XC_SoldToAddress__r.XC_StreetTypeText__c) ? 
            currentBpli.XC_SoldToAddress__r.XC_StreetTypeText__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_FullAddress__c :
            currentBpli.XC_SoldToAddress__r.XC_FullAddress__c;

            String localityString = currentBpli.XC_SoldToAddress__r.XC_PostalCode__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_City__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_AddressProvince__c;

            requestWr.address = addressString;
            requestWr.addressCity = localityString;
            requestWr.addressCountry = countryISOCode;
        }

        return requestWr;
    }

    private static XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA createReqWrapperSDD(NE__Billing_Profile__c bp, Contact c){
        XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA requestWr = new XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA();
        //String mandateId = bp.XC_SepaMandate__c;

        Map<Id,NE__Billing_Profile__c> bpRetrMap = new Map<Id,NE__Billing_Profile__c>([
                SELECT Id, XC_SepaMandate__c, XC_SepaMandateDate__c, XC_MandateType__c,XC_LegalEntity__c,
                    (SELECT Id,
                    XC_SoldToAddress__c,
                    XC_SoldToAddress__r.XC_FullAddress__c,
                    XC_SoldToAddress__r.XC_PostalCode__c,
                    XC_SoldToAddress__r.XC_AddressProvince__c,
                    XC_SoldToAddress__r.XC_StreetTypeText__c,
                    XC_SoldToAddress__r.XC_City__c,
                    XC_LegalEntity__c
                    FROM Billing_Profile_Line_Items__r 
                    ORDER BY CreatedDate DESC LIMIT 1)
                FROM NE__Billing_Profile__c
                WHERE Id =: bp.id
        ]);

        NE__Billing_Profile__c bpRetr = bpRetrMap.values()[0];
        XC_BillingProfileLineItem__c currentBpli = bpRetr.Billing_Profile_Line_Items__r[0];
        String countryISOCode = XC_UTIL_Country.getISOCodeByLegalEntity(currentBpli.XC_LegalEntity__c)!=null ? XC_UTIL_Country.getISOCodeByLegalEntity(currentBpli.XC_LegalEntity__c).XC_ISOCode__c : '';

        String mandateId = bpRetr.XC_SepaMandate__c;
        requestWr.name = 
        String.isNotBlank(c.Account.XC_FirstName__c) ? XC_UTIL_String.removeDiacriticsSIA(c.Account.XC_FirstName__c) : 
        String.isNotBlank(c.FirstName) ? XC_UTIL_String.removeDiacriticsSIA(c.FirstName) : c.Account.Name;

        requestWr.surname =   String.isNotBlank(c.Account.XC_LastName__c) ? XC_UTIL_String.removeDiacriticsSIA(c.Account.XC_LastName__c) : XC_UTIL_String.removeDiacriticsSIA(c.LastName);
        requestWr.email = String.isNotBlank(c.Account.PrimaryEmail__c) ? c.Account.PrimaryEmail__c : String.isNotBlank(c.Email) ? c.Email : c.Account.IdentityNumber__c +'@sepa.com';
        requestWr.nationalIdentificationCode = c.Account.IdentityNumber__c;
        requestWr.iban = bp.NE__Iban__c;
        requestWr.mandateID = mandateId;
        requestWr.birthDate = String.valueOf(c.Account.XC_BirthDate__c);
        if(bpRetr.XC_MandateType__c=='One Time'){
            requestWr.type = 'ONE_SHOT';
        } else {
            requestWr.type = bpRetr.XC_MandateType__c;
        }
        requestWr.sdd = new XC_REST_PaymentMethodSIA_U.SDDWrapper();
        requestWr.sdd.iban = bp.NE__Iban__c;
        requestWr.sdd.mandateId = mandateId;
        requestWr.sdd.mandateDate = String.valueOf(bpRetr.XC_SepaMandateDate__c); // String.valueOf(bp.XC_SepaMandateDate__c); 

        //added address fields for SDD
        String addressString = String.isNotBlank(currentBpli.XC_SoldToAddress__r.XC_StreetTypeText__c) ? 
        currentBpli.XC_SoldToAddress__r.XC_StreetTypeText__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_FullAddress__c :
        currentBpli.XC_SoldToAddress__r.XC_FullAddress__c;

        String localityString = currentBpli.XC_SoldToAddress__r.XC_PostalCode__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_City__c + ' ' + currentBpli.XC_SoldToAddress__r.XC_AddressProvince__c;

        requestWr.address = addressString;
        requestWr.addressCity = localityString;
        requestWr.addressCountry = countryISOCode;
        requestWr.bp = bp.id;

        return requestWr;
    }

    private static Contact getContactFields(String contactOrAccountId){
        Contact c = new Contact();

        List<Contact> contactList = new List<Contact>();
        Schema.SObjectType sobjectType = ((Id)contactOrAccountId).getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        if(sobjectName=='Account'){
            Map<Id,Account> accMap = new Map<Id,Account>([
                    SELECT Id, (
                            SELECT Id, Email, Name, AccountId, XC_Preferredlanguageofcontact__c, XC_MainLegalEntity__c, Account.XC_LastName__c,
                                    Account.XC_FirstName__c,LastName,FirstName,Account.PrimaryEmail__c, Account.IdentityNumber__c, Account.XC_BirthDate__c, Account.Name
                            FROM Contacts
                            WHERE XC_PrimaryContact__c = true )
                    FROM Account
                    WHERE Id =: contactOrAccountId
                    LIMIT 1
            ]);
            if(!accMap.values().isEmpty()){
                contactList = accMap.values()[0].contacts;
            }

        } else if(sobjectName=='Contact'){
            Map<Id,Contact> contactMap = new Map<Id,Contact>([
                    SELECT Id, Email, Name, AccountId, XC_Preferredlanguageofcontact__c, XC_MainLegalEntity__c, Account.XC_LastName__c, Account.XC_FirstName__c,
                            Account.PrimaryEmail__c, Account.IdentityNumber__c,FirstName,LastName, Account.XC_BirthDate__c,Account.Name
                    FROM Contact
                    WHERE Id =: contactOrAccountId
                    LIMIT 1
            ]);
            contactList = contactMap.values();
        }

        if(contactList.isEmpty()){
            return null;
        }

        return contactList[0];
    }

    public class SiaCallbackCC implements Queueable, Database.AllowsCallouts {
        Contact contact;
        NE__Billing_Profile__c billingProfile;
        XC_REST_PaymentMethodSIA.ResultWrapper resultWr;

        public SiaCallbackCC(Contact contact, NE__Billing_Profile__c billingProfile, XC_REST_PaymentMethodSIA.ResultWrapper resultWr) {
            this.contact = contact;
            this.billingProfile = billingProfile;
            this.resultWr = resultWr;
        }

        public void execute(QueueableContext context) {
            resultWr = XC_REST_PaymentMethodSIA.callForCreditCard(createReqWrapperCC(billingProfile, contact), contact.id, billingProfile.Id);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'siaValues ='+resultWr);

            Map<String,Object> siaValues = new Map<String,Object>();
            if(resultWr.paymentMethodSIA!=''){
                siaValues = (Map<String,Object>)JSON.deserializeUntyped(resultWr.paymentMethodSIA);
            }

            List<Map<String,Object>> customerInteractions = new List<Map<String,Object>>();
            customerInteractions.add(createValueMap(contact, String.valueOf(siaValues.get('redirectUrl')), billingProfile.Id));
            XC_UTIL_CustomerInteractionGeneration.manageCustomerInteractionInsert(customerInteractions);
        }

    }

    public class SiaCallbackSDD implements Queueable, Database.AllowsCallouts {
        XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA requestWr;
        XC_REST_PaymentMethodSIA_U.ResponseWrapper resultWr;
        NE__Billing_Profile__c billingProfile;
        Map<String,String> zuoraMap;


        public SiaCallbackSDD(XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA requestWr, NE__Billing_Profile__c billingProfile){
            this.requestWr = requestWr;
            this.billingProfile = billingProfile;
        }

        public SiaCallbackSDD(XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA requestWr, NE__Billing_Profile__c billingProfile,Map<String,String> zuoraOptionsMap){
            this.zuoraMap = zuoraOptionsMap;
            this.requestWr = requestWr;
            this.billingProfile = billingProfile;
        }

        public void execute(QueueableContext context) {
            resultWr = XC_REST_PaymentMethodSIA.callForSEPA(requestWr);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'siaValues ='+resultWr);

            if(resultWr.debtorCode!='' && resultWr.debtorCode!=null && String.isNotBlank(resultWr.debtorCode)){
                billingProfile.XC_Token__c = this.resultWr.debtorCode;
                billingProfile.XC_CreateMandate__c = true;
                XC_UTIL_Sobject.updateRecord(billingProfile);

                if(this.zuoraMap!=null && !this.zuoraMap.isEmpty()){
                    XC_REST_Account_B.callZuora(zuoraMap);
                }

            }
        }

    }

    /**
    *@author: Francesco Imperioli - fimperioli@deloitte.it
    *@description : returns picklist values for SepaMandate field on Billing profile Object
    *@return List<String> of picklistvalues
    **/
    private static List<String> getSepaMandatePickList(){
        List<String> result= new List<String>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.XC_MandateType__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            result.add(ple.getLabel());
        }
        return result;
    }

    /**
 *@author: Francesco Imperioli - fimperioli@deloitte.it
 *@description : returns picklist values for SepaMandate field on Billing profile Object
 *@return List<String> of picklistvalues
 **/
    private static List<Map<String,String>> getTaxExemptPickList(){
        List<Map<String,String>> result = new List<Map<String,String>>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.XC_TaxExemption__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            Map<String,String> row = new Map<String,String>();
            row.put('key',ple.getValue() );
            row.put('value', ple.getLabel());
            result.add(row);
        }
        return result;
    }



    private static List<Map<String,String>> getinvoiceDeliveryPreferencesPickList(String leagEntity){
        List<Map<String,String>> result = new List<Map<String,String>>();
        List<Map<String,String>> resultB2C = new List<Map<String,String>>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getinvoiceDeliveryPreferencesPickList');
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.XC_InvoiceDeliveryPref__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            Map<String,String> row = new Map<String,String>();
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'invoice delivery'+ple.getLabel());
            row.put('key',ple.getValue());
            row.put('value', ple.getLabel());
            result.add(row);
        }
        if(leagEntity== 'EnelX' || leagEntity == 'EnelDistribucion' || leagEntity == 'Codensa'){
            return result;

        } else{

            for(Schema.PickListEntry ple : entryList){
                if(ple.getValue()!='Smart Invoice'){  
                Map<String,String> row = new Map<String,String>();
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'invoice delivery'+ple.getLabel());
                row.put('key',ple.getValue()  );
                row.put('value', ple.getLabel());
                resultB2C.add(row);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'INVOICE B2C'+ result);
                }
            }

        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'INVOICE B2C'+ resultB2C);
        return resultB2C;
    }

    /**
    *@author: Francesco Imperioli - fimperioli@deloitte.it
    *@description : retrieve dynamically available payment methods from Billing Profile Object.
    *@createddate 2019-11-06 - modified 18-11-2019 added legalentity filter
    **/
    /*@AuraEnabled
    public static Map<String,Object> getPaymentMethodsPicklist(String legalEntity){


        Map<String,Object> result= new Map<String,Object>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.NE__Payment__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ple '+ple);
            result.put(ple.getLabel(),ple.getValue());
        }
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'metodi filtrati'+filterMopWithLegalEntity(legalEntity, result));
        List<String> listValues = filterMopWithLegalEntity(legalEntity, result.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'VALORI FILITRATO ' + listValues);
        Map<String,Object> resultFilter= new Map<String,Object>();
        for(String s : result.keySet()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'DONATO S ' + s);
            for(Object o : listValues){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'DONATO O ' + o);
                if(result.get(s)== String.valueOf(o)){
                    resultFilter.put(s,o);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Result FILTER'+resultFilter);

        return resultFilter;
        //return filterMopWithLegalEntity(legalEntity, result.values());
        //return result;
    }*/


    /**
    *@author: Francesco Imperioli - fimperioli@deloitte.it
    *@description : retrieve dynamically available payment methods from Billing Profile Object.
    *@createddate 2019-11-06 - modified 18-11-2019 added legalentity filter
    *@modifieddate 2020-30-04 by Nicola Mariniello - nmariniello@deloitte.it
    **/
    @AuraEnabled
    public static Map<String,Object> getPaymentMethodsPicklist(String legalEntity, String stream){


        // Map<String,Object> result= new Map<String,Object>();
        // Schema.DescribeFieldResult fr = NE__Billing_Profile__c.NE__Payment__c.getDescribe();
        // List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        // for(Schema.PickListEntry ple : entryList){
        //     XC_UTIL_Debug.debug(DEBUGACTIVE, 'ple '+ple);
        //     result.put(ple.getLabel(),ple.getValue());
        // }
        // //XC_UTIL_Debug.debug(DEBUGACTIVE, 'metodi filtrati'+filterMopWithLegalEntity(legalEntity, result));
        // List<String> listValues = filterMopWithLegalEntity(legalEntity, stream, result.values());
        // XC_UTIL_Debug.debug(DEBUGACTIVE, 'VALORI FILITRATO ' + listValues);
        Map<String,Object> resultFilter= new Map<String,Object>();
        List<XC_UTIL_PaymentMethodFilter.MopWrapper> filteredMopWrappers = XC_UTIL_PaymentMethodFilter.getAvailableMopsForLe(legalEntity,stream);

        for(XC_UTIL_PaymentMethodFilter.MopWrapper mw : filteredMopWrappers){
            resultFilter.put(mw.mopLabel,mw.mopValue);
        }

        // for(String s : result.keySet()){
        //     XC_UTIL_Debug.debug(DEBUGACTIVE, 'DONATO S ' + s);
        //     for(Object o : listValues){
        //         XC_UTIL_Debug.debug(DEBUGACTIVE, 'DONATO O ' + o);
        //         if(result.get(s)== String.valueOf(o)){
        //             resultFilter.put(s,o);
        //         }
        //     }
        // }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Result FILTER'+resultFilter);

        return resultFilter;
    }


    /* @AuraEnabled
     public static List<String> getPaymentMethodsPicklist(String legalEntity){

         List<String> result= new List<String>();
         Schema.DescribeFieldResult fr = NE__Billing_Profile__c.NE__Payment__c.getDescribe();
         List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
         for(Schema.PickListEntry ple : entryList){
             XC_UTIL_Debug.debug(DEBUGACTIVE, 'ple '+ple);
             result.add(ple.getLabel());
         }
         XC_UTIL_Debug.debug(DEBUGACTIVE, 'metodi filtrati'+filterMopWithLegalEntity(legalEntity, result));
         return filterMopWithLegalEntity(legalEntity, result);
         //return result;
     }
 */

    /* @AuraEnabled
     public static Map<String,Object> getPaymentMethodsPicklist(String legalEntity){

         Map<String,Object> result= new Map<String,Object>();
         Schema.DescribeFieldResult fr = NE__Billing_Profile__c.NE__Payment__c.getDescribe();
         List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
         for(Schema.PickListEntry ple : entryList){
             result.put(ple.getLabel(),ple.getValue());
         }
         // return filterMopWithLegalEntity(legalEntity, result);
         return result;
     }
 */

    /**
    *@author: Francesco Imperioli - fimperioli@deloitte.it
    *@description : filters available payment methods for legalentity - use custom metadata for the configuration
    *@createddate 2019-11-18
    **/
    /*private static List<String> filterMopWithLegalEntity(String legalEntity,List<Object> mops){
        List<String> mopsToString = new List<String>();
        for(Object m : mops){
            mopsToString.add(String.valueof(m));
        }

        if(String.isBlank(legalEntity)){
            return mopsToString;
        }

        List<XC_CM_Excluded_MOP_LE__mdt> excludedMopsConfs = [SELECT DeveloperName,XC_Excluded_Payment_Methods__c FROM XC_CM_Excluded_MOP_LE__mdt WHERE DeveloperName = :legalEntity LIMIT 1];
        if(excludedMopsConfs.isEmpty()){
            return mopsToString;
        }

        // extracting the list of unavailable payment methods from the custom metadata
        String[] excludedMops = excludedMopsConfs[0].XC_Excluded_Payment_Methods__c.split(';');
        if(excludedMops.isEmpty()){
            return mopsToString;
        }

        Set<String> excludedMopsSet = new Set<String>();
        excludedMopsSet.addAll(excludedMops);
        List<String> newMopList = new List<String>();

        for(String inputMop : mopsToString){
            //check if the mop is in the excluded mop set
            if(!excludedMopsSet.contains(inputMop)){
                newMopList.add(inputMop);
            }
        }

        return !newMopList.isEmpty() ? newMopList : mopsToString;

    }*/


    /**
    *@author: Francesco Imperioli - fimperioli@deloitte.it
    *@description : filters available payment methods for legalentity - use custom metadata for the configuration
    *@createddate 2019-11-18
    *@modifieddate 2020-30-04 by Nicola Mariniello - nmariniello@deloitte.it
    **/
    @TestVisible
    private static List<String> filterMopWithLegalEntity(String legalEntity, String stream, List<Object> mops){
        List<String> mopsToString = new List<String>();
        for(Object m : mops){
            mopsToString.add(String.valueof(m));
        }

        if(String.isBlank(legalEntity) || String.isBlank(stream)){
            return mopsToString;
        }

        List<XC_CM_Excluded_MOP_LE__mdt> excludedMopsConfs = [SELECT DeveloperName,XC_Excluded_Payment_Methods__c FROM XC_CM_Excluded_MOP_LE__mdt WHERE XC_LegalEntity__c = :legalEntity AND XC_Stream__c =: stream LIMIT 1];
        if(excludedMopsConfs.isEmpty()){
            return mopsToString;
        }

        // extracting the list of unavailable payment methods from the custom metadata
        String[] excludedMops = excludedMopsConfs[0].XC_Excluded_Payment_Methods__c.split(';');
        if(excludedMops.isEmpty()){
            return mopsToString;
        }

        Set<String> excludedMopsSet = new Set<String>();
        excludedMopsSet.addAll(excludedMops);
        List<String> newMopList = new List<String>();

        for(String inputMop : mopsToString){
            //check if the mop is in the excluded mop set
            if(!excludedMopsSet.contains(inputMop)){
                newMopList.add(inputMop);
            }
        }

        return !newMopList.isEmpty() ? newMopList : mopsToString;

    }



    /**
    *@author: Francesco Imperioli - fimperioli@deloitte.it
    *@description : retrieve dynamically available payment methods from Billing Profile Object.
    *@createddate 2019-11-06
    **/
    @AuraEnabled
    public static List<String> getPaymentMethodCategoryPickList(){
        List<String> result= new List<String>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.XC_PaymentMethodCategory__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            result.add(ple.getValue());
        }
        return result;
    }



    /**
    *@author: Francesco Imperioli - fimperioli@deloitte.it
    *@description : retrieve dynamically available payment methods from Billing Profile Object. 
    *@createddate 2019-11-06
    **/
    @AuraEnabled
    public static String getPaymentCategoryDependency(String paymentMethod){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Metodo di pagamento -->'+ paymentMethod);
        Map<String, List<String>> resMap = XC_UTIL_DependentPicklist.getDependentPicklist('NE__Billing_Profile__c', 'NE__Payment__c', 'XC_PaymentMethodCategory__c').pickListMap;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'RES MAP -->'+ resMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'RES MAP -->'+ resMap.get(paymentMethod)[0]);
        return resMap.get(paymentMethod)[0];
    }

    /** 
    *@author: Francesco Imperioli - fimperioli@deloitte.it
    *@description : manage updates on BPLI in case of we are modifying billTo/soldTo addresses for a non used BP
    *@createddate 2019-11-07
    **/

    @AuraEnabled
    public static String manageUpdateUnusedBPLISoldTo(Map<String,Object> paramsMap){

        Map<String,Object> result = new Map<String,Object>();

        String bpId = (String) paramsMap.get('bpId');
        String soldToAddressId = (String) paramsMap.get('soldToAddressId');
        String billToAddressId = (String) paramsMap.get('billToAddressId');
        String legalEntity = (String) paramsMap.get('legalEntity');
        String taxPick = (String) String.valueOf(paramsMap.get('taxPick'));
        String paymentTermfilter = (String) String.valueOf(paramsMap.get('paymentTermfilter'));

        List<XC_BillingProfileLineItem__c> itemsFound = [
                SELECT ID,XC_BillingProfile__c,XC_SoldToAddress__c,XC_BillToAddress__c,
                (SELECT ID FROM Configuration_Items__r)
                FROM XC_BillingProfileLineItem__c
                WHERE XC_BillingProfile__c = :bpId AND XC_LegalEntity__c = :legalEntity AND XC_BillToAddress__c != :billToAddressId AND XC_SoldToAddress__c != :soldToAddressId AND XC_Status__c = 'Active' AND XC_CustomerAccount__c != null AND  XC_PaymentTerm__c = : paymentTermfilter];

        XC_BillingProfileLineItem__c bpliToUpdate;

        //this method will look for an used billing profile line item in order to avoid duplication in Zuora --> it will update sold to address 

        for(XC_BillingProfileLineItem__c item : itemsFound){
            if(item.Configuration_Items__r.isEmpty()){
                bpliToUpdate = item;
                break;
            }
        }

        if(bpliToUpdate==null){
            result.put('bpliFound',false);
            result.put('success',true);
        }else{
            result.put('bpliFound',true);
            bpliToUpdate.XC_SoldToAddress__c = soldToAddressId;
            bpliToUpdate.XC_BillToAddress__c = billToAddressId;
            XC_UTIL_Sobject.WrapperResult updateResult = XC_UTIL_Sobject.updateRecord(bpliToUpdate);
            result.put('success',updateResult.success);

            if(!updateResult.success) {
                InputRollbackWrapper inputRollback =  new InputRollbackWrapper();
                inputRollback.billingProfileLineItemId = bpliToUpdate.Id;
                inputRollback.billingProfileId = null;
                inputRollback.errorMessage = updateResult.errorMessage;
                inputRollback.doRollback = false;
                rollbackForErrorBPLI(inputRollback);
                result.put('success',false);
                result.put('errorMessage',updateResult.errorMessage);
            }
        }

        return JSON.serialize(result);
    }

    /**
     * @author : Francesco Imperioli - fimperioli@deloitte.it
     * @description : check if the current user LE stream
     */
    /*public static Boolean checkLeB2BStream(){
        List<XC_CM_CountryLegalEntityAssociation__mdt> legalEntityCategory = [SELECT ID,DeveloperName,XC_LegalEntity__c,XC_Category__c 
        FROM XC_CM_CountryLegalEntityAssociation__mdt 
        WHERE XC_LegalEntity__c = : XC_UTIL_User.getLegalEntityFromUser()];

        return legalEntityCategory.isEmpty() ? false : legalEntityCategory[0].XC_Category__c=='B2B';
    }*/

    /**
     * @author : Francesco Imperioli - fimperioli@deloitte.it
     * @description : check if the current user LE stream
     */
    public static Boolean checkB2BStream(String stream){
        return stream=='B2B' || stream=='B2G';
    }

        /**
     * @author Andrea Di Cicco
     * @description check if the contact has email if the delivery preference is email
     * @param contactId
     * @return Boolean
     */
    @AuraEnabled
     public static Boolean checkContactEmail(String contactId){
         Contact selectedContact = [SELECT Email FROM Contact WHERE id = : contactId LIMIT 1];
         
         return selectedContact.Email != null;
     }

    
     /**
      * @author Francesco Imperioli - fimperioli@deloitte.it
      * @description check if eventual extra fields for contact are present
      * @createdDate 2020-03-03
      */
    /*public static Boolean retrieveContactExtraFields(String stream){
        //retrieve fieldset information - check if this can be made dynamic
        XC_CM_CountryLegalEntityAssociation__mdt userLE = XC_UTIL_User.getLegalEntityMetadataFromUser();
        String countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
        String userLEStream = stream; //userLE.XC_Category__c;
        String fieldSetKey = 'XC_' + countryIso + '_' + userLEStream +'_' +'ZuoraContactExtraFields';

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FIELDSET KEY FOR EXTRA FIELDS:: ' + fieldSetKey);

        List<XC_UTIL_FieldSet.FieldWrapper> fieldFromFieldSet = XC_UTIL_FieldSet.getFieldSetFields(fieldSetKey,'XC_BillingProfileLineItem__c');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FIELDSET FOUND:: ' + fieldFromFieldSet);
        return !fieldFromFieldSet.isEmpty();
    }*/
    

    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description check if eventual extra fields for contact are present
     * @createdDate 2020-10-16
     */
    public static Boolean retrieveContactExtraFields(String stream, Object legalEntityObj, Object sohoDocWrapObj) {

        String legalEntity = (legalEntityObj != null) ? String.valueOf(legalEntityObj) : null;
        XC_SohoDocumentWrapper sohoDocWrap = (sohoDocWrapObj != null) ? (XC_SohoDocumentWrapper) sohoDocWrapObj : null;
        if(legalEntity == 'EnelXMSP' && (sohoDocWrap == null || (sohoDocWrap != null && sohoDocWrap.docCountry != 'Italy'))) {
            return false;
        }

        //retrieve fieldset information - check if this can be made dynamic
        XC_CM_CountryLegalEntityAssociation__mdt userLE = XC_UTIL_User.getLegalEntityMetadataFromUser();
        String countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
        String userLEStream = stream; //userLE.XC_Category__c;
        String fieldSetKey = 'XC_' + countryIso + '_' + userLEStream +'_' +'ZuoraContactExtraFields';

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FIELDSET KEY FOR EXTRA FIELDS:: ' + fieldSetKey);

        List<XC_UTIL_FieldSet.FieldWrapper> fieldFromFieldSet = XC_UTIL_FieldSet.getFieldSetFields(fieldSetKey,'XC_BillingProfileLineItem__c');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FIELDSET FOUND:: ' + fieldFromFieldSet);
        return !fieldFromFieldSet.isEmpty();
    }


    /**
    * @author Francesco Imperioli - fimperioli@deloitte.it
    * @description return contracts for new commodity bill management for EndesaX
    * @createdDate 2020-03-03
    */
    @AuraEnabled
    public static List<Map<String,Object>> getCommodityContract(Map<String,Object> params){
        return XC_ZuoraBPCreationC_U.getCommodityContract(params);
    }

    /**
    * @description get infos about an existing commodity contract in case of a new lineItem avoiding a call to commodity system
    * @author Francesco Imperioli - fimperioli@deloitte.it | 16/4/2020 
    * @param billingProfileId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> getExistingCommodityContractInfos(String billingProfileId){
        Map<String,Object> result =  new Map<String,Object>();

        NE__Billing_Profile__c currentBP = [SELECT ID,XC_CommodityCupsID__c,XC_CommodityContractID__c,(SELECT ID,XC_CustomerAccount__r.Zuora__Batch__c FROM Billing_Profile_Line_Items__r WHERE XC_Status__c = 'Active' LIMIT 1) FROM NE__Billing_Profile__c WHERE ID = : billingProfileId];

        String billingBatch = !currentBP.Billing_Profile_Line_Items__r.isEmpty() ? currentBP.Billing_Profile_Line_Items__r[0].XC_CustomerAccount__r.Zuora__Batch__c : 'Batch1';

        result.put('contractId',currentBP.XC_CommodityContractID__c);
        result.put('contractCups',currentBP.XC_CommodityCupsID__c);
        result.put('billingBatch',billingBatch);

        return result;
    }


    // /**
    // * @description return the translated value for the BPLI search
    // * @author Francesco Imperioli - fimperioli@deloitte.it | 5/5/2020 
    // * @param paymentMethod 
    // * @return String 
    // **/
    // private static String getTranslatedBPLIPaymentSearchKey(String paymentMethod){

    //     Map<String,String> keyPaymentMap = new Map<String,String>();
    //     Schema.DescribeFieldResult fr = NE__Billing_Profile__c.NE__Payment__c.getDescribe();
    //     List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
    //     for(Schema.PickListEntry ple : entryList){
    //         keyPaymentMap.put(ple.getValue(),ple.getLabel());
    //     }
    //     return keyPaymentMap.containsKey(paymentMethod) ? keyPaymentMap.get(paymentMethod) : paymentMethod;
    // }
    
    /**
    * @author Andrea Di Cicco
    * @description retrieve the contact legal entities based on the user legal entities 
    * @param individualIds
    * @return a Map with key the Individual Id and value the associated Contact
    **/
    @AuraEnabled
    public static String getContactLegalEntities(String contactId){
        return JSON.serialize(XC_UTIL_Contact.getContactLegalEntities(contactId));
    }

    /**
    * @description save integration logs from component
    * @author Francesco Imperioli - fimperioli@deloitte.it | 11-10-2020 
    * @param integrationLogList 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean saveIntegrationLog(String integrationLogList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Init save integration log');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ integrationLogList -> ' + integrationLogList);
        List<XC_Integration_Log__c> logs = (List<XC_Integration_Log__c>) JSON.Deserialize(integrationLogList,List<XC_Integration_Log__c>.class);
        Boolean operationResult = true;
        List<XC_UTIL_Sobject.WrapperResult> results =  XC_UTIL_Sobject.insertListRecords(logs);
        operationResult = XC_UTIL_Sobject.checkDMLResults(results);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ operationResult -> ' + operationResult );
        return operationResult;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@ntdata.com
     * @date 04/02/2021 
     * @description Method to rollback if Zuora fails
     * @param billingProfLineItemId - String
     * @param message - String
     * @param doRollback - Boolean
     **/
    @TestVisible
    private static void rollbackForError(String billingProfLineItemId, String message, Boolean doRollback) {
        rollbackForError(billingProfLineItemId, message, doRollback, false);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@ntdata.com
     * @date 04/02/2021 
     * @description Method to rollback if Zuora fails
     * @param billingProfLineItemId - String
     * @param message - String
     * @param doRollback - Boolean
     **/
    @TestVisible
    private static void rollbackForError(String billingProfLineItemId, String message, Boolean doRollback, Boolean fromBillingProfile) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Rollback for Zuora error');
        XC_UTIL_DependentPicklist.PicklistWrapper pw = XC_UTIL_DependentPicklist.getDependentPicklist('NE__Billing_Profile__c', 'NE__Payment__c', 'XC_PaymentMethodCategory__c');
        List<String> listPaymentExternal = new List<String>();
        for(String key : pw.pickListMap.keySet()) {
            List<String> listPaymentMethod = pw.pickListMap.get(key);
            for(String mp : listPaymentMethod) {
                if(mp == Label.XC_CL_PaymentType_External) {
                    listPaymentExternal.add(key);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPaymentExternal: ' + listPaymentExternal);
        if(listPaymentExternal.isEmpty()) {
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPaymentExternal -> ' + listPaymentExternal);

        List<XC_BillingProfileLineItem__c> listBillingProfile = new List<XC_BillingProfileLineItem__c>([
            SELECT Id, XC_BillingProfile__c, XC_PaymentMethod__c 
            FROM XC_BillingProfileLineItem__c 
            WHERE Id = :billingProfLineItemId
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listBillingProfile  -> ' + listBillingProfile );
        if(listBillingProfile.isEmpty()) {
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listBillingProfile -> ' + listBillingProfile);

        List<XC_BillingProfileLineItem__c> listBplToUpdate = new List<XC_BillingProfileLineItem__c>();
        List<XC_BillingProfileLineItem__c> listBplToDelete = new List<XC_BillingProfileLineItem__c>();
        List<NE__Billing_Profile__c> listBillingProfileToDelete = new List<NE__Billing_Profile__c>();
        for(XC_BillingProfileLineItem__c bp : listBillingProfile) {
            // For external method:
            if(listPaymentExternal.contains(bp.XC_PaymentMethod__c) && doRollback && !fromBillingProfile) {
                listBplToDelete.add(new XC_BillingProfileLineItem__c(Id = bp.Id));
                listBillingProfileToDelete.add(new NE__Billing_Profile__c(Id = bp.XC_BillingProfile__c));
            } else if(listPaymentExternal.contains(bp.XC_PaymentMethod__c) && doRollback && fromBillingProfile) {
                listBplToDelete.add(new XC_BillingProfileLineItem__c(Id = bp.Id));
            }
            // For other method:
            else {
                listBplToUpdate.add(new XC_BillingProfileLineItem__c(
                    Id = bp.Id,
                    XC_Status__c = Label.XC_CL_ZuoraInvoiceDraft,
                    XC_ErrorLastCallout__c = message
                ));
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listBplToUpdate -> ' + listBplToUpdate);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listBplToDelete -> ' + listBplToDelete);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listBillingProfileToDelete -> ' + listBillingProfileToDelete);
        XC_UTIL_Sobject.updateListRecords(listBplToUpdate);
        XC_UTIL_Sobject.deleteListRecords(listBplToDelete);
        XC_UTIL_Sobject.deleteListRecords(listBillingProfileToDelete);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End rallback for error');
    }

    /**
     * @author Eleni Tsiolaki - etsiolaki@deloitte.it
     * @date 21/07/2021 
     * @description Method to rollback if Billing Profile Line Item DML operation fails
     * @param input - InputRollbackWrapper
     **/
    @TestVisible
    private static void rollbackForErrorBPLI(InputRollbackWrapper input) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Rollback for Billing Profile Line Item error');

        List<XC_BillingProfileLineItem__c> listBplToUpdate = new List<XC_BillingProfileLineItem__c>();
        List<NE__Billing_Profile__c> listBillingProfileToDelete = new List<NE__Billing_Profile__c>();
        
        if (input.doRollback && input.billingProfileId != null) {
            NE__Billing_Profile__c billProfileToDelete = [SELECT Id FROM NE__Billing_Profile__c WHERE Id = :input.billingProfileId LIMIT 1];
            listBillingProfileToDelete.add(billProfileToDelete);
            
        } else if(!input.doRollback && input.billingProfileLineItemId != null) {

            List<XC_BillingProfileLineItem__c> listBillingProfile = new List<XC_BillingProfileLineItem__c>([
                SELECT Id, XC_BillingProfile__c, XC_PaymentMethod__c 
                FROM XC_BillingProfileLineItem__c 
                WHERE Id = :input.billingProfileLineItemId
            ]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listBillingProfileLineItems  -> ' + listBillingProfile );
            if(listBillingProfile.isEmpty()) {
                return;
            }

            for(XC_BillingProfileLineItem__c bp : listBillingProfile) {
                listBplToUpdate.add(new XC_BillingProfileLineItem__c(
                    Id = bp.Id,
                    XC_Status__c = Label.XC_CL_ZuoraInvoiceDraft,
                    XC_ErrorLastCallout__c = input.errorMessage
                ));
            }
        }
        System.debug('listBillingProfileToDelete -> ' + listBillingProfileToDelete);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listBplToUpdate -> ' + listBplToUpdate);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listBillingProfileToDelete -> ' + listBillingProfileToDelete);
        XC_UTIL_Sobject.updateListRecords(listBplToUpdate);
        XC_UTIL_Sobject.deleteListRecords(listBillingProfileToDelete);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End rollback for error');
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@ntdata.com
     * @date 04/02/2021 
     * @description Method to rollback if Zuora fails for create payment method
     * @param paymentMethod - String
     * @param entityName - String
     * @param billingProfLineItemId - String
     * @param doRollback - Boolean
     * @return String
     **/
    @AuraEnabled
    public static String createPaymentMethod(String paymentMethod, String entityName, String billingProfLineItemId, Boolean doRollback){
        return createPaymentMethod(paymentMethod, entityName, billingProfLineItemId, doRollback, false);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@ntdata.com
     * @date 04/02/2021 
     * @description Method to rollback if Zuora fails for create payment method
     * @param paymentMethod - String
     * @param entityName - String
     * @param billingProfLineItemId - String
     * @param doRollback - Boolean
     * @return String
     **/
    @AuraEnabled
    public static String createPaymentMethod(String paymentMethod, String entityName, String billingProfLineItemId, Boolean doRollback, Boolean fromBillingProfile){
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        ZuoraWebservice.CreatePaymentMethodResponse resp = zws.createPaymentMethod(paymentMethod);
        if(resp.Success.toLowerCase() != 'true') {
            rollbackForError(billingProfLineItemId, resp.Errors[0].Code + ' - ' + resp.Errors[0].Message, doRollback, fromBillingProfile);
        }
        return JSON.serialize(resp);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@ntdata.com
     * @date 04/02/2021 
     * @description Method to rollback if Zuora fails for create payment method
     * @param paymentMethod - String
     * @param entityName - String
     * @param billingProfLineItemId - String
     * @return String
     **/
    @AuraEnabled
    public static String createPaymentMethod(String paymentMethod, String entityName, String billingProfLineItemId){
        return createPaymentMethod(paymentMethod, entityName, billingProfLineItemId, false);
    }

}