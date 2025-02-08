/**
 * @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
 * @date Creation 15/05/2019
 * @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
 * @description XC_LCC102_OrderPayment_Test 
 */
@isTest
public class XC_LCC102_OrderPayment_Test {

 /**
  * @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
  * @description  Method to test getListConfItem
  */
 @isTest
 static void getListConfItemTest() {

  insert XC_DF_OneOrg.createOneOrg('Spain');
  Test.startTest();
  NE__Order__c order = new NE__Order__c();

  Account a = new Account(Name = 'Test');
  a.PrimaryEmail__c = 'test@test.it';
  insert a;
  
//   NE__Order__c ord = new NE__Order__c();
//   ord.XC_LegalEntity__c = 'EnelXItalia';
//   ord.XC_Segment__c = 'B2C';
//   insert ord;

  NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
  NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__Account__c= ord.NE__AccountId__c,NE__OrderId__c = ord.id, NE__Qty__c = 2, XC_BillingModel__c = 'One Shot', XC_IsAProduct__c = true);
  insert ordItem;
  NE__OrderItem__c ordItem2 = new NE__OrderItem__c(NE__Account__c= ord.NE__AccountId__c,NE__OrderId__c = ord.id, NE__Qty__c = 1,XC_BillingModel__c = 'One Shot', XC_IsAProduct__c = true);
  insert ordItem2;
  String s = XC_LCC102_OrderPayment.getListConfItem(ord.id);
  
  System.assert(s != null);
  Test.stopTest();


 }
    
