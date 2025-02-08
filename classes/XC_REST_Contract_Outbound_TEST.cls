@isTest
public class XC_REST_Contract_Outbound_TEST {
    
    @TestSetup
    static void setup(){

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ContractOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        ic.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic.XC_Country__c = 'Spain';
        insert ic;
        
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;

        List<XC_Address__c> addr = XC_DF_Address.createAddress(acc);
        insert addr;

        List<Asset> a = XC_DF_Asset.createAssets(acc);
        insert a;
        
    } 
    
    @isTest
    public static void callActive(){
        
        /*XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ContractOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        ic.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic.XC_Country__c = 'Spain';
        insert ic;*/
        
        test.startTest();
        
        system.assert(XC_REST_Contract_Outbound.callToGetContract([select id from account][0].id, 'asd') != null);
            
        test.stopTest();
            
    }
    
    
    @isTest
    public static void initContractOutboundRequest(){
        
        /*XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ContractOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        ic.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic.XC_Country__c = 'Spain';
        insert ic;*/
        
        test.startTest();
        
        system.assert(XC_REST_Contract_Outbound.initContractOutboundRequest('asdasd')!=null);
            
        test.stopTest();
            
    }
    
    @isTest
    public static void callToGetContract(){
        
        /*XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ContractOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        insert ic;*/
        
        test.startTest();

        try{
            system.assert(XC_REST_Contract_Outbound.callToGetContract('test','test','Spain')!=null);
        } catch(exception e){
            XC_UTIL_Debug.Debug(true,e+'');
        }
        
        test.stopTest();
            
    }
    
     @isTest
    public static void wrappertest(){
    	test.startTest();
        XC_REST_Contract_W.WrapperContractRequest wcr = new XC_REST_Contract_W.WrapperContractRequest();
        XC_REST_Contract_W.ContractSourceWrapper csw = new XC_REST_Contract_W.ContractSourceWrapper();
        system.assert(csw!=null);
        test.stopTest();    
    }
    
    
    
    @isTest
    public static void callInactive(){
        List<XC_CS001_InterfaceConfiguration__c> ic = [SELECT Id FROM XC_CS001_InterfaceConfiguration__c WHERE Name =: Label.XC_CL_ContractOutbound ];
        ic[0].XC_activeInterface__c = false;
        update ic;
        
        test.startTest();

        system.assert(XC_REST_Contract_Outbound.callToGetContract([select id from account][0].id, 'asd') != null);
            
        test.stopTest();
            
    }

}