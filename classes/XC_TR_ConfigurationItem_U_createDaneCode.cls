/**
 *@author Nicola Arrigo - narrigo@deloitte.it 
* @date Creation 05/02/2020
 */
public with sharing class XC_TR_ConfigurationItem_U_createDaneCode {
   /**
 *@author Nicola Arrigo - narrigo@deloitte.it 
 *@description createDaneCodeInsert 
@date Creation 05/02/2020
 */
    public static void createDaneCodeInsert( List<NE__OrderItem__c> listNew){
    list<id> orderListId=new list<id>();
    id rtId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('Penalty').getRecordTypeId();
    for(NE__OrderItem__c orderItem:listNew){
        if(orderItem.recordtypeid==rtId){
        orderListId.add(orderItem.NE__OrderId__c);
        }  
    }  
    //retrieve Dane Code
    map<id,string> mapDaneCode=new map<id,string>(); 
    for(NE__Order__c order:[select id,(select id,XC_DaneCode__c  
                                        from  NE__Order_Items__r 
                                        where XC_DaneCode__c!=null 
                                         limit 1 ) 
                                        from NE__Order__c 
                                        where id IN:orderListId]){ 
        for(NE__OrderItem__c orderItem:order.NE__Order_Items__r){
            mapDaneCode.put(order.id,orderItem.XC_DaneCode__c);
        }
     }
    //Update Dane Code
     for (NE__OrderItem__c orderItem:listNew){
        if(mapDaneCode.get(orderItem.NE__OrderId__c)!=null){
            orderItem.XC_DaneCode__c=mapDaneCode.get(orderItem.NE__OrderId__c);
        }
    }
 }
}