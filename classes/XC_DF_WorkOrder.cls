/**
* @author Roberta Cossiga - rcossiga@deloitte.it 
* @date Creation 06/05/2019
* @description XC_DF_WorkOrder – Data Factory for WorkOrder
*/

@isTest
public class XC_DF_WorkOrder {
    
    /** 
     * @author Roberta Cossiga - rcossiga@deloitte.it 
     * @description Method to create One WorkType
     * @param numberOfWO
     * @param workTypeName
     * @return List<WorkOrder> 
    */

    public static List<WorkOrder> createWorkOrders (Integer numberOfWO, String workTypeName){
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType(workTypeName);
        insert workTypeToInsert;
        insert XC_DF_Address.createAddress(1);
        XC_Address__c address = [SELECT Id, XC_Address__c FROM XC_Address__c LIMIT 1];
        for (Integer i=0; i<numberOfWO; i++){
            WorkOrder workOrderToInsert = new WorkOrder();
            //workOrderToInsert.XC_WorkTypeLabel__c = workTypeName;
            workOrderToInsert.XC_WorkTypeCategory__c = workTypeName;
            workOrderToInsert.WorkTypeId = workTypeToInsert.Id;
            workOrderToInsert.XC_LegalEntity__c = 'EndesaX';
        	workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EndesaX_WorkOrder').getRecordTypeId();
            workOrderToInsert.XC_Address__c = address.Id;
            workOrderToInsert.Street = address.XC_Address__c;
            workOrderToInsert.XC_Digitized__c = true;
            workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
            workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
            workOrderList.add(workOrderToInsert);
        }
        return workOrderList;
    }

    /**
    * @description create work order with a specific worktype
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 24/9/2019 
    * @param numberOfWO 
    * @param workTypeName 
    * @param workTypeCategory 
    * @return List<WorkOrder> 
    **/
    public static List<WorkOrder> createWorkOrdersWithWorkTypeName(Integer numberOfWO, String workTypeName, String workTypeCategory){
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkTypeWithName(workTypeCategory, workTypeName);
        insert workTypeToInsert;
        insert XC_DF_Address.createAddress(1);
        XC_Address__c address = [SELECT Id, XC_Address__c FROM XC_Address__c LIMIT 1];
        for (Integer i=0; i<numberOfWO; i++){
            WorkOrder workOrderToInsert = new WorkOrder();
            //workOrderToInsert.XC_WorkTypeCategory__c = workTypeName;
            workOrderToInsert.WorkTypeId = workTypeToInsert.Id;
            workOrderToInsert.XC_LegalEntity__c = 'EndesaX';
        	workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EndesaX_WorkOrder').getRecordTypeId();
            workOrderToInsert.XC_Address__c = address.Id;
            workOrderToInsert.Street = address.XC_Address__c;
            workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
            workOrderList.add(workOrderToInsert);
        }
        return workOrderList;
    }

    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it 
     * @description Method to create One WorkType
     * @param numberOfWO
     * @return List<WorkOrder>
    */

    public static List<WorkOrder> createWorkOrdersForLead (Integer numberOfWO){
        Lead leadToInsert = XC_DF_Lead.createResidentialLead();
        leadToInsert.XC_MainLegalEntity__c = 'EndesaX';
        insert leadToInsert;
        insert XC_DF_Address.createAddress(1);
        XC_Address__c address = [SELECT Id, XC_Address__c FROM XC_Address__c LIMIT 1];
        Lead queriedLead = [SELECT Id FROM Lead LIMIT 1];
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType(Label.XC_CL_CommercialVisit);
        insert workTypeToInsert;
        for (Integer i=0; i<numberOfWO; i++){
            WorkOrder workOrderToInsert = new WorkOrder();
            workOrderToInsert.XC_Lead__c = queriedLead.Id;
            //workOrderToInsert.XC_WorkTypeLabel__c = Label.XC_CL_CommercialVisit;
            workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_CommercialVisit;
            workOrderToInsert.XC_LegalEntity__c = 'EndesaX';
        	workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EndesaX_WorkOrder').getRecordTypeId();
            workOrderToInsert.XC_Address__c = address.Id;
            workOrderToInsert.Street = address.XC_Address__c;
            workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
            workOrderList.add(workOrderToInsert);
        }
        return workOrderList;
    }

    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it 
     * @description Method to create One WorkType
     * @param woList
     * @return List<SkillRequirement>
    */

    public static List<SkillRequirement> createWorkOrderSkillRequirement (List<WorkOrder> woList){
        List<SkillRequirement> skillReqList = new List<SkillRequirement>();
        List<Skill> skillList = [SELECT Id FROM Skill LIMIT 1];
        for (WorkOrder wo : woList){
            SkillRequirement skillReq = new SkillRequirement();
            skillReq.RelatedRecordId = wo.Id;
            skillReq.SkillId = skillList[0].Id;
            skillReq.SkillLevel = 1;
            skillReqList.add(skillReq);
        }
        return skillReqList;
    }