/*     @isTest
 static void getListConfItemTest2() {

  insert XC_DF_OneOrg.createOneOrg('Spain');
  Test.startTest();
//   NE__Order__c ord = new NE__Order__c();
//   ord.XC_LegalEntity__c = 'EnelXItalia';
//   ord.XC_Segment__c = 'B2C';
//   insert ord;

  NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
  ord.XC_Segment__c='B2B';
     update ord;
  NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__Account__c= ord.NE__AccountId__c,NE__OrderId__c = ord.id, NE__Qty__c = 2,  XC_IsAProduct__c = true);
  insert ordItem;
  NE__OrderItem__c ordItem2 = new NE__OrderItem__c(NE__Account__c= ord.NE__AccountId__c,NE__OrderId__c = ord.id, NE__Qty__c = 1, XC_IsAProduct__c = true);
  insert ordItem2;
  String s = XC_LCC102_OrderPayment.getListConfItem(ord.id);
  System.assert(s != null);
  Test.stopTest();


 } */

 @IsTest
 static void methodTestcheckBillingAccount(){

   List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
   insert accs;

   List<XC_Address__c>  listOfAddress = XC_DF_Address.createAddress(accs);
   listOfAddress[0].XC_BillingAddress__c = true;
   listOfAddress[0].XC_DeliveryAddress__c = true;
   listOfAddress[0].XC_InstallationAddress__c = true;
   insert listOfAddress;

   List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1,false);
   opps[0].AccountId = accs[0].id;
   insert opps;

   NE__Order__c o = XC_DF_Order.createOrderWithAddress('InOrder', listOfAddress[0].Id, accs[0].Id, opps[0].Id);   

   Test.startTest();
   Boolean isBillingAccount = XC_LCC102_OrderPayment.checkBillingAccount(o.Id);
   Test.stopTest();

  /*  List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
   accs[0].Name = 'Enel X Mobility SRL';
   insert accs; */

  /*  List<XC_Address__c>  listOfAddress = XC_DF_Address.createAddress(accs);
   listOfAddress[0].XC_BillingAddress__c = true;
   listOfAddress[0].XC_DeliveryAddress__c = true;
   listOfAddress[0].XC_InstallationAddress__c = true;
   insert listOfAddress;  */

   /* List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1,false);
   //Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Spain').getRecordTypeId();
   opps[0].AccountId = accs[0].id;
   opps[0].XC_LegalEntity__c = 'EnelXMobilityItalia';
   opps[0].XC_Billing_Account__c = accs[0].id;
   //opps[0].recordTypeId = recordTypeId;
   
   insert opps;

   NE__Order__c o = XC_DF_Order.createOrderWithAddress('InOrder', addressToInsert.Id, accs[0].Id, opps[0].Id);

   Test.startTest();
   Boolean isBillingAccount = XC_LCC102_OrderPayment.checkBillingAccount(o.Id);
   opps[0].XC_Billing_Account__c = null;
   update opps;
   isBillingAccount = XC_LCC102_OrderPayment.checkBillingAccount(o.Id);
   Test.stopTest(); */
    
 }

 /**
  * @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
  * @description  Method to test getListConfItem
  */
 @isTest
 static void populateAddressPickTest() {

  insert XC_DF_OneOrg.createOneOrg('Spain');
  Test.startTest();
  Account a = new Account(Name = 'Test');
  a.PrimaryEmail__c = 'test@test.it';
  insert a;
  XC_Address__c ad = new XC_Address__c(XC_Account__c = a.id, XC_BillingAddress__c = true);
  insert ad;
  NE__Order__c ord = new NE__Order__c(NE__AccountId__c = a.id, NE__BillAccId__c = a.id);
  insert ord;

  List < Map < String, String >> plist = new List < Map < String, String >> ();
  XC_LCC102_OrderPayment.BillingAddressWrapper wrap = XC_LCC102_OrderPayment.populateAddressPick(ord.id);
  Test.stopTest();


 }

 @isTest
 static void retrieveBillingProfileTest() {


  insert XC_DF_OneOrg.createOneOrg('Spain');
  Test.startTest();

  Account a = new Account(Name = 'Test');
  a.PrimaryEmail__c = 'test@test.it';
  insert a;
  XC_Address__c ad = new XC_Address__c(XC_Account__c = a.id, XC_BillingAddress__c = true);
  insert ad;
  NE__Billing_Profile__c bp = new NE__Billing_Profile__c(NE__Account__c = a.id);
  insert bp;
  NE__Order__c ord = new NE__Order__c(NE__AccountId__c = a.id);
  insert ord;

  List < NE__Billing_Profile__c > plist = XC_LCC102_OrderPayment.retrieveBillingProfile(ord.id);
  System.assert(!plist.isEmpty());
  Test.stopTest();


 }

 /**
  * @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
  * @description  Method to test getListConfItem
  */
 @isTest
 static void updateConfItemTest() {

  insert XC_DF_OneOrg.createOneOrg('Spain');
  Test.startTest();
  Account a = new Account(Name = 'Test',XC_Country__c = 'Italy');
  a.PrimaryEmail__c = 'test@test.it';
  a.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
  insert a;
  a.XC_Segment__c = 'B2B';
  update a;
  XC_Address__c ad = new XC_Address__c(XC_Account__c = a.id, XC_BillingAddress__c = true);
  insert ad;
  Contact c=new Contact( XC_ContactDocumentNumber__c='Test',
            RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId(),
            FirstName = 'Test contact' +  Math.random(),
            LastName = 'Test contact' +  Math.random(),
            Email = 'test_soho' + Math.random() + '@email.com',
            AccountId = a.Id,
            XC_CountryLegalEntity__c = 'SPAIN',
            XC_SkipTriggerIndividual__c = true, 
            XC_MainLegalEntity__c = 'EndesaX',
            XC_GiveDataToNew__c = 'Yes',
            XC_PrimaryContact__c = TRUE);
  insert c;

  NE__Order__c ord = new NE__Order__c(NE__AccountId__c = a.id);
  insert ord;
  NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__OrderId__c = ord.id, NE__Qty__c = 2, XC_BillingModel__c = 'One Shot', XC_PaymentMethod__c ='Direct Debt',NE__Account__c = a.id);
  insert ordItem;

  NE__Billing_Profile__c bp = new NE__Billing_Profile__c(NE__Account__c = a.Id);
  insert bp;
  XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c = bp.Id);
  insert bpli;


 

  List < String > values = new List < String > {
   'Direct Debt',
   String.valueOf(bpli.id),
   ''
  };
  Map < String, List < String >> confBillingMap = new Map < String, List < String >> ();
  confBillingMap.put(ordItem.Id, values);
  XC_UTIL_ResultWrapper wr = XC_LCC102_OrderPayment.updateConfItem(confBillingMap, ord.Id, ad.Id);
  System.assert(wr != null);
  Test.stopTest();


 }

 @isTest
 static void getSoldToAddressTest(){
    insert XC_DF_OneOrg.createOneOrg('Spain');

    Test.startTest();
    Account a = new Account(Name = 'Test');
    a.PrimaryEmail__c = 'test@test.it';
    insert a;
    XC_Address__c ad = new XC_Address__c(XC_Account__c = a.id, XC_BillingAddress__c = true);
    insert ad;
    NE__Order__c ord = new NE__Order__c(NE__AccountId__c = a.id,XC_DeliveryAddress__c = ad.Id);
    insert ord;
    NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__OrderId__c = ord.id, NE__Qty__c = 2, XC_BillingModel__c = 'One Shot');
    insert ordItem;
    NE__Billing_Profile__c bp = new NE__Billing_Profile__c(NE__Account__c = a.Id);
    insert bp;
    XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c = bp.Id);
    insert bpli;
    XC_LCC102_OrderPayment.getSoldToAddress(ord.Id);
    Test.stopTest();
 }

 @isTest
 static void newPersonalDocumentTest(){
         insert XC_DF_OneOrg.createOneOrg('Spain');

    Test.startTest();
    Account a = new Account(Name = 'Test');
    a.PrimaryEmail__c = 'test@test.it';
    insert a;
    XC_Address__c ad = new XC_Address__c(XC_Account__c = a.id, XC_BillingAddress__c = true);
    insert ad;
    NE__Order__c ord = new NE__Order__c(NE__AccountId__c = a.id,XC_DeliveryAddress__c = ad.Id);
    insert ord;
    NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__OrderId__c = ord.id, NE__Qty__c = 2, XC_BillingModel__c = 'One Shot');
    insert ordItem;
    NE__Billing_Profile__c bp = new NE__Billing_Profile__c(NE__Account__c = a.Id);
    insert bp;
    XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c = bp.Id);
    insert bpli;
    String docStringVal = '{' + '"docCountry"' + ':' + '"Spain"' + ',' + '"docNumber"' + ':' + '"123456791010"' + ',' + '"docType"' + ':' +'"Passport"' + '}';
    XC_LCC102_OrderPayment.newPersonalDocument(ord.Id, docStringVal);

    Test.stopTest();
 }

  @isTest
 static void updateConfItemTestTechProduct() {

  insert XC_DF_OneOrg.createOneOrg('Spain');
  Test.startTest();
  Account a = new Account(Name = 'Test');
  a.PrimaryEmail__c = 'test@test.it';
  insert a;
  XC_Address__c ad = new XC_Address__c(XC_Account__c = a.id, XC_BillingAddress__c = true);
  insert ad;
  NE__Order__c ord = new NE__Order__c(NE__AccountId__c = a.id);
  insert ord;
  NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__OrderId__c = ord.id, NE__Qty__c = 2, XC_BillingModel__c = 'One Shot',XC_Product_Type__c = Label.XC_CL_Technical);
  insert ordItem;

  NE__Billing_Profile__c bp = new NE__Billing_Profile__c(NE__Account__c = a.Id);
  insert bp;
  XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c = bp.Id);
  insert bpli;


  List < String > values = new List < String > {
   'Credit Card',
   String.valueOf(bpli.id),
   ''
  };
  Map < String, List < String >> confBillingMap = new Map < String, List < String >> ();
  confBillingMap.put(ordItem.Id, values);
  XC_UTIL_ResultWrapper wr = XC_LCC102_OrderPayment.updateConfItem(confBillingMap, ord.Id, ad.Id);
  System.assert(wr != null);
  Test.stopTest();


 }

 @isTest
 static void getPaymentMethodsPicklist(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        XC_LCC102_OrderPayment.getPaymentMethodsPicklist('EndesaX');
    Test.stopTest();
 }

 @isTest
 static void checkIfCASurveyHasToBeExecuted_TEST(){
   NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
     ord.XC_LegalEntity__c= 'EndesaX';
     update ord;
     NE__OrderItem__c ordItemBundle = new NE__OrderItem__c(NE__OrderId__c = ord.id, NE__Qty__c = 2, XC_BillingModel__c = 'One Shot', XC_IsAProduct__c = true, XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive, XC_CreditAssignmentSurvey__c ='test');
   insert ordItemBundle;
   NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__OrderId__c = ord.id, NE__Qty__c = 2, XC_BillingModel__c = 'One Shot', XC_IsAProduct__c = true, XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive, XC_CreditAssignmentSurvey__c ='test', NE__Bundle_Configuration__c = ordItemBundle.id);
   insert ordItem;

   Test.startTest();
      XC_LCC102_OrderPayment.checkIfCASurveyHasToBeExecuted(ord.Id);
   Test.stopTest();
 }

 @isTest
 static void getSearchLegendaText_TEST(){
   NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
   // insert ord;
   NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__OrderId__c = ord.id, NE__Qty__c = 2, XC_BillingModel__c = 'One Shot', XC_IsAProduct__c = true);
   insert ordItem;

   Test.startTest();
      XC_LCC102_OrderPayment.getSearchLegendaText(ord.Id);
   Test.stopTest();
 }

 @isTest
 static void isBillToPartnerTEST(){

   NE__Order__c ord = XC_DF_Order.createOrder('InOrder');

   Test.startTest();
      Account a = new Account(Name = 'Test');
      a.PrimaryEmail__c = 'test@test.it';
      insert a;
      ord.NE__BillAccId__c = a.id;
      update ord;
      XC_LCC102_OrderPayment.isBillToPartner(ord.Id);
   Test.stopTest();

 }
 @isTest
