/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 25/09/2019
 * @date Modification dd/mm/yyyy
 * @description XC_IN032_ChangeOrder_WOPlanAdaptation – public class with invocable method. It is invoked by a Flow to call Stock Management
 */

public without sharing class XC_IN032_ChangeOrder_WOPlanAdaptation {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN032_ChangeOrder_WOPlanAdaptation');

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description Input Wrapper for integration with flow
    */
    public class InputWrapper {
        @Invocablevariable
        public String stepId;
    }

    /**
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @description wrapper of WorkOrder
    */
    public class WrapperWo {
        public WorkOrder newWo;
        public WorkOrder oldWo;
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description Call stock management.
    * @param inputWrapperList - the parameters passed by flow
    */
    @InvocableMethod
    public static void callStockManagement(List<InputWrapper> inputWrapperList) {
        if(inputWrapperList.isEmpty()) {
            return;
        }
        XC_Provisioning_Step__c step = getProvisioningStep(inputWrapperList);
        String catalogName = step.XC_Configuration_Item__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name;
        Boolean checkCatalogName = catalogName == 'Gas' || catalogName == 'Electric' || catalogName =='Air conditioning' || catalogName == 'Suscripción';
        Boolean checkCatalogNameService = catalogName == 'Gas' || catalogName == 'Electric' || catalogName == 'Suscripción';
        if(checkCatalogName) {
            List<Asset> listAsset = getAsset(step.XC_ConfigurationId__c , catalogName);
            Boolean found = XC_IN032_ChangeOrder_WOPlanAdaptation_U.checkWorkOrders(listAsset);
            if(!found){
                manageStatus(step, Label.XC_CL_Step_Skipped);
                return;
            }
            List<Asset> listAssetAdd = new List<Asset>();
            List<Asset> listAssetRemove = new List<Asset>();
            List<WorkOrder> listAllWorkOrder = new List<WorkOrder>();
            if(checkCatalogNameService){
                listAllWorkOrder = populateListOfAsset(listAsset, listAssetAdd, listAssetRemove);
            }else {
                listAllWorkOrder = populateAssetAirConditioning(listAllWorkOrder, listAsset);
            }
            Asset assetInProvisioning;
            if(checkCatalogNameService){                
                for(Asset asset :listAssetAdd) {
                    if(asset.XC_Configuration_Item__r.XC_NeedProvisioning__c == true) {
                        assetInProvisioning = asset;
                    }
                }
            }else if (catalogName == Label.XC_CL_CatalogNameAirConditioning){
                assetInProvisioning = listAsset[0];
            }
            List<String> listWorkOrderid = XC_UTIL_Sobject.getIds(listAllWorkOrder);
            WorkOrder oldWorkOrder = populateOldWo(listAssetRemove, catalogName, listAsset);
            WorkOrder newWo = createWorkOrder(assetInProvisioning, oldWorkOrder, step);
            XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.insertRecord(newWo);
            if(!dmlResult.success) {
                XC_IN030_ChangeOrder_ContractChange.errorOperationDML(step, dmlResult.errorMessage);
                return;
            }
            XC_IN032_ChangeOrder_WOPlanAdaptation_U.createSA(newWo, oldWorkOrder, listWorkOrderid);
            manageStatus(step, Label.XC_CL_Completed_Ok);
        }
    }

    private static void manageStatus(XC_Provisioning_Step__c step, String status){
        step.XC_Status__c = status;
        XC_UTIL_Sobject.updateRecord(step);
    }

    /**
    * @description getProvisioningStep description
    * @param inputWrapperList InputWrapper
    * @return List<XC_Provisioning_Step__c>
    */

    private static XC_Provisioning_Step__c getProvisioningStep(List<InputWrapper> inputWrapperList){
        if(!Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()) {
            return null;
        }
        List<String> stepIdList = populateStepIdList(inputWrapperList);
        return [SELECT Id, XC_Country__c, XC_Configuration_Item__c, XC_ConfigurationId__c, XC_Configuration_Item__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name
                FROM XC_Provisioning_Step__c
                WHERE Id IN : stepIdList LIMIT 1];
    }
    private static List<Asset> getAsset(String orderId, String catalogName) {
        if(!Schema.sObjectType.Asset.isAccessible()) {
            return null;
        }
        List<Asset> listOfAsset = new List<Asset>();
        if(!Label.XC_CL_CatalogNameAirConditioning.equals(catalogName)){
            listOfAsset = [SELECT Id, XC_Configuration_Item__r.XC_NeedProvisioning__c, NE__Action__c,
                                (SELECT Id, WorkTypeId, XC_PositionInMaintenancePlan__c, XC_MaintenanceYearFrequency__c, Country, State, City, PostalCode, Street, Latitude, Longitude, ServiceTerritoryId 
                                FROM WorkOrders WHERE XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_PlannedMaintenance AND (Status = : Label.XC_CL_Cancelled OR Status =: Label.XC_CL_WorkOrder_CannotComplete ))
                                FROM Asset WHERE NE__Order_Config__c = : orderId AND (NE__Action__c = :Label.XC_CL_ActionAsset_Add OR NE__Action__c = :Label.XC_CL_ActionAsset_Remove)];
        }else {
            listOfAsset = [SELECT Id, XC_Configuration_Item__r.XC_NeedProvisioning__c, NE__Action__c,
                                (SELECT Id, WorkTypeId, XC_PositionInMaintenancePlan__c, XC_MaintenanceYearFrequency__c, Country, State, City, PostalCode, Street, Latitude, Longitude, ServiceTerritoryId 
                                FROM WorkOrders WHERE XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_PlannedMaintenance AND (Status = : Label.XC_CL_Cancelled OR Status =: Label.XC_CL_WorkOrder_CannotComplete ))
                                FROM Asset WHERE NE__Order_Config__c = : orderId AND XC_Configuration_Item__r.XC_NeedProvisioning__c =: true];
        }
        return listOfAsset;
    }

    /**
    * @description
    * @author Domenico Del Prete - domenico.delprete@nttdata.com
    * @param asset - Asset
    * @param oldWo - WorkOrder
    * @param provStep - XC_Provisioning_Step__c
    * @return XC_UTIL_Sobject.WrapperResult
    **/
    public static WorkOrder createWorkOrder (Asset asset, WorkOrder oldWo, XC_Provisioning_Step__c provStep){
        List<String> listAssetIds = new List<String>();
        listAssetIds.add(asset.id);
        Map<Id, XC_UTIL_Asset.MaintenanceWrapper> mapAssetMaintenance = XC_UTIL_Asset.getMapAssetMaintenance(listAssetIds);
        WorkOrder woToInsert = new WorkOrder();
        woToInsert.WorkTypeId = oldWo.WorkTypeId;
        woToInsert.AssetId = asset.Id;
        woToInsert.XC_Provisioning_Step__c = provStep.id;
        woToInsert.XC_Configuration_Item__c = provStep.XC_Configuration_Item__c;
        woToInsert.XC_PositionInMaintenancePlan__c = oldWo.XC_PositionInMaintenancePlan__c + 1;
        woToInsert.XC_PreviousMaintenanceWorkOrder__c = oldWo.Id;
        woToInsert.XC_MaintenanceYearFrequency__c = mapAssetMaintenance.get(asset.id).yearFrequency;
        woToInsert.XC_CreateMaintenanceServiceAppointment__c = true;
        woToInsert.XC_CreatedAutomaticallyBySystem__c = true;
        return woToInsert;  
    }
    private static Boolean isEmptyOptionalMainteinance(String orderId) {
        NE__Order__c order = new List<NE__Order__c>([SELECT Id, (SELECT Id FROM NE__Order_Items__r WHERE NE__ProdName__c = 'Mantenimiento instalacion calefaccion bienal' AND NE__Action__c= :Label.XC_CL_ActionAsset_Add) FROM NE__Order__c WHERE Id = : orderId LIMIT 1]).get(0);
        return order.NE__Order_Items__r.isEmpty();
    }

    private static WorkOrder populateOldWo(List<Asset> listAssetRemove, String catalogName, List<Asset> listOfAsset){
        WorkOrder oldWorkOrder = new WorkOrder();
        if(!Label.XC_CL_CatalogNameAirConditioning.equals(catalogName)){
            for(Asset asset : listAssetRemove) { 
                if(!asset.WorkOrders.isEmpty()) {
                    oldWorkOrder = asset.WorkOrders[0];
                }
            }
        }else {
            oldWorkOrder = listOfAsset[0].WorkOrders[0];
        }
            
        return oldWorkOrder;
    }
    private static List <WorkOrder> populateListOfAsset (List<Asset> listAsset, List<Asset> listAssetAdd, List<Asset> listAssetRemove){
        List<WorkOrder> listWorkOrder = new List<WorkOrder>(); 
        for(Asset asset :listAsset) {
            if(asset.NE__Action__c == Label.XC_CL_ActionAsset_Add) {
                listAssetAdd.add(asset);
            }
            if(asset.NE__Action__c == Label.XC_CL_ActionAsset_Remove) {
                listAssetRemove.add(asset);
                listWorkOrder.addAll(asset.WorkOrders);
            }
        }
        return listWorkOrder;
    }

    /*private static Boolean checkCatalogNameAirCondition(String catalogName, XC_Provisioning_Step__c step){
        if(catalogName =='Air conditioning' && !isEmptyOptionalMainteinance(step.XC_ConfigurationId__c)){
            Map<String, Object> inputs = new Map<String, Object>();
            inputs.put('step', step);
            new Flow.Interview.XC_FL_Provisioning_MaintenanceInspection(inputs).start();
            manageStatus(step, Label.XC_CL_Completed_Ok);
        }
        return(catalogName =='Air conditioning' && !isEmptyOptionalMainteinance(step.XC_ConfigurationId__c));
    }*/

    private static List<String> populateStepIdList (List<InputWrapper> inputWrapperList){
        List<String> stepIdList = new List<String>();
        for(InputWrapper inputWr : inputWrapperList) {
            stepIdList.add(inputWr.stepId);
        }
        return stepIdList;
    }

    private static List<WorkOrder> populateAssetAirConditioning (List<WorkOrder> listWorkOrder, List<Asset> listOfAsset){
        for(Asset asset : listOfAsset){
            listWorkOrder.addAll(asset.WorkOrders);
        }
        return listWorkOrder;
    }
}