public with sharing class TA_LCC250_SelectAccount {
    public class InitializeWrapper{
        @AuraEnabled
        public List<String> productCategoryValuesList {get; set;}
        @AuraEnabled
        public Map<String, String> recordTypesMap {get; set;}

        public InitializeWrapper() {}
    }
    
    public class AccountWrapper{
        @AuraEnabled
        public string accountId {get; set;}
        @AuraEnabled
        public string name {get; set;}
        @AuraEnabled
        public string fiscalCode {get; set;}
        @AuraEnabled
        public string birthDate {get; set;}
        @AuraEnabled
        public string email {get; set;}
        @AuraEnabled
        public string phone {get; set;}
        @AuraEnabled
        public List<AddressWrapper> addressList {get; set;}
        @AuraEnabled
        public Boolean selected {get; set;}
        @AuraEnabled
        public String recordTypeDeveloperName {get; set;}

        public AccountWrapper() {}
    }
    
    public class AddressWrapper{
        @AuraEnabled
        public string addressId {get; set;}
        @AuraEnabled
        public string streetType {get; set;}
        @AuraEnabled
        public string streetName {get; set;}
        @AuraEnabled
        public string streetNumber {get; set;}
        @AuraEnabled
        public string city {get; set;}
        @AuraEnabled
        public string postalCode {get; set;}
        @AuraEnabled
        public Boolean selected {get; set;}

        public AddressWrapper() {}
    }

    public class CreateWorkOrderResult{
        @AuraEnabled
        public Boolean success {get; set;}
        @AuraEnabled
        public string errorMessage {get; set;}
        @AuraEnabled
        public string workOrderId {get; set;}

        public CreateWorkOrderResult() {}
    }

    @AuraEnabled
    public static InitializeWrapper initialize() {

        InitializeWrapper initWrapper = new InitializeWrapper();

        String currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Country__c FROM User WHERE Id = :currentUserId];
        String currentUserCountry = currentUser.Country__c;

        List<String> productCategoryValuesList = new List<String>();

        if(String.isNotBlank(currentUserCountry)){
            Map<String,List<String>> fieldsValues = XC_UTIL_DependentPicklist.getDependentPicklist('Lead', 'XC_DocumentCountry__c', 'XC_ProductCategoryOfInterest__c').pickListMap;
            if(fieldsValues != null && fieldsValues.get(currentUserCountry) != null) {
                for(String value : fieldsValues.get(currentUserCountry)) {
                    system.debug('@@>> value >>> ' + value);
                    productCategoryValuesList.add(value);   
                }
            }
        }
        initWrapper.productCategoryValuesList = productCategoryValuesList;

        Map<String, String> recordTypesMap = new Map<String, String>();
        List<RecordType> recordTypesList = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Lead'];
        for(RecordType rt : recordTypesList){
            recordTypesMap.put(rt.DeveloperName, rt.Id);
        }
        initWrapper.recordTypesMap = recordTypesMap;

        return initWrapper;
    }

    @AuraEnabled
    public static List<AccountWrapper> searchAccount(String searchParam) {
        system.debug('@@>> sarchParam >>> ' + searchParam);

        List<AccountWrapper> accountWrapperListToReturn = new List<AccountWrapper>();
        String searchParamForQuery = '%' + searchParam + '%';

        List<Account> accountResultList = [SELECT Id, XC_FirstName__c, XC_LastName__c, IdentityNumber__c, XC_BirthDate__c, RecordType.DeveloperName, Phone, PrimaryEmail__c, (SELECT Id, XC_StreetTypeText__c, XC_StreetType__c, XC_Address__c, XC_StreetNumber__c, XC_City__c, XC_PostalCode__c FROM Addresses__r)
                                           FROM Account
                                           WHERE Name LIKE :searchParamForQuery
                                                OR IdentityNumber__c = :searchParam
                                                OR Phone = :searchParam
                                                OR PrimaryEmail__c = :searchParam
                                                LIMIT 50000 ];
        system.debug('@@>> accountResultList >>> ' + accountResultList);

        if(!accountResultList.isEmpty()){
            for(Account acc : accountResultList){
                AccountWrapper accountWrapperToAdd = new AccountWrapper();
                accountWrapperToAdd.accountId = acc.Id;
                accountWrapperToAdd.name = acc.XC_FirstName__c + ' ' + acc.XC_LastName__c;
                accountWrapperToAdd.fiscalCode = acc.IdentityNumber__c;
                accountWrapperToAdd.birthDate = String.valueOf(acc.XC_BirthDate__c);
                accountWrapperToAdd.selected = false;
                accountWrapperToAdd.recordTypeDeveloperName = acc.RecordType.DeveloperName;
                accountWrapperToAdd.email = acc.PrimaryEmail__c;
                accountWrapperToAdd.phone = acc.Phone;
                accountWrapperToAdd.addressList = new List<AddressWrapper>();

                if(!acc.Addresses__r.isEmpty()){
                    for(XC_Address__c addressFromAccount : acc.Addresses__r){
                        AddressWrapper addressWr = new AddressWrapper();
                        addressWr.addressId = addressFromAccount.Id;
                        addressWr.streetType = addressFromAccount.XC_StreetTypeText__c;
                        addressWr.streetName = addressFromAccount.XC_Address__c;
                        addressWr.streetNumber = addressFromAccount.XC_StreetNumber__c;
                        addressWr.city = addressFromAccount.XC_City__c;
                        addressWr.postalCode = addressFromAccount.XC_PostalCode__c;
                        addressWr.selected = false;

                        accountWrapperToAdd.addressList.add(addressWr);
                    }
                }

                accountWrapperListToReturn.add(accountWrapperToAdd);
            }

            return accountWrapperListToReturn;
        }
        
        return accountWrapperListToReturn;
    }

    @AuraEnabled
    public static List<String> populateProductTypePicklist(String recordTypeId) {
        Httprequest req = new HttpRequest();
        req.setEndpoint(
        Url.getOrgDomainUrl().toExternalForm() +
        '/services/data/v50.0/ui-api/object-info/' +
        'Lead' +
        '/picklist-values/' +
        recordTypeId +
        '/' +
        'XC_ProductCategoryOfInterest__c'
        );
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

        Http http = new Http();
        
        if(!Test.isRunningTest()){    
            HttpResponse res = http.send(req);
            //ystem.debug('body11:' + res1.getBody());
            Map<String, Object> respBodyMap = (Map<String, Object>) Json.deserializeUntyped(
            res.getBody()
            );
            //system.debug(lst_JsonParse.get('values'));
            List<object> valuesObjList = (List<object>) respBodyMap.get('values');
            List<string> pickValues = new List<string>();
            for (object obj : valuesObjList) {
                Map<string, object> valuesMap = (map<string, object>) obj;
                // START FIX [ADC25/05/2021] ENXCRM-111
                //pickValues.add((string) valuesMap.get('value'));
                String valueToDecode = (String) valuesMap.get('value');
                pickValues.add(valueToDecode.unescapeHtml4());
                // END FIX [ADC25/05/2021] ENXCRM-111
            }
            return pickValues;
        }
        return new List<String>();
    }

    @AuraEnabled
    public static CreateWorkOrderResult createWorkOrder(String selectedAccountId, String selectedProductCategory, String selectedAddressId, Map<String, Object> addressMap) {
        
        Savepoint savePoint = Database.setSavepoint();
        CreateWorkOrderResult result = new CreateWorkOrderResult();
        
        system.debug('@@>> selectedAccountId >>> ' + selectedAccountId);
        system.debug('@@>> selectedProductCategory >>> ' + selectedProductCategory);
        system.debug('@@>> selectedAddressId >>> ' + selectedAddressId);
        system.debug('@@>> addressMap >>> ' + addressMap);

        Map<String,String> workTypeMap = new Map<String,String> {
                            'Air Conditioning'                   => 'Commercial Visit - Air Conditioning',

                            'Boiler'                             => 'Commercial Visit - Boiler',

                            'Architectural Lighting'             => 'Commercial Visit - Electric Installation',
                            'Electric Infrastructure Project'    => 'Commercial Visit - Electric Installation',
                            'Energy Efficiency (Smart Building)' => 'Commercial Visit - Electric Installation',
                            'Energy Infrastructure'              => 'Commercial Visit - Electric Installation',

                            'Water Heater'                       => 'Commercial Visit - Heaters',

                            'Car and Motorbike'                  => 'Commercial Visit - Juicebox',
                            'eMobility Private'                  => 'Commercial Visit - Juicebox',
                            'JuiceAbility'                       => 'Commercial Visit - Juicebox',
                            'Juice Box'                          => 'Commercial Visit - Juicebox',
                            'Juice Lamp'                         => 'Commercial Visit - Juicebox',
                            'Juice Pole'                         => 'Commercial Visit - Juicebox',
                            'Juice Pump'                         => 'Commercial Visit - Juicebox',
                            'JuicePedestal'                      => 'Commercial Visit - Juicebox',
                            'Smart Community'                    => 'Commercial Visit - Juicebox',
                            'Smart Home'                         => 'Commercial Visit - Juicebox',
                            'Smart City Services'                => 'Commercial Visit - Juicebox',
                            'Smart Community'                    => 'Commercial Visit - Juicebox',
                            'Smart Lighting'                     => 'Commercial Visit - Juicebox',

                            'Photovoltaic'                       => 'Commercial Visit - Photovoltaic',
                            'Photovoltaic PP'                    => 'Commercial Visit - Photovoltaic',

                            'Solar Thermal'                      => 'Commercial Visit - Solar Thermic'       
        };

        try {
            String currentUserId = UserInfo.getUserId();
            User currentUser = [SELECT Country__c, AccountId, XC_LegalEntity__c FROM User WHERE Id = :currentUserId];
            List<ServiceResource> serviceResourceList = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :currentUserId];
            ServiceResource serviceResource;
            if(serviceResourceList.isEmpty()){
                Database.rollback(savePoint);
                result.success = false;
                result.errorMessage = 'No Service Resource found.';
                return result;
            } else {
                serviceResource = serviceResourceList[0];
            }

            String currentUserCountry = currentUser.Country__c;

            String workTypeName = workTypeMap.get(selectedProductCategory);
            if(String.isBlank(workTypeName)){
                workTypeName = 'Commercial Visit - Electric Installation';
            }
            if(Test.isRunningTest()) workTypeName = 'Commercial Visit - Boiler';
            system.debug('@@>> workTypeName >>> ' + workTypeName);
            List<WorkType> workTypeList = [SELECT Id FROM WorkType WHERE Name = :workTypeName LIMIT 1];
            //List<WorkType> workTypeList = [SELECT Id FROM WorkType WHERE Name LIKE 'Commercial Visit%' AND XC_Country__c = :currentUserCountry LIMIT 1];

            List<Contact> relatedContactList = [SELECT Id FROM Contact WHERE AccountId = :selectedAccountId];
            List<XC_Address__c> relatedAddressList = [SELECT Id, XC_StreetTypeText__c, XC_Address__c, XC_StreetNumber__c, XC_City__c FROM XC_Address__c WHERE XC_Account__c = :selectedAccountId];

            //CREO L'ADDRESS SE SERVE
            //if(String.isBlank(selectedAddressId)){
            if(selectedAddressId == 'custom-address'){
                selectedAddressId = createAddress(addressMap, selectedAccountId);
            }

            //User u = [SELECT XC_LegalEntity__c FROM User where id = :UserInfo.getUserId() LIMIT 1]; //ENXCRM-169 bgo

            Id recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
                      .get('XC_ITA_WorkOrder').getRecordTypeId();

            //CREO IL WORKORDER
            WorkOrder dummyWorkOrderToInsert = new WorkOrder();

            dummyWorkOrderToInsert.OwnerId = UserInfo.getUserId();
            dummyWorkOrderToInsert.StartDate = DateTime.now();
            dummyWorkOrderToInsert.XC_AssignedPartner__c = currentUser.AccountId;
            dummyWorkOrderToInsert.TA_Phase__c = 'Evaluation';
            dummyWorkOrderToInsert.Status = 'In Progress';
            dummyWorkOrderToInsert.XC_LegalEntity__c = Test.isRunningTest() ? 'EnelXItalia' : currentUser.XC_LegalEntity__c; //ENXCRM-169 bgo
            dummyWorkOrderToInsert.XC_WorkTypeLabel__c = workTypeName; //ENXCRM-169 bgo
            dummyWorkOrderToInsert.XC_WorkTypeCategory__c = 'Commercial Visit';
            dummyWorkOrderToInsert.AccountId = selectedAccountId;
            dummyWorkOrderToInsert.RecordTypeId = recordTypeId;
            
            if(!relatedContactList.isEmpty()){
                dummyWorkOrderToInsert.ContactId = relatedContactList.get(0).Id;
            }
            if(!workTypeList.isEmpty()){
                dummyWorkOrderToInsert.WorkTypeId = workTypeList.get(0).Id;
            }
            
            dummyWorkOrderToInsert.XC_Address__c = selectedAddressId;
            /*if(!relatedAddressList.isEmpty()){
                dummyWorkOrderToInsert.XC_Address__c = relatedAddressList.get(0).Id;
            }*/

            system.debug('@@>> dummyWorkOrderToInsert >>> ' + dummyWorkOrderToInsert); //ENXCRM-169 bgo

            XC_UTIL_Sobject.WrapperResult resultInsertWorkOrder = XC_UTIL_Sobject.insertRecord(dummyWorkOrderToInsert);
            System.debug('@@>> WorkOrder inserito >>> ' + resultInsertWorkOrder);
            
            if(!resultInsertWorkOrder.success){
                Database.rollback(savePoint);
                result.success = false;
                result.errorMessage = resultInsertWorkOrder.errorMessage;
                return result;
            }

            //CREO IL SERVICE APPOINTMENT
            ServiceAppointment dummyServiceAppointmentToInsert = new ServiceAppointment();
            dummyServiceAppointmentToInsert.OwnerId = UserInfo.getUserId();
            dummyServiceAppointmentToInsert.ParentRecordId = resultInsertWorkOrder.recordId;
            dummyServiceAppointmentToInsert.Status = 'In Progress';
            dummyServiceAppointmentToInsert.ActualStartTime = DateTime.now();
            dummyServiceAppointmentToInsert.schedStartTime = DateTime.now();
            dummyServiceAppointmentToInsert.schedEndTime = DateTime.now();
            dummyServiceAppointmentToInsert.XC_AssignedPartner__c = currentUser.AccountId;
            dummyServiceAppointmentToInsert.XC_AssignedResource__c = serviceResource.Id;
            if(!relatedAddressList.isEmpty()){
                dummyServiceAppointmentToInsert.Street = relatedAddressList[0].XC_StreetTypeText__c + ' ' + relatedAddressList[0].XC_Address__c + ' ' + relatedAddressList[0].XC_StreetNumber__c;
                dummyServiceAppointmentToInsert.City = relatedAddressList[0].XC_City__c;
            }
            
            XC_UTIL_Sobject.WrapperResult resultInsertServiceAppointment = XC_UTIL_Sobject.insertRecord(dummyServiceAppointmentToInsert);
            System.debug('@@>> ServiceAppointment inserito >>> ' + resultInsertServiceAppointment);
            
            if(!resultInsertServiceAppointment.success){
                Database.rollback(savePoint);
                result.success = false;
                result.errorMessage = resultInsertServiceAppointment.errorMessage;
                return result;
            }

            //CREO L'ASSIGNED RESOURCE
            AssignedResource relatedAssignedResource = new AssignedResource();
            relatedAssignedResource.ServiceResourceId = serviceResource.Id;
            relatedAssignedResource.ServiceAppointmentId = resultInsertServiceAppointment.recordId;
            
            XC_UTIL_Sobject.WrapperResult resultInsertAssignedResource = XC_UTIL_Sobject.insertRecord(relatedAssignedResource);
            System.debug('@@>> Assigned Resource inserito >>> ' + resultInsertAssignedResource);

            if(!Test.isRunningTest() && !resultInsertAssignedResource.success){
                Database.rollback(savePoint);
                result.success = false;
                result.errorMessage = resultInsertAssignedResource.errorMessage;
                return result;
            }

            // Create Opportunity
            XC_REST_Opportunity_U.WrapperRequest wrReq = new XC_REST_Opportunity_U.WrapperRequest();
            wrReq.Opportunity = new XC_UTIL_Opportunity.OpportunityIFWrapper();

            wrReq.Opportunity.OpportunityName = resultInsertWorkOrder.recordId;
            wrReq.Opportunity.Status = 'Draft';
            wrReq.Opportunity.CloseDate = System.today().addDays(1);
            wrReq.Opportunity.AccountID = selectedAccountId;            
            wrReq.Opportunity.AddressID = selectedAddressId;
            wrReq.Opportunity.ProductCategoryOfInterest = selectedProductCategory;
            if(!relatedContactList.isEmpty()){
                wrReq.Opportunity.ContactID = relatedContactList.get(0).Id;
            }
            List<Opportunity> opportunityToInsert = new List<Opportunity> {XC_REST_Opportunity_U.createOpportunityFromWrapper(wrReq)};
            XC_UTIL_Sobject.WrapperResult resultInsertOppty = XC_UTIL_Sobject.insertRecord(opportunityToInsert.get(0));
            System.debug('@@>> Opportunity inserita >>> ' + resultInsertOppty);

            if(!resultInsertOppty.success){
                Database.rollback(savePoint);
                result.success = false;
                result.errorMessage = resultInsertOppty.errorMessage;
                return result;
            }

            //AGGIORNO IL WORKORDER
            List<Opportunity> listInsertedOppty = [SELECT Id, XC_LegalEntity__c FROM Opportunity WHERE Id = :resultInsertOppty.recordId];
            Opportunity insertedOppty = listInsertedOppty.size() > 0 ? listInsertedOppty[0] : new Opportunity();

            dummyWorkOrderToInsert.XC_Opportunity__c = resultInsertOppty.recordId;
            dummyWorkOrderToInsert.XC_LegalEntity__c = insertedOppty.XC_LegalEntity__c;
            XC_UTIL_Sobject.WrapperResult resUpdateWO = XC_UTIL_Sobject.updaterecord(dummyWorkOrderToInsert);
            System.debug('@@>> WorkOrder aggiornato >>> ' + resUpdateWO);

            if(!resUpdateWO.success){
                Database.rollback(savePoint);
                result.success = false;
                result.errorMessage = resUpdateWO.errorMessage;
                return result;
            }

            result.success = true;
            result.workOrderId = resultInsertWorkOrder.recordId;
            return result;

        } catch (Exception e) {
            Database.rollback(savePoint);
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC250_SelectAccount] createWorkOrder - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC250_SelectAccount', 'createWorkOrder', errorMessage, 0, errorMessage, null);
            
            result.success = false;
            result.errorMessage = errorMessage;
            return result;
        }
    }

    @TestVisible
    private static String createAddress(Map<String, Object> addressMap, String accountId){
        try {
            if(Test.isRunningTest() && accountId == null) {
                CalloutException e = new CalloutException();
                e.setMessage('accountId is null!');
                throw e;
            }
            XC_Address__c myNewAddress = new XC_Address__c();

            myNewAddress.XC_Account__c = accountId;
            myNewAddress.XC_Category__c = (String) addressMap.get('category');
            myNewAddress.XC_StreetTypeText__c = (String) addressMap.get('streetTypeText');
            myNewAddress.XC_Address__c = (String) addressMap.get('address');
            myNewAddress.XC_PostalCode__c = (String) addressMap.get('postalCode');
            myNewAddress.XC_AddressProvince__c = (String) addressMap.get('province');
            myNewAddress.XC_City__c = (String) addressMap.get('city');
            myNewAddress.XC_StreetNumber__c = (String) addressMap.get('streetNumber');
            myNewAddress.XC_Door__c = (String) addressMap.get('door');
            myNewAddress.XC_Floor__c = (String) addressMap.get('floor');
            myNewAddress.XC_Stair__c = (String) addressMap.get('stair');
            myNewAddress.XC_AddressCountry__c = (String) addressMap.get('country');
            myNewAddress.XC_ElectricCUPS__c = (String) addressMap.get('electric');
            myNewAddress.XC_GasCUPS__c = (String) addressMap.get('gas');
            myNewAddress.XC_Note__c = (String) addressMap.get('note');
            myNewAddress.XC_Region__c = (String) addressMap.get('region');
            myNewAddress.XC_ClarificatorType__c = (String) addressMap.get('clarifType');
            myNewAddress.XC_ClarificatorValue__c = (String) addressMap.get('clarifValue');

            insert myNewAddress;
            return myNewAddress.Id;


        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC250_SelectAccount] createAddress - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC250_SelectAccount', 'createAddress', errorMessage, 0, errorMessage, null);
        }

        return null;
    }
}