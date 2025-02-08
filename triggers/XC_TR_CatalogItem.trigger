/**
* @author Nicola Mariniello nmariniello@deloitte.it
* @date Creation 12/07/2021
* @date Modification
* @description XC_TR_CatalogItem – Trigger on Catalog Item
*/

trigger XC_TR_CatalogItem on NE__Catalog_Item__c (before insert, before update, before delete, after insert, after update, after delete) {
  XC_TR_Dispatcher.init(new XC_TR_CatalogItem_Handler(), Trigger.operationType, constants.MDT_SKIP_CATALOGITEM);
}