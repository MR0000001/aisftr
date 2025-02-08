@isTest
public class XC_TR_ConfigurationItem_U_BiProf_TEST {
    static testMethod void hasBillingProfile(){
        test.startTest();
        List<NE__Billing_Profile__c> bilineIte = XC_DF_BillingProfile.createBillingProfileBankTrans(1);
        bilineIte = [select id from NE__Billing_Profile__c limit 1];
        NE__Order__c ord = new NE__Order__c();
        insert ord;
  		List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(2);
        listNew[0].NE__Parent_Order_Item__c=null;
        listNew[0].XC_BillingProfileLineItem__c=null;
       	listNew[1].NE__Parent_Order_Item__c= listNew.get(1).id;
        listNew[1].XC_BillingProfileLineItem__c=bilineIte.get(0).id;
       	NE__OrderItem__c olditem =  listNew[0].clone(true,false,false,false); 
        Map<id,NE__OrderItem__c> mapOld= new Map <id,NE__OrderItem__c>(); 
        mapOld.put(olditem.id,olditem);
   		XC_TR_ConfigurationItem_U_BillingProfile.hasBillingProfile(listNew,mapOld);

        test.stopTest();
    }
       
    	static testMethod void hasBillingProfile1(){
        test.startTest();
        List<NE__Billing_Profile__c> bilineIte = XC_DF_BillingProfile.createBillingProfileBankTrans(2);
        bilineIte = [select id from NE__Billing_Profile__c limit 1];
        NE__Order__c ord = new NE__Order__c();
        insert ord;
  		List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(2);
        listNew[1].NE__Parent_Order_Item__c=listNew.get(0).id;
        listNew[0].NE__Parent_Order_Item__c= null;
        listNew[0].XC_BillingProfileLineItem__c=bilineIte.get(0).id;
        NE__OrderItem__c olditem =  listNew[0].clone(true,false,false,false);
        Map<id,NE__OrderItem__c> mapOld= new Map <id,NE__OrderItem__c>(); 
        mapOld.put(olditem.id,olditem);   
        XC_TR_ConfigurationItem_U_BillingProfile.hasBillingProfile(listNew,mapOld);       
        test.stopTest();
    }
    
      static testMethod void hasBillingProfileInsert()
      {
        test.startTest();
        List<NE__Billing_Profile__c> bilineIte = XC_DF_BillingProfile.createBillingProfileBankTrans(1);
        bilineIte = [select id from NE__Billing_Profile__c limit 1];
        NE__Order__c ord = new NE__Order__c() ;
        insert ord;
  		List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(1);
        listNew[0].XC_BillingProfileLineItem__c=bilineIte.get(0).Id;
        listNew[0].NE__Parent_Order_Item__c=null;
        listNew[0].XC_HasBillingProfile__c=true;
        //insert listNew;
        XC_TR_ConfigurationItem_U_BillingProfile.hasBillingProfileInsert(listNew);
      
        test.stopTest();
      }  
    static testMethod void hasBillingProfileInsert1()
      {
        test.startTest();
        List<NE__Billing_Profile__c> bilineIte = XC_DF_BillingProfile.createBillingProfileBankTrans(1);
        bilineIte = [select id from NE__Billing_Profile__c limit 1];
        NE__Order__c ord = new NE__Order__c() ;
        insert ord;
  		List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(2);
        //listNew[0].XC_BillingProfileLineItem__c=bilineIte.get(0).Id;
        listNew[0].NE__Parent_Order_Item__c=listNew.get(0).id;
        listNew[1].XC_HasBillingProfile__c=true;
        XC_TR_ConfigurationItem_U_BillingProfile.hasBillingProfileInsert(listNew);
      
        test.stopTest();
      }  
    
   	 static testMethod void billingProfileComplexProduct()
     {
         test.startTest();
        List<NE__Billing_Profile__c> bilineIte1 = XC_DF_BillingProfile.createBillingProfileBankTrans(2);
        bilineIte1[0].NE__Payment__c= bilineIte1.get(0).Id;	
        //insert bilineIte1;
        List<XC_BillingProfileLineItem__c>  bilineIte = [select Id,XC_BillingProfile__c,XC_PaymentMethod__c from XC_BillingProfileLineItem__c limit 2];
        bilineIte[0].XC_BillingProfile__c=bilineIte1.get(0).Id;       
  		List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(2);
     	list<Ne__Order__c> ord =[select id, XC_Segment__c from Ne__order__c limit 1]; 
        ord.get(0).XC_Segment__c = 'B2B';
        update ord;
        listNew[0].XC_BillingModel__c='One Shot';
        listNew[0].XC_PaymentMethod__c=bilineIte.get(0).XC_PaymentMethod__c; 
		listNew[1].XC_BillingModel__c='One Shot';
        listNew[1].XC_PaymentMethod__c=bilineIte.get(0).XC_PaymentMethod__c;
        listNew[0].Ne__OrderId__c=ord.get(0).Id;        
        listNew[0].XC_BillingProfileLineItem__c=bilineIte.get(0).Id;
        listNew[0].NE__Parent_Order_Item__c=null;
        listNew[1].XC_BillingProfileLineItem__c=bilineIte.get(1).Id;
        insert listNew;
        listNew=[select id,XC_Segment__c,XC_BillingProfileLineItem__c,NE__Parent_Order_Item__c,NE__Root_Order_Item__c from NE__OrderItem__c limit 2];
		System.debug('ord1' + listNew[0]);
		System.debug('ord1' + listNew[1]);
        System.debug('ord1' + listNew[0].NE__Parent_Order_Item__c);
        
        Map<id,NE__OrderItem__c> mapOld= new Map <id,NE__OrderItem__c>();
        mapOld.put(listNew.get(0).id,listNew.get(1));
        Map<id,NE__OrderItem__c> mapNew= new Map <id,NE__OrderItem__c>();
        mapNew.put(listNew.get(0).id,listNew.get(0));
        
        
      	XC_TR_ConfigurationItem_U_BillingProfile.billingProfileComplexProduct(mapNew,mapOld); 
        test.stopTest();
      }  
         
     static testMethod void setPartnerAccount ()
      {
        test.startTest();
  		List<Account> acc = XC_DF_Account.createCondominiumAccounts(1);
        insert acc;
        List <Contact> cont = XC_DF_Contact.createCondominiumContacts(acc);
       	cont[0].AccountId=acc.get(0).id;
        insert cont; 
        NE__Order__c ord = new NE__Order__c();
        insert ord;
  		List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(1);
        insert listNew;
        listNew[0].Ne__OrderId__c=ord.Id;
        update listNew;
        ord.XC_Segment__c='B2B';
		update ord;
        User u = XC_DF_User.createCommunityUser(cont.get(0));
        listNew = [Select id, XC_Segment__c,NE__Billing_Account__c, NE__Root_Order_Item__c From NE__OrderItem__c limit 1 ];
        insert u;
		system.runAs(u){
       			 XC_TR_ConfigurationItem_U_BillingProfile.setPartnerAccount(listNew);
          }
        test.stopTest();
      }  

}