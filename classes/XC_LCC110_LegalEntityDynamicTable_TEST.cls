/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  14/05/2019 
* @description XC_LCC110_LegalEntityDynamicTable_TEST – Test class for XC_LCC110_LegalEntityDynamicTable
*/ 
@isTest
public class XC_LCC110_LegalEntityDynamicTable_TEST {
      //Test method retrieveLegalEntities
    @isTest
    static void retrieveLegalEntities(){
      insert XC_DF_OneOrg.createOneOrg('Spain');
      Test.startTest();
          List<Map<String,String>> results = XC_LCC110_LegalEntityDynamicTable.retrieveLegalEntities();
        // System.assertEquals(expected, actual);
      Test.stopTest();
    }

    @isTest
    static void retrieveLegalEntityDataTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
          XC_LCC110_LegalEntityDynamicTable.retrieveLegalEntityData();
        Test.stopTest();
    }

    @isTest
    static void getLegalEntitiesByCountryTest(){
      insert XC_DF_OneOrg.createOneOrg('Spain');
      Test.startTest();
        XC_LCC110_LegalEntityDynamicTable.getLegalEntitiesByCountry('Spain');
      Test.stopTest();
    }
}