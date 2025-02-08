@isTest
public class XC_TR_ProductRequired_Handler_TEST {
   @isTest
    static void insertTest() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        ProductRequired z = new ProductRequired();
        List<ProductRequired> listZ = new List<ProductRequired>();
        Map<Id,ProductRequired> mapNew = new Map<id,ProductRequired>();
        XC_TR_ProductRequired_Handler zu = new XC_TR_ProductRequired_Handler();
        //zu.onAfterUpdate();
        zu.onBeforeInsert(listZ);
        zu.onBeforeUpdate(mapNew,mapNew);
        zu.onAfterInsert(mapNew);
        zu.onAfterUpdate(mapNew,mapNew);
        zu.onAfterDelete(mapNew);
        zu.onAfterUnDelete(mapNew);
        zu.onBeforeDelete(mapNew);
        zu.executedTrigger();

    }

}