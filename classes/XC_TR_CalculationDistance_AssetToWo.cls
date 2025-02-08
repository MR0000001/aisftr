/**
* @author De Blasio Valentina valentina.de.blasio@accenture.com
* @date Creation 22/02/2022
* @description XC_TR_CalculationDistance_AssetToWo – Class for calcolate distance for asset to wo
*/  

public without sharing class XC_TR_CalculationDistance_AssetToWo {

    public static void updateDistanceWo(List<WorkOrder> woList, Map <id,WorkOrder> mapOld){
        List<WorkOrder> woListToBeUpdated=new List<WorkOrder>();
        List<WorkOrder> wroList=[SELECT Id,Longitude, Latitude, AssetId,Asset.Location.Longitude,Asset.Location.Latitude,XC_Distance__c, XC_CheckInMobility__c //DeAv INC000091122500 added field XC_CheckInMobility__c
                                 FROM WorkOrder
                                 WHERE Id IN:woList];
        Double dist;
        Location loc1;
        Location loc2;

        if(!wroList.isEmpty()){
        	for(WorkOrder wor:wroList){                 
                if(wor.XC_CheckInMobility__c==true && wor.AssetId!=null && wor.Longitude!=null && wor.Latitude!=null && wor.Asset.Location.Longitude!=null && wor.Asset.Location.Latitude!=null){ //DeAv INC000091122500 added check on XC_CheckInMobility__c         
                    wor.XC_Longitude__c= String.valueOf(wor.Longitude);   
                    wor.XC_Latitude__c= String.valueOf(wor.Latitude);         
                    loc1 = Location.newInstance(wor.Asset.Location.Latitude,wor.Asset.Location.Longitude);               
                    loc2 = Location.newInstance(wor.Latitude,wor.Longitude);                 
                    dist = (Location.getDistance(loc1,loc2,'km'))*1000;                                                                                                        
                    wor.XC_Distance__c=dist;
                    woListToBeUpdated.add(wor);
                }                             
            }
        }

        //PERFORMANCE IMPROVEMENT - MAY 2022 - GDB
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        if(!woListToBeUpdated.isEmpty() && !Test.isRunningTest()){
            update woListToBeUpdated;
        }
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
    }        
}