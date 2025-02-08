/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  28/05/2019 
* @description XC_UTIL_ResultWrapper_TEST – Test class for XC_UTIL_ResultWrapper
*/
@isTest
public class XC_REST_PodsByAddressAPI_TEST {
    
    
    //Test Method callToPODByAddress
    static testMethod void callToPODByAddress(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_Address.AddressWrapper addrWrapper = new XC_UTIL_Address.AddressWrapper();
        XC_REST_PodsByAddressAPI.callToPODByAddress(addrWrapper);
        
        system.assertEquals(true , addrWrapper!=null); 
        
        Test.stopTest();
         
    }
    
    //Test Method callToPODByAddress1
    static testMethod void callToPODByAddress1(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();         
        
        
        XC_UTIL_Address.AddressWrapper addrWrapper = new XC_UTIL_Address.AddressWrapper();
        addrWrapper.address= 'test';        
        XC_REST_PodsByAddressAPI.callToPODByAddress(addrWrapper); 
        
        system.assertEquals(true , addrWrapper!=null); 
        
        Test.stopTest();
         
    }
    
    //Test Method callToPODByAddress2
    static testMethod void callToPODByAddress2(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();         
        
        
        XC_UTIL_Address.AddressWrapper addrWrapper = new XC_UTIL_Address.AddressWrapper();
        addrWrapper.address= 'test';
        addrWrapper.streetNumber='test';
        XC_REST_PodsByAddressAPI.callToPODByAddress(addrWrapper); 
        
        system.assertEquals(true , addrWrapper!=null); 
        
        Test.stopTest();
         
    }
    
    //Test Method callToPODByAddress3
    static testMethod void callToPODByAddress3(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();         
        
        
        XC_UTIL_Address.AddressWrapper addrWrapper = new XC_UTIL_Address.AddressWrapper();
        addrWrapper.address= 'test';
        addrWrapper.streetNumber='test';
        addrWrapper.zipCode = '28080';
        XC_REST_PodsByAddressAPI.callToPODByAddress(addrWrapper);
        
        system.assertEquals(true , addrWrapper!=null); 
        
        Test.stopTest();
         
    }
    
    
    
    //Test Method callToPODByAddress4
    static testMethod void callToPODByAddress4(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();         
        
        
        XC_UTIL_Address.AddressWrapper addrWrapper = new XC_UTIL_Address.AddressWrapper();
        addrWrapper.address= 'test';
        addrWrapper.streetNumber='test';
        addrWrapper.zipCode = '28080';
        addrWrapper.province = 'Barcelona';
        XC_REST_PodsByAddressAPI.callToPODByAddress(addrWrapper); 
        
        system.assertEquals(true , addrWrapper!=null); 
        
        Test.stopTest();
         
    }
    
    //Test Method callToPODByAddress5
    static testMethod void callToPODByAddress5(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();         
        
        
        XC_UTIL_Address.AddressWrapper addrWrapper = new XC_UTIL_Address.AddressWrapper();
        addrWrapper.address= 'test';
        addrWrapper.streetNumber='test';
        addrWrapper.zipCode = '28080';
        addrWrapper.province = 'Barcelona';
        addrWrapper.city = 'Barcelona';
        
        
        
        XC_REST_PodsByAddressAPI.callToPODByAddress(addrWrapper); 
        
        
        system.assertEquals(true , addrWrapper!=null); 
        
        Test.stopTest();
         
    }
    
    
    //Test Method callToPODByAddress6
    static testMethod void callToPODByAddress6(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
                
        
        
        XC_UTIL_Address.AddressWrapper addrWrapper = new XC_UTIL_Address.AddressWrapper();
        addrWrapper.address= 'test';
        addrWrapper.streetNumber='test';
        addrWrapper.zipCode = '28080';
        addrWrapper.province = 'Barcelona';
        addrWrapper.city = 'Barcelona';
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = Label.XC_CL_PodsByAddress;
        ic.XC_interfaceName__c = Label.XC_CL_PodsByAddress;
        ic.XC_URL_Required__c = 'test';
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_PodsByAddressAPI_Mock());
        Test.startTest(); 
        XC_REST_PodsByAddressAPI.callToPODByAddress(addrWrapper); 
        
        
        system.assertEquals(true , addrWrapper!=null); 
        
        Test.stopTest();
         
    }
    
   
}