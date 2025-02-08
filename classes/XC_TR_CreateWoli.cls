/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date 06/09/2020
* @description classes.XC_TR_CreateWoli
*/
public with sharing class XC_TR_CreateWoli {
  /**
     * @author Nicola Arrigo - narrigo@deloitte.it
     * @description  creation WOLI related to the Malfunctioning WO 
     * @param mapNew List<WorkOrder>
    */
       public static void createWoli(List<WorkOrder> listNew){
         // List<id> woIdList=new List<id>(); 
         List<WorkOrder>woList=new List<WorkOrder>();
         List<id> woIdList=new List<id>(); 
         List<string>woCountry=new List<string>();
         for(WorkOrder wo:listNew){
               if(wo.XC_WorkTypeCategory__c=='Malfunctioning' &&
			       (wo.XC_Segment__c=='B2B' ||
                    wo.XC_Segment__c=='B2G') &&
                    wo.CaseId!=null
                    ){ 
                     woIdList.add(wo.id);
                     woCountry.add(wo.Country);   
                     woList.add(wo);
                   system.debug('woIdMalfunctioning'+' '+wo.id);
                }
                //woIdList.add(wo.id);
            }
            /*List<WorkOrder>woList=[select id,WorkTypeId from WorkOrder
                                     where id IN:woIdList];*/
            /*woList=[select id,WorkTypeId,AccountId,AssetId,Country,XC_Segment__c
                      from WorkOrder 
                      where id IN:woIdList];*/  
     Map<Id, WorkOrder> mapWo = new Map<Id, WorkOrder>([
                        SELECT Id, WorkTypeId
                        FROM WorkOrder
                        WHERE Id IN:woIdList
]);
            List<XC_WorkOrderActivityPlanItem__c> woActList=[select XC_Comment__c,XC_WorkType__c,XC_CatalogItem__c,XC_RecordType__c,XC_Country__c, XC_BlockName__c,XC_BlockNumber__c,XC_ActivityName__c,XC_ActivityNumber__c, XC_RelatedMeasure__c,XC_Required__c,
                                                     XC_Range__c, XC_Description__c,XC_RepeatEachAsset__c,XC_NumberOfMeasurement__c, XC_MeasurementUnitOne__c, XC_TechnicianResponse__c,XC_ObservationOne__c, XC_ObservationTwo__c, XC_CompletionMode__c, XC_ServiceAffected__c
                                                    FROM XC_WorkOrderActivityPlanItem__c
                                                   WHERE XC_WorkType__c=:'Malfunctioning' and XC_Country__c IN:woCountry
                                                   ORDER BY XC_BlockNumber__c, XC_ActivityNumber__c];  
           //if(woActList.size()>0){
          // recordtype rt=[select id,DeveloperName from RecordType where SobjectType='workorderlineitem' and DeveloperName='XC_ITA_Woli_ManualDialing'];                                          
           Map<WorkOrder,string> mapRTDevName=getRTDevName(woList);
           Map<string,RecordType> mapRT=retrieveRT(mapRTDevName);
           List<WorkOrderLineItem> woliList=new List<WorkOrderLineItem>();                                                                           
           for(WorkOrder wo:woList){
                id woTypeId;
                /* if(mapWo.get(wo.id).WorkTypeId!=null){
                woTypeId= mapWo.get(wo.id).WorkTypeId;
                }*/
                //new Technical Asset woli
                if(mapRTDevName.get(wo)!=null && wo.XC_LegalEntity__c != 'EnelSole'){
                string devNameRT;
                devNameRT=mapRTDevName.get(wo);
                system.debug('rt devName TA For Cycle'+' '+ devNameRT);
                RecordType rtTA=mapRT.get(devNameRT);
                WorkOrderLineItem woliTA= woliTACreation(wo,rtTA,woTypeId);
                woliList.add(woliTA);
                }
                //woliCheckList
                if(woActList.size()>0){
                  List<recordtype> rtList=retrieveRTList(woActList);
                  Map<string,id> mapRTCheckList=mapRecordTpe(rtList);
                  if(!rtList.isEmpty()){
                    for(XC_WorkOrderActivityPlanItem__c woAct:woActList ){
                        WorkOrderLineItem woli = new WorkOrderLineItem();
                        system.debug('rt devName'+' '+woActList[0].XC_RecordType__c);  
                        system.debug('rt devName For Cycle'+' '+woAct.XC_RecordType__c);
                        woli.WorkOrderId = wo.Id;
                      // Id recordTypeId =Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get(woAct.XC_RecordType__c).getRecordTypeId();
                      //  woli.RecordTypeId=rt.id;
                        woli.RecordTypeId=mapRTCheckList.get(woAct.XC_RecordType__c);
                        system.debug('rt woli '+mapRTCheckList.get(woAct.XC_RecordType__c));
                      // woli.WorkTypeId=wo.WorkTypeId;
                        woli.XC_MacroBlocName__c= woAct.XC_BlockName__c; 
                        woli.XC_MacroBlocNumber__c=woAct.XC_BlockNumber__c; 
                        woli.XC_ActivityName__c = woAct.XC_ActivityName__c; 
                        woli.XC_ActivityNumber__c = woAct.XC_ActivityNumber__c;   
                        woli.Description = woAct.XC_Description__c; 
                        woli.XC_ObservationsOne__c = woAct.XC_ObservationOne__c;
                        woli.XC_ObservationsTWO__c = woAct.XC_ObservationTwo__c;
                        woli.XC_CompletionMode__c = woAct.XC_CompletionMode__c;
                        woli.XC_ServiceAffected__c= woAct.XC_ServiceAffected__c;
                        woli.XC_TechnicianResponseForConfiguration__c = woAct.XC_TechnicianResponse__c;
                        woli.XC_NumberOfMeasurement__c   = woAct.XC_NumberOfMeasurement__c;
                        woli.XC_RelatedMeasure__c = woAct.XC_RelatedMeasure__c;
                        woli.XC_MeasurementUnitOne__c = woAct.XC_MeasurementUnitOne__c; 
                        woli.XC_Range__c = woAct.XC_Range__c;
                        woli.XC_Comment__c = woAct.XC_Comment__c;
                        woli.XC_Required__c = woAct.XC_Required__c;
                        woli.XC_WOLIType__c='Activity';
                        woliList.add(woli); 
                    }
                  }
                }
             }
          insert woliList;             
       }
       private static Map<WorkOrder,string> getRTDevName(List<WorkOrder> woList){
        string devName;  
        Map<WorkOrder,string> mapRTDevName=new Map<WorkOrder,string>();
        for(WorkOrder wo:woList){
           /* if(wo.Country=='Italy'){
              if(wo.XC_Segment__c=='B2B'){
                devName='XC_B2B_EnelXItalia_TA_WOLI';
                mapRTDevName.put(wo,devName);   
              }else if(wo.XC_Segment__c=='B2G'){
                devName='XC_B2G_EnelXItalia_TA_WOLI';
                mapRTDevName.put(wo,devName);
              }
            }*/
            system.debug('WoSegment '+wo.XC_Segment__c);
            system.debug('wo '+wo.XC_LegalEntity__c);
            devName='XC_'+wo.XC_Segment__c+'_'+wo.XC_LegalEntity__c+'_'+'TA_WOLI';
            system.debug('RT Developer Name '+devName);
            mapRTDevName.put(wo,devName);
          }
          return  mapRTDevName;  
       }
       private static Map<string,RecordType> retrieveRT( Map<WorkOrder,string> mapRTDevName){
        Map<string,RecordType> mapRT=new  Map<string,RecordType>();
        if(mapRTDevName.values().size()>0){
        List<string> rtDevNameList=mapRTDevName.values();  
        List<RecordType> rtList=[select id,DeveloperName from RecordType
                              where DeveloperName IN:rtDevNameList];
        system.debug('RecordTypeList '+rtList);
         for(RecordType rt:rtList){
          mapRT.put(rt.DeveloperName,rt);
        }
      }  
        system.debug('MapRecordTypeList '+mapRT);
        return mapRT;                      
       }
       private static WorkOrderLineItem woliTACreation(WorkOrder wo, RecordType rtTA,id woTypeId){
        WorkOrderLineItem woli = new WorkOrderLineItem();
        system.debug('woWorkTypeMalfunctioning'+' '+woTypeId);
       // woli.WorkTypeId=woTypeId; 
        woli.RecordTypeId=rtTA.id;
        woli.StartDate=System.now();
        woli.WorkOrderId=wo.id;
        woli.XC_AccountId__c=wo.AccountId;
        woli.XC_WOLIType__c=Label.XC_CL_TechnicalAssetType;
        woli.AssetId=wo.AssetId;
        return woli;
       }  
       private static  List<recordtype> retrieveRTList( List<XC_WorkOrderActivityPlanItem__c> woActList){
        system.debug('enter retrieveRTList'); 
        List<string> devNameRT=new List<string>();
         for(XC_WorkOrderActivityPlanItem__c woAct:woActList){
          devNameRT.add(woAct.XC_RecordType__c);
         }
         List<recordtype> rtList=[select id,DeveloperName from RecordType where SobjectType='workorderlineitem' and DeveloperName IN:devNameRt]; 
         return rtList;
       }
       private static Map<string,id> mapRecordTpe(List<recordtype> rtList){
         Map<string,id>mapRTCheckList=new Map<string,id>();
         for(recordtype rt:rtList){
              mapRTCheckList.put(rt.DeveloperName,rt.id);
         }
         return mapRTCheckList;
       }
}