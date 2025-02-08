/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com    
* @date Creation 05/09/2019
* @date Modification 
* @description XC_LCC103_ConfItemEditForm_TEST 
*/  
@isTest
public class XC_LCC103_ConfItemEditForm_TEST {
    
/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com 
* @description  Method to test checkPrepayment
*/
@isTest
static  void checkPrepaymentTest1(){

     insert XC_DF_OneOrg.createOneOrg('Spain');
     Test.startTest();
    
     List<NE__OrderItem__c> o = XC_DF_OrderItem.createOrderItems(1);
     insert o;
     XC_LCC103_ConfItemEditForm.checkPrepayment(o[0].id);
     Test.stopTest();
    
    
}

/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com
* @description  Method to test checkPrepayment
*/
@isTest
static void checkPrepaymentTest2(){

     insert XC_DF_OneOrg.createOneOrg('Spain');
     Test.startTest();
    
     List<NE__OrderItem__c> o = XC_DF_OrderItem.createOrderItems(1);
     
     insert o;
     NE__Order_Item_Attribute__c oa = new NE__Order_Item_Attribute__c();
     oa.Name = 'PrePayment';
     oa.NE__Value__c='Yes';
     oa.NE__Order_Item__c = o[0].id;
     insert oa;
     XC_LCC103_ConfItemEditForm.checkPrepayment(o[0].id);
     Test.stopTest();
    
    
}

@isTest
static void checkSohoWithDifferentSohoTypeTest(){

     insert XC_DF_OneOrg.createOneOrg('Spain');
     Test.startTest();
          Account sohoAccount = XC_DF_Account.createSohoAccounts(1)[0];
          sohoAccount.XC_SohoType__c = 'Associated Companies';
          insert sohoAccount;

          XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
          List<NE__OrderItem__c> ois = XC_DF_OrderItem.createOrderItems(1);
          ois[0].NE__Account__c = sohoAccount.Id;
          NE__OrderItem__c oi = ois[0];
          insert oi;
    	 
          NE__Order_Item_Attribute__c oa = new NE__Order_Item_Attribute__c();
          oa.Name = 'PrePayment';
          oa.NE__Value__c='Yes';
          oa.NE__Order_Item__c = oi.id;
          insert oa;
          XC_LCC103_ConfItemEditForm.checkSohoWithDifferentSohoType(oi, new List<String>{'Credit Card','Commodity Bill','Direct Debt'}, wr);
		  XC_LCC103_ConfItemEditForm.checkImpliedInterest(oi.id);	

     Test.stopTest();

}

@isTest
static void checkOrderStatusTest(){

     insert XC_DF_OneOrg.createOneOrg('Spain');
     Test.startTest();
          Account sohoAccount = XC_DF_Account.createSohoAccounts(1)[0];
          sohoAccount.XC_SohoType__c = 'Associated Companies';
          insert sohoAccount;

          XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
          List<NE__OrderItem__c> ois = XC_DF_OrderItem.createOrderItems(1);
          ois.get(0).NE__Account__c = sohoAccount.Id;
        //  NE__OrderItem__c oi =  ois[0];
        //  insert oi;ù
          insert ois;
          NE__Order_Item_Attribute__c oa = new NE__Order_Item_Attribute__c();
          oa.Name = 'PrePayment';
          oa.NE__Value__c='Yes';
         // oa.NE__Order_Item__c = oi.id;
          oa.NE__Order_Item__c = ois.get(0).Id;
          insert oa;
          //XC_LCC103_ConfItemEditForm.checkOrderStatus(oi.Id);
          XC_LCC103_ConfItemEditForm.checkOrderStatus(ois.get(0).Id);


     Test.stopTest();
}

     /**
     * @author Elio Adami -elio.adami@accenture.com
     * @description  Method to test checkPartnerCode
     */
     @isTest
     static  void checkPartnerCodeTest1(){
          insert XC_DF_OneOrg.createOneOrg('Spain');
          Test.startTest();
          List<NE__OrderItem__c> o = XC_DF_OrderItem.createOrderItems(1);
          insert o;
          XC_LCC103_ConfItemEditForm.checkPartnerCode(o[0].id);
          Test.stopTest();
     }

     /**
     * @author Elio Adami -elio.adami@accenture.com
     * @description  Method to test checkPartnerCode
     */
     @isTest
     static void checkPartnerCodeTest2(){
          insert XC_DF_OneOrg.createOneOrg('Spain');
          Test.startTest();
    
          List<NE__OrderItem__c> o = XC_DF_OrderItem.createOrderItems(1);
     
          insert o;
          NE__Order_Item_Attribute__c oa = new NE__Order_Item_Attribute__c();
          oa.Name = 'Partner Code';
          oa.NE__Value__c='Yes';
          oa.NE__Order_Item__c = o[0].id;
          insert oa;
          XC_LCC103_ConfItemEditForm.checkPartnerCode(o[0].id);
          XC_LCC103_ConfItemEditForm.getFieldOfAttributes(o[0].id);
          Test.stopTest();
     }
}