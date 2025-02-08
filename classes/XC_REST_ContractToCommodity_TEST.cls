@isTest
public class XC_REST_ContractToCommodity_TEST {

    @TestSetup
	static void setup(){

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        
    }

    public static testMethod void testCallInactive(){
        
        test.startTest();
        
        XC_REST_ContractToCommodity.WrapperResult wr = XC_REST_ContractToCommodity.callToContractCommodity('test', '123');
        system.assert(wr!=null);
		
        test.stopTest();
    }

    public static testMethod void testCallActive(){
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'test';
        ic.XC_interfaceName__c = 'test';
        insert ic;
        
        test.startTest();
       
        XC_REST_ContractToCommodity.WrapperResult wr = XC_REST_ContractToCommodity.callToContractCommodity('test', '123');
        system.assert(wr!=null);
		
        test.stopTest();
    }
    
    

}