static void managebundleTEST(){
   insert XC_DF_OneOrg.createOneOrg('Spain');
  Test.startTest();
  List<NE__OrderItem__c> ordItemnew = new List<NE__OrderItem__c>();
   Account a = new Account(Name = 'Test');
  a.PrimaryEmail__c = 'test@test.it';
  insert a;
  XC_Address__c ad = new XC_Address__c(XC_Account__c = a.id, XC_BillingAddress__c = true);
  insert ad;
  NE__Order__c ord = new NE__Order__c(NE__AccountId__c = a.id);
  insert ord;
  
  NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__OrderId__c = ord.id, NE__Qty__c = 2, XC_BillingModel__c = 'One Shot',XC_Product_Type__c = 'Bundle');
  insert ordItem;
  NE__OrderItem__c ordItem1= new NE__OrderItem__c(NE__Bundle_Configuration__c=ordItem.Id,NE__OrderId__c = ord.id, NE__Qty__c = 2, XC_BillingModel__c = 'One Shot',XC_Product_Type__c = 'Bundle');
  insert ordItem1;
  ordItemnew.add(ordItem);
  ordItemnew.add(ordItem1);
  XC_LCC102_OrderPayment.manageBundle(ordItemnew);
   Test.stopTest();
}
@isTest
static void updateConfItemTestCommodityBill() {
 insert XC_DF_OneOrg.createOneOrg('Spain');
 Test.startTest();
 Account a = new Account(Name = 'Test');
 a.PrimaryEmail__c = 'test@test.it';
 insert a;
 XC_Address__c ad = new XC_Address__c(XC_Account__c = a.id, XC_BillingAddress__c = true);
 insert ad;
 NE__Order__c ord = new NE__Order__c(NE__AccountId__c = a.id,XC_Segment__c='B2C');
 insert ord;
 NE__OrderItem__c ordItem = new NE__OrderItem__c(NE__OrderId__c = ord.id, NE__Qty__c = 2, XC_BillingModel__c = 'One Shot',XC_Product_Type__c = Label.XC_CL_Technical,XC_Country__c = 'Brazil',XC_PaymentMethod__c=Constants.ORDER_PAYMENT_METHOD_TYPE);
 insert ordItem;

 NE__Billing_Profile__c bp = new NE__Billing_Profile__c(NE__Account__c = a.Id);
 insert bp;
 XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c = bp.Id);
 insert bpli;


 List < String > values = new List < String > {
   Constants.ORDER_PAYMENT_METHOD_TYPE,
  String.valueOf(bpli.id),
  ''
 };
 Map < String, List < String >> confBillingMap = new Map < String, List < String >> ();
 confBillingMap.put(ordItem.Id, values);
 XC_UTIL_ResultWrapper wr = XC_LCC102_OrderPayment.updateConfItem(confBillingMap, ord.Id, ad.Id);
 System.assert(wr != null);
 Test.stopTest();

}




}