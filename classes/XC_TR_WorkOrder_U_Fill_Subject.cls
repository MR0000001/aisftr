/**
 * @author              : Denise Avolio - denise.avolio@accenture.com
 * @group               : ACN Team
 * @created date        : 02-02-2022
 * @last modified date  : 02-02-2022
 * @last modified by    : Denise Avolio - denise.avolio@accenture.com
 * @description         : Utility Class for XC_TR_WorkOrder_Handler to populate Subject field
 * @test class          : XC_TR_WorkOrder_U_Fill_Subject_TEST
**/

public with sharing class XC_TR_WorkOrder_U_Fill_Subject {

    public final static String ENELXITALIA_RT = 'XC_B2G_EnelXItalia_WorkOrder';

    public final static String ORGANIZER_TYPE = 'Organizer';

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method populates the Subject field with Opprtunity Name.
     * @param listNew The list of new WorkOrder
     */
    public static void populateSubjectFromOpportunity(List<WorkOrder> listNew){

        Set<Id> oppIds = new Set<Id>();
        for(WorkOrder wo : listNew){
            oppIds.add(wo.XC_Opportunity__c);
        }

        Map<Id, Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Name FROM Opportunity WHERE Id IN : oppIds]);
        
        if(!oppMap.isEmpty()){
            for(WorkOrder wo : listNew){
                String rtWO = Schema.SObjectType.WorkOrder.getRecordTypeInfosById().get(wo.RecordTypeId).getDeveloperName();           
                if(String.isNotBlank(wo.XC_Opportunity__c) && ENELXITALIA_RT.equalsIgnoreCase(rtWO) && ORGANIZER_TYPE.equalsIgnoreCase(wo.XC_WorkTypeLabel__c)){
                    wo.Subject = oppMap.get(wo.XC_Opportunity__c).Name;
                }
            }
        }
    }
}