@isTest
public class ZuoraWebserviceUtil_TEST {
    @isTest
    static void readFieldSetTest(){
        ZuoraWebserviceUtil.readFieldSet('zqu__Fields_For_Select_Billing_Account','Account');
    }
    
    @isTest
    static void generateFieldsToQueryFromFieldSetTest(){
        ZuoraWebserviceUtil.generateFieldsToQueryFromFieldSet('zqu__Fields_For_Select_Billing_Account','Account');
    }
    
    @isTest
    static void generateAdditionalFieldsTest(){
        Account testAccount = new Account(Name='Account_Name_Test');
        ZuoraWebserviceUtil.generateAdditionalFields('zqu__Fields_For_Select_Billing_Account','Account', testAccount);
    }
    

}