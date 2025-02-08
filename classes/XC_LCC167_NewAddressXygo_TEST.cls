/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  08/05/2019
* @description XC_LCC167_NewAddressXygo_TEST – Test class for XC_LCC167_NewAddressXygo
*/
@isTest
public class XC_LCC167_NewAddressXygo_TEST {

    //Test Method saveAddressApex
    static testMethod void saveAddressApex(){
        insert XC_DF_OneOrg.createOneOrg('Chile');
        
        Test.startTest();

        Map<String, Object> mapAddressFields = new Map<String, Object>{
                'country' => 'Chile',
                'address' => 'test',
                'streetNumber' => '2',
                'postalCode' => '2',
                'city' => 'test',
                'region' => 'Santiago',
                'municipality' => 'test',
                'installationAddress' => true,
                'deliveryAddress' => true,
                'billingAddress' => true,
                'validate' => false,
                'isAccountPartner' => false
        };

        String mapAccountString = JSON.serialize(mapAddressFields);
        XC_LCC011_U_NewAddress.WrapperInput wrp = new  XC_LCC011_U_NewAddress.WrapperInput();
        List<Account> accList = XC_DF_Account.createSohoAccounts(1);
        insert accList;
        mapAddressFields.put('account',accList[0]);
        String inputAddress= JSON.serialize(wrp);
        XC_UTIL_ResultWrapper wr = XC_LCC167_NewAddressXygo.saveAddressApex(inputAddress);
        System.assertEquals(true, wr.success);
        Test.stopTest();
    }

    //Test Method retrieveAccountRecordTypeName
    static testMethod void retrieveAccountRecordTypeName(){
        insert XC_DF_OneOrg.createOneOrg('Chile');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        XC_UTIL_ResultWrapper result = XC_LCC167_NewAddressXygo.retrieveAccountRecordTypeName(accList[0].Id);
        System.assertEquals(result.success, true);
        Test.stopTest();
    }
    //Test Method checkAddress

    //Test Method callToAddressValidation
    static testMethod void callToAddressValidation(){
        insert XC_DF_OneOrg.createOneOrg('Chile');

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressValidation';
        ic.XC_URL_Required__c  = 'vvvvvv';
        ic.XC_interfaceName__c = 'AddressValidation';
        ic.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic;
        
        XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c();
        ic2.XC_activeInterface__c = true;
        ic2.Name = 'AddressValidationDC';
        ic2.XC_URL_Required__c  = 'vvvvv';
        ic2.XC_interfaceName__c = 'AddressValidationDC';
        ic2.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic2;
        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());

        Test.startTest();
        Map<String, Object> mapAddressFields = new Map<String, Object>{
                'country' => 'Chile',
                'address' => 'test',
                'streetNumber' => '2',
                'postalCode' => '2',
                'city' => 'test',
                'region' => 'Santiago',
                'municipality' => 'test',
                'installationAddress' => true,
                'deliveryAddress' => true,
                'billingAddress' => true,
                'validate' => false,
                'isAccountPartner' => false
        };

