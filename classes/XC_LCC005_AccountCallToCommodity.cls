/**
 * @author Nicolò Leonardi - nleonardi@deloitte.it & Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 12/09/2018
 * @date Modification 10/10/2018 by Riccardo Cossu
 * @date Modification 24/10/2018 by Fabrizio Antonioli - Fabrizio.Antonioli@nttdata.com & Giovanni Schioppa - Giovanni.Schioppa@nttdata.com
 * @date Modification 04/04/2019 by Monica Cutillo - monica.cutillo@nttdata.com
 * @date Modification 06/05/2019 by Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Modification 22/10/2019 by Andrea Di Cicco
 * @description XC_LCC005_AccountCallToCommodity – Controller for XC_LCP005_AccountCallToCommodity Component
 */

public without sharing class XC_LCC005_AccountCallToCommodity {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC005_AccountCallToCommodity');

    /** @description The Class MainResultWrapper */
    public class MainResultWrapper{
        /** @description Success The Success */
        @AuraEnabled 
        public Boolean success {get; set;}
        /** @description resultMessage */
        @AuraEnabled
        public String resultMessage {get; set;}

        /** @description accountsResulWrappers */
        @AuraEnabled
        public List<ResultWrapper> accountsResulWrappers {get; set;}
        /** @description response JSON from API */
        @AuraEnabled
        public XC_REST_Account_W.WrapperResponseGET accountsResponseJSON {get; set;}
        /** @description Map used to map the address on the other objects */
        @AuraEnabled
        public Map<String,String> addressMap {get; set;}
    }

    /** @description The Class ResultWrapper */
    public class ResultWrapper{  
        /** @description Success The Success */
        @AuraEnabled 
        public Boolean success {get; set;} 
        /** @description String resultMessage */
        @AuraEnabled
        public String resultMessage {get; set;} 
        /** @description recordFields */
        @AuraEnabled
        public List<FieldWrapper> recordFields {get; set;}
        /** @description sections */
        @AuraEnabled
        public Map<String,SectionFieldWrapper> sections {get; set;}
        
        /** @description XC_UTIL_IntegrationLog to insert **/
        public List<XC_Integration_Log__c> integrationLog;

        /** @description ResultWrapper */
        public ResultWrapper(){
            recordFields = new List<FieldWrapper>();
            sections = new Map<String,SectionFieldWrapper>();
        }

        /**
         * @description Instantiates a new result wrapper.
         * @param success the success
         * @param resultMessage the result message
         */
        public ResultWrapper(Boolean success, String resultMessage){
            this();
            this.success = success; 
            this.resultMessage = resultMessage;
        }
    }

    /** @description FieldWrapper */
    public class FieldWrapper{ 
        /** @description String fieldKey */
        @AuraEnabled
        public String fieldKey {get; set;} 
        /** @description String fieldLabel */
        @AuraEnabled
        public String fieldLabel {get; set;} 
        /** @description String fieldValue */
        @AuraEnabled 
        public String fieldValue {get; set;} 
        /** @description String fieldType: inputText default value - MC 25/04/2020 */
        @AuraEnabled 
        public String fieldType {get; set;} 
        /** @description Instantiates a new field wrapper */
        public FieldWrapper(){ //NB >>> NON CANCELLARE!!!
            this.fieldType = 'inputText';
            //XC_UTIL_Debug.debug(false,'FieldWrapper creation');
        }
    }

    /** @description The Class SectionFieldWrapper */
    public class SectionFieldWrapper{
        /** @description dataObjects */
        @AuraEnabled
        public List<String> dataObjects {get; set;} 
        /** @description sectionLabel */
        @AuraEnabled
        public String sectionLabel {get; set;} 
        /** @description objectsRecordFields */
        @AuraEnabled 
        public List<List<FieldWrapper>> objectsRecordFields {get; set;}
        /** @description subsectionObjects */ 
        @AuraEnabled
        public List<List<List<FieldWrapper>>> subsectionObjects {get; set;}
        /** @description subsectionLabels */
        @AuraEnabled
        public List<String> subsectionLabels {get; set;} 
    }
    
    /**
     * @description manage Account Commodity response
     * @param response the response
     * @param recordId the recordId
     * @param sobjectType the sobjectType
     * @return the wrapper result
     */
    public static MainResultWrapper manageAccountCommodityResponse(HttpResponse response, String recordId, String sobjectType){
        XC_REST_ReadAccont.WrapperResult callResult = XC_REST_ReadAccont.manageResponse(response);
        XC_REST_Account_W.WrapperResponseGET commodityResult = callResult.readAccountResponse;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_LCC005_AccountCallToCommodity manageAccountCommodityResponse > '+commodityResult);
        if(commodityResult == null || commodityResult.Account == null || commodityResult.Account.isEmpty()){
            MainResultWrapper rw = new MainResultWrapper();
            rw.success = false;
            rw.resultMessage = Label.XC_CL_NoAccountForDoc;
            return rw;
        }
        
        List<XC_LCC005_AccountCallToCommodity.ResultWrapper> accRes = XC_LCC005_AccountCallToCommodity_Manage.manageCallCommodityMain(callResult, recordId, sobjectType);
        MainResultWrapper rw = new MainResultWrapper();
        rw.success = true;
        rw.accountsResulWrappers = accRes;
        return rw;
    }

    /**
     * @description Call commodity new.
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @param recordId the record id
     * @param sobjectType the sobject Type
     * @return the result wrapper list
     * @date Creation 04/04/2019
     */
    /*@AuraEnabled
    public static MainResultWrapper callCommodityNew(String recordId, String sobjectType){
        //Account acc = retrieveAccountData(recordId);
        String identityNumber = retrieveIdentityNumber(recordId, sobjectType);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ callCommodityNew -> identityNumber='+identityNumber);
        //if(acc == null || acc.IdentityNumber__c == null || acc.IdentityNumber__c == ''){
        if(identityNumber == ''){
            MainResultWrapper rw = new MainResultWrapper();
            rw.success = false;
            rw.resultMessage = Label.XC_CL_NoDocForAccountMess;
            return rw;
        }

        XC_REST_ReadAccont.WrapperResult callResult = executeCallCommodityNew(identityNumber); //(acc.IdentityNumber__c); //recordId
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ callCommodityNew -> Commodity callResult='+callResult);
        if(callResult == null ){ // || !callResult.success 
            //return new ResultWrapper(false, callResult.message) ;
            MainResultWrapper rw = new MainResultWrapper();
            rw.success = false;
            rw.resultMessage = callResult.message;
            return rw;
        }
        //XC_REST_ReadAccont_U.WrapperResponseCommoditySpain commodityResult = callResult.commoditySpainResponse;
        XC_REST_Account_W.WrapperResponseGET commodityResult = callResult.readAccountResponse;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ callCommodityNew -> readAccountResponse='+commodityResult);
        /*ResultWrapper result = new ResultWrapper();
        result.success = true;* /

        if(commodityResult == null || commodityResult.Account == null || commodityResult.Account.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'WrapperResponseCommoditySpain='+commodityResult);
            //return new ResultWrapper(false, 'No Commodity Account found for this document');
            MainResultWrapper rw = new MainResultWrapper();
            rw.success = false;
            rw.resultMessage = Label.XC_CL_NoAccountForDoc;
            return rw;
        }
        //return XC_LCC005_AccountCallToCommodity_Manage.manageCallCommodityMain(callResult, recordId); //manageCallCommodityNew(commodityResult,result, ..)
        List<XC_LCC005_AccountCallToCommodity.ResultWrapper> accRes = XC_LCC005_AccountCallToCommodity_Manage.manageCallCommodityMain(callResult, recordId, sobjectType);
        MainResultWrapper rw = new MainResultWrapper();
        rw.success = true;
        rw.accountsResulWrappers = accRes;
        return rw;
    }*/

    /**
     * @description Identify Data Wrapper
     */
    public class IdentifyDataWrapper {
        public String identityNumber;
        public String identityType;
        public String country;
    }

    /**
     * @description retrieveAccountData
     * @param recordId the record id
     * @param sobjectType the sobject type name
     * @return the IdentifyDataWrapper
     */
    //@AuraEnabled
    public static IdentifyDataWrapper retrieveIdentityData(String recordId, String sobjectType){
        IdentifyDataWrapper result = new IdentifyDataWrapper();
        if('Account'.equals(sobjectType)){
            Map<Id,Account> accs = new Map<Id,Account>([SELECT Id, IdentityNumber__c, IdentityType__c,XC_DocumentCountry__c  FROM Account WHERE Id =: recordId ]);
            if(!accs.isEmpty()){
                result.identityNumber = accs.values()[0].IdentityNumber__c;
                result.identityType = accs.values()[0].IdentityType__c;
                result.country = accs.values()[0].XC_DocumentCountry__c;
            }
        }
        else if('Lead'.equals(sobjectType)){
            Map<Id,Lead> leads = new Map<Id,Lead>([SELECT Id, XC_DocumentNumber__c, XC_DocumentType__c,XC_DocumentCountry__c FROM Lead WHERE Id =: recordId ]);
            if(!leads.isEmpty()){
                result.identityNumber = leads.values()[0].XC_DocumentNumber__c;
                result.identityType = leads.values()[0].XC_DocumentType__c;
                result.country = leads.values()[0].XC_DocumentCountry__c;
            }
        }
        return result;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description Method to create a section in the view
     * @param sectionName name to identify the section
     * @param wrapperObjs Listo of wrapper with data to view in the section
     * @param viewDef the ReadAccountViewDefinition
     * @return SectionFieldWrapper the object to pass frontend 
    */
    public static SectionFieldWrapper sectionCreation(String sectionName, List<Object> wrapperObjs, XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition viewDef){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Wrapper Section '+sectionName+' = '+wrapperObjs);
        if(wrapperObjs!=null && !wrapperObjs.isEmpty()){
            return buildSectionFieldWrapper(sectionName, wrapperObjs, viewDef);
        }
        return new SectionFieldWrapper();
    }

    /**
     * @description Builds the fields wrapper Map.
     * @param commodityWrapperObj the commodity wrapper obj
     * @param viewDef the ReadAccountViewDefinition
     * @return the list
     */
    public static Map<String,FieldWrapper> buildFieldsWrapperMap(Object commodityWrapperObj, XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition viewDef){
        Map<String,FieldWrapper> fieldsWr = new Map<String,FieldWrapper>();
        Map<String,Object> objectDataMap = XC_REST_ReadAccont_U.buildMapFromWrapperObject(commodityWrapperObj);
        Map<String,String> labels = viewDef.labels;
        for(String key : viewDef.keySet){
            if(labels.get(key)!=null){
                FieldWrapper wr = new FieldWrapper();
                if(String.isNotBlank(key)){
                    wr.fieldKey   = key;
                    wr.fieldLabel = labels.get(key);
                    wr.fieldValue = String.valueOf(objectDataMap.get(key));
                    fieldsWr.put(key,wr);
                }
            }
        }
        return fieldsWr;
    }

    /**
     * @description Builds the fields wrapper List.
     * @param commodityWrapperObj the commodity wrapper obj
     * @param viewDef the ReadAccountViewDefinition
     * @return the list
     */
    public static List<FieldWrapper> buildFieldsWrapper(Object commodityWrapperObj, XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition viewDef){
        return (buildFieldsWrapperMap(commodityWrapperObj, viewDef)).values();
        /*List<FieldWrapper> fieldsWr = new List<FieldWrapper>();
        Map<String,Object> objectDataMap = XC_REST_ReadAccont_U.buildMapFromWrapperObject(commodityWrapperObj);
        Map<String,String> labels = viewDef.labels;
        for(String key : viewDef.keySet){
            if(labels.get(key)!=null){
                FieldWrapper wr = new FieldWrapper();
                if(String.isNotBlank(key)){
                    wr.fieldKey   = key;
                    wr.fieldLabel = labels.get(key);
                    wr.fieldValue = String.valueOf(objectDataMap.get(key));
                    fieldsWr.add(wr);
                }
            }
        }
        return fieldsWr;*/
    }

    /**
     * @description Builds Contact section, with its subsections.
     * @param wrapperContact list of wrapper Contact
     * @param viewDef the ReadAccountViewDefinition
     * @return the Contact section wrapper
     */
    public static SectionFieldWrapper sectionContactCreation(List<XC_UTIL_Account.ContactIFWrapper> wrapperContact, Map<String,XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition> viewDef){
		List<List<List<FieldWrapper>>> subsectionObjects = new List<List<List<FieldWrapper>>>();
        //create Subsection
        /*for(XC_UTIL_Account.ContactIFWrapper contact: wrapperContact){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '->->->->->->->->->->->->->->->-> Wrapper Contact = '+contact);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '->->->->->->->->->->->->->->->-> Wrapper GDPR = '+contact.GDPR);
            /*if(contact.GDPR != null && contact.GDPR.LegalEntity != null && !contact.GDPR.LegalEntity.isEmpty()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '->->->->->->->->->->->->->->->-> Wrapper LegalEntity = '+contact.GDPR.LegalEntity);
                SectionFieldWrapper subsectionWrapper = buildSectionFieldWrapper('LegalEntity', contact.GDPR.LegalEntity, viewDef.get('LegalEntity'));//sectionCreation
                subsectionObjects.add(subsectionWrapper.objectsRecordFields);

            }* /
            XC_UTIL_Debug.debug(DEBUGACTIVE, '########### subsectionObjects parziale > '+subsectionObjects);
            
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->->->->->->->->->->->->->->->-> subsectionObjects = '+subsectionObjects);*/

		SectionFieldWrapper sectionWrapper = buildSectionContactFieldWrapper(wrapperContact, viewDef.get('Contact'));//sectionCreation
        sectionWrapper.subsectionObjects = subsectionObjects;
        return sectionWrapper;
    }

    /**
     * @description Builds legalEntitySection
     * @param wrapperContact list of wrapper Contact
     * @param viewDef the ReadAccountViewDefinition
     * @param documentNumber account document number
     * @return the Contact section wrapper
     */
    public static SectionFieldWrapper sectionLegalEntityCreation(List<XC_UTIL_Account.ContactIFWrapper> wrapperContact, Map<String,XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition> viewDef,  String documentNumber){
        SectionFieldWrapper sectionWrapper  = new SectionFieldWrapper();
        //create Subsection
        for(XC_UTIL_Account.ContactIFWrapper contact: wrapperContact){
            //if(contact.IdentityNumber == documentNumber){
                if(contact.GDPR != null && contact.GDPR.LegalEntity != null){
                    for(XC_UTIL_Account.LegalEntityWrapper legalEnitity : contact.GDPR.LegalEntity){
                        legalEnitity.GiveDataToThirdParties = contact.GDPR.GiveDataToThirdParties;
                    }
                sectionWrapper = buildSectionLegalEntityFieldWrapper( contact.GDPR.LegalEntity, viewDef.get('LegalEntity') );
                }
            //}
        }
		//sectionCreation
        return sectionWrapper;
    }
    /**
     * @description Builds address section, with eventually its subsections.
     * @param wrapperAddress list of wrapper address
     * @param viewDef the ReadAccountViewDefinition
     * @return the address section wrapper
     */
    public static SectionFieldWrapper sectionAddressCreation(List<XC_UTIL_Address.AddressWrapper> wrapperAddress, Map<String,XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition> viewDef){
		List<XC_UTIL_Address.AddressWrapper> listAccToShow = new List<XC_UTIL_Address.AddressWrapper>();
        List<List<List<FieldWrapper>>> subsectionObjects = new List<List<List<FieldWrapper>>>();

        //create Subsection
        for(XC_UTIL_Address.AddressWrapper address: wrapperAddress){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '->->->->->->->->->->->->->->->-> Wrapper Address = '+address);
            if(address.PointOfService != null && !address.PointOfService.isEmpty()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '->->->->->->->->->->->->->->->-> Wrapper POS = '+address.PointOfService);
                SectionFieldWrapper subsectionWrapper = buildSectionFieldWrapper('PointOfService', address.PointOfService, viewDef.get('PointOfService'));//sectionCreation
                subsectionObjects.add(subsectionWrapper.objectsRecordFields);
				listAccToShow.add(address);

            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '########### subsectionObjects parziale > '+subsectionObjects);

        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->->->->->->->->->->->->->->->-> subsectionObjects = '+subsectionObjects);

		SectionFieldWrapper sectionWrapper = buildSectionFieldWrapper('Address', listAccToShow, viewDef.get('Address'));//sectionCreation
        sectionWrapper.subsectionObjects = subsectionObjects;
        return sectionWrapper;
    }

    /**
     * @description Builds the section field wrapper.
     * @param sectionName the section name
     * @param sectionObjs the section objs
     * @param viewDef the ReadAccountViewDefinition
     * @return the section field wrapper
     */
    public static SectionFieldWrapper buildSectionFieldWrapper(String sectionName, List<Object> sectionObjs, XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition viewDef){
        SectionFieldWrapper section = new SectionFieldWrapper();
        section.sectionLabel = sectionName;
        List<List<FieldWrapper>> objsFields = new List<List<FieldWrapper>>();
        if(sectionObjs !=  null){
            for(Object obj : sectionObjs){
                List<FieldWrapper> fieldsObj = buildFieldsWrapper(obj, viewDef);
                if(!fieldsObj.isEmpty()){
                    objsFields.add(fieldsObj);
                }
            }
        }
        section.objectsRecordFields = objsFields;

        return section;
    }

    /**
     * @description Builds the section field wrapper.
     * @param wrapperContacts the section objs
     * @param viewDef the ReadAccountViewDefinition
     * @return the section field wrapper
     */
    private static SectionFieldWrapper buildSectionContactFieldWrapper(List<XC_UTIL_Account.ContactIFWrapper> wrapperContacts, XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition viewDef){
        SectionFieldWrapper section = new SectionFieldWrapper();
        section.sectionLabel = Label.XC_CL_Contact;
        List<List<FieldWrapper>> objsFields = new List<List<FieldWrapper>>();
        Map<String,FieldWrapper> fieldsMap;
        for(XC_UTIL_Account.ContactIFWrapper contObj : wrapperContacts){
            fieldsMap = buildFieldsWrapperMap(contObj, viewDef);
            //Add Legal Entity  ->  [MC - Anomalia 2400 - 27/02/2020]
            /*if(contObj.GDPR != null && contObj.GDPR.LegalEntity != null && !contObj.GDPR.LegalEntity.isEmpty()){
                String contactLEs = '';
                for(XC_UTIL_Account.LegalEntityWrapper contLE : contObj.GDPR.LegalEntity){
                    if(String.isNotBlank(contLE.LegalEntity)){
                        contactLEs = contactLEs + (String.isNotBlank(contactLEs) ? ',' : '') + contLE.LegalEntity;
                    }
                }
                FieldWrapper wr = new FieldWrapper();
                wr.fieldKey = 'LegalEntities';
                wr.fieldValue = contactLEs;
                wr.fieldLabel = 'LegalEntities';
                fieldsMap.put('LegalEntities',wr);
            }*/
            //modifico nel Contact il campo proveniente dal suo GDPR, se valorizzato
            /*if(contObj.GDPR != null && contObj.GDPR.GiveDataToThirdParties != null){
                FieldWrapper wr = fieldsMap.get('GiveDataToThirdParties');
                wr.fieldValue = contObj.GDPR.GiveDataToThirdParties;
                fieldsMap.remove('GiveDataToThirdParties');
                fieldsMap.put('GiveDataToThirdParties',wr);
            }*/
            if(!fieldsMap.isEmpty()){
                objsFields.add(fieldsMap.values());
            }
        }
        section.objectsRecordFields = objsFields;
        return section;
    }


    /**
     * @description Builds the section field wrapper.
     * @param wrapperLE the section objs
     * @param viewDef the ReadAccountViewDefinition
     * @return the section field wrapper
     */
    private static SectionFieldWrapper buildSectionLegalEntityFieldWrapper(List<XC_UTIL_Account.LegalEntityWrapper> wrapperLE, XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition viewDef){
        SectionFieldWrapper section = new SectionFieldWrapper();
        section.sectionLabel = Label.XC_CL_Contact;
        List<List<FieldWrapper>> objsFields = new List<List<FieldWrapper>>();
        Map<String,FieldWrapper> fieldsMap;
        for(XC_UTIL_Account.LegalEntityWrapper contObj : wrapperLE){
            fieldsMap = buildFieldsWrapperMap(contObj, viewDef);
            //modifico nel Contact il campo proveniente dal suo GDPR, se valorizzato
            /*if(contObj.GDPR != null && contObj.GDPR.GiveDataToThirdParties != null){
                FieldWrapper wr = fieldsMap.get('GiveDataToThirdParties');
                wr.fieldValue = contObj.GDPR.GiveDataToThirdParties;
                fieldsMap.remove('GiveDataToThirdParties');
                fieldsMap.put('GiveDataToThirdParties',wr);
            }*/
            if(!fieldsMap.isEmpty()){
                objsFields.add(fieldsMap.values());
            }
        }
        section.objectsRecordFields = objsFields;
        return section;
    }



    /**
     * @description Execute call commodity new.
     * @param identityNumber the record id
     * @return the x C RES T read accont. wrapper result
     */
    /*public static XC_REST_ReadAccont.WrapperResult executeCallCommodityNew(String identityNumber){
        //String interfaceName = Label.XC_CL_ReadAccountCommoditySpain;
        //XC_REST_ReadAccont_U.WrapperAccount wrAccount = new XC_REST_ReadAccont_U.WrapperAccount();
        //wrAccount.IdentityNumber = identityNumber;
        //XC_REST_ReadAccont_U.WrapperAddress wrAddress = setFakeCommodityAddress(); 
        //return XC_REST_ReadAccont.callToGetReadAccont(interfaceName, wrAccount, wrAddress);
        Map<String, String> paramsMap = new Map<String, String>();
        paramsMap.put('IdentityNumber', identityNumber);
        return XC_REST_ReadAccont.callToReadAccount(Label.XC_CL_ReadAccountCommoditySpain, paramsMap); 
    }*/

    /**
     * @description Call commodity.
     * @param recordId the record id
     * @return the result wrapper
     */
    /*@AuraEnabled
    public static ResultWrapper callCommodity(String recordId){
        Account a = retrieveAccount(recordId);
        ResultWrapper result = new ResultWrapper();
        Boolean activeInterface = XC_UTIL_RESTCallout.checkActiveInterface(Label.XC_CL_Account_CallToCommodity);
		String url = Label.XC_CL_Account_CallToCommodityURL;
        String requestString = '';
        if(activeInterface){  
            
            HttpRequest request = XC_UTIL_RESTCallout.createRequest(url, requestString);
            HttpResponse response = XC_UTIL_RESTCallout.sendRequest(request,'XC_LCC005_AccountCallToCommodity');
            result = XC_LCC005_AccountCallToCommodity_Manage.manageResponse(response);
        }
        else {
            String fakeResponse = '{"Nombre":"Penélope",'+
                                '"Appelidos":"Cruz",'+
                                '"Correo electrónico":"penelope.cruz@gmail.com",'+
                                '"Teléfono":"0034915482556",'+
                                '"Moviles":"00319136468",'+
                                '"Tipo documento identificación":"NIE",'+
                                '"Número de documento de identificación":"Z1648141N",'+
                                '"Fecha de Nacimiento":"28-04-1974",'+
                                '"#KWh ":"3,5 kW",'+
                                '"#Energy Account":"LUZ",' +
                                '"Control de lista negra":""}';
            result = XC_LCC005_AccountCallToCommodity_Manage.manageResponseFake(fakeResponse); 
        }
        return result;  
    }*/

    

    /**
     * @description importAddressFromCommodity.
     * @param inputDataToSave map with all params input
     * @param addressValues addressValues to save
     * @param posValues posValues to save
     * @return the result wrapper
     */
    @AuraEnabled
    public static ResultWrapper importAddressFromCommodity(Map<String,Object> inputDataToSave, List<Map<String,Object>> addressValues, List<List<Map<String,Object>>> posValues){
        return XC_LCC005_AccountCallToCommodity_U.importAddressFromCommodity( inputDataToSave, addressValues, posValues);
    }

    /**
     * @description update the Account
     * @param value the value of the field 
     * @param label the label of the fiueld
     * @param recordId the Id of the account
     * @return the result of the update 
    
     */
    @AuraEnabled
    public static ResultWrapper updateAccount(String value, String label, String recordId){
        return XC_LCC005_AccountCallToCommodity_U.updateAccount(value, label, recordId);
    }
    /**
     * @author Andrea Di Cicco
     * @description importAddressFromCommodity.
     * @param inputDataToSave map with all params input
     * @param contactValues addressValues to save
     * @return the result wrapper
     */
    @AuraEnabled
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper importContactFromCommodity(Map<String,Object> inputDataToSave, List<Map<String,Object>> contactValues){
        return XC_LCC005_AccountCallToCommodity_U.importContactFromCommodity( inputDataToSave, contactValues);
    }
    /**
     * @author Andrea Di Cicco
     * @description update the Name and surname.
     * @param resultListString map with all params input
     * @param recordId addressValues to save
     * @return the result wrapper
     */
    @AuraEnabled
    public static ResultWrapper  saveNameSurname(String resultListString, String recordId){
        return XC_LCC005_AccountCallToCommodity_U.saveNameSurname( resultListString,  recordId);
    }

    /**
     * @author Andrea Di Cicco
     * @description update main phone.
     * @param resultListString map with all params input
     * @param recordId addressValues to save
     * @return the result wrapper
     */
    @AuraEnabled
    public static ResultWrapper  savePrimaryPhone(String resultListString, String recordId){
        return XC_LCC005_AccountCallToCommodity_U.savePrimaryPhone( resultListString,  recordId);
    }

       /**
     * @author Andrea Di Cicco
     * @description update main phone.
     * @param resultListString map with all params input
     * @param recordId addressValues to save
     * @return the result wrapper
     */
    @AuraEnabled
    public static ResultWrapper  saveSecondaryPhone(String resultListString, String recordId){
        return XC_LCC005_AccountCallToCommodity_U.saveSecondaryPhone( resultListString,  recordId);
    }


    /**
     * @author Andrea Di Cicco
     * @description update main phone.
     * @param email map with all params input
     * @param recordId addressValues to save
     * @return the result wrapper
     */
    @AuraEnabled
    public static ResultWrapper  saveEmail(String email, String recordId){
        ResultWrapper result = new ResultWrapper();
        result.success = true;
        Account account = new Account();
        account.id = recordId;
        account.PrimaryEmail__c = email;
        List<NE__Billing_Profile__c> billingProfileList = new List<NE__Billing_Profile__c>();
        if(Schema.sObjectType.NE__Billing_Profile__c.isAccessible()){
            billingProfileList = [Select  NE__Account__c, id from NE__Billing_Profile__c where NE__Account__c =: recordId ];
        }

        if(!billingProfileList.isEmpty()){
            result.success = false;
            result.resultMessage = Label.XC_CL_360EmailError+ ' Billing Profile';
            return result;
        }

        List<Opportunity> opportuniyList = new List<Opportunity>();
        if(Schema.sObjectType.Opportunity.isAccessible()){
            opportuniyList = [Select  id from Opportunity where AccountId =: recordId ];
        }

        if(!opportuniyList.isEmpty()){
            result.success = false;
            result.resultMessage = Label.XC_CL_360EmailError + ' Opportunity';
            return result;
        }

        List<Case> caseList = new List<Case>();
        if(Schema.sObjectType.Case.isAccessible()){
            caseList = [Select  id from Case where AccountId =: recordId ];
        }

        if(!caseList.isEmpty()){
            result.success = false;
            result.resultMessage = Label.XC_CL_360EmailError + ' Case';
            return result;
        }
          


        XC_UTIL_Sobject.WrapperResult accountResult = XC_UTIL_Sobject.updateRecord(account);
        result.success = accountResult.success;
        result.resultMessage = (accountResult.success) ? Label.XC_CL_360AccountUpdate : accountResult.errorMessage;
        return result;
    }

    /**
     * @author Andrea Di Cicco
     * @description save consents
     * @param recordId id of the entity
     * @param accountInfo information of the account
     */
    @AuraEnabled
    public static void saveConsents(String recordId, String accountInfo){
        XC_LCC005_AccountCallToCommodity_UU.saveConsents( recordId,  accountInfo);
    }
    /**
     * @description Sets the fake commodity address.
     * @return the x C RES T read accont u. wrapper address
     */
    /*private static XC_REST_ReadAccont_U.WrapperAddress setFakeCommodityAddress(){
        XC_REST_ReadAccont_U.WrapperAddress wrAddress = new XC_REST_ReadAccont_U.WrapperAddress();
        wrAddress.CUPS = '500';
        wrAddress.StreetType = 'Via';
        wrAddress.Address = 'Milazzo';
        wrAddress.StreetNumber = '33';
        wrAddress.Appartment = '7';
        wrAddress.Door = '1';
        wrAddress.Stair = '3';
        wrAddress.ZipCode = '04100';
        return wrAddress;
    }*/

    /**
     * @description Retrieve account.
     * @param recordId the record id
     * @return the account
     */
   /* private static Account retrieveAccount(String recordId){
        Account a = new Account();
        return a;
    }*/
}