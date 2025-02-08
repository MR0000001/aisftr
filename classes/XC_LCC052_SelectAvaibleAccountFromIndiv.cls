/**
 * The Class XC_LCC052_SelectAvaibleAccountFromIndiv.
 * @description  XC_LCC052_SelectAvaibleAccountFromIndiv
 */
public without sharing class XC_LCC052_SelectAvaibleAccountFromIndiv {
    
    /** @description UtilWrapper */
    public class UtilWrapper {
        @AuraEnabled
        public String typeObject = '';
        @AuraEnabled
        public Boolean documentExists = true;
       @AuraEnabled
        public String defaultLE = '';
        @AuraEnabled
        public List<Map<String, Object>> listOfAvaibleLE = new List<Map<String, Object>>();
        @AuraEnabled
        public Boolean showSelectLE = false;
    }

    @AuraEnabled
    public static UtilWrapper checkAvaibleLE(String recordTypeId) {
        List<String> listRecordTypeToShowCmp = new List<String>{'italy', 'spain', 'romania', 'chile'};
        UtilWrapper utility = new UtilWrapper();
        List<RecordType> listCurrentRecordTypeName = new List<RecordType>([SELECT Name from RecordType WHERE id =: recordTypeId]);
        String currentRT = listCurrentRecordTypeName[0].Name;

        Boolean found = false;
        for(String singleCountry : listRecordTypeToShowCmp){
            if(currentRT.toLowerCase().contains(singleCountry)){
                found = true;
                break;
            }
        }

        if(!found){
            utility.showSelectLE = false;
            return utility;
        }else{
            utility.showSelectLE = true;
        }

        List<User> listUser = new List<User>([
            SELECT Id, toLabel(XC_LegalEntity__c) LabelMainLegalEntity, toLabel(XC_LegalEntities__c) LabelsOtherLegalEntites, XC_LegalEntity__c, XC_LegalEntities__c
            FROM User 
            WHERE Id =: UserInfo.getUserId()
        ]);

        utility.defaultLE = listUser[0].XC_LegalEntity__c;
        Map<String, Object> mapConverted = listUser[0].getPopulatedFieldsAsMap();
        utility.listOfAvaibleLE.add(new Map<String, Object>{
            'id'        => listUser[0].XC_LegalEntity__c,
            'label'     => (''+mapConverted.get('LabelMainLegalEntity')),
            'selected'  => true
        });
        if(String.isNotBlank(listUser[0].XC_LegalEntities__c)) {
            List<String> listValueLE = listUser[0].XC_LegalEntities__c.split(';');
            List<String> listLabelLE = (''+mapConverted.get('LabelsOtherLegalEntites')).split(';');
            for(Integer i=0; i<listValueLE.size(); i++) {
                if(listValueLE[i] != listUser[0].XC_LegalEntity__c) {
                    utility.listOfAvaibleLE.add(new Map<String, Object>{
                        'id'    => listValueLE[i],
                        'label' => listLabelLE[i]
                    });
                }
            }
        }
        return utility;
    }

    /**
     * @description Select avaible account.
     * @param recordId the record id
     * @return the list
     */
    @AuraEnabled
    public static List<Map<String,String>> selectAvaibleAccount(String recordId) {
        List<Map<String,String>> accIdAccName = new List<Map<String,String>>();
        System.debug('entrato in selectAvaibleAccount con id= '+recordId);
        if(!Schema.SObjectType.AccountContactRelation.isAccessible()) {
            return new List<Map<String,String>>();
        }
        List<Account> acr = new List<Account>();   
        if(Schema.sObjectType.Account.isAccessible()) {
            acr = [select id, Name from account where id in (select accountid from contact where id =: recordId)];
        }
        if(!acr.isEmpty()){
             
            for(Account a : acr){
                Map<String,String> acrMap = new Map<String,String>();
                acrMap.put('key' , a.Id);
                acrMap.put('value' , a.Name); 
                accIdAccName.add(acrMap);
            }
        }
        System.debug('LA MAPPA '+accIdAccName);
        return accIdAccName;   
    }

    /**
     * @description Select avaible Contact from Account.
     * @param recordId the Account record id
     * @return data to view From Account (Contacts and Address)
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper selectAvaibleContact(String recordId) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        Map<String,Object> objData = new Map<String,Object>();

        Map<id, AccountContactRelation> relData = new  Map<id, AccountContactRelation>([
            SELECT Id, ContactId, IsActive, IsDeleted
              FROM AccountContactRelation 
             WHERE AccountId =: recordId
               AND IsActive = true
               AND IsDeleted = false
        ]);

        Set<Id> contactIds = new Set<Id>();
        for(AccountContactRelation rel : relData.values()){
            contactIds.add(rel.ContactId);
        }
        
        Map<id, Account> acc = new  Map<id, Account>([
            SELECT Id, Name FROM Account WHERE Id =: recordId
        ]);
        objData.put('accountName', acc.values()[0].Name);

        Map<id, Contact> contacts = new  Map<id, Contact>([
            SELECT Id, Name FROM Contact WHERE Id IN: contactIds ORDER BY Name
        ]);
        List<Map<String,String>> contactData = new List<Map<String,String>>();Map<String,String> contactMap;
        for(Contact cont : contacts.values()){
            contactMap = new Map<String,String>();
            contactMap.put('key' , cont.id);
            contactMap.put('value' , cont.Name);
            contactData.add(contactMap);
        }
        objData.put('contactData', contactData);

        List<Map<String,String>> addressData = getAddressesForOpp(recordId);
        objData.put('addressData', addressData);
        
        rw.objectInfo = JSON.serialize(objData);
        return rw;
    }
    
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createAssetApex(String assetValues){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = false;
        Asset a = new Asset();
        Map<String, Object> optionsMap = (Map<String, Object>)JSON.deserializeUntyped(assetValues);
        a.ContactId =  String.valueOf(optionsMap.get('contactId'));
        a.AccountId =  String.valueOf(optionsMap.get('accountId'));
        a.XC_Catalog__c = String.valueOf(optionsMap.get('catalog'));
        a.XC_CatalogCategory__c = String.valueOf(optionsMap.get('catalogCategory'));
        a.XC_Address__c = String.valueOf(optionsMap.get('addressId'));  
        a.Description = String.valueOf(optionsMap.get('description'));
        a.XC_Model__c =  String.valueOf(optionsMap.get('modelValue'));
        a.Name = String.valueOf(optionsMap.get('assetName'));
        a.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('XC_ESP_Customer').getRecordTypeId();
        a.Status = 'Active';
        a.XC_Product_Type__c = String.valueOf(optionsMap.get('productType'));
        a.XC_Product_Subtype__c = String.valueOf(optionsMap.get('productSubType'));
        XC_UTIL_Sobject.WrapperResult insertWr = XC_UTIL_Sobject.insertRecord(a); 
        rw = new XC_UTIL_ResultWrapper(insertWr);
        System.debug('result from createAsset = '+rw);
        return rw;
         
    }

    /**
     * @description updateContactOnAccount
     * @param contactId the Contact record id
     * @return the result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updateContactOnAccount(String accountId, String contactId) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        Account account = new Account();
        account.Id = accountId;
        account.XC_ContactToNotify__c = contactId;
        List<XC_UTIL_Sobject.WrapperResult> dmlRes = XC_UTIL_DML.updateRecords(new List<Account>{account});
        if(!dmlRes[0].success){
            rw.success = false;
            rw.resultMessage = dmlRes[0].errorMessage;
        }
        return rw;
    }
     
    @AuraEnabled
    public static XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper getListAddress(String recordId, Boolean applyIstallCondition) {
        return XC_LCC014_CreateWorkOrder.getListAddress(recordId,applyIstallCondition);
    }

    
    /**
     * @description Select all addresses by accountid
     * @param recordId the account id
     * @autor Simone Trenta - strenta@deloitte.it
     * @return the list
     */
    @AuraEnabled
    public static List<Map<String,String>> getAddressesForOpp(String recordId) {
        List<Map<String,String>> accIdAccName = new List<Map<String,String>>();

        Map<id, XC_Address__c> add = new  Map<id, XC_Address__c>([Select id, Name, XC_Account__c from XC_Address__c where XC_Account__c =: recordId and CreatedById != '0051i000002EpBCAA0' order by createdDate desc]);

        for(XC_Address__c a : add.values()){
            Map<String,String> acrMap = new Map<String,String>();
            acrMap.put('key' , a.id);
            acrMap.put('value' , a.Name);
            accIdAccName.add(acrMap);
        }

        return accIdAccName;   
    }

    /**
     * @description Check if is possible to chenge address for this opp
     * @param recordId the opportunity id
     * @autor Simone Trenta - strenta@deloitte.it
     * @return the wrapper result 
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkChangeAddress(String recordId) {
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();

        Map<Id,Opportunity> mapOp = new Map<Id,Opportunity>([
            SELECT id, (SELECT id FROM Orders), (SELECT id FROM Work_Orders__r) 
            FROM Opportunity
            WHERE Id =: recordId
            LIMIT 1
        ]);
        Opportunity opp = mapOp.values()[0];

        if(!opp.Orders.isEmpty()){
            result.success = false;
            result.resultMessage = 'Its not possibile to change the address because already exist a configuration related to this opportunity'; 
            return result;
        }

        if(!opp.Work_Orders__r.isEmpty()){
            result.success = false;
            result.resultMessage = 'Its not possibile to change the address because already exist a work order related to this opportunity';
            return result;
        }

        result.success = true;
        return result;   
    }

    /**
     * @description return the type
     * @param recordId the record id
     * @autor Simone Trenta - strenta@deloitte.it
     * @return the string 
     */
    @AuraEnabled
    public static UtilWrapper getType(String recordId) {
        UtilWrapper wr = new UtilWrapper();
        wr.typeObject = XC_UTIL_Sobject.getObjectType(recordId);
        wr.documentExists = checkDocumentOnAccount(recordId, wr.typeObject);
        return wr;
    }

    /**
    * @description check if document is populated on Account
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 5/11/2019 
    * @param recordId id of record
    * @param sObjectName id of sObject
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean checkDocumentOnAccount(String recordId, String sObjectName) {
        String query = String.escapeSingleQuotes('SELECT ID FROM ACCOUNT WHERE ((XC_DocumentCountry__c != NULL AND IdentityType__c != NULL AND IdentityNumber__c != NULL) OR (XC_SFMTechnicalField__c != NULL) )AND ID IN (SELECT AccountId FROM  ' + sObjectName + ' WHERE ID = :recordId)');
        System.debug('Query: ' + query);
        List<Account> accList = Database.query(query);
        return !accList.isEmpty();
    }
 
    /**
     * @description return the type
     * @param recordId the record id
     * @autor Simone Trenta - strenta@deloitte.it
     * @return the string 
     */
    @AuraEnabled
    public static Map<String,String> getAccountFromOpportunity(String recordId) {
        Map<String,String> res = new Map<String,String>();
        Map<id,Opportunity> mp = new Map<id,opportunity>([Select id, accountid, XC_Address__c from opportunity where id =: recordId]); 
        res.put('accountId',mp.values()[0].accountid);    
        res.put('addressId',mp.values()[0].XC_Address__c);  
        return res;
    }

    /**
     * @description return the type
     * @param inputFields the inputFields
     * @autor Simone Trenta - strenta@deloitte.it
     * @return the string 
     */
    @AuraEnabled
    public static String updateOpportunityAddress(String inputFields) {
        String result;
        Map<String,Object> fields = (Map<String,Object>) JSON.deserializeuntyped(inputFields);

        String addrId = String.valueOf(fields.get('addressId'));
        Map<Id,XC_Address__c> addMap = new Map<Id,XC_Address__c>([
            SELECT Id, XC_PricinRegion__c, XC_ElectricCUPS__c, XC_GasCUPS__c FROM XC_Address__c WHERE Id =: addrId LIMIT 1
        ]);
        XC_Address__c add = addMap.values()[0];

        Opportunity opp = new Opportunity();
        opp.id = String.valueOf(fields.get('opportunityId'));
        opp.XC_Address__c = addrId;
        opp.XC_PrincingRegion__c = add.XC_PricinRegion__c;
        opp.XC_ElectricContract__c = null;
        opp.XC_ElectricTariff__c = null;
		opp.XC_ElectricMinimumConsumption__c = null;
        opp.XC_ElectricTensionType__c = null;
		opp.XC_ElectricContractedPower__c = null;
		opp.XC_ElectricOwnerCompany__c = null;
        opp.XC_ElectricCieAuthorizedMaximumPower__c = null;
        opp.XC_GasContract__c = null;
        opp.XC_GasTariff__c  = null;
		opp.XC_GasOwnerCompany__c = null;
        opp.XC_GasMaximumPower__c = null;

        Map<String,String> infoMap = new Map<String,String>();
        if(add.XC_ElectricCUPS__c!=null){
            opp.XC_ElectricCUPS__c = add.XC_ElectricCUPS__c;
            infoMap.put('cups', add.XC_ElectricCUPS__c);
            infoMap.put('opp', JSON.serialize(opp));
            infoMap.put('contractType', 'Electric');
            XC_TR_Opportunity_U_AssignOpportunity.getContractAsyncExecution(infoMap);
            //ID jobID = System.enqueueJob(new XC_TR_Opportunity_U_AssignOpportunity.XC_TR_GetContractAsyncExecution(add.XC_ElectricCUPS__c,opp, 'Electric'));
        }
        if(add.XC_GasCUPS__c!=null){
            opp.XC_GasCUPS__c = add.XC_GasCUPS__c;
            infoMap.put('cups', add.XC_GasCUPS__c);
            infoMap.put('opp', JSON.serialize(opp));
            infoMap.put('contractType', 'Gas');
            XC_TR_Opportunity_U_AssignOpportunity.getContractAsyncExecution(infoMap);
            //ID jobID = System.enqueueJob(new XC_TR_Opportunity_U_AssignOpportunity.XC_TR_GetContractAsyncExecution(add.XC_GasCUPS__c,opp,'Gas'));
        }

        result = JSON.serialize(XC_UTIL_Sobject.updateRecord(opp),true);
        system.debug(result);

        return result;
    }


    /**
    *@description return the values from product type field
    *@author Francesco Imperioli - Fimperioli@deloitte.it
    **/

    @AuraEnabled
    public static List<String> getProductTypeValues(){

        List<String> values = new List<String>();

        Schema.DescribeFieldResult fieldResult = NE__Product__c.XC_Product_Type__c.getDescribe();
        List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry ple : pleList){
            values.add(ple.getLabel());
        }

        return values;
    }
    /**
    *@description return the values from product subtype field
    *@author Francesco Imperioli - Fimperioli@deloitte.it
    **/
    @AuraEnabled
    public static Map<String,List<String>> getProductSubTypeValues(){
        System.Debug('PICKLIST MAP::: ' +  XC_UTIL_DependentPicklist.getDependentPicklist('NE__Product__c', 'XC_Product_Type__c', 'XC_Product_Subtype__c').pickListMap);
        return XC_UTIL_DependentPicklist.getDependentPicklist('NE__Product__c', 'XC_Product_Type__c', 'XC_Product_Subtype__c').pickListMap;
    }



    @AuraEnabled
    public static Boolean showResidentialAddress (String recordTypeId){
        List<RecordType> listOfRecordType = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE Id =: recordTypeId]);
        if(listOfRecordType.isEmpty()){
            return false;
        }
        if(listOfRecordType[0].DeveloperName.equals('XC_Opportunity_ITA')){
            return true;
        }else{
            return false;
        }
    }
	
    //Start CR758
    @AuraEnabled
    public static Boolean showSedeLegale(String recordId){
        Account acc = [SELECT id, XC_Segment__c, XC_Country__c FROM Account WHERE Id =:recordId];
        if(acc!=null && acc.XC_Segment__c != 'B2C' && acc.XC_Country__c!=null && 'Italy'.equalsIgnoreCase(acc.XC_Country__c)){
            return true;
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getAddressesForOppCat(String recordId, Boolean category) {
        List<Map<String,String>> accIdAccName = new List<Map<String,String>>();

        Map<id, XC_Address__c> add = new  Map<id, XC_Address__c>([Select id, Name, XC_Account__c from XC_Address__c where XC_Account__c =: recordId AND CreatedById != '0051i000002EpBCAA0' AND XC_Category__c = 'Registered Office' order by createdDate desc]);

        for(XC_Address__c a : add.values()){
            Map<String,String> acrMap = new Map<String,String>();
            acrMap.put('key' , a.id);
            acrMap.put('value' , a.Name);
            accIdAccName.add(acrMap);
        }

        return accIdAccName;   
    }
    //End CR758
    
}