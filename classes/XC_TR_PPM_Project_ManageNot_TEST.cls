/**
* @author Dario Andrea Di Cicco
* @date Creation 26/11/2020
* @date Modification dd/mm/yyyy
* @description 
*/
@isTest
public class XC_TR_PPM_Project_ManageNot_TEST {
    public static testMethod void projectCreatedCustomerInteraction(){
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        insert opp;
        project_cloud__Project__c ppm = new project_cloud__Project__c();
        ppm.XC_Segment__c = 'B2B';
        ppm.XC_LegalEntity__c = 'EnelXItalia';
        ppm.XC_Status__c = 'Assigned';
        ppm.XC_Country__c = 'Italy';
        ppm.ccpe_ocp__Opportunity__c = opp[0].id;
        insert ppm;
        Map<Id,project_cloud__Project__c > mapNew = new Map<Id,project_cloud__Project__c >();
        mapNew.put(ppm.id, ppm);
        Test.startTest();
        XC_TR_PPM_Project_ManageNotification.projectCreatedCustomerInteraction(mapNew);
        Test.stopTest();
    }
        public static testMethod void projectSuspendAndCancelledCustomerInteraction1(){
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        insert opp;
        project_cloud__Project__c ppm = new project_cloud__Project__c();
        ppm.XC_Segment__c = 'B2B';
        ppm.XC_LegalEntity__c = 'EnelXItalia';
        ppm.XC_Status__c = 'Assigned';
        ppm.XC_Country__c = 'Italy';
        ppm.ccpe_ocp__Opportunity__c = opp[0].id;
        insert ppm;
        ppm.XC_Status__c = 'Planned';
        update ppm;
        ppm.XC_Status__c = 'Work in Progress';
        update ppm;
        ppm.XC_Status__c = 'Suspended';
        update ppm;
        project_cloud__Project__c ppm2 = new project_cloud__Project__c();
        ppm2.XC_Segment__c = 'B2B';
        ppm2.XC_LegalEntity__c = 'EnelXItalia';
        ppm2.XC_Status__c = 'Cancelled';
        ppm2.XC_Country__c = 'Italy';
        ppm2.ccpe_ocp__Opportunity__c = opp[0].id;
        Map<Id,project_cloud__Project__c > mapNew = new Map<Id,project_cloud__Project__c >();
        mapNew.put(ppm.id, ppm);
        Map<Id,project_cloud__Project__c > mapOld = new Map<Id,project_cloud__Project__c >();
        mapOld.put(ppm.id, ppm2);
        Test.startTest();
        XC_TR_PPM_Project_ManageNotification.projectSuspendAndCancelledCustomerInteraction(mapNew, mapOld);
        Test.stopTest();
    }
        public static testMethod void projectSuspendAndCancelledCustomerInteraction2(){
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        insert opp;
        project_cloud__Project__c ppm = new project_cloud__Project__c();
        ppm.XC_Segment__c = 'B2B';
        ppm.XC_LegalEntity__c = 'EnelXItalia';
        ppm.XC_Status__c = 'Assigned';
        ppm.XC_Country__c = 'Italy';
        ppm.ccpe_ocp__Opportunity__c = opp[0].id;
        insert ppm;
        ppm.XC_Status__c = 'Cancelled';
        update ppm;
        project_cloud__Project__c ppm2 = new project_cloud__Project__c();
        ppm2.XC_Segment__c = 'B2B';
        ppm2.XC_LegalEntity__c = 'EnelXItalia';
        ppm2.XC_Status__c = 'Assigned';
        ppm2.XC_Country__c = 'Italy';
        ppm2.ccpe_ocp__Opportunity__c = opp[0].id;
        Map<Id,project_cloud__Project__c > mapNew = new Map<Id,project_cloud__Project__c >();
        mapNew.put(ppm.id, ppm);
        Map<Id,project_cloud__Project__c > mapOld = new Map<Id,project_cloud__Project__c >();
        mapOld.put(ppm.id, ppm2);
        Test.startTest();
        XC_TR_PPM_Project_ManageNotification.projectSuspendAndCancelledCustomerInteraction(mapNew, mapOld);
        Test.stopTest();
    }
    
