/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Data factory for the RatePlan object
*/
@isTest
public class XC_DF_RatePlan {
    
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @param order the order to link to the work order
    * @param item the configuration item to link to the rateplan
    * @return the junction record
    * @description Creates the junction record between the rateplan and the item after inserting all the necessary data
    */
    public static B2WExtCat__Work_Order_Item__c createJunctionProductRatePlanToItem(NE__Order__c order, NE__OrderItem__c item) {

        Product2 realProduct = new Product2();
        realProduct.Name = 'Real Product Name';                                        
        realProduct.IsActive = true;                                       
        realProduct.zqu__ZuoraId__c = '8adc8f996a3446ab016a4fc80e1f1e1f';
        insert realProduct;

        zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c();
        prp.Name = item.NE__ProdName__c;
        prp.zqu__ProductRatePlanFullName__c =  item.NE__ProdName__c;
        prp.zqu__EffectiveEndDate__c = Date.newInstance(3000, 12, 12);
        prp.zqu__EffectiveStartDate__c = Date.today();
        prp.zqu__ZuoraId__c = '8adc8f996a3446ab016a4fc80e1f1e1f';
        prp.CurrencyIsoCode = 'EUR';
        prp.zqu__ActiveCurrencies__c = 'EUR';
        prp.zqu__Product__c = realProduct.Id;
        insert prp;

        zqu__ProductRatePlanCharge__c prpc = new zqu__ProductRatePlanCharge__c();
        prpc.Name = 'Rate Plan Charge TEST';
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.zqu__ProductRatePlanChargeName__c = 'Rate Plan Charge TEST';
        prpc.zqu__ZuoraId__c = '8adc8f996a3446ab016a4fc80e1f1e1f';
        prpc.zqu__Model__c = 'Per Unit Pricing';
        insert prpc;

        B2WExtCat__External_Catalog__c extCatalog = new B2WExtCat__External_Catalog__c();
        extCatalog.B2WExtCat__External_Catalog_Name__c = 'TEST CATALOG';
        insert extCatalog;

        B2WExtCat__External_Catalog_Item__c extCatalogItem = new B2WExtCat__External_Catalog_Item__c();
        extCatalogItem.B2WExtCat__Type__c = 'Item';
        extCatalogItem.B2WExtCat__External_Catalog_Item_Name__c = 'catalogo';
        extCatalogItem.B2WExtCat__External_Catalog__c = extCatalog.Id;
        insert extCatalogItem;
        
        B2WZC__ECI_RatePlan_Junction__c junctionB2WZC = new B2WZC__ECI_RatePlan_Junction__c();
        junctionB2WZC.B2WZC__Name__c = 'Junction Test B2W';
        junctionB2WZC.B2WZC__IdRatePlan__c = prp.Id;
        junctionB2WZC.B2WZC__EciId__c = extCatalogItem.Id;
        insert junctionB2WZC;

        B2WExtCat__Work_Order__c b2wWorkOrder = new B2WExtCat__Work_Order__c();
        b2wWorkOrder.B2WExtCat__External_Catalog__c = extCatalog.Id;
        b2wWorkOrder.B2WExtCat__Configuration__c = order.Id;
        insert b2wWorkOrder;

        Id junctionRT = Schema.SObjectType.B2WExtCat__Work_Order_Item__c.getRecordTypeInfosByDeveloperName().get('ZuoraOneTime').getRecordTypeId();

        B2WExtCat__Work_Order_Item__c junction = new B2WExtCat__Work_Order_Item__c();
        junction.B2WExtCat__Work_Order_Item_Code__c = prp.Id;
        junction.B2WExtCat__Configuration_Item__c = item.Id;
        junction.B2WExtCat__Work_Order__c = b2wWorkOrder.Id;
        junction.B2WExtCat__Action__c = 'Provide';
        junction.RecordTypeId = junctionRT;
        return junction;
        
    }

}