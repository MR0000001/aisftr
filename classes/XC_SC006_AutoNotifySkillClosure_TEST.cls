/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/05/2019
* @description XC_SC006_AutoNotifySkillClosure_TEST – Test class for XC_SC006_AutoNotifySkillClosure
*/ 

@isTest
private class XC_SC006_AutoNotifySkillClosure_TEST { 
    @isTest
    private static void extecuteBatch() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResources(1);
        ServiceResourceSkill srs = XC_DF_ServiceResource.createServiceResourcesSkill(listServiceResource[0]);
        insert srs;
        srs.EffectiveEndDate = System.today().addDays(9);
        update srs;
        System.assertEquals(listServiceResource!=null, true);
        
        Test.startTest();
        Database.executeBatch(new XC_SC006_AutoNotifySkillClosure());
		    Test.stopTest();        
    }
}