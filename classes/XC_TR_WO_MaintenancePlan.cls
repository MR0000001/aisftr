public with sharing class XC_TR_WO_MaintenancePlan {
    public static void createWO(List<WorkOrder> listNew){
        List<id> PlannedListId=new List<id>();
        List<WorkOrder> WoList=new List<WorkOrder>();
        for(WorkOrder wo:listNew){
           if(wo.MaintenancePlanId!=null
               /*&&
               (wo.XC_Segment__c=='B2B'||
               wo.XC_Segment__c=='B2G')*/){
            PlannedListId.add(wo.MaintenancePlanId);
            system.debug('Planned Maintenance not null'+' '+wo.MaintenancePlanId); 
            WoList.add(wo);
          }   
        }
        Map<id,MaintenancePlan> mapMaintenancePlan=new Map<id,MaintenancePlan> ([select id,XC_Address__c,XC_LegalEntity__c,
                                                                                      XC_Address__r.XC_City__c,XC_Segment__c,
                                                                                       XC_Address__r.XC_AddressCountry__c,WorkTypeId,
                                                                                       WorkType.Name
                                                                                     from MaintenancePlan
                                                                                     where id IN:PlannedListId]);
   /* List<WorkOrder> WoList=[select id,MaintenancePlan.XC_LegalEntity__c,MaintenancePlan.XC_Address__c,XC_WorkTypeCategory__c,
                            XC_LegalEntity__c,XC_Address__c,City, Country,MaintenancePlan.XC_Address__r.XC_City__c,MaintenancePlanId,
                             XC_Segment__c,MaintenancePlan.XC_Segment__c ,WorkTypeId,AssetId,MaintenancePlan.WorkTypeId         
                             from WorkOrder
                             where (MaintenancePlanId!=null and 
                                     (MaintenancePlan.XC_Segment__c='B2B' OR MaintenancePlan.XC_Segment__c='B2G')
                                     )];*/

      List<XC_CM_LegalEntity_Configuration__mdt> legalEntityConfigurationList=[select id,XC_LegalEntity__c, XC_Stream__c, XC_RecordType_WorkOrder__c 
                                                                               from XC_CM_LegalEntity_Configuration__mdt 
                                                                               where (XC_RecordType_WorkOrder__c!=null and 
                                                                                      XC_OrgId__c=:UserInfo.getOrganizationId())
                                                                                ];    
        Map<string,string> mapDevName= getMap(legalEntityConfigurationList);
        List<RecordType> woRT=[select id,DeveloperName from RecordType 
                               where (SobjectType='WorkOrder' and 
                                      DeveloperName IN:mapDevName.values())];
        Map<string,string> getRTId=getRTId(woRT);
         for(WorkOrder wo:woList){
          wo.XC_WorkTypeCategory__c='Planned Maintenance';
          if(String.isBlank(wo.AssetId)){
            wo.WorkTypeId=mapMaintenancePlan.get(wo.MaintenancePlanId).WorkTypeId;
            wo.XC_WorkTypeLabel__c=mapMaintenancePlan.get(wo.MaintenancePlanId).WorkType.Name;
          } 
          wo.XC_LegalEntity__c=mapMaintenancePlan.get(wo.MaintenancePlanId).XC_LegalEntity__c;
          system.debug('LegalEntity'+' '+wo.XC_LegalEntity__c);
          wo.City=mapMaintenancePlan.get(wo.MaintenancePlanId).XC_Address__r.XC_City__c;
          wo.Country=mapMaintenancePlan.get(wo.MaintenancePlanId).XC_Address__r.XC_AddressCountry__c;
          wo.XC_Address__c=mapMaintenancePlan.get(wo.MaintenancePlanId).XC_Address__c;
          wo.XC_Segment__c=mapMaintenancePlan.get(wo.MaintenancePlanId).XC_Segment__c; 
          string key=wo.XC_LegalEntity__c+'_'+wo.XC_Segment__c;
          string devName= mapDevName.get(key);
          string rtId=getRTId.get(devName);
          wo.RecordTypeId=rtId;
        }
    }
    public static Map<string,string> getMap(List<XC_CM_LegalEntity_Configuration__mdt> legalEntityConfigurationList){
     Map<string,string> mapDevName=new Map<string,string>();
     for(XC_CM_LegalEntity_Configuration__mdt cm:legalEntityConfigurationList){
        string key=cm.XC_LegalEntity__c+'_'+cm.XC_Stream__c;
        string devName=cm.XC_RecordType_WorkOrder__c;
        mapDevName.put(key,devName);
        //mapDevName.put(cm.XC_LegalEntity__c+'_'+cm.XC_Stream__c,cm.XC_RecordType_WorkOrder__c);
     }
     return mapDevName;
   }
   public static Map<string,string> getRTId(List<RecordType> woRT){
    Map<string,string> getWoRTId=new Map<string,string>();  
    for(RecordType rt:woRT){
        getWoRTId.put(rt.DeveloperName,rt.id);
       }
     return getWoRTID;  
   }
}