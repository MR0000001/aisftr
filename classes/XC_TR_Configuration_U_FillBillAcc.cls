/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttadata.com 
* @date Creation 18/09/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Configuration_U_FillBillAcc – Util class for populate BillAccount if there is a Cost Center on Opportunity
*/

public without sharing class XC_TR_Configuration_U_FillBillAcc { 
    
      public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_FillBillAcc');
    
      public static void populateBillingAccount(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '<---- @205 ENTER IN populateBillingAccount --- ' ); 
        List<NE__Order__c> orderToUpdate = new List<NE__Order__c>();
        Map<Id,Id> oppIdToConfId = new Map<Id,Id>();
        Map<String,String> orderNameToOldConfId = new Map<String,String>();
        for(NE__Order__c ord : listNew){
                oppIdToConfId.put(ord.NE__OptyId__c,ord.Id);
        }
        if(oppIdToConfId.keySet().isEmpty()){       // SS-DDP FIX 19/11/2019
            return;
        }
        List<Opportunity> oppList = new List<Opportunity>([SELECT id, XC_CostCenter__c FROM Opportunity WHERE Id IN: oppIdToConfId.keySet()]);
        for(Opportunity opp : oppList){
            if(opp.XC_CostCenter__c != null){
                orderNameToOldConfId.put(opp.XC_CostCenter__c , oppIdToConfId.get(opp.id));
            }
        }
        if(orderNameToOldConfId.keySet().isEmpty()){    // SS-DDP FIX 19/11/2019
            return;
        }        
        Map<Id,NE__Order__c> newOrderMap = new Map<Id,NE__Order__c>([SELECT Id, Name, NE__BillAccId__c,NE__AccountId__c
                                                                        FROM NE__Order__c WHERE Name IN: orderNameToOldConfId.keySet() ]);
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '<---- @205 mappa nuovi ordini --- '+newOrderMap); 
        for(NE__Order__c order : newOrderMap.values()){
            if(mapNew.get(orderNameToOldConfId.get(order.Name)).Name != order.Name && String.isBlank(mapNew.get(orderNameToOldConfId.get(order.Name)).NE__BillAccId__c)) {
                mapNew.get(orderNameToOldConfId.get(order.Name)).NE__BillAccId__c = order.NE__AccountId__c;   
            }
        }

        
    }
    
    
     public static void checkIfCostCenter(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){
          XC_UTIL_Debug.debug(DEBUGACTIVE, '<---- @205 ENTER IN checkIfCostCenter --- ' ); 
          List<String> fieldList = new List<String>{'NE__BillAccId__c'};
          List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
          if(!listChanged.isEmpty()){
            populateBillAccForCostCenter(listChanged);
          }
         
     }
    
    
    
     public static void populateBillAccForCostCenter(List<NE__Order__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '<---- @205 Enter in populateBillAccForCostCenter --- '); 
       
        List<Id> orderIds = XC_UTIL_Sobject.getIds(listNew);
        List<NE__OrderItem__c> orderItemToUpdate = new List<NE__OrderItem__c>();
        List<NE__Order__c> orderList = [SELECT Id, NE__AccountId__c, NE__BillAccId__c,(SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id IN: orderIds];
        for(NE__Order__c order : orderList){
            
            if(order.NE__AccountId__c!=order.NE__BillAccId__c){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '<---- Found cost center case --- '); 
                
                for(NE__OrderItem__c oi : order.NE__Order_Items__r){
                    oi.NE__Billing_Account__c = order.NE__BillAccId__c;
                    orderItemToUpdate.add(oi);
            }
        } 
         
    } 
         XC_UTIL_Sobject.updateListRecords(orderItemToUpdate);
    }

}