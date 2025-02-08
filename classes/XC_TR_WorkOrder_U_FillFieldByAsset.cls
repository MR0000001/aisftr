/**
* @author: Salvatore Scarpato - salvatore.scarpato@nttdata.com, Marco Rosa - marco.rosa@nttdata.com
* @date  : 17/12/2018
* @description The class populates a work order record according to the linked asset.
*/

public without sharing class XC_TR_WorkOrder_U_FillFieldByAsset {  

    /**
     * @description Fill Fields On WorkOrder by the parent Asset
     * @param listNew the list new
     */
    public static void fillFieldsFromAsset(List<WorkOrder> listNew,boolean isAssetModified){
        List<Id> listAssetId = XC_UTIL_SObject.getListFieldValues(listNew, 'AssetId');
        if(listAssetId.isEmpty()){
            return;
        }
        Map<Id, Asset> mapAsset = new Map<ID, Asset>([
            SELECT Id, AccountId,XC_Address__c,SerialNumber, ContactId, XC_Address__r.XC_Account__c, XC_Address__r.XC_PostalCode__c, XC_Address__r.XC_Address__c,
                NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, XC_Address__r.XC_City__c, XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_AddressProvince__c,
                NE__CatalogItem__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__CatalogItem__r.NE__Product_Name__c, XC_LegalEntity__c, 
                (SELECT Id,XC_WorkTypeLabel__c,XC_Comments__c, EndDate,XC_SubStatus__c, XC_WorkTypeCategory__c FROM WorkOrders)
            FROM Asset 
            WHERE Id IN:listAssetId]);
                                                                        
        if(mapAsset.isEmpty()){
            return;
        }
                
        List<WorkOrder> woRepairList = new List<WorkOrder>();
        for(WorkOrder wo : listNew){    
            if(!mapAsset.containsKey(wo.AssetId)){
                continue;
            }
            Asset a =  mapAsset.get(wo.AssetId); 
            XC_TR_WorkOrder_U_FillFieldByAsset_U.fillFields(wo, a, isAssetModified);
            if(XC_UTIL_WorkType.isRepair( wo.XC_WorkTypeCategory__c )){
                woRepairList.add(wo);
            }
        }
        if(!woRepairList.isEmpty()){ 
            manageRepair(woRepairList, mapAsset); 
        }        
    }

    private static void manageRepair(List<WorkOrder> woRepairList, Map<Id, Asset> mapAsset){
        for(WorkOrder wo : woRepairList){  
            Asset a =  mapAsset.get(wo.AssetId); 
            List<WorkOrder> listPreviousWorkOrders = a.WorkOrders;
            if(listPreviousWorkOrders.isEmpty()){
                continue;
            }
            checkPreviousWorkOrders(wo, listPreviousWorkOrders);
        }
        /*List<String> listAssetIds = XC_UTIL_SObject.getListFieldValues(woRepairList, 'AssetId');
        Map<Id, XC_UTIL_Asset.RepairWrapper> mapAssetRepair = XC_UTIL_Asset_U.getMapAssetRepair(listAssetIds);
        System.debug('mapAssetRepair->' + mapAssetRepair);
        for(WorkOrder wo : woRepairList ){
            if(mapAssetRepair.containsKey(wo.AssetId)){
                if(!mapAssetRepair.get(wo.AssetId).isAssetActive){ 
                    wo.addError(Label.XC_CL_AssetNotActive);
                } else if(!mapAssetRepair.get(wo.AssetId).isRepairAssetActive){
                    wo.addError(Label.XC_CL_WorkOrder_NoRepairServices);
                } else if(mapAssetRepair.get(wo.AssetId).numberOfRepairWORemaining <= 0){
                    wo.addError(Label.XC_CL_WorkOrder_MaximumNumberOfRepairReached);
                }       
            }
        }*/  
    }

    private static void checkPreviousWorkOrders(WorkOrder wo, List<WorkOrder> listPreviousWorkOrders){
        XC_UTIL_WorkType.WorkOrderWrapper woWrapper = XC_UTIL_WorkType.splitWorkOrders(listPreviousWorkOrders);
        List<WorkOrder> listWorkOrderDeliveryInstallation = woWrapper.listWorkOrderDeliveryInstallation;
        List<WorkOrder> listWorkOrderMaintenance = woWrapper.listWorkOrderMaintenance;
        List<WorkOrder> listWorkOrderRepair = woWrapper.listWorkOrderRepair;

        if(!listWorkOrderRepair.isEmpty()){
            WorkOrder mostRecentRepair = getMaxWorkorderByDate(listWorkOrderRepair);
            if(DateTime.now().addMonths(-6) < mostRecentRepair.EndDate){
                wo.XC_WarrantyPossibility__c = true;
                wo.XC_Comments__c = mostRecentRepair.XC_Comments__c;
                return;
            }
        }
        Boolean continueAfterCheckMaintenance = checkPreviousWorkOrdersMaintenance(wo, listWorkOrderMaintenance);
        if(!continueAfterCheckMaintenance){
            return;
        } 
        if(!listWorkOrderDeliveryInstallation.isEmpty()){
            WorkOrder mostRecentInstallation = getMaxWorkorderByDate(listWorkOrderDeliveryInstallation);
            if(DateTime.now().addMonths(-6) < mostRecentInstallation.EndDate){
                wo.XC_WarrantyPossibility__c = true;
                wo.XC_Comments__c = mostRecentInstallation.XC_Comments__c; 
                return;
            }
        }  
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description checks WorkOrder Maintenance
     * @param wo the work order
     * @param listWorkOrderMaintenance the list of Maintenance work order
     * @return the continue Boolean
     */

    private static Boolean checkPreviousWorkOrdersMaintenance(WorkOrder wo, List<WorkOrder> listWorkOrderMaintenance){
        if(listWorkOrderMaintenance.isEmpty()){
            return true;
        }
        List<WorkOrder> listWoAnomalies = new List<WorkOrder>(); 
        for(WorkOrder woToCheck : listWorkOrderMaintenance){
            if(woToCheck.XC_SubStatus__c == Label.XC_CL_WorkOrder_Anomalies){
                listWoAnomalies.add(woToCheck);
            }
        }
        if(!listWoAnomalies.isEmpty()){
            WorkOrder mostRecentMaintenance = getMaxWorkorderByDate(listWoAnomalies);
            if(DateTime.now().addDays(-15) < mostRecentMaintenance.EndDate){
                wo.XC_WarrantyPossibility__c = true;
                wo.XC_Comments__c = mostRecentMaintenance.XC_Comments__c; 
                return false;
            }
        } 
        return true;
    } 

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 06/03/2019
    * @description orderWorkorderByDate() – Get MAX of WorkOder by EndDate field
    * @param listWo - List<WorkOrder>
    * @return maxWo - WorkOrder
    */
    private static WorkOrder getMaxWorkorderByDate(List<WorkOrder> listWo) {
        WorkOrder maxWo = listWo[0];
        Integer sizelist = listWo.size();
        Integer countlist = 1;
        while(countlist < sizelist) {
            if(listWo[countlist-1].EndDate < listWo[countlist].EndDate) {
                maxWo = listWo[countlist];
            }
            countlist = countList + 1;
        }
        return maxWo;
    }

    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @date Creation 14/05/2019
    * @description checkChangedWarrantyResolution – Check if Warranty Resolution is changed
    * @param listNew 
    * @param mapOld
    * @param mapNew
    */

    public static void checkChangedWarrantyResolution(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String>{'XC_WarrantyResolution__c'};
        List<WorkOrder> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
			setWarrantyPossibility(listChanged);
		}
	}


    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @date Creation 14/05/2019
    * @description setWarrantyPossibility 
    * @param listNew 
    */
	private static void setWarrantyPossibility(List<WorkOrder> listNew){
		for(WorkOrder wo : listNew){
			if(wo.XC_WarrantyResolution__c == Label.XC_CL_WarrantyResolution){
				wo.XC_WarrantyPossibility__c = false;
			}
		}
	}
        /**
    * @author Nicola Arrigo - narrigo@deloitte.it
    * @date Creation 15/06/2021
    * @description retrievefromAssetOnUpdate 
    * @param listNew 
    * @param mapOldWo 
    */
    public static void fillFieldsFromAssetOnUpdate(List<WorkOrder> listNew, Map<id,WorkOrder> mapOldWo, boolean isAssetModified ){
       List<WorkOrder> woToUpdate= new List<WorkOrder>();
        for(workorder wo:listNew){
            if((wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G') &&
               wo.AssetId!=null &&
               wo.AssetId!=mapOldWo.get(wo.id).AssetId
            ){
                woToUpdate.add(wo);
            }
        }
        XC_TR_WorkOrder_U_FillFieldByAsset.fillFieldsFromAsset(woToUpdate,isAssetModified);
    }
}