/**
 * Created by snekkanti002 on 11/07/2022.
 */

@IsTest
public with sharing class TestRequestGEDCVAcknowledgement {

    @IsTest
    public static void requestGEDCVAcknowledgement() {
        Map<Case, List<ContentVersion>> caseCvsMap = new Map<Case, List<ContentVersion>>();
        List<ContentVersion> cvs = new List<ContentVersion>();
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions(cases);

        for(Case c : cases) {
            for(ContentVersion cv : contentVersions) {
                if(cv.CaseId__c == c.Id) {
                    cvs.add(cv);
                    caseCvsMap.put(c, cvs);
                }
            }
        }


        Test.startTest();
        new RequestGEDContentVersionAcknowledgement(caseCvsMap);
        Test.stopTest();
    }
}