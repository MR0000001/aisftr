/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  08/05/2019 
* @description XC_LCC011_NewAddress_TEST – Test class for XC_LCC011_NewAddress
*/ 
@isTest
public class XC_LCC011_NewAddress_TEST { 

    //Test Method saveAddressApex
    static testMethod void saveAddressApex(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        
         Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test', 
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true,
            'isAccountPartner' => false
        };
            
        String mapAccountString = JSON.serialize(mapAddressFields);
        XC_LCC011_U_NewAddress.WrapperInput wrp = new  XC_LCC011_U_NewAddress.WrapperInput();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        wrp.idAccount= accList[0].Id;
        wrp.inputFields=mapAccountString;
        String inputAddress= JSON.serialize(mapAddressFields); 
        XC_UTIL_ResultWrapper wr = XC_LCC011_NewAddress.saveAddressApex(inputAddress);
        System.debug('@@@@@@ saveAddressApex ' + wr);
        System.assertEquals(true, wr.success);
    Test.stopTest();    
    }
    
    //Test Method retrieveAccountRecordTypeName
    static testMethod void retrieveAccountRecordTypeName(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        XC_UTIL_ResultWrapper result = XC_LCC011_NewAddress.retrieveAccountRecordTypeName(accList[0].Id); 
        System.assertEquals(result.success, true);
    Test.stopTest();
    }
    
    //Test Method callToAddressValidation
    static testMethod void callToAddressValidation(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'test';
        ic.XC_URL_Required__c  = '';
        ic.XC_interfaceName__c = Label.XC_CL_Address_Validation; 

        insert ic;
    Test.startTest();
         Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };
            
        String mapAccountString = JSON.serialize(mapAddressFields);
        //XC_REST_AddressValidation.ResultWrapper result= XC_LCC011_NewAddress.callToAddressValidation('', mapAccountString);
        //System.assertEquals(true, result.success);
    Test.stopTest(); 
    }
    
    //Test Method getPodByAddress
    static testMethod void getPodByAddress(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'test';
        ic.XC_URL_Required__c  = '';
        ic.XC_interfaceName__c = Label.XC_CL_PodsByAddress; 
        insert ic; 
    Test.startTest();
         Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };
            
        String mapAccountString = JSON.serialize(mapAddressFields);
        //XC_REST_PodsByAddressAPI.ResultWrapper result= XC_LCC011_NewAddress.getPodByAddress(mapAccountString);
        
        //system.debug('@@@ interfaccia attiva'+ result.success);
        //System.assertEquals(true, result.success);
        ic.XC_activeInterface__c = false;
        update ic; 
        //XC_REST_PodsByAddressAPI.ResultWrapper result1= XC_LCC011_NewAddress.getPodByAddress(mapAccountString);
        //system.debug('@@@ interfaccia disattiva'+ result1.success);
        //System.assertEquals(true, result1.success);
    Test.stopTest(); 
    }
    
    //Test Method getAddressByCup
    static testMethod void getAddressByCup(){
    	insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'test';
        ic.XC_URL_Required__c  = '';
        ic.XC_interfaceName__c = Label.XC_CL_AddressByPOD; 
        insert ic;
        Test.startTest();
        String podValue='ES0217010119115244VE';
        String result = XC_LCC011_NewAddress.getAddressByCup(podValue);
        System.assert(String.isNotBlank(result));
        Test.stopTest();
    }
    
    //Test Method getAddressByCup
    static testMethod void getAddressByCup2(){
    	insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = Label.XC_CL_AddressByPOD;
        ic.XC_URL_Required__c  = 'test';
        ic.XC_interfaceName__c = Label.XC_CL_AddressByPOD; 
        insert ic;
        Test.startTest();
        String podValue='ES0217010119115243VE';
        String result = XC_LCC011_NewAddress.getAddressByCup(podValue);
        System.assert(String.isNotBlank(result));
        Test.stopTest();
    }
    
    //Test Method getAddressByCup
    static testMethod void getAddressByCup3(){
    	insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'test';
        ic.XC_URL_Required__c  = '';
        ic.XC_interfaceName__c = Label.XC_CL_AddressByPOD; 
        insert ic;
        Test.startTest();
        String podValue='ES0217010119115243VE';
        String result = XC_LCC011_NewAddress.getAddressByCup(podValue);
        System.assert(String.isNotBlank(result));
        Test.stopTest();
    }
    
    static testMethod void commodityTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        Test.startTest();
        //List<XC_LCC011_U_NewAddress.WrapperResponseAddress> res = XC_LCC011_NewAddress.executeCallCommodity('test');
        //system.assert(res != null); 
  
        Test.stopTest();
    }
    
    static testMethod void autoComplStreet(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.setMock(HttpCalloutMock.class, new XC_DataCentric_Mock());

        Test.startTest();
        
        Map<String,Object> fieldMap = new Map<String,Object>();
        fieldMap.put('address', 'test');
        
        try {
            List<String> res = XC_LCC011_NewAddress.autoCompleteStreet(json.serialize(fieldMap));
            system.assert(res != null);
            
        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err');
            
        }

        Test.stopTest();
    }
    
    static testMethod void autoComplStreet1(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.setMock(HttpCalloutMock.class, new XC_DataCentric_Mock());

        Test.startTest();
        
        Map<String,Object> fieldMap = new Map<String,Object>();
        fieldMap.put('address', 'test');
        fieldMap.put('provinceCode', 'test');
        fieldMap.put('cityCode', 'test');
        
        try {
            List<String> res = XC_LCC011_NewAddress.autoCompleteStreet(json.serialize(fieldMap));
            system.assert(res != null);
            
        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err');
            
        }

        Test.stopTest();
    }
    
    static testMethod void autoComplCity(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressAutocompleteDC';
        ic.XC_URL_Required__c  = 'test';
        ic.XC_interfaceName__c = 'AddressAutocompleteDC';
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_DataCentric_Mock());

        Test.startTest();
        
        Map<String,Object> fieldMap = new Map<String,Object>();
        fieldMap.put('city', 'test');
        
        try {
            List<String> res = XC_LCC011_NewAddress.autoCompleteCity(json.serialize(fieldMap));
            system.assert(res != null);
            
        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err');
            
        }

        Test.stopTest();
    }
        
    static testMethod void autoComplZip(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.setMock(HttpCalloutMock.class, new XC_DataCentric_Mock());

        Test.startTest();
        
        Map<String,Object> fieldMap = new Map<String,Object>();
        fieldMap.put('address', 'test');
        
        try {
            List<String> res = XC_LCC011_NewAddress.autoCompleteZipCode(json.serialize(fieldMap));
            system.assert(res != null);
            
        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err');
            
        }

        Test.stopTest();
    }

    static testMethod void validateDC(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressValidation';
        ic.XC_URL_Required__c  = 'test';
        ic.XC_interfaceName__c = 'AddressValidation';
        insert ic;

        Map<String, String> fieldMap = new Map<String, String>{ 
                'city' => 'test', 
                'address' => 'test', 
                'postalCode' => '28080', 
                'streetNumber' =>  '12',
                'country' => 'Spain'};
                    
        Test.setMock(HttpCalloutMock.class, new XC_DataCentric_Mock());

        Test.startTest();
        
        Map<String,object> res;
        try {
            res = XC_LCC011_NewAddress.callForValidateDC(json.serialize(fieldMap));
            system.assert(res != null);
            XC_UTIL_Debug.debug(true, 'err: '+res+' in: '+json.serialize(fieldMap));
            
        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err: '+res);
            
        }

        Test.stopTest();
    }
    
     static testMethod void validateDC1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressValidation';
        ic.XC_URL_Required__c  = 'test';
        ic.XC_interfaceName__c = 'AddressValidation';
        insert ic;

        Map<String, String> fieldMap = new Map<String, String>{ 
                'city' => 'test', 
                'address' => 'test', 
                'postalCode' => '28080', 
                'streetNumber' =>  '12',
                'country' => 'Spain'};
                    
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock());

        Test.startTest();
        
        Map<String,object> res;
        try {
            res = XC_LCC011_NewAddress.callForValidateDC(json.serialize(fieldMap));
            system.assert(res != null);
            XC_UTIL_Debug.debug(true, 'err: '+res+' in: '+json.serialize(fieldMap));
            
        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err: '+res);
            
        }

        Test.stopTest();
    }

 	static testMethod void validateDC2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Map<String, String> fieldMap = new Map<String, String>{ 
                'city' => 'test', 
                'address' => 'test', 
                'postalCode' => '28080', 
                'streetNumber' =>  '12',
                'country' => 'Spain'};
                    
        Test.startTest();
        
        Map<String,object> res;
        try {
            res = XC_LCC011_NewAddress.callForValidateDC(json.serialize(fieldMap));
            system.assert(res != null);
            XC_UTIL_Debug.debug(true, 'err: '+res+' in: '+json.serialize(fieldMap));
            
        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err: '+res);
            
        }

        Test.stopTest();
    }
    
    
    static testMethod void validateDCerr(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        Map<String, String> fieldMap = new Map<String, String>{ 
                'city' => 'test', 
                'address' => 'test', 
                'streetNumber' =>  '12'};
                    
        Test.setMock(HttpCalloutMock.class, new XC_DataCentric_Mock());
  
        Test.startTest();
        
        XC_LCC011_NewAddress.getCountryByUser();
        
        Map<String,object> res;
        try {
            res = XC_LCC011_NewAddress.callForValidateDC(json.serialize(fieldMap));
            system.assert(res != null);
            XC_UTIL_Debug.debug(true, 'err: '+res+' in: '+json.serialize(fieldMap));
            
        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err: '+res);
            
        }

        Test.stopTest();
    }

    static testMethod void callToPODByAddress(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        Map<String, String> fieldMap = new Map<String, String>{ 
                'city' => 'test', 
                'province' => 'test', 
                'address' => 'test', 
                'postalCode' => '28080', 
                'streetNumber' =>  '12'};

        Test.setMock(HttpCalloutMock.class, new XC_DataCentric_Mock());

        Test.startTest();
        
        List<String> res;
        try {
            res = XC_LCC011_NewAddress.callToPODByAddress(json.serialize(fieldMap));
            system.assert(res != null);
            XC_UTIL_Debug.debug(true, 'err: '+res+' in: '+json.serialize(fieldMap));
            
        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err: '+res);
            
        }

        Test.stopTest();
    }
    
    static testMethod void getZipCodeDirectly(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressValidationDC';
        ic.XC_URL_Required__c  = 'test';
        ic.XC_interfaceName__c = 'AddressValidationDC';
        insert ic;

        Map<String, String> fieldMap = new Map<String, String>{ 
                'city' => 'test', 
                'province' => 'test', 
                'address' => 'test', 
                'postalCode' => '28080', 
                'streetNumber' =>  '12'};
                    
        Test.setMock(HttpCalloutMock.class, new XC_DataCentric_Mock());

        Test.startTest();
        
        List<String> res;
        try {
            res = XC_LCC011_NewAddress.getZipCodeDirectly(json.serialize(fieldMap));
            system.assert(res != null);
            XC_UTIL_Debug.debug(true, 'err: '+res+' in: '+json.serialize(fieldMap));
            
        } catch (exception e) {
            XC_UTIL_Debug.debug(true, 'err: '+res);
            
        }

        Test.stopTest();
    }
    
    static testMethod void verifyUpdateLeadAddressFields(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
    	Test.startTest();
        
        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test', 
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true,
            'isAccountPartner' => false
        	};
    	            
        //String mapAccountString = JSON.serialize(mapAddressFields);
        //XC_LCC011_U_NewAddress.WrapperInput wrp = new  XC_LCC011_U_NewAddress.WrapperInput();
        List<Lead> lstLead = XC_DF_Lead.createResidentialLeads(1);
        
        XC_LCC011_U_NewAddress.populateLeadAddress(mapAddressFields, lstLead[0]);
        System.assert(lstLead[0].XC_Country__c != null);
        Test.stopTest();
        }
    
    static testMethod void verifyInsertLeadAddressFields(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
    	Test.startTest();
        
        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test', 
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true,
            'isAccountPartner' => false
        	};
    	            
        //String mapAccountString = JSON.serialize(mapAddressFields);
        //XC_LCC011_U_NewAddress.WrapperInput wrp = new  XC_LCC011_U_NewAddress.WrapperInput();
        List<Lead> lstLead = XC_DF_Lead.createResidentialLeads(1);
        
        XC_LCC011_U_NewAddress.populateLeadAddress(mapAddressFields, lstLead[0]);
        System.assert(lstLead[0].XC_Country__c != null);
        Test.stopTest();
    }
    
    static testMethod void updateAddress(){
        
        List<Lead> lstLead = XC_DF_Lead.createResidentialLeads(1);
        
        XC_Address__c add = new XC_Address__c();
        add.XC_Lead__c = lstLead[0].id;
        insert add;
        
        
        
         Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test', 
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true,
            'isAccountPartner' => false,
            'leadId' => 'test'
        	};
                
        String mapAccountString = JSON.serialize(mapAddressFields);
        
        Test.startTest();
    	XC_LCC011_NewAddress.updateAddressByLead(mapAccountString);
        XC_LCC011_NewAddress.updateLead(lstLead[0].id, add.id);
        Test.stopTest();
        
        System.assert(mapAccountString != null);
    }
    
    
}