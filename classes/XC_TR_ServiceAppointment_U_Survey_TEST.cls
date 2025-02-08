@isTest
public class XC_TR_ServiceAppointment_U_Survey_TEST {
    /*
    @isTest
    public static void populateSurvey(){
        
        WorkOrder wo = new WorkOrder();
        List<ServiceAppointment> sa = new List<ServiceAppointment>();
        XC_TR_ServiceAppointment_U_Survey.populateSurvey(wo, sa);
        XC_TR_ServiceAppointment_U_Survey.populateSurvey(wo, sa, 'TEST');
       	//sa = XC_DF_ServiceAppointment.createServiceAppointment(1, 'Malfunctioning');
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Malfunctioning');
        insert woList;

        woList[0].XC_LegalEntity__c = 'EnelXItalia';
        woList[0].XC_Segment__c = 'B2B';
        woList[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();

        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        NE__Catalog_Item__c ci = XC_DF_CatalogItem.createCatalogItem();
        ci.XC_ProductLine__c='E700';
        insert ci;
        assetList[0].NE__CatalogItem__c = ci.id;
        //assetList[0].TAM_IsLogical__c = true;
        insert assetList;
        woList[0].AssetId = assetList[0].id;
        woList[0].XC_WorkTypeLabel__c = 'Malfunctioning - Architectural Lighting';
        woList[0].XC_Product_Name__c='Architectural Lighting';
		
       
        upsert woList;
        sa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        sa[0].XC_Segment__c = 'B2B';
        sa[0].XC_LegalEntity__c = 'EnelXItalia';
        sa[0].Status = 'Scheduled';
        insert sa;
                sa[0].Status = 'Dispatched';
        update sa;
        sa[0].Status = 'In Progress';
        update sa;
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        sa[0].Status = 'Completed';
        sa[0].ActualStartTime = System.now();
        sa[0].ActualEndTime = System.now();
        sa[0].XC_WorkTypeLabel__c = 'Malfunctioning';
        update sa;
    }
    */
    @isTest
    public static void populateSurvey2(){
        
        WorkOrder wo = new WorkOrder();
        List<ServiceAppointment> sa = new List<ServiceAppointment>();
        XC_TR_ServiceAppointment_U_Survey.populateSurvey(wo, sa);
        XC_TR_ServiceAppointment_U_Survey.populateSurvey(wo, sa, 'TEST');
       	//sa = XC_DF_ServiceAppointment.createServiceAppointment(1, 'Malfunctioning');
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        insert woList;

        woList[0].XC_LegalEntity__c = 'EnelXItalia';
        woList[0].XC_Segment__c = 'B2B';
        woList[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();

        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        NE__Catalog_Item__c ci = XC_DF_CatalogItem.createCatalogItem();
        ci.XC_ProductLine__c='E700';
        insert ci;
        assetList[0].NE__CatalogItem__c = ci.id;
        //assetList[0].TAM_IsLogical__c = true;
        insert assetList;
        woList[0].AssetId = assetList[0].id;
        woList[0].XC_WorkTypeLabel__c = 'Planned Maintenance - Digital City Services';
        //woList[0].XC_Product_Name__c='Architectural Lighting';
		
       
        upsert woList;
        sa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        sa[0].XC_Segment__c = 'B2B';
        sa[0].XC_LegalEntity__c = 'EnelXItalia';
        sa[0].Status = 'Scheduled';
        insert sa;
                sa[0].Status = 'Dispatched';
        update sa;
        sa[0].Status = 'In Progress';
        update sa;
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        sa[0].Status = 'Completed';
        sa[0].ActualStartTime = System.now();
        sa[0].ActualEndTime = System.now();
        sa[0].XC_WorkTypeLabel__c = 'Planned Maintenance';
        update sa;
    }
    
    @isTest
    public static void populateSurvey3(){
        
        WorkOrder wo = new WorkOrder();
        List<ServiceAppointment> sa = new List<ServiceAppointment>();
        XC_TR_ServiceAppointment_U_Survey.populateSurvey(wo, sa);
        XC_TR_ServiceAppointment_U_Survey.populateSurvey(wo, sa, 'TEST');
       	//sa = XC_DF_ServiceAppointment.createServiceAppointment(1, 'Malfunctioning');
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        insert woList;

        woList[0].XC_LegalEntity__c = 'EnelXItalia';
        woList[0].XC_Segment__c = 'B2B';
        woList[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();

        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        NE__Catalog_Item__c ci = XC_DF_CatalogItem.createCatalogItem();
        ci.XC_ProductLine__c='E700';
        insert ci;
        assetList[0].NE__CatalogItem__c = ci.id;
        //assetList[0].TAM_IsLogical__c = true;
        insert assetList;
        woList[0].AssetId = assetList[0].id;
        woList[0].XC_WorkTypeLabel__c = 'Delivery & Installation - Gas';
        //woList[0].XC_Product_Name__c='Architectural Lighting';
		
       
        upsert woList;
        sa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        sa[0].XC_Segment__c = 'B2B';
        sa[0].XC_LegalEntity__c = 'EnelXItalia';
        sa[0].Status = 'Scheduled';
        insert sa;
                sa[0].Status = 'Dispatched';
        update sa;
        sa[0].Status = 'In Progress';
        update sa;
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        sa[0].Status = 'Completed';
        sa[0].ActualStartTime = System.now();
        sa[0].ActualEndTime = System.now();
        sa[0].XC_WorkTypeLabel__c = 'Delivery & Installation';
        update sa;
    }
}