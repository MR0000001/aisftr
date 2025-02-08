/**
 * Created by SNEKKANTI00 on 23/02/2021.
 */

public with sharing class BrogliaccioRequestController {

    @AuraEnabled
    public static List<Case> sendRequest(String caseToSendString) {
        System.debug('@@@ caseToSendString '+caseToSendString);
        Case caseToSend = CaseSelector.getCaseById(caseToSendString);
        List<Case> cases = new List<Case>();
        BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapper = new BrogliaccioCaseListWrapperNew(true, new List<Case>{caseToSend});
        cases = BrogliaccioCaseCalloutNew.brogliaccioCaseCallout(brogliaccioCaseListWrapper);
        DebugService.printList('BrogliaccioRequestController', 'sendRequest if', 'cases', cases, true);
        return cases;
    }
}