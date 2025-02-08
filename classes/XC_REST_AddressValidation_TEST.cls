/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  28/05/2019 
* @description XC_REST_AddressValidation_TEST – Test class for XC_REST_AddressValidation
*/
@isTest
public class XC_REST_AddressValidation_TEST {
     @TestSetup
    static void setup(){ 
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'AddressValidation';
        ic.XC_URL_Required__c  = 'vvvvvv';
        ic.XC_interfaceName__c = 'AddressValidation';
        ic.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic;
        
        XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c();
        ic2.XC_activeInterface__c = true;
        ic2.Name = Label.XC_CL_Address_Validation;
        ic2.XC_URL_Required__c  = 'vvvvv';
        ic2.XC_interfaceName__c = Label.XC_CL_Address_Validation;
        ic2.XC_URL_Required__c = 'callout:XC_AddressValidation?api_key=etxfrn5spygkanhed78emgg5';
        insert ic2;
        

    }
        //Test Method callToAddressValidation
    static testMethod void callToAddressValidation(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock());
        
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        
        XC_REST_AddressValidation.ResultWrapper rw = XC_REST_AddressValidation.callToAddressValidation(addrToVal);
        
        //System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    } 
    //Test Method callToAddressValidation1
    static testMethod void callToAddressValidation1(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        addrToVal.streetType ='Calle';
        addrToVal.street= 'test';
        addrToVal.streetNumber='test';
        addrToVal.zipCode = '28080';
        addrToVal.country = 'SPAIN';
        addrToVal.city = 'Barcelona';
        addrToVal.province = 'Barcelona';
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_URL_Required__c = 'test';
        ic.XC_activeInterface__c = true;
        ic.Name = Label.XC_CL_Address_Validation;
        ic.XC_interfaceName__c = Label.XC_CL_Address_Validation;
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock());
        
