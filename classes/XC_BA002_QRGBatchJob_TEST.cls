/**
* @author Tommaso Precania - tommaso.precania@accenture.com
* @date Creation 01/12/2021
* @date Modification 10/12/2021
* @description XC_BA002_QRGBatchJob_TEST – Test class for XC_BA002_QRGBatchJob, XC_BA002_QRGBatchJob_U and XC_SC064_QRGBatchJob
*/
@isTest
public class XC_BA002_QRGBatchJob_TEST {
    @TestSetup
    static void setup()
    {
        insert new XC_CS001_InterfaceConfiguration__c(Name = 'XC_QRBatchJobStatusUpdate', XC_interfaceName__c='QRBatchJobStatusUpdate',XC_activeInterface__c=true,XC_URL_Required__c='http://www.google.com', XC_Stream__c='B2C', XC_ServerSystem__c='Mashery', XC_Country__c='');
        insert new XC_CS_UtilityGlobalValues__c(Name = 'XC_BA002_QRGBatchJob', Value__c='true');
        List<XC_QueuedRequest__c> qrs = new List<XC_QueuedRequest__c>();
        for(Integer i=0;i<100;i++)
        {
            qrs.add(new XC_QueuedRequest__c(XC_ClientSystem__c='ThirdPartyB2C', XC_Status__c='In Error', XC_BulkJobId__c=('TEST_CASE_'+Math.mod(i,5)), XC_CallbackRequested__c=false, XC_RequestBody__c = '{"Account":{"AccountType":"Residential","FirstName":"MIGUEL ANGEL","LastName":"RAMIREZ","MainPhonePrefix":"+57","MainPhone":"3011234592","PrimaryEmail":"josemove67@gmail.com"},"Identity":[{"Country":"COLOMBIA","IdentityType":"CC","IdentityNumber":"1014237801"}],"Contact":[{"LastName":"RAMIREZ","FirstName":"MIGUEL ANGEL","PrimaryContact":true,"Email":"testingstesbd@yopmail.com","MainPhonePrefix":"+57","MainPhone":"3011234592","PhonePrefix":"+57","Phone":"3011234522","IdentityType":"CC","IdentityNumber":"1014237801","Country":"COLOMBIA","GDPR":{"GiveDataToThirdParties":"N","LegalEntity":[{"LegalEntity":"CODENSA","GiveDataToLegalEntity":"Y","GiveDataForMarketing":"N","GiveDataForProfiling":"Y"}]}}],"Address":[{"StreetType":"Street","Address":"URBANA  005502","StreetNumber":"0","ZipCode":"11001","City":"Bogotá, D.C.","Country":"COLOMBIA","Province":"Bogotá, D.C.","ShippingAddress":true,"InstallationAddress":false,"MunicipalCode":"11001000","MunicipalName":"Bogotá, D.C.","StreetCode":"Bogotá, D.C.","Municipality":"Bogotá, D.C."},{"StreetType":"Street","Address":"URBANA  004565","StreetNumber":"0","ZipCode":"11001","City":"Bogotá, D.C.","Country":"COLOMBIA","Province":"Bogotá, D.C.","BillingAddress":true,"InstallationAddress":false,"MunicipalCode":"11001000","MunicipalName":"Bogotá, D.C.","StreetCode":"Bogotá, D.C.","Municipality":"Bogotá, D.C.","PointOfService":[{"POSType":"Light","POS":"4392939"}]}],"BillingProfile":[{"LegalEntity":"CODENSA","PaymentMethod":"Commodity Bill","InvoicePreferredLanguage":"Colombian Spanish","InvoiceDeliveryPref":"Email","CupsID":"4392939","CommodityContractNum":"15783233"}],"Order":{"LegalEntity":"CODENSA","OrderStatus":"In Progress","Channel":"EnelEnergiaColombia","OrderType":"New","OrderItem":[{"ProdID":"SRPG","Quantity":1,"BaseOneTimeFee":0.0,"BaseRecurringCharge":9000.0,"Attribute":[{"Name":"Payment details:Payment Method","Value":"Monthly","ProductFamilyPropertyID":"a1V1l000000PNaMEAW"},{"Name":"Payment details:Payment type","ProductFamilyPropertyID":"a1V1l000000PNaLEAW"},{"Name":"Payment details:PrePayment","Value":"Yes","ProductFamilyPropertyID":"a1V1l000000PNaOEAW"},{"Name":"Payment details:Valor residual","Value":"Yes","ProductFamilyPropertyID":"a1V1l000000PNaOEAW"},{"Name":"Payment details:Active Promo","Value":"false","ProductFamilyPropertyID":"a1V1l000000PNaPEAW"}]}]}}'));
        }
        insert qrs;

        List<XC_QueuedRequestGroup__c> groups = new List<XC_QueuedRequestGroup__c>();
        for(Integer i=0; i<5; i++)
        {
            groups.add(new XC_QueuedRequestGroup__c(XC_JobId__c=('TEST_CASE_'+i), XC_Status__c='NOT COMPLETED'));
        }
        insert groups;
    }

    static testMethod void checkSchedule(){
        Test.startTest();
        XC_SC064_QRGBatchJob schedBatch = new XC_SC064_QRGBatchJob(45, 50);
        String sch = '0 0 23 * * ?'; 
        System.schedule('TEST_EXECUTION_BATCH', sch, schedBatch); 
        Test.stopTest();
    }
    static testMethod void checkBatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XC_QRBatchJobStatusUpdate_MockGenerator(new Map<String,String>{
            'TEST_CASE_1' => '0',
            'TEST_CASE_2' => '402',
            'TEST_CASE_3' => '404'
        }, new Map<String,String>{
            'TEST_CASE_1' => 'Operation completed successfully',
            'TEST_CASE_2' => 'Error: cannot update BulkJobId',
            'TEST_CASE_3' => 'Error: BulkJobId not found'
        }));
        
        Database.executeBatch(new XC_BA002_QRGBatchJob(45), 100);
        Test.stopTest();
        List<XC_QueuedRequestGroup__c> groups = [SELECT XC_JobId__c, XC_Status__c, XC_ResultMessage__c FROM XC_QueuedRequestGroup__c WHERE XC_JobId__c like 'TEST_CASE_%'];
        for(XC_QueuedRequestGroup__c gr : groups)
        {
            if('TEST_CASE_1'.equalsIgnoreCase(gr.XC_JobId__c)) System.assertEquals('REQUEST SENT', gr.XC_Status__c);
            if('TEST_CASE_2'.equalsIgnoreCase(gr.XC_JobId__c)) System.assertEquals('IN ERROR', gr.XC_Status__c);
            if('TEST_CASE_3'.equalsIgnoreCase(gr.XC_JobId__c)) System.assertEquals('IN ERROR', gr.XC_Status__c);
        }
    }
}