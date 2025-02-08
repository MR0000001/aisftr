/**
 * Created by dolombardi on 30/04/2021.
 */
@isTest
public with sharing class XC_TR_Contract_Handler_TEST {
    @isTest
    static void insertTest() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Contract z = new Contract();
        List<Contract> listZ = new List<Contract>();
        Map<Id,Contract> mapNew = new Map<id,Contract>();
        XC_TR_Contract_Handler zu = new XC_TR_Contract_Handler();
        //zu.onAfterUpdate();
        zu.onBeforeInsert(listZ);
        zu.onBeforeUpdate(mapNew,mapNew);
        zu.onAfterInsert(mapNew);
        zu.onAfterUpdate(mapNew,mapNew);
        zu.onAfterDelete(mapNew);
        zu.onAfterUnDelete(mapNew);
        zu.onBeforeDelete(mapNew);
        zu.executedTrigger();
		zu.stopRecursion();
    }

}