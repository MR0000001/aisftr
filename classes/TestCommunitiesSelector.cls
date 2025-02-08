/**
 * Created by SNEKKANTI00 on 01/03/2021.
 */

@isTest
public with sharing class TestCommunitiesSelector {

    @isTest
    public static void communitiesSelectorTest() {
        List<Communities__c> communities = TestDataFactory.createCommunities();

        Test.startTest();
        CommunitiesSelector.getCommunityCodeByProvinceAndCity(communities[0].province_short__c, communities[0].Name);
        CommunitiesSelector.getCommunityCodeByCountry(communities[0].Name);
        Test.stopTest();
    }
}