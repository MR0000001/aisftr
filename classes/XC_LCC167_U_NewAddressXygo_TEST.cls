/**
* @author Andrea Di Cicco
* @date Creation  08/05/2019
* @description XC_LCC167_NewAddressXygo_TEST – Test class for XC_LCC167_NewAddressXygo
*/
@isTest
public class XC_LCC167_U_NewAddressXygo_TEST {
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
        XC_UTIL_ResultWrapper wr = XC_LCC167_U_NewAddressXygo.saveAddressApex(inputAddress);
        System.assertEquals(true, wr.success);
        Test.stopTest();
    }   
    
    static testMethod void updateAddressByLead(){
        insert XC_DF_OneOrg.createOneOrg('Chile');
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;
        
                List<XC_Address__c> addList = XC_DF_Address.createAddress(1);
        addList.get(0).XC_Lead__c = leadList.get(0).id;
        insert addList;
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
                'isAccountPartner' => false,
                 'lead' => leadList.get(0).id
        };
        
        Test.startTest();
		

		XC_LCC167_U_NewAddressXygo.AddressWrapper addWrapp = new XC_LCC167_U_NewAddressXygo.AddressWrapper();
            
            
        String mapAccountString = JSON.serialize(mapAddressFields);
        XC_LCC011_U_NewAddress.WrapperInput wrp = new  XC_LCC011_U_NewAddress.WrapperInput();
        List<Account> accList = XC_DF_Account.createSohoAccounts(1);
        insert accList;
        mapAddressFields.put('account',accList[0]);
        String inputAddress= JSON.serialize(wrp);
        XC_UTIL_Sobject.WrapperResult wr = XC_LCC167_U_NewAddressXygo.updateAddressByLead(mapAccountString);
        System.assertEquals(true, wr.success);
        Test.stopTest();
    }
    
    static testMethod void populateLeadAddress(){
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList; 
        
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
        
        Test.startTest();
        	XC_LCC167_U_NewAddressXygo.populateLeadAddress(mapAddressFields, leadList.get(0));
        Test.stopTest();
    }
}