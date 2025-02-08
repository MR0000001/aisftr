/**
 * Created by snekkanti002 on 23/09/2021.
 */

public without sharing class BrogliaccioCaseListWrapperNew {
    public Boolean isFromComponent;
    public List<Case> cases;
    public Map<String, Case> caseMap = new Map<String, Case>();
    public Map<String, Integer> caseIdCvCount = new Map<String, Integer>();
    public Map<String, String> caseIdExternalStatusOldMap = new Map<String, String>();
    public Map<String, List<ContentVersion>> caseIdCvsMap = new Map<String, List<ContentVersion>>();

    public BrogliaccioCaseListWrapperNew(Boolean isFromComponent, List<Case> cases) {
        this.isFromComponent = isFromComponent;
        this.cases = cases;
    }
}