/**
* @author Benjamin Geronimo
* @date Creation 13/04/2021
* @date Modification 09/05/2022 GDB - PERFORMANCE IMPROVEMENT - MAY 2022
* @description TA_TR_WorkOrder_TEST – Test Class for TA_TR_WorkOrder AND Handler
*/

@isTest
public class TA_TR_WorkOrder_TEST {
    @TestSetup
    static void setup (){

        TA_Action_Configuration__c actionConf = new TA_Action_Configuration__c();
        actionConf.TA_Type__c = 'Closing';
        actionConf.TA_DeveloperName__c = 'CloseService';
        actionConf.TA_External_Id__c = 'test';
        insert actionConf;

        TA_Phase_Configuration__c phaseConf = new TA_Phase_Configuration__c(
            Name = 'Pre Service',
            TA_DeveloperName__c = 'PreService',
            TA_External_Id__c = 'TA_Phase_000001'
        );
        insert phaseConf;

        TA_Layout_Matrix_Configuration__c lmc = new TA_Layout_Matrix_Configuration__c(
            TA_Phase__c = phaseConf.Id,
            TA_WorkTypeCategory__c = 'Planned Maintenance',
            TA_ConfigurationSet__c = 'B2C_Italy_Set',
            TA_IndexPhase__c = 1,
            TA_IndexAction__c = 1,
            TA_Action__c = actionConf.Id,
            TA_External_Id__c = 'test',
            TA_Active__c = true
        );
        insert lmc;
    }

    static testMethod void onInsert(){
        Test.startTest(); 
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(2, 'Planned Maintenance');
        for(WorkOrder w : wo){
            w.XC_Segment__c = 'B2C';
       		w.XC_Country__c = 'Italy';
            w.XC_LegalEntity__c = 'EnelXItalia';
        }
        wo[1].XC_StatusReason__c = 'To be scheduled';
        wo[1].Status = 'Assigned';
        insert wo;
        wo[0].XC_StatusReason__c = 'To be scheduled';
        wo[1].Status = 'In Progress';
        update wo;
        delete wo;
        Test.stopTest();     
    }

    static testMethod void onUpdate1(){
        Test.startTest(); 
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        for(WorkOrder w : wo){
            w.XC_Segment__c = 'B2C';
            w.XC_Country__c = 'Italy';
            w.XC_LegalEntity__c = 'EnelXItalia';
        }
        insert  wo;
        
        wo[0].XC_StatusReason__c = 'Assigned to the technician';
        wo[0].Status = 'Complete';
        update wo;        
        Test.stopTest();
    }

    static testMethod void onUpdate2(){
        Test.startTest(); 
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(4, 'Delivery & Installation');
        for(WorkOrder w : wo){
            w.XC_Segment__c = 'B2C';
            w.XC_Country__c = 'Italy';
            w.XC_LegalEntity__c = 'EnelXItalia';
            w.Status = 'Assigned';
        }
        wo[1].XC_WorkTypeCategory__c = 'Repair';
        wo[2].XC_WorkTypeCategory__c = 'Return';
        wo[3].XC_WorkTypeCategory__c = 'Site Inspection';
        insert  wo;  

        for(WorkOrder w : wo){
            w.Status = 'In Progress';
        }
        update wo;        
        Test.stopTest();
    }

}