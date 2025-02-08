/*
* @author:		Marco Lazzaroni (mlazzaroni@pic-informatica.it)
* @description:	Technical Asset management: global class for flows invocable method to set TFIP entries. 
*				Get all data references to build temporary pick list for flow interviews
*/ 
global class TAMGetTFIPEntries {

/*
* @author:		Marco Lazzaroni (mlazzaroni@pic-informatica.it)
* @description:	Inner class wrapper for invocable method inputs 
*/ 
    public class FlowInputs {
        @InvocableVariable
        public String FlowGUId;
        
        @InvocableVariable
        public Id WOLIid;
        
        @InvocableVariable
        public Id WOid;

    }
    
/*
* @author:		Marco Lazzaroni (mlazzaroni@pic-informatica.it)
* @description:	Invocable method to set TFIP entries. 
*				Get all data references to build temporary pick list for flow interviews
* @Param:		List<FlowInputs>
*/ 
    @InvocableMethod
    public static void getRecords(List<FlowInputs> inputs) {
        if(!inputs.isEmpty()){
            FlowInputs inParams = inputs[0];
            List<TAM_TempFIPicklist__c> TFIPs = new List<TAM_TempFIPicklist__c>();
            //Get all associated assets with their addresses and create the related TFIPs
            Map<Id, Asset> assetsMap = new Map<Id, Asset>([SELECT Id, Name, RecordType.Name, XC_Address__c, XC_Address__r.Name, Status, TAM_IsTechnical__c FROM Asset WHERE Id IN (SELECT TAM_Asset__c FROM XC_ProductConsumed__c WHERE XC_WorkOrderLineItem__c = :inParams.WOLIid)]);
            Map<Id, Asset> ReplacedAsMap = new Map<Id, Asset>([SELECT Id FROM Asset WHERE Id IN (SELECT RelatedAssetId FROM AssetRelationship WHERE RelationshipType = 'Replacement' AND RelatedAssetId IN :assetsMap.keySet())]);
            for(Asset a : assetsMap.values()) {
                if(a.Status == 'New' || a.Status == 'Installed') {
                    TFIPs.add(new TAM_TempFIPicklist__c(
                            PEValue__c = a.Name,
                            PEId__c = a.Id,
                            Type__c = a.RecordType.Name,
                            InterviewGuid__c = inParams.FlowGUId
                        )
                    );
                }
                if(a.Status == 'Uninstalled' && a.TAM_IsTechnical__c && !ReplacedAsMap.keySet().contains(a.Id)) {
                    TFIPs.add(new TAM_TempFIPicklist__c(
                            PEValue__c = a.Name,
                            PEId__c = a.Id,
                            Type__c = 'Maintenance',
                            InterviewGuid__c = inParams.FlowGUId
                        )
                    );
                }
                //Addresses if needed
            }
            /*List<WorkOrder> WOs = [SELECT Id, AssetId, Asset.TAM_IsTechnical__c, AccountId, XC_AssignedPartner__c, XC_Address__c
                FROM WorkOrder
                WHERE Id =: inParams.WOid
                    AND XC_WorkTypeCategory__c IN ('Maintenance with Substitution', 'Malfunctioning', 'Planned Maintenance')];
            if(WOs.size() > 0) {
                List<Asset> relAssets = new List<Asset>();
                if(WOs[0].Asset.TAM_IsTechnical__c) {
                    relAssets = [SELECT Id, Name FROM Asset
                        WHERE Id !=: WOs[0].AssetId
                            AND AccountId =: WOs[0].AccountId
                            AND AssetServicedById =: WOs[0].XC_AssignedPartner__c
                            AND TAM_IsTechnical__c = TRUE
                        AND (RootAssetId =: WOs[0].AssetId
                            OR XC_Address__c =: WOs[0].XC_Address__c)];
                } else {
                    relAssets = [SELECT Id, Name FROM Asset
                        WHERE Id !=: WOs[0].AssetId
                            AND AccountId =: WOs[0].AccountId
                            AND AssetServicedById =: WOs[0].XC_AssignedPartner__c
                            AND TAM_IsTechnical__c = TRUE
                            AND Id IN (SELECT AssetId FROM AssetRelationship WHERE RelatedAssetId =: WOs[0].AssetId)];
                }
                if(relAssets.size() > 0) {
                    for(Asset a : relAssets) {
                        TFIPs.add(new TAM_TempFIPicklist__c(
                                PEValue__c = a.Name,
                                PEId__c = a.Id,
                                Type__c = 'MaintAsset',
                                InterviewGuid__c = inParams.FlowGUId
                           )
                        );
                    }
                }
            }*/
            //Get Work Order address
            WorkOrder WO = [SELECT XC_Address__c, XC_Address__r.Name FROM WorkOrder WHERE Id =: inParams.WOid];
            if(WO.XC_Address__c != null) {
                TFIPs.add(new TAM_TempFIPicklist__c(
                        PEValue__c = WO.XC_Address__r.Name,
                        PEId__c = WO.XC_Address__c,
                        Type__c = 'Address',
                        InterviewGuid__c = inParams.FlowGUId
                    )
                );                
                
            }
            //Get Work Order associated products
            Set<Id> pIds = new Set<Id>();
            //if(WO.project_cloud__Project_Task__c != null) {
                //If there is a cloud coach project associated, get products from the good issue WOLI
                for(XC_ProductConsumed__c pc : [SELECT XC_Product2Id__c FROM XC_ProductConsumed__c WHERE XC_WorkOrderLineItem__c IN (SELECT Id FROM WorkOrderLineItem WHERE WorkOrderId =: inParams.WOid AND RecordType.Name LIKE '%GOOD_ISSUE%')]){
                    pIds.add(pc.XC_Product2Id__c);
                }
            //} else {
                //else get products from products required
                for(ProductRequired pc : [SELECT Product2Id FROM ProductRequired WHERE ParentRecordId =: inParams.WOid]){
                    pIds.add(pc.Product2Id);
                }                
            //}
            for(Product2 p : [SELECT Id, Name FROM Product2 WHERE Id in: pIds AND IsActive = TRUE]) {
                    TFIPs.add(new TAM_TempFIPicklist__c(
                        PEValue__c = p.Name,
                        PEId__c = p.Id,
                        Type__c = 'Product',
                        InterviewGuid__c = inParams.FlowGUId
                    )
                             );                
            }
            if(!TFIPs.isEmpty()) {
                Database.insert(TFIPs);
            }
        }
    }
}