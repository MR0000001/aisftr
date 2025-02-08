/**
 * @author: Francesco Imperioli - fimperioli@deloitte.it
 * @description : TestClass for XC_Zuora_BP_CreationC_U
 */
@IsTest
public  class XC_Zuora_BP_CreationC_U_TEST {

    @TestSetup
    static void setup(){
        Account a = XC_DF_Account.createResidentialAccounts(1)[0];
        a.IdentityType__c = 'NIF';
        a.IdentityNumber__c = '24699062Y';
        insert a;
    }


    @IsTest
    public static void  getCommodityContractTest(){

        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_ContractOutbound;
        csInt.XC_activeInterface__c = true;
        csInt.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        csInt.XC_Country__c = 'Spain';
        csInt.XC_ServerSystem__c = 'Test';
        insert csInt;

        XC_CS001_InterfaceConfiguration__c csInt2 = new XC_CS001_InterfaceConfiguration__c();
        csInt2.Name = Label.XC_CL_ReadAccountCommoditySpain;
        csInt2.XC_activeInterface__c = false;
        csInt2.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        csInt2.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Account?api_key=etxfrn5spygkanhed78emgg5';
        csInt2.XC_Country__c = 'Spain';
        csInt2.XC_ServerSystem__c = 'Test';
        insert csInt2;

        Account a = [SELECT ID FROM Account LIMIT 1];
        Map<String,Object> params = new Map<String,Object>{
            'documentType'=>'NIF',
            'docCountry'=>'Spain',
            'documentNumber'=>'24699062Y',
            'accountId'=>a.Id
        };

        Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock()); 
        Test.startTest();
            XC_ZuoraBPCreationC_U.getCommodityContract(params);
        Test.stopTest();
    }



}