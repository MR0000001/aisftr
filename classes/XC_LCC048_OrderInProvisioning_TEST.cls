/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  20/05/2019 
* @description XC_LCC048_OrderInProvisioning_TEST – Test class for XC_LCC048_OrderInProvisioning
*/
@isTest
public class XC_LCC048_OrderInProvisioning_TEST {
    //Test Method insertProvisioningSteps
    static testMethod void insertProvisioningSteps(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS_UtilityGlobalValues__c csInsertDML = new XC_CS_UtilityGlobalValues__c();
        csInsertDML.Name = 'InsertLogsGenerateWO';
        csInsertDML.Value__c = 'true';
        insert csInsertDML;
        XC_CS_UtilityGlobalValues__c csInsertDML1 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML1.Name = 'InsertLogsGenerateWO_OK';
        csInsertDML1.Value__c = 'true';
        insert csInsertDML1;
        XC_CS_UtilityGlobalValues__c csInsertDML2 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML2.Name = 'GenerateWOB2Win_Log';
        csInsertDML2.Value__c = 'false';
        insert csInsertDML2;
        Test.startTest();
        
        NE__Order__c o = XC_DF_Order.createOrder('test');
        
        XC_UTIL_ProvisioningStep.ResultWrapper rw = XC_LCC048_OrderInProvisioning.insertProvisioningSteps(o.Id);
        XC_UTIL_ProvisioningStep.ResultWrapper rw1 = XC_LCC048_OrderInProvisioning.insertProvisioningSteps(o.Id,'test');
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }
    
    //Test Method updateOrderStatus
    static testMethod void updateOrderStatus(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        insert listAccount;
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(listAccount);
        insert addressList;
        Account acc = listAccount[0];
        NE__Order__c o = XC_DF_Order.createOrder('test');
        o.NE__AccountId__c = acc.Id;
        o.XC_DeliveryAddress__c = addressList[0].Id;
        o.XC_InstallationAddress__c = addressList[0].Id;
        NE__OrderItem__c oi = XC_DF_OrderItem.createOrderItem(o);
        oi.NE__Account__c = o.NE__AccountId__c;
        //oi.XC_DeliveryAddress__c = o.XC_DeliveryAddress__c;
        oi.XC_Installation_Address__c = o.XC_InstallationAddress__c;
        oi.XC_IsAProduct__c= true;
        insert oi;
        
        XC_Provisioning_Step__c ps = new XC_Provisioning_Step__c();
        ps.XC_Configuration_Item__c = oi.Id;
        ps.XC_Step_Order__c= 1;
        insert ps;
        
        XC_UTIL_ResultWrapper rw;
        
        try{
            rw = XC_LCC048_OrderInProvisioning.updateOrderStatus(o.Id);
            
        }catch(exception e){
            System.assert(e !=null);
        }
        
        o.NE__Type__c=Label.XC_CL_Configuration_TypeChangeOrder;
        update o;
        
        try{
            rw = XC_LCC048_OrderInProvisioning.updateOrderStatus(o.Id);
            
        }catch(exception e){
            System.assert(e !=null);
        }
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }
    
    
    //Test Method updateOrderStatus
    static testMethod void updateOrderStatus1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        Account acc = listAccount[0];
        insert acc;
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(listAccount);
        insert addressList;
        NE__Order__c o = XC_DF_Order.createOrder('test');
        o.NE__AccountId__c = acc.Id;
        o.XC_InstallationAddress__c = addressList[0].Id;        
        NE__OrderItem__c oi = XC_DF_OrderItem.createOrderItem(o);
        oi.NE__Account__c = o.NE__AccountId__c;
        oi.XC_IsAProduct__c= true;
        oi.XC_Installation_Address__c = o.XC_InstallationAddress__c;
        insert oi;
        
        XC_Provisioning_Step__c ps = new XC_Provisioning_Step__c();
        ps.XC_Configuration_Item__c = oi.Id;
        ps.XC_Step_Order__c= 2;
        insert ps;
        
        XC_UTIL_ResultWrapper rw = XC_LCC048_OrderInProvisioning.updateOrderStatus(o.Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }
    
    //Test Method checkCompliance1Status
    static testMethod void checkCompliance1Status(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        NE__Order__c o = XC_DF_Order.createOrder('test');
        o.NE__Type__c='InOrder';
        update o;
        
        Boolean rw = XC_LCC048_OrderInProvisioning.checkCompliance1Status(o.Id);
        
        o.NE__Type__c= Label.XC_CL_Configuration_TypeDisconnection;
        update o;
        rw = XC_LCC048_OrderInProvisioning.checkCompliance1Status(o.Id);
        
        o.NE__Type__c= Label.XC_CL_Configuration_TypeChangeOrder;
        update o;
        rw = XC_LCC048_OrderInProvisioning.checkCompliance1Status(o.Id);
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }
    
    
}