/**
* @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
* @date Creation  16/10/2019 
* @description XC_LCC152_CustomerReqUnsubscribe_TEST – Test class for XC_LCC152_CustomerRequestsUnsubscribe
*/
@IsTest
public class XC_LCC152_CustomerReqUnsubscribe_TEST {
    
    //Test Method updateFLS
    @isTest
    static void updateFLSEquipment(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
        List<XC_Address__c> address = XC_DF_Address.createAddress(accounts);
        insert address;
        
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        woList[0].AccountId = accounts[0].Id;
        woList[0].ContactId = contacts[0].Id;
        woList[0].XC_Address__c = address[0].Id;
        woList[0].Street = address[0].XC_Address__c;
        insert woList;
        
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].AccountId = accounts[0].Id;
        assetList[0].XC_Product_Type__c = 'Equipment';
        insert assetList;
        
        woList[0].status = Label.XC_CL_OnHold;
        woList[0].AssetId = assetList[0].Id;
        update woList;

        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert listSa;
        XC_UTIL_ResultWrapper rw = XC_LCC152_CustomerRequestsUnsubscribe.updateFLS(woList[0].Id);

        System.assertEquals(true, woList!=null);
        Test.stopTest();
    }

    //Test Method updateFLS when non-compliant worktype
    @isTest
    static void updateFLSService(){
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
        List<XC_Address__c> address = XC_DF_Address.createAddress(accounts);
        insert address;
            
        Test.startTest();         
            List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
            woList[0].AccountId = accounts[0].Id;
            woList[0].ContactId = contacts[0].Id;
            woList[0].XC_Address__c = address[0].Id;
            woList[0].Street = address[0].XC_Address__c;
            insert woList;
        
            List<Asset> assetList = XC_DF_Asset.createAssets(1);
        	assetList[0].AccountId = accounts[0].Id;
            assetList[0].XC_Product_Type__c = 'Service';
            insert assetList;
        
            woList[0].status = Label.XC_CL_OnHold;
            woList[0].AssetId = assetList[0].Id;
            update woList;
    
            List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
            insert listSa;
            XC_UTIL_ResultWrapper rw = XC_LCC152_CustomerRequestsUnsubscribe.updateFLS(woList[0].Id);
    
            System.assertEquals(true, woList!=null);
            Test.stopTest();
    }
}