    /** 
     * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com
     * @description Method to create Wo
     * @param numberOfWO
     * @param workTypeName
     * @param assetProductName
     * @return List<WorkOrder> 
    */
    
    public static List<WorkOrder> createWorkOrdersAsset (Integer numberOfWO, String workTypeName, String assetProductName){
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        insert XC_DF_Address.createAddress(1);
        XC_Address__c address = [SELECT Id, XC_Address__c FROM XC_Address__c LIMIT 1];
        List<NE__Product__c> productToInsert = XC_DF_Product.createProducts(numberOfWO);
        for (Integer i=0; i<numberOfWO; i++){
            productToInsert[i].Name = assetProductName;
            productToInsert[i].XC_LIC_Product_Name__c = assetProductName;
            productToInsert[i].XC_Product_Subtype__c = 'Gas';
            productToInsert[i].XC_Product_Type__c = 'Service';
        }
        insert productToInsert;
        System.debug ('@@@@ product' + productToInsert);

        List<Asset> assetToInsert = XC_DF_Asset.createAssets(numberOfWO);  
        for (Integer i=0; i<numberOfWO; i++){
            assetToInsert[i].Name = assetProductName;
            assetToInsert[i].NE__ProdId__c = productToInsert[i].id;
            assetToInsert[i].XC_LegalEntity__c = 'EndesaX';
        }
        insert assetToInsert;
        System.debug ('@@@@ assetToInsert' + assetToInsert);
        
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType(workTypeName);
        insert workTypeToInsert;

        for (Integer i=0; i<numberOfWO; i++){
            WorkOrder workOrderToInsert = new WorkOrder();
            workOrderToInsert.XC_WorkTypeLabel__c = workTypeName;
            workOrderToInsert.WorkTypeId = workTypeToInsert.Id;
            workOrderToInsert.AssetId =assetToInsert[i].id;
            workOrderToInsert.XC_LegalEntity__c = 'EndesaX';
        	workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EndesaX_WorkOrder').getRecordTypeId();
            workOrderToInsert.XC_Address__c = address.Id;
            workOrderToInsert.Street = address.XC_Address__c;
            workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
            workOrderList.add(workOrderToInsert);

        }
        return workOrderList;
    }    
    
    
    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 22/10/2019 
    * @param numberOfWO 
    * @param workTypeLabel 
    * @param workTypeCategory 
    * @param assetProductName 
    * @return List<WorkOrder> 
    **/
    public static List<WorkOrder> createWorkOrdersAsset (Integer numberOfWO, String workTypeLabel, String workTypeCategory, String assetProductName){
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        insert XC_DF_Address.createAddress(1);
        XC_Address__c address = [SELECT Id, XC_Address__c FROM XC_Address__c LIMIT 1];
        List<NE__Product__c> productToInsert = XC_DF_Product.createProducts(numberOfWO);
        for (Integer i=0; i<numberOfWO; i++){
            productToInsert[i].Name = assetProductName;
            productToInsert[i].XC_LIC_Product_Name__c = assetProductName;
            productToInsert[i].XC_Product_Subtype__c = 'Gas';
            productToInsert[i].XC_Product_Type__c = 'Service';
        }
        insert productToInsert;
        System.debug ('@@@@ product' + productToInsert);

        List<Asset> assetToInsert = XC_DF_Asset.createAssets(numberOfWO);  
        for (Integer i=0; i<numberOfWO; i++){
            assetToInsert[i].Name = assetProductName;
            assetToInsert[i].NE__ProdId__c = productToInsert[i].id;
            assetToInsert[i].XC_LegalEntity__c = 'EndesaX';
        }
        insert assetToInsert;
        System.debug ('@@@@ assetToInsert' + assetToInsert);
        
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkTypeWithName(workTypeCategory, workTypeLabel);
        insert workTypeToInsert;

        for (Integer i=0; i<numberOfWO; i++){
            WorkOrder workOrderToInsert = new WorkOrder();
            workOrderToInsert.XC_WorkTypeLabel__c = workTypeLabel;
            workOrderToInsert.WorkTypeId = workTypeToInsert.Id;
            workOrderToInsert.XC_LegalEntity__c = 'EndesaX';
        	workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EndesaX_WorkOrder').getRecordTypeId();
            workOrderToInsert.AssetId =assetToInsert[i].id;
            workOrderToInsert.XC_Address__c = address.Id;
            workOrderToInsert.Street = address.XC_Address__c;
            workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
            workOrderList.add(workOrderToInsert);

        }
        return workOrderList;
    }    
    
}