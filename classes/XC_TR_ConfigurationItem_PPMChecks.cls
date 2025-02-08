/**
 * The Class XC_TR_ConfigurationItem_PPMChecks .
 * @author Nicola Arrigo - narrrigo@deloitte.it
 * @date Creation 18/05/2020
 * @description XC_TR_ConfigurationItem_PPMChecks – Class to make some Checks for Configuration Items on Provisioning activities 
 */
public with sharing class XC_TR_ConfigurationItem_PPMChecks {
    /**
     * @author Nicola Arrigo - narrigo@deloitte.it 
     * @description method to check if a project template is on Configuration item
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkProjectTemplate( List<NE__OrderItem__c> listNew,Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
       List<id> orderId=new List<id>();
       //Map<id,boolean> hasProjectTemplateMap=new Map<id,boolean>();
     for(NE__OrderItem__c orderItem:mapNew.values()){
       if(mapOld.get(orderItem.id).XC_Project_Template__c!=mapNew.get(orderItem.id).XC_Project_Template__c){
         orderId.add(orderItem.NE__OrderId__c);
       }
     }
     if(!orderId.isEmpty()){
     List<NE__Order__c> listConfs=[select id, XC_hasProjectTemplate__c,
                                  (select id,XC_Project_Template__c from NE__Order_Items__r
                                  where XC_Project_Template__c!=null)
                                  from NE__Order__c where id IN:orderId
                                  ];
     List<NE__Order__c> listConfigurations= new List<NE__Order__c>() ;
     for(NE__Order__c order:listConfs){
                  if(order.NE__Order_Items__r.size()>0){
                  order.XC_hasProjectTemplate__c=true;
                  }else{
                  order.XC_hasProjectTemplate__c=false;
                  }
           listConfigurations.add(order);	   
     }
     update listConfigurations;
    }
   }
   /**
     * @description method for Legal Entity on Insert Configuration Item
     * @param listNew the list new
     */
	public static void legalEntityConfItemBeforeInsert( List<NE__OrderItem__c> listNew){
        List<id> orderId=new List<id>();
        List<NE__OrderItem__c> orderItemsList=new List<NE__OrderItem__c>();
        for(NE__OrderItem__c conf:listNew){
          if(conf.XC_Segment__c=='B2B' ||
              conf.XC_Segment__c=='B2G'){  
               orderId.add(conf.NE__OrderId__c);
               orderItemsList.add(conf);
            }
        }
        if(orderItemsList.isEmpty()){
          return;
        }
        Map<Id,NE__Order__c> orderMap=new Map<Id,NE__Order__c>( [select id,XC_LegalEntity__c,NE__Type__c
                                                                from NE__Order__c
                                                                where id IN:orderId]);
         for(NE__OrderItem__c conf:orderItemsList){
           conf.XC_LegalEntity__c=orderMap.get(conf.NE__OrderId__c).XC_LegalEntity__c; 
          // conf.XC_ConfigurationType__c=orderMap.get(conf.NE__OrderId__c).NE__Type__c;
         }
       }

    /**
    * @description method for Legal Entity on Insert Configuration Item
    * @param listNew the list new
    */
    public static void updateCommercialParent( List<NE__OrderItem__c> listNew){
        List<id> orderId=new List<id>();
        List<id> parentCommercialId=new List<id>();
        List<NE__OrderItem__c> orderItemsList=new List<NE__OrderItem__c>();
        for(NE__OrderItem__c conf:listNew){
            if((conf.XC_Segment__c=='B2B' || conf.XC_Segment__c=='B2G') && conf.XC_ParentCommercialItem__c!=null){
                orderId.add(conf.NE__OrderId__c);
                parentCommercialId.add(conf.XC_ParentCommercialItem__c);
                orderItemsList.add(conf);
            }
        }
        if(orderItemsList.isEmpty()){
            return;
        }
        Map<Id,NE__Order__c> orderMap=new Map<Id,NE__Order__c>( [select id,XC_LegalEntity__c,NE__Type__c,
        (select id, NE__Item_Code__c from NE__Order_Items__r)
        from NE__Order__c
        where id IN:orderId]);

        Map<Id,NE__OrderItem__c> orderItemMap=new Map<Id,NE__OrderItem__c>( [select id, NE__Item_Code__c from NE__OrderItem__c
        where id IN :parentCommercialId]);
        for(NE__OrderItem__c conf:orderItemsList){
            NE__OrderItem__c oldParent = orderItemMap.get(conf.XC_ParentCommercialItem__c);
            NE__OrderItem__c newParent = null;
            for(NE__OrderItem__c oi : orderMap.get(conf.NE__OrderId__c).NE__Order_Items__r){
                if(oi.NE__Item_Code__c == oldParent.NE__Item_Code__c){
                    newParent = oi;
                    break;
                }
            }
            if(newParent != null){
                conf.XC_ParentCommercialItem__c = newParent.Id;
            }
        }
    }
}