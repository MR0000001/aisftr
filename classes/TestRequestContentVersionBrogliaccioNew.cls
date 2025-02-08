/**
 * Created by snekkanti002 on 11/07/2022.
 */

@IsTest
public with sharing class TestRequestContentVersionBrogliaccioNew {

    @IsTest
    public static void requestContentVersionBrogliaccioNew() {
        Integer count = 1;
        Map<String, List<ContentVersion>> caseIdCvsMap = new Map<String, List<ContentVersion>>();
        Map<String, Case> caseMap = new Map<String, Case>();

        List<ContentVersion> cvs = new List<ContentVersion>();
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions(cases);

        for(Case c : cases) {
            caseMap.put(c.Id, c);
            c.ExternalSystemId_Brogliaccio__c = String.valueOf(count);
            for(ContentVersion cv : contentVersions) {
                if(cv.CaseId__c == c.Id) {
                    cvs.add(cv);
                    caseIdCvsMap.put(c.Id, cvs);
                }
            }
            count++;
        }
        update cases;

        BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapper = new BrogliaccioCaseListWrapperNew(false, cases);
        brogliaccioCaseListWrapper.caseIdCvsMap = caseIdCvsMap;
        brogliaccioCaseListWrapper.caseMap = caseMap;

        Test.startTest();
        new RequestContentVersionBrogliaccioNew(brogliaccioCaseListWrapper);
        Test.stopTest();
    }
}