        Test.startTest();
        XC_REST_AddressValidation.ResultWrapper rw;
        Map<String,Object> inputMap = new Map<String,Object>();
        inputMap.put('streetType','Calle');
        inputMap.put('province','Calle');
        inputMap.put('city','Calle');
        inputMap.put('country','SPAIN');
        inputMap.put('zipCode','Calle');
        inputMap.put('streetNumber','Calle');
        inputMap.put('street','Calle');
        try{
            XC_REST_AddressValidation.callToAddressValidationNew(inputMap);
        }catch(exception e){
            System.assert(e!=null);
        }
         
        
        //System.assertEquals(false, rw!=null);
        Test.stopTest();
        
    }
    
     static testMethod void callToAddressValidation01(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        addrToVal.streetType ='Calle';
        addrToVal.street= 'test';
        addrToVal.streetNumber='test';
        addrToVal.zipCode = '28080';
        addrToVal.country = 'SPAIN';
        addrToVal.city = 'Barcelona';
        addrToVal.province = 'Barcelona';
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_URL_Required__c = 'test';
        ic.XC_activeInterface__c = true;
        ic.Name = Label.XC_CL_Address_Validation;
        ic.XC_interfaceName__c = Label.XC_CL_Address_Validation;
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock());
        
        Test.startTest();
        XC_REST_AddressValidation.ResultWrapper rw;
        Map<String,Object> inputMap = new Map<String,Object>();
        inputMap.put('streetType','Calle');
        inputMap.put('province','Calle');
        inputMap.put('city','Calle');
        inputMap.put('country','SPAIN');
        inputMap.put('zipCode','Calle');
        inputMap.put('streetNumber','Calle');
        inputMap.put('street','Calle');
        try{
            XC_REST_AddressValidation.callToAddressValidation(addrToVal);
        }catch(exception e){
            System.assert(e!=null);
        }
         
        
        //System.assertEquals(false, rw!=null);
        Test.stopTest();
        
    }
    //Test Method callToAddressValidation2
    static testMethod void callToAddressValidation2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        addrToVal.streetType ='Calle';
        addrToVal.street= 'test';
        addrToVal.streetNumber='test';
        addrToVal.zipCode = '28080';
        addrToVal.country = 'SPAIN';
        addrToVal.city = 'Barcelona';
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_URL_Required__c = 'test';
        ic.XC_activeInterface__c = false;
        ic.Name = Label.XC_CL_Address_Validation;
        ic.XC_interfaceName__c = Label.XC_CL_Address_Validation;
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock());
        
        Test.startTest();
        XC_REST_AddressValidation.ResultWrapper rw = XC_REST_AddressValidation.callToAddressValidation(addrToVal);
        
        //System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
   	static testMethod void callToAddressValidation3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        addrToVal.streetType ='Calle';
        addrToVal.street= '';
        addrToVal.streetNumber='test';
        addrToVal.zipCode = '28080';
        addrToVal.country = 'SPAIN';
        addrToVal.city = 'Barcelona';
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_URL_Required__c = 'test';
        ic.XC_activeInterface__c = false;
        ic.Name = Label.XC_CL_Address_Validation;
        ic.XC_interfaceName__c = Label.XC_CL_Address_Validation;
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock());
        
        Test.startTest();
        XC_REST_AddressValidation.ResultWrapper rw = XC_REST_AddressValidation.callToAddressValidation(addrToVal);
        
        //System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
	static testMethod void callToAddressValidation4(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        addrToVal.streetType ='Calle';
        addrToVal.street= 'street';
        addrToVal.streetNumber='test';
        addrToVal.zipCode = '28080';
        addrToVal.country = 'SPAIN';
        addrToVal.city = 'Barcelona';
        addrToVal.province = '';
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_URL_Required__c = 'test';
        ic.XC_activeInterface__c = false;
        ic.Name = Label.XC_CL_Address_Validation;
        ic.XC_interfaceName__c = Label.XC_CL_Address_Validation;
        insert ic;
        
        //Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock(JSON.serialize(addrToVal)));
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock());
        Test.startTest();
        XC_REST_AddressValidation.ResultWrapper rw = XC_REST_AddressValidation.callToAddressValidation(addrToVal);
        
        //System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
	static testMethod void callToAddressValidation5(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        addrToVal.streetType ='Calle';
        addrToVal.street= 'street';
        addrToVal.streetNumber='test';
        addrToVal.zipCode = '28080';
        addrToVal.country = 'SPAIN';
        addrToVal.city = '';
        addrToVal.province = 'Barcelona';
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_URL_Required__c = 'test';
        ic.XC_activeInterface__c = false;
        ic.Name = Label.XC_CL_Address_Validation;
        ic.XC_interfaceName__c = Label.XC_CL_Address_Validation;
        insert ic;
        
        //Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock(JSON.serialize(addrToVal)));
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock());
        Test.startTest();
        XC_REST_AddressValidation.ResultWrapper rw = XC_REST_AddressValidation.callToAddressValidation(addrToVal);
        
        //System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    static testMethod void callToAddressValidation6(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        addrToVal.streetType ='Calle';
        addrToVal.street= 'street';
        addrToVal.streetNumber='test';
        addrToVal.zipCode = '28080';
        addrToVal.country = '';
        addrToVal.city = 'Barcelona';
        addrToVal.province = 'Barcelona';
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_URL_Required__c = 'test';
        ic.XC_activeInterface__c = false;
        ic.Name = Label.XC_CL_Address_Validation;
        ic.XC_interfaceName__c = Label.XC_CL_Address_Validation;
        insert ic;
        
        //Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock(JSON.serialize(addrToVal)));
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock());
        Test.startTest();
        XC_REST_AddressValidation.ResultWrapper rw = XC_REST_AddressValidation.callToAddressValidation(addrToVal);
        
        //System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    static testMethod void callToAddressValidation7(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        addrToVal.streetType ='Calle';
        addrToVal.street= 'street';
        addrToVal.streetNumber='test';
        addrToVal.zipCode = '28080';
        addrToVal.country = 'SPAIN';
        addrToVal.city = 'Barcelona';
        addrToVal.province = 'Barcelona';
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_URL_Required__c = 'test';
        ic.XC_activeInterface__c = false;
        ic.Name = Label.XC_CL_Address_Validation;
        ic.XC_interfaceName__c = Label.XC_CL_Address_Validation;
        insert ic;
        
        //Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock(JSON.serialize(addrToVal)));
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_Mock());
        Test.startTest();
        XC_REST_AddressValidation.ResultWrapper rw = XC_REST_AddressValidation.callToAddressValidation(addrToVal);
        
        //System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    static testMethod void callToAddressValidation8(){
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        
        Test.startTest();
        XC_UTIL_Integration.Result rw = XC_REST_AddressValidation_U.checkRequiredParameters(addrToVal);
        addrToVal.streetType ='Calle';
        rw = XC_REST_AddressValidation_U.checkRequiredParameters(addrToVal);
        addrToVal.street= 'street';
        rw = XC_REST_AddressValidation_U.checkRequiredParameters(addrToVal);
        addrToVal.streetNumber='test';
        rw = XC_REST_AddressValidation_U.checkRequiredParameters(addrToVal);
        addrToVal.zipCode = '28080';
        rw = XC_REST_AddressValidation_U.checkRequiredParameters(addrToVal);
        addrToVal.country = 'SPAIN';
        rw = XC_REST_AddressValidation_U.checkRequiredParameters(addrToVal);
        addrToVal.city = 'Barcelona';
        addrToVal.province = 'Barcelona';
        //System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    static testMethod void checkResponseParameterTEST(){
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        
        Test.startTest();
        XC_UTIL_Integration.Result rw = XC_REST_AddressValidation_U.checkResponseParameters(addrToVal);
        addrToVal.streetType ='Calle';
        rw = XC_REST_AddressValidation_U.checkResponseParameters(addrToVal);
        addrToVal.street= 'street';
        rw = XC_REST_AddressValidation_U.checkResponseParameters(addrToVal);
        addrToVal.province='Barcelona';
        rw = XC_REST_AddressValidation_U.checkResponseParameters(addrToVal);
                addrToVal.city = 'Barcelona';
        rw = XC_REST_AddressValidation_U.checkResponseParameters(addrToVal);
        addrToVal.country = 'SPAIN';
        rw = XC_REST_AddressValidation_U.checkResponseParameters(addrToVal);

        
        //System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    static testMethod void manageResponseFakeTEST(){
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        
        Test.startTest();
        	XC_REST_AddressValidation.ResultWrapper rw =XC_REST_AddressValidation.manageResponseFake();
        Test.stopTest();
        
        //System.assert(rw != null);
    }
    
    static testMethod void manageResponseTEST(){
        XC_UTIL_Address.AddressWrapper addrToVal = new XC_UTIL_Address.AddressWrapper();
        HttpResponse response = new HttpResponse();
        response.setStatusCode(504);
        
        Test.startTest();
        	XC_REST_AddressValidation.ResultWrapper rw = XC_REST_AddressValidation.manageResponse(null);
        	rw = XC_REST_AddressValidation.manageResponse(response);
        	response.setStatusCode(200);
        	response.setBody(JSON.serialize(addrToVal));
            rw = XC_REST_AddressValidation.manageResponse(response);
        	
        	response.setStatusCode(500);
        	response.setBody(JSON.serialize(addrToVal));
            rw = XC_REST_AddressValidation.manageResponse(response);
        
       		
            XC_REST_AddressValidation_U.WrapperAddressResponse wrapperResult = new XC_REST_AddressValidation_U.WrapperAddressResponse();
             wrapperResult.Address= new List<XC_UTIL_Address.AddressWrapper>{new XC_UTIL_Address.AddressWrapper()};
             wrapperResult.Address[0].street = 'Calle';
             wrapperResult.Address[0].province = 'Calle';
             wrapperResult.Address[0].city = 'Calle';
             wrapperResult.Address[0].country = 'Calle'; 
             wrapperResult.Result = new XC_UTIL_Integration.Result();
             wrapperResult.Result.ErrorCode = '0';
             // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(wrapperResult, true));
        
            rw = XC_REST_AddressValidation.manageResponse(res);
        Test.stopTest();
        
        //System.assert(rw != null);
    }
    
}