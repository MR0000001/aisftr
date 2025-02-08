/** 
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 29/10/2020
* @date Modification dd/mm/yyyy
* @description Giic_TR_TransferOrder_UTIL – Utility for Transfer Order                                 
*/  
global without sharing class Giic_TR_TransferOrder_UTIL {
   private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_TransferOrder_UTIL');
    
    /**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date 29/10/2019
* @description setEmailFiled
* @param listNew List<gii__TransferOrder__c>  
*/     
    public static void setEmailFiled(List<gii__TransferOrder__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In setEmailFiled----->>' );
        List<String> toWHIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__TransferToWarehouse__c');
        toWHIds.addAll(XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__FromWarehouse__c')); 
        map<Id,gii__Warehouse__c> whMaps = new  map<Id,gii__Warehouse__c> ([SELECT Id  , giic_ParentWarehouse__c,
                                                                                    giic_ParentWarehouse__r.gii__Account__r.PrimaryEmail__c,
                                                                                    gii__Account__r.PrimaryEmail__c
                                                                            FROM gii__Warehouse__c
                                                                            WHERE Id IN: toWHIds ]); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'whMaps----->>' + whMaps );
        System.debug('whMaps = '+whMaps.values());
        for(gii__TransferOrder__c t : listNew){   
            XC_UTIL_Debug.debug(DEBUGACTIVE,'t ----->>' + t );
                if(whMaps.containskey(t.gii__FromWarehouse__c) && whMaps.get(t.gii__FromWarehouse__c).giic_ParentWarehouse__c == null){
                    t.giic_Email3PL__c = whMaps.get(t.gii__FromWarehouse__c).gii__Account__r.PrimaryEmail__c;
                }else if(whMaps.containskey(t.gii__TransferToWarehouse__c)  && whMaps.get(t.gii__TransferToWarehouse__c).giic_ParentWarehouse__c == null){  t.giic_Email3PL__c = whMaps.get(t.gii__TransferToWarehouse__c).gii__Account__r.PrimaryEmail__c;
                }else{ t.giic_Email3PL__c = whMaps.get(t.gii__FromWarehouse__c).giic_ParentWarehouse__r.gii__Account__r.PrimaryEmail__c;
                }
            
        }
    }
    
    
    /**
* @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
* @date 17/11/2020
* @description set goods_not_available_in_warehouse to true on WO if TO has SO lookup populated
* @param listNew List<gii__TransferOrder__c>  
*/

    public static void setGoodsNotAvailable(List<gii__TransferOrder__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In setGoodsNotAvailable----->>' );
		list<WorkOrder> woList = new list<WorkOrder>();
        list<string> soIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'giic_SalesOrder__c');
        map<id, gii__SalesOrder__c> soMap = new map<id, gii__SalesOrder__c>([SELECT id, giic_WorkOrder__c 
                                                                             FROM gii__SalesOrder__c 
                                                                             WHERE id IN: soIds]) ;
          
        for(gii__SalesOrder__c so : soMap.values()){
            if (so.giic_WorkOrder__c != null){
                WorkOrder wo = new WorkOrder(id = so.giic_WorkOrder__c , XC_GoodsNotAvailableInWarehouse__c = true );
                woList.add(wo);
            }
        }
        xc_util_dml.updateRecords(woList);
    }
    
}