            public static testMethod void projectSuspendAndCancelledCustomerInteraction3(){
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        insert opp;
        List<NE__OrderItem__c> itemList = XC_DF_OrderItem.createOrderItems(1);
        insert itemList;
        project_cloud__Project__c ppm = new project_cloud__Project__c();
        ppm.XC_Segment__c = 'B2B';
        ppm.XC_LegalEntity__c = 'EnelXItalia';
        ppm.XC_Status__c = 'New';
        ppm.XC_Country__c = 'Italy';
        ppm.ccpe_ocp__Opportunity__c = opp[0].id;
        ppm.XC_ConfigurationItem__c = itemList[0].id;
        insert ppm;
                ppm.XC_Status__c = 'Closed';
                update ppm;
        project_cloud__Project__c ppm2 = new project_cloud__Project__c();
        ppm2.XC_Segment__c = 'B2B';
        ppm2.XC_LegalEntity__c = 'EnelXItalia';
        ppm2.XC_Status__c = 'Assigned';
        ppm2.XC_Country__c = 'Italy';
        ppm2.ccpe_ocp__Opportunity__c = opp[0].id;
        Map<Id,project_cloud__Project__c > mapNew = new Map<Id,project_cloud__Project__c >();
        mapNew.put(ppm.id, ppm);
        Map<Id,project_cloud__Project__c > mapOld = new Map<Id,project_cloud__Project__c >();
        mapOld.put(ppm.id, ppm2);
        Test.startTest();
        XC_TR_PPM_Project_ManageNotification.projectSuspendAndCancelledCustomerInteraction(mapNew, mapOld);
        Test.stopTest();
    }
                public static testMethod void projectSuspendAndCancelledCustomerInteraction4(){
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        insert opp;
        NE__Order__c order = XC_DF_Order.createOrder('Order');
                    
        //insert order;
        project_cloud__Project__c ppm = new project_cloud__Project__c();
        ppm.XC_Segment__c = 'B2B';
        ppm.XC_LegalEntity__c = 'EnelXItalia';
        ppm.XC_Status__c = 'New';
        ppm.XC_Country__c = 'Italy';
        ppm.ccpe_ocp__Opportunity__c = opp[0].id;
        ppm.XC_Configuration__c = order.id;
        insert ppm;
                ppm.XC_Status__c = 'Closed';
                update ppm;
        project_cloud__Project__c ppm2 = new project_cloud__Project__c();
        ppm2.XC_Segment__c = 'B2B';
        ppm2.XC_LegalEntity__c = 'EnelXItalia';
        ppm2.XC_Status__c = 'Assigned';
        ppm2.XC_Country__c = 'Italy';
        ppm2.ccpe_ocp__Opportunity__c = opp[0].id;
        Map<Id,project_cloud__Project__c > mapNew = new Map<Id,project_cloud__Project__c >();
        mapNew.put(ppm.id, ppm);
        Map<Id,project_cloud__Project__c > mapOld = new Map<Id,project_cloud__Project__c >();
        mapOld.put(ppm.id, ppm2);
        Test.startTest();
        XC_TR_PPM_Project_ManageNotification.projectSuspendAndCancelledCustomerInteraction(mapNew, mapOld);
        Test.stopTest();
    }
    public static testMethod void populateCustomerInteraction(){
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        insert opp;
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> contacts= XC_DF_Contact.createResidentialContacts(acc);
        Contact c = contacts[0];
        insert c;
        c.XC_PrimaryContact__c=true;
        update c;
        NE__Order__c order = XC_DF_Order.createOrder('Order');
        project_cloud__Project__c ppm = new project_cloud__Project__c();
        ppm.XC_Segment__c = 'B2B';
        ppm.XC_LegalEntity__c = 'EnelXItalia';
        ppm.XC_Status__c = 'Assigned';
        ppm.XC_Country__c = 'Italy';
        ppm.ccpe_ocp__Opportunity__c = opp[0].id;
        ppm.XC_Configuration__c = order.id;
        ppm.ccpe_ocp__Account__c = acc[0].id;
        insert ppm;
        project_cloud__Project__c ppmRetrived=[SELECT id, Name, XC_ExternalProjectView__c, ccpe_ocp__Opportunity__c, XC_ConfigurationItem__c,XC_Configuration__c,XC_Configuration__r.NE__OptyId__c,ccpe_ocp__Opportunity__r.XC_Contact__c,ccpe_ocp__Account__c,ccpe_ocp__Opportunity__r.XC_Contact__r.email,ccpe_ocp__Opportunity__r.XC_Contact__r.Name,ccpe_ocp__Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c,XC_LegalEntity__c,XC_Segment__c,ccpe_ocp__Opportunity__r.XC_BusinessLine__c,XC_Configuration__r.NE__OptyId__r.XC_BusinessLine__c FROM project_cloud__Project__c WHERE Id=:ppm.Id];
        Test.startTest();
        XC_Customer_Interaction__c ci=XC_TR_PPM_Project_ManageNotification.populateCustomerInteraction(ppmRetrived,'Survey_Maintenance');
        System.assertEquals('Survey_Maintenance', ci.XC_Communication_Type__c);
        Test.stopTest();
    }
}