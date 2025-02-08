@isTest
public with sharing class TA_LCC220_LeadConversion_Test {
    @testSetup static void setup() {
        TA_UTIL_Test.loadSetup();
    }
    @isTest
    static void initialize_Test() {

        TA_LCC220_LeadConversion instance = new TA_LCC220_LeadConversion();

        List<TA_LCC220_LeadConversion.FieldStructure> listFdStruct = new List<TA_LCC220_LeadConversion.FieldStructure>();

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit')[0];
        insert workOrderTest;

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        workOrderTest.AccountId = accountToInsert.Id;
        update workOrderTest;

        Map<String,String> values = new Map<String,String>();
        values.put('Lead', 'test');

        
        List<Map<String,String>> mapStList = new List<Map<String,String>>{values};

        String jsonTest = '[{"object":"Account","fields":[{"apiName":"XC_FirstName__c","isDisplayed":"true"},{"apiName":"XC_LastName__c","isDisplayed":"true"},{"apiName":"Phone","isDisplayed":"true"},{"apiName":"MainPhone__c","isDisplayed":"true"},{"apiName":"PrimaryEmail__c","isDisplayed":"true"},{"apiName":"XC_DocumentCountry__c","isDisplayed":"true"},{"apiName":"IdentityType__c","isDisplayed":"true"},{"apiName":"IdentityNumber__c","isDisplayed":"true"},{"apiName":"XC_BirthDate__c","isDisplayed":"true"}],"addressFields":[{"apiName":"BillingCountry","isDisplayed":"true"},{"apiName":"BillingCity","isDisplayed":"true"},{"apiName":"BillingStreet","isDisplayed":"true"},{"apiName":"BillingPostalCode","isDisplayed":"true"}]},{"object":"Lead","fields":[{"apiName":"FirstName","isDisplayed":"true"},{"apiName":"LastName","isDisplayed":"true"},{"apiName":"Phone","isDisplayed":"true"},{"apiName":"MobilePhone","isDisplayed":"true"},{"apiName":"Email","isDisplayed":"true"},{"apiName":"XC_DocumentCountry__c","isDisplayed":"true"},{"apiName":"XC_DocumentType__c","isDisplayed":"true"},{"apiName":"XC_DocumentNumber__c","isDisplayed":"true"},{"apiName":"XC_Birthdate__c","isDisplayed":"true"},{"apiName":"XC_NIE_expedition_date__c","isDisplayed":"true"},{"apiName":"XC_NIE_expiration_date__c","isDisplayed":"true"}],"addressFields":[{"apiName":"Country","isDisplayed":"true"},{"apiName":"City","isDisplayed":"true"},{"apiName":"XC_StreetType__c","isDisplayed":"true"},{"apiName":"Street","isDisplayed":"true"},{"apiName":"XC_StreetNumber__c","isDisplayed":"true"},{"apiName":"PostalCode","isDisplayed":"true"},{"apiName":"XC_Province__c","isDisplayed":"false"}]}]';

        test.startTest();
        TA_LCC220_LeadConversion.initialize(jsonTest, workOrderTest.Id);
        test.stopTest();
    }

    /*
    @isTest
    static void manageConfirm_Test() {

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1,'Repair')[0];

        insert workOrderTest;

        Map<String,String> values = new Map<String,String>();
        values.put('Lead', 'test');

        List<Map<String,String>> mapStList = new List<Map<String,String>>{values};

        TA_LCC220_LeadConversion.FieldStructure fdstruct = new TA_LCC220_LeadConversion.FieldStructure();
        fdstruct.label = 'TA_Phase__c';
        fdstruct.apiName = 'TA_Phase__c';
        fdstruct.value = 'test';
        fdstruct.availableValues = mapStList;
        fdstruct.type = 'String';
        fdstruct.required = false;
        fdstruct.type = 'readOnly';
        fdstruct.readOnly = false;

        List<TA_LCC220_LeadConversion.FieldStructure> listFdStruct = new List<TA_LCC220_LeadConversion.FieldStructure>{fdstruct};

        TA_LCC220_LeadConversion.ModalParams modalParamss = new TA_LCC220_LeadConversion.ModalParams();
        modalParamss.title = 'test';
        modalParamss.description = 'Attenzione prova';
        modalParamss.imgPath = '/src/test';

        TA_LCC220_LeadConversion.InfoBag infoBagWrp = new TA_LCC220_LeadConversion.InfoBag();
        infoBagWrp.objectName = 'WorkOrder';
        infoBagWrp.fieldStructureList = listFdStruct;
        infoBagWrp.modalParams = modalParamss;
        infoBagWrp.error = '';
        infoBagWrp.lookupId = 'XC_WorkTypeCategory__c';
        infoBagWrp.lookupObjectName = 'Lead';

        //String jsonTest = '{[{"name":"showLCP208Modal","parameters":{"title":"","description":"Are you arrived at customers location?","type":"","imgPath":"/imgs/im-here.svg","phaseName":"CheckIn_ModalImHere","actionsName":["Cancel","YesImHere"],"workTypeCategory":"Delivery & Installation","country":"Italy_Set"}}],"apex":[]}';

        String jsonTest = '[{"object":"Account","fields":["XC_FirstName__c","XC_LastName__c","BillingStreet","BillingCity","BillingCountry","BillingPostalCode","Phone","MainPhone__c","PrimaryEmail__c","XC_DocumentCountry__c","IdentityType__c","IdentityNumber__c","XC_BirthDate__c"]},{"object":"Lead","fields":["FirstName","LastName","XC_StreetType__c","Street","XC_StreetNumber__c","City","Country","PostalCode","Phone","MobilePhone","Email","XC_DocumentCountry__c","XC_DocumentType__c","XC_DocumentNumber__c","XC_Birthdate__c","XC_NIE_expedition_date__c","XC_NIE_expiration_date__c"]}]';

        test.startTest();
        TA_LCC220_LeadConversion.manageConfirm(jsonTest, true);
        test.stopTest();
    }
    */
}