        String mapAccountString = JSON.serialize(mapAddressFields);
        Map<String,Object> result= XC_LCC167_NewAddressXygo.callForValidateXygo(mapAccountString);
        //System.assertEquals(true, result.success);
        Test.stopTest();
    }
    

    //Test Method getAddressByCup
    static testMethod void getAddressByCup(){
        insert XC_DF_OneOrg.createOneOrg('Chile');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = Label.XC_CL_AddressByPOD;
        ic.XC_URL_Required__c  = 'xxxx';
        ic.XC_interfaceName__c = Label.XC_CL_AddressByPOD;
        insert ic;
        
        XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c();
        ic2.XC_activeInterface__c = true;
        ic2.Name = 'AddressValidation';
        ic2.XC_URL_Required__c  = 'xxx';
        ic2.XC_interfaceName__c = 'AddressValidation';
        ic2.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic2;
        Test.startTest();
        String podValue='ES0021000003149909NX';
        String result = XC_LCC167_NewAddressXygo.getAddressByCup(podValue);
        System.assert(String.isNotBlank(result));
        ic.XC_activeInterface__c = false;
        update ic;

        Test.stopTest();
    }



    static testMethod void autoComplStreet(){ 
        insert XC_DF_OneOrg.createOneOrg('Chile');

        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());
		XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressValidationDC';
        ic.XC_URL_Required__c  = 'xxxxx';
        ic.XC_interfaceName__c = 'AddressValidationDC';
        insert ic;
        
        XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c();
        ic2.XC_activeInterface__c = true;
        ic2.Name = 'AddressValidation';
        ic2.XC_URL_Required__c  = '';
        ic2.XC_interfaceName__c = 'AddressValidation';
        ic2.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic2;
        Test.startTest();

        Map<String,Object> fieldMap = new Map<String,Object>();
        fieldMap.put('address', 'test');

        try {
            List<String> res = XC_LCC167_NewAddressXygo.autoCompleteStreet(json.serialize(fieldMap));
            fieldMap.put('city', 'test');
            fieldMap.put('province', 'test');
            res = XC_LCC167_NewAddressXygo.autoCompleteStreet(json.serialize(fieldMap));
            system.assert(res != null);

        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err');

        }

        Test.stopTest();
    }

    static testMethod void autoComplStreet1(){
        insert XC_DF_OneOrg.createOneOrg('Chile');
XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressValidationDC';
        ic.XC_URL_Required__c  = 'xxxx';
        ic.XC_interfaceName__c = 'AddressValidationDC';
        ic.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic;
        XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c();
        ic2.XC_activeInterface__c = true;
        ic2.Name = 'AddressValidation';
        ic2.XC_URL_Required__c  = '';
        ic2.XC_interfaceName__c = 'AddressValidation';
        ic2.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic2;
        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());

        Test.startTest();

        Map<String,Object> fieldMap = new Map<String,Object>();
        fieldMap.put('address', 'test');
        fieldMap.put('provinceCode', 'test');
        fieldMap.put('cityCode', 'test');

        try {
            List<String> res = XC_LCC167_NewAddressXygo.autoCompleteStreet(json.serialize(fieldMap));
            system.assert(res != null);

        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err');

        }

        Test.stopTest();
    }

    static testMethod void autoComplCity(){
        insert XC_DF_OneOrg.createOneOrg('Chile');
XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressValidation';
        ic.XC_URL_Required__c  = '';
        ic.XC_interfaceName__c = 'AddressValidation';
        ic.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic;
        XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c();
        ic2.XC_activeInterface__c = true;
        ic2.Name = 'AddressValidationDC';
        ic2.XC_URL_Required__c  = 'xxxxx';
        ic2.XC_interfaceName__c = 'AddressValidationDC';
        ic2.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic2;
        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());

		XC_CS001_InterfaceConfiguration__c ic3 = new XC_CS001_InterfaceConfiguration__c();
        ic3.XC_activeInterface__c = true;
        ic3.Name = 'AddressAutocompleteCHL';
        ic3.XC_URL_Required__c  = '';
        ic3.XC_interfaceName__c = 'AddressAutocompleteCHL';
        insert ic3;
        
        
        Test.startTest();

        Map<String,Object> fieldMap = new Map<String,Object>();
        fieldMap.put('city', 'test');

        try {
            List<String> res = XC_LCC167_NewAddressXygo.autoCompleteCity(json.serialize(fieldMap));
            system.assert(res != null);

        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err');

        }

        Test.stopTest();
    }

    static testMethod void autoComplZip(){
        insert XC_DF_OneOrg.createOneOrg('Chile');

        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());
		XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressAutocompleteCHL';
        ic.XC_URL_Required__c  = 'xxxxx';
        ic.XC_interfaceName__c = 'AddressAutocompleteCHL';
        insert ic;
        XC_CS001_InterfaceConfiguration__c ic3 = new XC_CS001_InterfaceConfiguration__c();
        ic3.XC_activeInterface__c = true;
        ic3.Name = 'AddressValidationDC';
        ic3.XC_URL_Required__c  = 'xxxxx';
        ic3.XC_interfaceName__c = 'AddressValidationDC';
        ic3.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic3;
        XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c();
        ic2.XC_activeInterface__c = true;
        ic2.Name = 'AddressValidation';
        ic2.XC_URL_Required__c  = '';
        ic2.XC_interfaceName__c = 'AddressValidation';
        ic2.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic2;
        Test.startTest();

        Map<String,Object> fieldMap = new Map<String,Object>();
        fieldMap.put('address', 'test');

        try {
            List<String> res = XC_LCC167_NewAddressXygo.autoCompleteZipCode(json.serialize(fieldMap));
            system.assert(res != null);

        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err');

        }

        Test.stopTest();
    }




    static testMethod void callToPODByAddress(){
        insert XC_DF_OneOrg.createOneOrg('Chile');
XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c();
        ic2.XC_activeInterface__c = true;
        ic2.Name = 'AddressValidationDC';
        ic2.XC_URL_Required__c  = 'xxxxxx';
        ic2.XC_interfaceName__c = 'AddressValidationDC';
        ic2.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic2;
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressValidation';
        ic.XC_URL_Required__c  = '';
        ic.XC_interfaceName__c = 'AddressValidation';
        ic.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic;
        Map<String, String> fieldMap = new Map<String, String>{
                'city' => 'test',
                'province' => 'test',
                'address' => 'test',
                'postalCode' => '28080',
                'streetNumber' =>  '12'};

        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());

        Test.startTest();

        List<String> res;
        try {
            res = XC_LCC167_NewAddressXygo.callToPODByAddress(json.serialize(fieldMap));
            system.assert(res != null);
            XC_UTIL_Debug.debug(true, 'err: '+res+' in: '+json.serialize(fieldMap));

        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err: '+res);

        }

        Test.stopTest();
    }

    static testMethod void getZipCodeDirectly(){
        insert XC_DF_OneOrg.createOneOrg('Chile');

        Map<String, String> fieldMap = new Map<String, String>{
                'city' => 'test',
                'province' => 'test',
                'address' => 'test',
                'postalCode' => '28080',
                'streetNumber' =>  '12'};

        Test.setMock(HttpCalloutMock.class, new XC_LCC167_NewAddressXygo_MOCK());
XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c();
        ic2.XC_activeInterface__c = true;
        ic2.Name = 'AddressValidationDC';
        ic2.XC_URL_Required__c  = 'xxxxxx';
        ic2.XC_interfaceName__c = 'AddressValidationDC';
        ic2.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic2;
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressValidation';
        ic.XC_URL_Required__c  = '';
        ic.XC_interfaceName__c = 'AddressValidation';
        ic.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic;
        Test.startTest();

        List<String> res;
        try {
            res = XC_LCC167_NewAddressXygo.getZipCodeDirectly(json.serialize(fieldMap));
            system.assert(res != null);
            XC_UTIL_Debug.debug(true, 'err: '+res+' in: '+json.serialize(fieldMap));

        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err: '+res);

        }

        Test.stopTest();
    }
    
    static testMethod void getAddressApex(){
        //insert XC_DF_OneOrg.createOneOrg('Chile');
       
        
        List<Lead> l = XC_DF_Lead.createResidentialLeads(1);
        l[0].Email = 'test@test.it';
        insert l; 
        List<XC_Address__c> a = XC_DF_Address.createAddress(1);
        // insert a;
        //List<XC_Address__c> ad = [SELECT ID,XC_Lead__r.id  FROM XC_Address__c where id=:a[0].id];
        a[0].XC_Lead__c = l[0].id;
        insert a;
        //update ad;
        Test.startTest();
        String res =  XC_LCC167_NewAddressXygo.getAddressApex(l[0].id);
        system.assert(res != null);
        XC_CS001_InterfaceConfiguration__c cs = new XC_CS001_InterfaceConfiguration__c();
        cs.Name = 'AddressValidationDC';
        cs.XC_interfaceName__c='AddressValidationDC';       
        cs.XC_activeInterface__c = true;
        cs.XC_URL_Required__c= 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';        
        insert cs;
        String res1 = XC_LCC167_NewAddressXygo.updateLead(l[0].id,a[0].id);
        system.assert(res1 != null);
        Test.stopTest();            
        
        }
    
    
        static testMethod void getCountryByUser(){
            User admin = XC_DF_User.createUserAdmin() ;
            insert admin;
            Test.startTest();
                System.runas(admin){
                    String country = XC_LCC167_NewAddressXygo.getCountryByUser();
                    System.assert(country == 'SPAIN');
                    admin.Country__c = 'Chile';
                    update admin;
                    country = XC_LCC167_NewAddressXygo.getCountryByUser();
                    System.assert(country != 'SPAIN');
                }
            Test.stopTest();
        }

        static testMethod void getCountryByLead(){
            List<Lead> lead = XC_DF_Lead.createResidentialLeads(1);
            insert lead;
            Test.startTest();
                XC_LCC167_NewAddressXygo.getCountryByLead(lead.get(0).id);
                XC_LCC167_NewAddressXygo.getCountryByLead('23456789');
            Test.stopTest();
        }
		
    static testMethod void updateAddressByLead(){
        Test.startTest();
        	XC_LCC167_NewAddressXygo.updateAddressByLead('{}');
        Test.stopTest();
    }
}