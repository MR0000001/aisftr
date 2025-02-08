/**
*@author Sara Miozza sara.miozza@nttdata.com 
*@date Creation 15/05/2019
*@description XC_LCC015_RecordEditForm_TEST - Test class for XC_LCC015_RecordEditForm
*/

@isTest
public class XC_LCC015_RecordEditForm_TEST {
    
    @isTest
    static void getFieldsSetValuesTest(){
        Test.startTest();
        String objName = 'Account';
        String fieldsSetName = 'XC_ESP_Account_New_Opportunity';
        List<String> listField =  XC_LCC015_RecordEditForm.getFieldsSetValues(objName,fieldsSetName);
        System.assert(!listField.isEmpty()); 
        Test.stopTest();
    } 
    
    @isTest
    static void callToAddressValidationTest(){
         Test.startTest();
        Map<String,Object> addsMap = new Map<String,Object>();
        addsMap.put('XC_Country__c', '');
        addsMap.put('XC_StreetType__c', '');
        addsMap.put('XC_Address__c', '');
        addsMap.put('XC_StreetNumber__c', '');
        addsMap.put('XC_Door__c', '');
        addsMap.put('XC_Stair__c', '');
        addsMap.put('XC_ZipCode__c', '');
        addsMap.put('XC_City__c', '');
        addsMap.put('XC_Province__c', '');
        addsMap.put('XC_Category__c', '');
        XC_REST_AddressValidation.ResultWrapper rw = XC_LCC015_RecordEditForm.callToAddressValidation('',addsMap);
        System.assert(rw!=null);
        Test.stopTest();
        
    }
    
        @isTest
    static void callToAddressValidationTest2(){
         Test.startTest();
        Map<String,Object> addsMap = new Map<String,Object>();
        addsMap.put('XC_Country__c', '');
        addsMap.put('XC_StreetType__c', '');
        addsMap.put('XC_Address__c', '');
        addsMap.put('XC_StreetNumber__c', '');
        addsMap.put('XC_Door__c', '');
        addsMap.put('XC_Stair__c', '');
        addsMap.put('XC_ZipCode__c', '');
        addsMap.put('XC_City__c', '');
        addsMap.put('XC_Province__c', '');
        addsMap.put('XC_Category__c', '');
        try{
        	XC_REST_AddressValidation.ResultWrapper rw = XC_LCC015_RecordEditForm.callToAddressValidationDC(addsMap);
            System.assert(rw!=null);
        }catch(Exception e){
            System.debug('In Catch');
        }
        Test.stopTest();
        
    }

}