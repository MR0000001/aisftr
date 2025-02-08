/**
 * Created by sbarbera on 04/01/22.
 */
@IsTest
public with sharing class XC_TR_PPM_ProjectTask_FillFields_TEST {
    @IsTest
    static void setupAndTest(){
        //Project
        project_cloud__Project__c p = new project_cloud__Project__c(name='ProgettoTestTemplate',
                project_cloud__Type__c='Maintenance Plan',
                project_cloud__IsTemplate__c=true,
                XC_LegalEntity__c='EnelXItalia',
                project_cloud__Units__c='Duration',
                XC_Country__c ='Italy'
        );

        insert p;
        //Create a new phase
        project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c(	Name='Phase Progetto di Test Partner Engagement',
                project_cloud__Project__c=p.id
        );
        insert ph;

        List <project_cloud__Project_Task__c> listPt = new List<project_cloud__Project_Task__c>();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        accList[0].XC_AccountType__c = 'Partner Account';
        insert accList;

        system.debug('@@@ Nome Progetto Test'+ph.name);
        // Created a Project Task
        project_cloud__Project_Task__c ptPartnerEngagement1=new project_cloud__Project_Task__c(name='Project Task Test Partner Engagement',
                project_cloud__Duration__c=1,
                project_cloud__Project_Phase__c=ph.id,
                XC_TaskType__c='Partner Engagement',
                XC_TaskReason__c='Partner Engagement',
                XC_TaskStatus__c='Planned',
                project_cloud__Estimated_Hours__c=1,
                project_cloud__Autonomous_Start__c=system.today(),
                XC_PreferredPartner__c = accList[0].id

        );

        project_cloud__Project_Task__c ptPartnerEngagement2=new project_cloud__Project_Task__c(name='Project Task Test Partner Engagement',
                project_cloud__Duration__c=1,
                project_cloud__Project_Phase__c=ph.id,
                XC_TaskType__c='Partner Engagement',
                XC_TaskReason__c='Partner Engagement',
                XC_TaskStatus__c='Planned',
                project_cloud__Estimated_Hours__c=1,
                project_cloud__Autonomous_Start__c=system.today(),
                XC_Executor__c = accList[0].id

        );

        project_cloud__Project_Task__c ptMaterialSupply1=new project_cloud__Project_Task__c(name='Project Task Test Material Supply',
                project_cloud__Duration__c=1,
                project_cloud__Project_Phase__c=ph.id,
                XC_TaskType__c='Material Supply',
                XC_TaskReason__c='Material Supply',
                XC_TaskStatus__c='Planned',
                project_cloud__Estimated_Hours__c=1,
                project_cloud__Autonomous_Start__c=system.today(),
                XC_PreferredPartner__c = accList[0].id
        );

        project_cloud__Project_Task__c ptMaterialSupply2=new project_cloud__Project_Task__c(name='Project Task Test Material Supply',
                project_cloud__Duration__c=1,
                project_cloud__Project_Phase__c=ph.id,
                XC_TaskType__c='Material Supply',
                XC_TaskReason__c='Material Supply',
                XC_TaskStatus__c='Planned',
                project_cloud__Estimated_Hours__c=1,
                project_cloud__Autonomous_Start__c=system.today()
        );


        listPt.add(ptPartnerEngagement1);
        listPt.add(ptPartnerEngagement2);
        listPt.add(ptMaterialSupply1);
        listPt.add(ptMaterialSupply2);

        insert listPt;

        ptMaterialSupply2.XC_Executor__c = accList[0].id;
        update ptMaterialSupply2;


    }
}