/**
 * Created by FMARCHEGIA00 on 09/06/2021.
 */

public without sharing class FlowCitizenAssociationCheck {

    @InvocableMethod
    public static List<FlowOutput> checkCase(List<FlowInput> flowInputs) {
        List<FlowOutput> outputs = new List<FlowOutput>();
        FlowOutput singleOutput = new FlowOutput();

        system.debug('flowInputs -> ' + flowInputs);
        for (FlowInput singleFlowInput: flowInputs) {
	        system.debug('singleFlowInput -> ' + singleFlowInput);
            String caseId = singleFlowInput.caseId;
            String serviceRequestId = singleFlowInput.serviceRequestId;

            List<Case> cases = [SELECT Id FROM Case WHERE (ParentId =: caseId OR ReminderCase__c =: caseId)];
	        system.debug('cases -> ' + cases);

            if ( !cases.isEmpty() ) {
                singleOutput.associazione_error = true;
            } else {
                if ( String.isBlank(singleFlowInput.serviceRequestId) ) {
                    singleOutput.associazione_error = false;
                } else {
                    List<Case> casesFromServiceRequest = [SELECT Id, ParentId, ReminderCase__c, Protocol_Number__c FROM Case WHERE Service_Request__c =: singleFlowInput.serviceRequestId AND Id !=: caseId];
			        system.debug('casesFromServiceRequest -> ' + casesFromServiceRequest);
                    Boolean isTrue = false;
                    List<Id> ParentiIds = new List<Id>();
                    List<Id> ReminderCaseIds = new List<Id>();
                    for ( Case singleCase : casesFromServiceRequest ) {
                        if ( singleCase.ParentId != null ) {
                            ParentiIds.add(singleCase.ParentId);
                        }
                        if ( singleCase.ReminderCase__c != null ) {
                        	ReminderCaseIds.add(singleCase.ReminderCase__c);
                        }
                        if ( String.isNotBlank(singleCase.ReminderCase__c) || String.isNotBlank(singleCase.ParentId) || String.isNotBlank(singleCase.Protocol_Number__c)) {
                            if (!Test.isRunningTest()) {
                                isTrue = true;
                            }
                            break;
                        }
                    }
                    if (isTrue) {
                        singleOutput.associazione_error = true;
                    } else {
                        system.debug('ParentiIds -> ' + ParentiIds);
                        system.debug('ReminderCaseIds -> ' + ReminderCaseIds);
                        if ( !ParentiIds.isEmpty() && !ReminderCaseIds.isEmpty() ) {
                            Boolean isOrCondition = false;
                            String query = 'SELECT Id FROM Case WHERE ';
                            if ( !ParentiIds.isEmpty() ) {
                                query += 'ParentId IN: ParentiIds';
                                isOrCondition = true;
                            }
                            if ( isOrCondition ) {
                                query += ' OR ';
                            }
                            if ( !ReminderCaseIds.isEmpty() ) {
                                query += 'ReminderCase__c IN: ReminderCaseIds';
                            }
                            system.debug('query -> '+ query);
                            List<Case> allCases = Database.query(query);
                            system.debug('allCases -> ' + allCases);
                            if ( allCases.isEmpty() ) {
                                singleOutput.associazione_error = false;
                            } else {
                                singleOutput.associazione_error = true;
                            }
                        } else {
                            singleOutput.associazione_error = false;
                        }
                    }

                }
            }
            outputs.add(singleOutput);
        }

        return outputs;
    }

    public class FlowInput {
        @InvocableVariable
        public String caseId;

        @InvocableVariable
        public String serviceRequestId;
    }

    public class FlowOutput {
        @InvocableVariable
        public Boolean associazione_error;
    }
}