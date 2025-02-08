/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description XC_IN030_ChangeOrder_ContractChange_U – Util class for XC_IN030_ChangeOrder_ContractChange methods
*/

public without sharing class XC_IN030_ChangeOrder_ContractChange_U {
  
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_XC_IN030_ChangeOrder_ContractChange');
    /**
     * @description get ProvisioningStep from stepId
     * @param stepIdList stepIdList description
     * @return List<XC_Provisioning_Step__c>
    */ 
    public static XC_Provisioning_Step__c getProvisioningStep(List<String> stepIdList){
        if(!Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            return null; 
        }
        return  [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Status__c, XC_ErrorMessage__c
                    FROM XC_Provisioning_Step__c 
                    WHERE Id IN: stepIdList LIMIT 1];  
    } 

    /**
    * @description get WorkOrder, Cases, and Addresses from Asset  
    * @param listAccountAsset - List<Asset>
    * @return List<Asset>
    */
    public static List<Asset> getAssetChildren(List<Asset> listAccountAsset) {
        List<String> listIdAsset = new List<String>();
        for(Asset asset:listAccountAsset) {
            listIdAsset.add(asset.id);
        }     
        List<Asset> assetChildren = new List<Asset>([SELECT Id, XC_Address__c, XC_Contract__c, AccountId, XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_AddressProvince__c, XC_Address__r.XC_Address__c, XC_Address__r.XC_BillingAddress__c, XC_Address__r.XC_City__c, XC_Address__r.XC_DeliveryAddress__c, XC_Address__r.XC_FullAddress__c, XC_Address__r.XC_InstallationAddress__c, XC_Address__r.XC_Municipality__c, XC_Address__r.XC_PickUpPoint__c,
                                                    XC_Address__r.XC_PointOfSales__c, XC_Address__r.XC_PostalCode__c, XC_Address__r.XC_PricinRegion__c, XC_Address__r.XC_StreetNumber__c, XC_Address__r.XC_WareHouse__c, XC_Address__r.XC_LowLight__c, XC_Address__r.XC_LocationProblems__c, XC_Address__r.XC_ComplexDisassembly__c, XC_Address__r.XC_NoElevator__c, XC_Address__r.XC_LadderRequired__c, XC_Address__r.XC_AddressNotValidated__c,
                                                    XC_Address__r.XC_StreetTypeText__c, XC_Address__r.XC_AddressValidated__c, XC_Address__r.XC_AddressValidatedCUPS__c, XC_Address__r.XC_KeyForDuplication__c, XC_Address__r.XC_KeyForDuplicationOne__c,                                                        
                                                        (SELECT Id, Status, SubCause__c, Reason, Description, AssetId, RecordType.DeveloperName FROM Cases ),
                                                        (SELECT Id, XC_Check_Final_Status__c, XC_WorkTypeCategory__c, Status, RootWorkOrderId FROM WorkOrders)
                                                    FROM Asset WHERE Id IN :listIdAsset]);
        return assetChildren;
    }  
    /**
    * @description get Asset sons from Order
    * @author Valeria Martino valeria.martino@nttdata.com
    * @param orderId - String
    * @return NE__Order__c
    */
    public static NE__Order__c getOrder(String orderId) {
        List<NE__Order__c> orderList = new List<NE__Order__c>([SELECT Id, NE__AccountId__c, NE__OptyId__r.Stagename, XC_ChangedContact__c, XC_Segment__c, XC_LegalEntity__c,
                                                              XC_Type__c,XC_Subtype__c, XC_InstallationAddress__c, XC_DeliveryAddress__c, XC_DeliveryAddress__r.XC_PickUpPoint__c, 
                                                              XC_ChangedContact__r.Phone,
                                                              XC_InstallationAddress__r.XC_AddressCountry__c, XC_InstallationAddress__r.XC_City__c,XC_InstallationAddress__r.XC_AddressProvince__c,
                                                              XC_InstallationAddress__r.XC_StreetNumber__c, XC_InstallationAddress__r.XC_Address__c, XC_InstallationAddress__r.XC_StreetTypeText__c,
                                                              XC_InstallationAddress__r.XC_Municipality__c , XC_InstallationAddress__r.XC_PostalCode__c,
                                                              (SELECT Id, AccountId, XC_Contract__c, XC_Contract__r.AccountId, XC_Address__c FROM NE__Assets__r)
                                                              FROM  NE__Order__c 
                                                              WHERE Id = :orderId]);
        NE__Order__c order = orderList[0];  
        return order;   
    }
        /**
    * @description update Status on ProvisioningStep in Completed KO if Contract has more than one related Asset 
    * @author Valeria Martino valeria.martino@nttdata.com
    * @param  provisioningStep - XC_Provisioning_Step__c
    * @param  listAccountAsset - List<Asset> 
    * @return XC_Provisioning_Step__c
    */
    public static XC_Provisioning_Step__c checkContractFather(XC_Provisioning_Step__c provisioningStep, List<Asset> listAccountAsset) {
        XC_Provisioning_Step__c provStepToUpdate;
        List<String> listIdContractFather = new List<String>();
        for(Asset asset: listAccountAsset){
            listIdContractFather.add(asset.XC_Contract__c);
        }
        //1° Error Message
        List<Contract> listContract = new List<Contract>([SELECT Id ,(SELECT Id FROM Assets1__r WHERE Status !=: Label.XC_CL_Asset_StatusInactive AND XC_Product_Type__c !=: Label.XC_CL_ProductTypeCoverage AND  XC_Product_Type__c !=:Label.XC_CL_Technical AND XC_Product_Type__c !=: 'Billing') FROM Contract WHERE Id IN :listIdContractFather]);
        List<Asset> listContractAssetChildren = new List<Asset>();
        for(Contract contract : listContract){
            if(contract.Assets1__r.size()> 1) {
                provisioningStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                provisioningStep.XC_ErrorMessage__c = Label.XC_CL_ChangeOwnership_MoreAsset;
                provStepToUpdate = provisioningStep;
                break;
            }
        }
        return provStepToUpdate;
    }


    /**
    * @description get WorkOrder, WorkOrderLineItems, and Addresses from WorkOrder  
    * @param woToMigrate - Set<Id>
    * @return Map<Id,WorkOrder>
    */
    public static Map<Id,WorkOrder> getWo(Set<Id> woToMigrate) {
        Set<String> workOrderToManage = new Set<String>{Label.XC_CL_WorkType_Repair, Label.XC_CL_WorkType_PlannedMaintenance,
                                                        'Diagnostic', Label.XC_CL_WorkType_QualityCheckInspection};

        Map<Id,WorkOrder> allWo = new Map<Id,WorkOrder>([SELECT id, Status,XC_WorkTypeCategory__c,  XC_Address__r.XC_AddressCountry__c,XC_Address__r.XC_City__c,XC_Address__r.XC_AddressProvince__c,
                                                                XC_Address__r.XC_StreetNumber__c,XC_Address__r.XC_Address__c, 
                                                                XC_Address__r.XC_StreetTypeText__c,XC_Address__r.XC_Municipality__c,XC_Address__r.XC_PostalCode__c,
                                                                (SELECT id, Address FROM ServiceAppointments WHERE Status =: Label.XC_CL_ServiceAppointment_None OR Status =: Label.XC_CL_ServiceAppointment_Scheduled OR Status =: Label.XC_CL_ServiceAppointment_OnHold),
                                                                (SELECT id, XC_AccountId__c FROM WorkOrderLineItems)
                                                                FROM WorkOrder WHERE (Id IN: woToMigrate OR RootWorkOrderId IN:woToMigrate) AND 
                                                                (Status =: Label.XC_CL_WorkOrder_New OR Status =: Label.XC_CL_WorkOrder_Assigned OR Status =: Label.XC_CL_OnHold) AND
                                                                XC_WorkTypeCategory__c IN: workOrderToManage]);

        return allWo;
    }

}