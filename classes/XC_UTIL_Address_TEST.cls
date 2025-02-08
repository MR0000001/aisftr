/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/05/2019
* @description XC_UTIL_Address_TEST – Test class for XC_UTIL_Address
*/ 

@isTest
private class XC_UTIL_Address_TEST {
    static testMethod void onInsert() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<XC_UTIL_Address.AddressWrapper> listAddressWrapper = new List<XC_UTIL_Address.AddressWrapper>();
        XC_UTIL_Address.AddressWrapper addressWrapper = new XC_UTIL_Address.AddressWrapper();
        addressWrapper.Country = 'SPAIN';
        addressWrapper.isPartner = true;
        listAddressWrapper.add(addressWrapper);
        listAddressWrapper.add(new XC_UTIL_Address.AddressWrapper('REST'));
        XC_UTIL_Address.PoSWrapper posWrapper = new XC_UTIL_Address.PoSWrapper();
        XC_Address__c address = new XC_Address__c(
            XC_City__c = 'Test',
            XC_AddressCountry__c = 'Test',
            XC_PostalCode__c = '28080',
            XC_Address__c = 'Test');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        System.assertEquals(addressWrapper != null , true);
        
        Test.startTest();
        XC_UTIL_Address.insertAddress(listAddressWrapper[0]);
        String recordType = XC_UTIL_Address.getAddressRecordTypeByCountry('SPAIN', true);
        XC_UTIL_Address.populateAddressFieldsFromAddress(listWorkOrder[0], address);
        XC_UTIL_Address.createWrapperFromLead(listLead[0]);
		Test.stopTest();        
    }
}