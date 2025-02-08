/**
 *@author Nicola Arrigo - narrigo@deloitte.it 
* @date Creation 07/01/2020
 */
public without sharing class XC_TR_ConfigurationItem_U_BillingProfile {
  /**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 07/01/2020
* @description XC_TR_ConfigurationItem_Handler – Handler for NE__Order__c Trigger
*/
  public static void hasBillingProfile (List<NE__OrderItem__c> listNew,Map<Id, NE__OrderItem__c> mapOld){
      system.debug('@@@@@@@@@@@@@@ hasBillingProfile');
      for(NE__OrderItem__c oi:listNew){
            if(//oi.NE__Parent_Order_Item__c==null &&
               oi.XC_BillingProfileLineItem__c!=null &&
               mapOld.get(oi.id).XC_BillingProfileLineItem__c==null
               ){
              oi.XC_HasBillingProfile__c=true;
            }//NA 2602
              else if(oi.NE__Parent_Order_Item__c!=null &&
                     mapOld.get(oi.id).NE__Parent_Order_Item__c==null){
                      oi.XC_HasBillingProfile__c=true;    
            }
             else{
              system.debug('No Update'); 
            }                   
      }
  }
  /**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 07/01/2020
* @description hasBillingProfileInsert 
*/
  public static void hasBillingProfileInsert (List<NE__OrderItem__c> listNew){
   system.debug('enter hasBillingProfileInsert');
    for(NE__OrderItem__c oi:listNew){
      system.debug('Parent id'+' '+oi.NE__Parent_Order_Item__c);  
              if(
               oi.XC_BillingProfileLineItem__c!=null && oi.NE__Parent_Order_Item__c==null
               ){
                  oi.XC_HasBillingProfile__c=true;
               }
              //NA2702 FOR ConfigurationItem penalty
                else if(oi.NE__Parent_Order_Item__c!=null){                
                system.debug('enter else if'); 
                oi.XC_HasBillingProfile__c=true;
               } 
    }          
  }


/**
* @author Andrea Di Cicco
* @date Creation 07/06/2020
* @description method used to set the billing profile to child order item
* @param mapNew
* @param mapOld
*/
public static void billingProfileComplexProduct (Map<Id, NE__OrderItem__c> mapNew,Map<Id, NE__OrderItem__c> mapOld){
    Map<Id, NE__OrderItem__c> mapFatherOrderItem = new Map<Id, NE__OrderItem__c>();
    List<NE__OrderItem__c> listChildren = new List<NE__OrderItem__c>();
    for(NE__OrderItem__c oi :mapNew.values() ){
      if((oi.XC_Segment__c == 'B2B' || oi.XC_Segment__c == 'B2G') && oi.XC_BillingProfileLineItem__c != null && oi.NE__Root_Order_Item__c == null && mapOld.get(oi.id).XC_BillingProfileLineItem__c != oi.XC_BillingProfileLineItem__c){
        mapFatherOrderItem.put(oi.id, oi);
      }
    }

    if(mapFatherOrderItem.isEmpty()){
      return;
    }
    String technicalItemRT = Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('Technical_Item').getRecordTypeId();
    if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
      listChildren = [SELECT  id, XC_BillingProfileLineItem__c, NE__Parent_Order_Item__c,XC_BillingModel__c, NE__Root_Order_Item__c
                      FROM NE__OrderItem__c 
                      WHERE NE__Root_Order_Item__c   IN : mapFatherOrderItem.keySet()
                      AND RecordTypeId != : technicalItemRT];
    }

    if(listChildren.isEmpty()){
      return;
    }

    for(NE__OrderItem__c oi : listChildren){
      oi.XC_BillingProfileLineItem__c = mapFatherOrderItem.get(oi.NE__Root_Order_Item__c).XC_BillingProfileLineItem__c;
      oi.XC_PaymentMethod__c = mapFatherOrderItem.get(oi.NE__Root_Order_Item__c).XC_PaymentMethod__c;
      oi.XC_BillingModel__c = mapFatherOrderItem.get(oi.NE__Root_Order_Item__c).XC_BillingModel__c;
    }

    update listChildren ;
  }


    /**
     * @author Andrea Di Cicco
     * @date Creation 16/07/2020
     * @description when an opportunity is created, populate fields
     * @param listNew List<Opportunity>
    */
    public static void setPartnerAccount(List<NE__OrderItem__c> listNew){
      String userId = UserInfo.getUserId();
      List<User> sessionUser = new List<User>(); 
      List<NE__OrderItem__c> communityOrderItem = new List<NE__OrderItem__c>();

      /*for(NE__OrderItem__c ordItem : listNew){
          if(ordItem.XC_Segment__c == 'B2B' || ordItem.XC_Segment__c == 'B2G' ){
            communityOrderItem.add(ordItem);
          }
      }

      if(communityOrderItem.isEmpty()){
          return;
      }*/

      if(Schema.sObjectType.User.isAccessible()){
          sessionUser = [Select ContactId, Contact.AccountId, Contact.Account.XC_Account__c, Contact.Account.XC_BillToPartner__c from User where ContactId != null and Contact.AccountId != null and id =: userId];
      }

      if(sessionUser == null || sessionUser.isEmpty()){
          return;
      }
      
      for(NE__OrderItem__c ordItem : listNew ){  
        if(sessionUser.get(0).Contact.Account.XC_BillToPartner__c){
          ordItem.NE__Billing_Account__c   = sessionUser.get(0).Contact.Account.XC_Account__c;
        }
      }

  }
}