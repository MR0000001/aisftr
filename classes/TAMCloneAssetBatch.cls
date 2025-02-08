/*
* @author:		Marco Lazzaroni (mlazzaroni@pic-informatica.it)
* @description:	Technical Asset management: global batchable class for technical asset cloning.
*				Creates the given number of clones and if the asset is a root asset it clones all the asset structure.
*/

global class TAMCloneAssetBatch implements Database.Batchable<Id>, Database.Stateful {
    public Id AssetId;
    public Integer ClonesNumber;
    public Id WOId;
    public Id WOLIId;

    public Map<Integer, List<Asset>> AssetStructbyLevel = new Map<Integer, List<Asset>>();
    public List<String> CloneIds = new List<String>();

    global TAMCloneAssetBatch(Id AssetId, Integer ClonesNumber, Id WOId, Id WOLIId) {
        this.AssetId = AssetId;
        this.ClonesNumber = ClonesNumber;
        this.WOId = WOId;
        this.WOLIId = WOLIId;
    }

    global Iterable<Id> start(Database.BatchableContext bc) {
        List<Id> DummyIterator = new List<Id>();
        if(AssetId == null) return DummyIterator;
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('Asset').getDescribe().fields.getMap();
        List<String> editableFields = new List<String>();
        for (Schema.SObjectField fieldRef : fields.values()) {
            Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
            if (fieldResult.isAccessible() && fieldResult.isUpdateable()) {
                editableFields.add(fieldResult.getName());
            }
        }
        String q = 'SELECT AssetLevel,' + String.join(editableFields, ',') + ' FROM Asset WHERE RootAssetId = \'' + AssetId + '\'';
        List<SObject> AssetList = Database.query(q);
        if(AssetList.size() == 0) {
            q = 'SELECT ' + String.join(editableFields, ',') + ' FROM Asset WHERE Id = \'' + AssetId + '\'';
            AssetList = Database.query(q);
            AssetStructbyLevel.put(1, new List<Asset>{
                    (Asset)AssetList[0]
            });
        } else {
            for (Asset a : (List<Asset>) AssetList) {
                if (AssetStructbyLevel.containsKey(a.AssetLevel)) {
                    AssetStructbyLevel.get(a.AssetLevel).add(a);
                } else {
                    AssetStructbyLevel.put(a.AssetLevel, new List<Asset>{
                            a
                    });
                }
            }
        }

        for (Integer i = 0; i < ClonesNumber; i++) {
            DummyIterator.add(AssetId);
        }
        return DummyIterator;
    }

    global void execute(Database.BatchableContext bc, List<Id> records) {
        Integer Level = 1;
        Map<Integer, Map<Id, Id>> CloneIdsMap = new Map<Integer, Map<Id, Id>>();
        while (AssetStructbyLevel.containsKey(Level)) {
            List<Asset> Clones = new List<Asset>();
            for (Asset a : AssetStructbyLevel.get(Level)) {
                Asset aClone = a.clone(false, true, true, false);
                aClone.SerialNumber = null;
                if (CloneIdsMap.containsKey(Level - 1)) {
                    aClone.ParentId = CloneIdsMap.get(Level - 1).get(a.ParentId);
                }
                Clones.add(aClone);
            }
            List<Database.SaveResult> SRs = Database.insert(Clones);
            CloneIdsMap.put(Level, new Map<Id, Id>());
            List<XC_ProductConsumed__c> AssociatedPCs = new List<XC_ProductConsumed__c>();
            for (Integer ix = 0; ix < Clones.size(); ix++) {
                if (SRs[ix].isSuccess()) {
                    CloneIdsMap.get(Level).put(Clones[ix].getCloneSourceId(), SRs[ix].getId());
                    CloneIds.add(SRs[ix].getId());
                    AssociatedPCs.add(new XC_ProductConsumed__c(
                            XC_WorkOrder__c = WOId,
                            XC_WorkOrderLineItem__c = WOLIId,
                            TAM_Asset__c = SRs[ix].getId()
                    ));
                }
            }
            if(AssociatedPCs.size() > 0) Database.insert(AssociatedPCs);

            List<AssetRelationship> ARs = [SELECT Id, AssetId, RelatedAssetId, RelationshipType
                FROM AssetRelationship
                WHERE AssetId IN :CloneIdsMap.get(Level).keySet()
                    AND RelationshipType != 'Replacement'];
            List<AssetRelationship> ClonedARs = new List<AssetRelationship>();
            for(AssetRelationship AR : ARs) {
                ClonedARs.add(new AssetRelationship(
                        AssetId = CloneIdsMap.get(Level).get(AR.AssetId),
                        RelatedAssetId = AR.RelatedAssetId,
                        RelationshipType = AR.RelationshipType
                ));
            }
            if(ClonedARs.size() > 0) Database.insert(ClonedARs);

            Level += 1;
        }
    }

    global void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [
                SELECT Id,
                        Status,
                        ExtendedStatus,
                        NumberOfErrors,
                        JobItemsProcessed,
                        TotalJobItems,
                        CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
                a.CreatedBy.Email
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Technical Asset Clone Batch ' + a.Status);
        mail.setPlainTextBody('Technical asset clones processed ' + a.TotalJobItems +
                ' with ' + a.NumberOfErrors + ' failures.\n');
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('TechnicalAsset' + bc.getJobId() + '.csv');
        Blob efaBody = Blob.valueOf('Id\n' + String.join(CloneIds, '\n'));
        efa.setBody(efaBody);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }

    public static Id RunMe(Id AssetId, Integer ClonesNumber, Id WOId, Id WOLIId) {
        Id BJId = Database.executeBatch(new TAMCloneAssetBatch(AssetId, ClonesNumber, WOId, WOLIId), 1);
        return BJId;
    }

    public class FlowInputs {
        @InvocableVariable
        public Id AssetId;

        @InvocableVariable
        public Integer ClonesNumber;

        @InvocableVariable
        public Id WOId;

        @InvocableVariable
        public Id WOLIId;
    }

    @InvocableMethod
    public static void InvokeRunMe(List<FlowInputs> inputs) {
        RunMe(inputs[0].AssetId, inputs[0].ClonesNumber, inputs[0].WOId, inputs[0].WOLIId);
    }

}