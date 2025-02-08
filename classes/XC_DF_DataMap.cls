/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Data factory for the NE__Map__c object
*/
@isTest
public class XC_DF_DataMap {
        
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @param dataMapName the name of the dataMap to create 
    * @description Creates the dataMap to create the zQuote record
    */
    public static void createDataMap(String dataMapName, zqu__BillingEntity__c billingEntity) {

        NE__Map__c dataMap = new NE__Map__c();
        dataMap.NE__Map_Name__c = dataMapName;
        dataMap.NE__Type__c = 'Object2Object';
        dataMap.CurrencyIsoCode = 'EUR';
        insert dataMap; 

        NE__MapObject__c mapObject = new NE__MapObject__c();
        mapObject.NE__Source__c = 'order__c';
        mapObject.NE__Target__c = 'zqu__quote__c';
        mapObject.NE__Source_Map_Object_Id__c = dataMap.Id;
        mapObject.Name = dataMapName;
        mapObject.NE__Sequence__c = 0;
        mapObject.NE__Map__c = dataMap.Id;
        insert mapObject;
        
        createMapObjectItem(mapObject, dataMapName, billingEntity);
    }

    private static void createMapObjectItem(NE__MapObject__c mapObject, String dataMapName, zqu__BillingEntity__c billingEntity) {

        NE__MapObjectItem__c mapObjectItem;
        List<NE__MapObjectItem__c> listItem = new List<NE__MapObjectItem__c>();

        if(dataMapName == 'Order2ZQuote' || dataMapName == 'ChangeOrder2ZQuote') {
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__billingentity__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = billingEntity.Id, NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zpaymentmethodid__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__electronicpaymentmethodid__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'accountid__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__account__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zpaymentmethodtype__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__paymentmethod__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__subscriptiontype__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'Amend Subscription', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__invoiceprocessingoption__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'Subscription', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__currency__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'EUR', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__status__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'New', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__billingbatch__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'Batch1', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__paymentterm__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'Net 30', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zsoldtocontact__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__soldtocontact__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zbilltocontact__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__billtocontact__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__renewalterm__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = '1', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__initialterm__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = '1', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = true, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zstart_date__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__validuntil__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = true, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zstart_date__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__startdate__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zpaymentmethodid__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__electronicpaymentmethodid__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'accountid__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__account__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zpaymentmethodtype__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__paymentmethod__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__subscriptiontype__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'New Subscription', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__invoiceprocessingoption__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'Subscription', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__status__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'New', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__billingbatch__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'Batch1', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__paymentterm__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'Net 30', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zsoldtocontact__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__soldtocontact__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zbilltocontact__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__billtocontact__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__renewalterm__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = '1', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = false, NE__TargetField__c = 'zqu__initialterm__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = '1', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = true, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zstart_date__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__validuntil__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = true, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = 'b2wzc__zstart_date__c', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__startdate__c', NE__Type__c = 'Field', NE__UseAsKey__c =  false, NE__Value__c = '', NE__Field_Type__c = 'String'));
            listItem.add(new NE__MapObjectItem__c( NE__Map_Object__c = mapObject.Id, NE__IsDateField__c = false, NE__MapAsTag__c =false, NE__QueryOnly__c = false, NE__SourceField__c = '', NE__Stop_Trigger__c = true, NE__TargetField__c = 'zqu__currency__c', NE__Type__c = 'Value', NE__UseAsKey__c =  false, NE__Value__c = 'EUR', NE__Field_Type__c = 'String'));
        } 
        
        insert listItem;

    }

    /**
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param dataMapName the name of the dataMap to create 
    * @description Creates the dataMap to create the order record
    */
    public static void createDataMap(String dataMapName) {

        NE__Map__c dataMap = new NE__Map__c();
        dataMap.NE__Map_Name__c = dataMapName;
        dataMap.NE__Type__c = 'Object2Object';
        dataMap.CurrencyIsoCode = 'EUR';
        insert dataMap; 

        NE__MapObject__c mapObject = new NE__MapObject__c();
        mapObject.NE__Source__c = 'order__c';
        mapObject.NE__Target__c = 'order__c';
        mapObject.NE__Source_Map_Object_Id__c = dataMap.Id;
        mapObject.Name = dataMapName;
        mapObject.NE__Sequence__c = 0;
        mapObject.NE__Map__c = dataMap.Id;
        insert mapObject;
        
    }

}