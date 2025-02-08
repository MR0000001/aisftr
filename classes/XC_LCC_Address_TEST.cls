@isTest
private class XC_LCC_Address_TEST {

    @isTest
    static void saveAddressApex(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        Account acc = accList[0];
        insert acc;

        Map<String, Object> inputMap = new Map<String, Object>{
            'country' => 'Spain',
            'streetTypeText' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true,
            'validatedCups' => true,
            'XC_ElectricCUPS__c' => '12345678'
        };
        XC_LCC_Address.saveAddressApex(JSON.serialize(inputMap), acc.Id);
        String country=XC_LCC_Address.getCountryByUser();
        Test.startTest();
       
     Test.setMock(HttpCalloutMock.class, new XC_LCC_AddressMock());
       // HTTPResponse result =null;
        Test.stopTest();
        XC_LCC_Address.getHiddenFieldsByCountry(country, false); 
         XC_LCC_Address.getAddressByCup('12345678');
        try{
               XC_LCC_Address.getZipDirectly(JSON.serialize(inputMap));
        }catch (Exception e){
        }
        
        XC_LCC_Address.callToPODByAddress(JSON.serialize(inputMap));
        XC_Address__c[] res = [SELECT Id FROM XC_Address__c WHERE XC_Account__c = :acc.Id];
        System.assert(res.size() == 1);
    }
    
    static testMethod void updateAddressByLead(){
      List<Lead> leadList=XC_DF_Lead.createResidentialLeads(1);  
      insert leadList;
       string leadId=leadList[0].id;
         Map<String, Object> inputMap = new Map<String, Object>{
            'country' => 'Spain',
            'streetTypeText' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true,
            'validatedCups' => true,
            'XC_ElectricCUPS__c' => '12345678'    
        };
           XC_LCC_Address.saveAddressApex(JSON.serialize(inputMap), leadList[0].Id);
          XC_LCC_Address.updateAddressByLead(JSON.serialize(inputMap), leadList[0].Id);            
    }
    
    static testMethod void updateAddressByLead2(){
      List<Lead> leadList=XC_DF_Lead.createResidentialLeads(1);  
      insert leadList;
       string leadId=leadList[0].id;
         Map<String, Object> inputMap = new Map<String, Object>{
            'country' => 'Chile',
            'streetTypeText' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true,
            'validatedCups' => true,
            'XC_ElectricCUPS__c' => '12345678'    
        };
           XC_LCC_Address.saveAddressApex(JSON.serialize(inputMap), leadList[0].Id);
          XC_LCC_Address.updateAddressByLead(JSON.serialize(inputMap), leadList[0].Id);            
    }
    
    static testMethod void autoCompleteStreet(){
           List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        Account acc = accList[0];
        insert acc;   
        Map<String, Object> inputMap = new Map<String, Object>{
            'country' => 'Spain',
            'streetTypeText' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true,
            'validatedCups' => true,
            'XC_ElectricCUPS__c' => '12345678'
        };
     //  XC_LCC_Address.saveAddressApex(JSON.serialize(inputMap), acc.Id); 
      Test.startTest();       
       Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_MOCK());
    // HTTPResponse result =null;
      Test.stopTest();
       // XC_LCC_Address.autoCompleteZipCode(JSON.serialize(inputMap));
        XC_LCC_Address.autoCompleteStreet(JSON.serialize(inputMap));
    }
     static testMethod void autoCompleteZipCode(){
           List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        Account acc = accList[0];
        insert acc;   
        Map<String, Object> inputMap = new Map<String, Object>{
            'country' => 'Spain',
            'streetTypeText' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true,
            'validatedCups' => true,
            'XC_ElectricCUPS__c' => '12345678'
        };
     //  XC_LCC_Address.saveAddressApex(JSON.serialize(inputMap), acc.Id); 
      Test.startTest();       
       Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_MOCK());
    // HTTPResponse result =null;
      Test.stopTest();
        XC_LCC_Address.autoCompleteZipCode(JSON.serialize(inputMap));
       // XC_LCC_Address.autoCompleteStreet(JSON.serialize(inputMap));
    }
    static testMethod void autoCompleteCity(){
           List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        Account acc = accList[0];
        insert acc;   
        Map<String, Object> inputMap = new Map<String, Object>{
            'country' => 'Spain',
            'streetTypeText' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true,
            'validatedCups' => true,
            'XC_ElectricCUPS__c' => '12345678'
        };
     //  XC_LCC_Address.saveAddressApex(JSON.serialize(inputMap), acc.Id); 
      Test.startTest();       
       Test.setMock(HttpCalloutMock.class, new XC_REST_AddressValidation_MOCK());
    // HTTPResponse result =null;
      Test.stopTest();
          XC_LCC_Address.autoCompleteCity(JSON.serialize(inputMap));
    }
    static testMethod void callForValidate(){
           List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        Account acc = accList[0];
        insert acc;   
        Map<String, Object> inputMap = new Map<String, Object>{
            'country' => 'Spain',
            'streetTypeText' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true,
            'validatedCups' => true,
            'XC_ElectricCUPS__c' => '12345678'
        };
            XC_LCC_Address.saveAddressApex(JSON.serialize(inputMap), acc.Id);  
     //  XC_LCC_Address.saveAddressApex(JSON.serialize(inputMap), acc.Id); 
      Test.startTest();       
       Test.setMock(HttpCalloutMock.class, new XC_LCC_AddressMock());
    // HTTPResponse result =null;
      Test.stopTest();
        try{
        XC_LCC_Address.callForValidate(JSON.serialize(inputMap));
        }catch(exception e){
            
        }   
    }
}