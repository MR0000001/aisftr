/*
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/10/2020
* @description XC_LCC114_MassiveAssignmentWorkType_TEST – Test class for XC_LCC114_MassiveAssignmentWorkType
*/

@isTest
private class XC_LCC114_MassiveAssignmentWorkType_TEST {

    @isTest
    private static void onUtil() {
        List<Account> listAccount = XC_DF_Account.insertPartnerAccounts(1);
        List<User> listUser = new List<User>([
            SELECT Id, Country__c, XC_LegalEntity__c
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ]);
        WorkType workType = new WorkType(
            Name = 'Commercial Visit - Boiler',
            XC_LegalEntity__c = listUser[0].XC_LegalEntity__c ,
            XC_WorkTypeCategory__c = 'Commercial Visit',
            DurationType = Label.XC_CL_WorkType_Hours,
            EstimatedDuration = 1,
            XC_Segment__c = 'B2C'
        );
        insert workType;
        List<XC_PartnerCoverage__c> listPc = new List<XC_PartnerCoverage__c>();
        listPc.add(new XC_PartnerCoverage__c(
            XC_Account__c = listAccount[0].Id,
            XC_ZipCode__c = '00000',
            XC_WorkType__c = workType.Id,
            XC_ExternalIdForDuplication__c = listAccount[0].Id+'_00000_'+workType.Id
        ));
        listPc.add(new XC_PartnerCoverage__c(
            XC_Account__c = listAccount[0].Id,
            XC_ZipCode__c = '00001',
            XC_WorkType__c = workType.Id,
            XC_ExternalIdForDuplication__c = listAccount[0].Id+'_00001_'+workType.Id,
            XC_ExternalId__c = '00001_'+workType.Id,
            XC_WorkTypeLabel__c = workType.Name
        ));
        insert listPc;
        List<Object> listCombo = new List<Object>();
        listCombo.add(new Map<Object, Object>{
            'WorkType' => workType.Id,
            'ZipCode' => '00000'
        });
        List<Account> listAccountDestination = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResourcesFromAccount(listAccount);

        Test.startTest();
        XC_LCC114_MassiveAssignmentWorkType.getUserInformation();
        XC_LCC114_MassiveAssignmentWorkType.OutputWrapper outWrapper = XC_LCC114_MassiveAssignmentWorkType.initAddOperation(listAccount[0].Id);
        XC_LCC114_MassiveAssignmentWorkType.OutputWrapper resultAdd = XC_LCC114_MassiveAssignmentWorkType.addOperation(listCombo, listAccount[0].Id);
        for(Integer i=0; i<4001; i++) {
            listCombo.add(new Map<Object, Object>{
                'WorkType' => workType.Id,
                'ZipCode' => '0000'+String.valueOf(i)
            });
        }
        XC_LCC114_MassiveAssignmentWorkType.addOperation(listCombo, listAccount[0].Id);
        XC_LCC114_MassiveAssignmentWorkType.OutputWrapper result1 = XC_LCC114_MassiveAssignmentWorkType.getPartnerCoverage(listAccount[0].Id, 'Transfer', new List<String>{'00000'}, new List<String>{workType.Id});
        XC_LCC114_MassiveAssignmentWorkType.getPartnerCoveragePart2(listAccount[0].Id, JSON.serialize(result1));
        XC_LCC114_MassiveAssignmentWorkType.OutputWrapper result2 = XC_LCC114_MassiveAssignmentWorkType.getPartnerCoverage(listAccount[0].Id, 'Remove', new List<String>{'00000'}, new List<String>{workType.Id});
        XC_LCC114_MassiveAssignmentWorkType.getPartnerCoveragePart2(listAccount[0].Id, JSON.serialize(result2));
        XC_LCC114_MassiveAssignmentWorkType.OutputWrapper result3 = XC_LCC114_MassiveAssignmentWorkType.getPartnerCoverage(listAccount[0].Id, 'Remove', new List<String>(), new List<String>());
        XC_LCC114_MassiveAssignmentWorkType.getPartnerCoveragePart2(listAccount[0].Id, JSON.serialize(result3));

        Test.stopTest();
    }

        @isTest
    private static void onUtil2() {
                List<Account> listAccount = XC_DF_Account.insertPartnerAccounts(1);
        List<User> listUser = new List<User>([
            SELECT Id, Country__c, XC_LegalEntity__c
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ]);
        WorkType workType = new WorkType(
            Name = 'Commercial Visit - Boiler',
            XC_LegalEntity__c = listUser[0].XC_LegalEntity__c ,
            XC_WorkTypeCategory__c = 'Commercial Visit',
            DurationType = Label.XC_CL_WorkType_Hours,
            EstimatedDuration = 1,
            XC_Segment__c = 'B2C'
        );
        insert workType;
        List<XC_PartnerCoverage__c> listPc = new List<XC_PartnerCoverage__c>();
        listPc.add(new XC_PartnerCoverage__c(
            XC_Account__c = listAccount[0].Id,
            XC_ZipCode__c = '00000',
            XC_WorkType__c = workType.Id,
            XC_ExternalIdForDuplication__c = listAccount[0].Id+'_00000_'+workType.Id
        ));
        listPc.add(new XC_PartnerCoverage__c(
            XC_Account__c = listAccount[0].Id,
            XC_ZipCode__c = '00001',
            XC_WorkType__c = workType.Id,
            XC_ExternalIdForDuplication__c = listAccount[0].Id+'_00001_'+workType.Id,
            XC_ExternalId__c = '00001_'+workType.Id,
            XC_WorkTypeLabel__c = workType.Name
        ));
        insert listPc;
        List<Id> listPcIds = new List<Id>();
        for(XC_PartnerCoverage__c pc : listPc){
            listPcIds.add(pc.Id);
        }
        List<Object> listCombo = new List<Object>();
        listCombo.add(new Map<Object, Object>{
            'WorkType' => workType.Id,
            'ZipCode' => '00000'
        });
        List<Account> listAccountDestination = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResourcesFromAccount(listAccount);

        Test.startTest();
        XC_LCC114_MassiveAssignmentWorkType.getUserInformation();
        XC_LCC114_MassiveAssignmentWorkType.OutputWrapper outWrapper = XC_LCC114_MassiveAssignmentWorkType.initAddOperation(listAccount[0].Id);
        XC_LCC114_MassiveAssignmentWorkType.OutputWrapper resultAdd = XC_LCC114_MassiveAssignmentWorkType.addOperation(listCombo, listAccount[0].Id);
        for(Integer i=0; i<4001; i++) {
            listCombo.add(new Map<Object, Object>{
                'WorkType' => workType.Id,
                'ZipCode' => '0000'+String.valueOf(i)
            });
        }
        XC_LCC114_MassiveAssignmentWorkType.OutputWrapper resultTransfer = XC_LCC114_MassiveAssignmentWorkType.otherOperation(listPcIds, listAccount[0].Id, listAccountDestination[0].Id, 'Transfer');
        XC_LCC114_MassiveAssignmentWorkType.OutputWrapper resultRemove = XC_LCC114_MassiveAssignmentWorkType.otherOperation(listPcIds, listAccountDestination[0].Id, '', 'Remove');
        XC_LCC114_MassiveAssignmentWorkType.UploadWrapper upWrapper = new XC_LCC114_MassiveAssignmentWorkType.UploadWrapper();
        upWrapper.WorkTypeName = 'Commercial Visit - Boiler';
        upWrapper.PostalCode = '00001';
        XC_LCC114_MassiveAssignmentWorkType.UtilCSVWrapper cvsWrapper1 = XC_LCC114_MassiveAssignmentWorkType.uploadFileCsvOtherOperation(JSON.serialize(new List<XC_LCC114_MassiveAssignmentWorkType.UploadWrapper>{upWrapper}), listAccount[0].Id, listUser[0].XC_LegalEntity__c, true);
        XC_LCC114_MassiveAssignmentWorkType.UtilCSVWrapper cvsWrapper2 = XC_LCC114_MassiveAssignmentWorkType.uploadFileCsvOtherOperation(JSON.serialize(new List<XC_LCC114_MassiveAssignmentWorkType.UploadWrapper>{upWrapper}), listAccount[0].Id, listUser[0].XC_LegalEntity__c, false);
        XC_LCC114_MassiveAssignmentWorkType.UtilCSVWrapper cvsWrapper3 = XC_LCC114_MassiveAssignmentWorkType.uploadFileCsvAdd(listUser[0].XC_LegalEntity__c, new List<String>{'Commercial Visit - Boiler'}, listAccount[0].Id);
        // System.enqueueJob(new XC_LCC114_MassiveAssignmentWorkType_U.XC_Queueable_RemoveSRC());
        // System.enqueueJob(new XC_LCC114_MassiveAssignmentWorkType_U.XC_Queueable_CreateSRC());
        XC_ServiceResourceCoverage__c srcToInsert = new XC_ServiceResourceCoverage__c(
            XC_ServiceResourceId__c = listSr[0].Id,
            XC_WorkTypeId__c = workType.Id,
            XC_ZipCodeText__c = '00000'
        );
        System.enqueueJob(new XC_LCC114_MassiveAssignmentWorkType_U.XC_Queueable_CreateSRC(new List<XC_ServiceResourceCoverage__c>{srcToInsert}));
    }
    
    @isTest
    private static void onUtil3() {
     	List<Account> listAccount = XC_DF_Account.insertPartnerAccounts(1);
        List<User> listUser = new List<User>([
            SELECT Id, Country__c, XC_LegalEntity__c
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ]);
        WorkType workType = new WorkType(
            Name = 'Commercial Visit - Boiler',
            XC_LegalEntity__c = listUser[0].XC_LegalEntity__c ,
            XC_WorkTypeCategory__c = 'Commercial Visit',
            DurationType = Label.XC_CL_WorkType_Hours,
            EstimatedDuration = 1,
            XC_Segment__c = 'B2C'
        );
        insert workType;
        List<XC_PartnerCoverage__c> listPc = new List<XC_PartnerCoverage__c>();
        listPc.add(new XC_PartnerCoverage__c(
            XC_Account__c = listAccount[0].Id,
            XC_ZipCode__c = '00000',
            XC_WorkType__c = workType.Id,
            XC_ExternalIdForDuplication__c = listAccount[0].Id+'_00000_'+workType.Id
        ));
        listPc.add(new XC_PartnerCoverage__c(
            XC_Account__c = listAccount[0].Id,
            XC_ZipCode__c = '00001',
            XC_WorkType__c = workType.Id,
            XC_ExternalIdForDuplication__c = listAccount[0].Id+'_00001_'+workType.Id,
            XC_ExternalId__c = '00001_'+workType.Id,
            XC_WorkTypeLabel__c = workType.Name
        ));
        insert listPc;
        List<Object> listCombo = new List<Object>();
        listCombo.add(new Map<Object, Object>{
            'WorkType' => workType.Id,
            'ZipCode' => '00000'
        });
        List<Account> listAccountDestination = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResourcesFromAccount(listAccount);

        Test.startTest();
        XC_LCC114_MassiveAssignmentWorkType.getUserInformation();
        XC_LCC114_MassiveAssignmentWorkType.OutputWrapper outWrapper = XC_LCC114_MassiveAssignmentWorkType.initAddOperation(listAccount[0].Id);
        XC_LCC114_MassiveAssignmentWorkType.OutputWrapper resultAdd = XC_LCC114_MassiveAssignmentWorkType.addOperation(listCombo, listAccount[0].Id);
        for(Integer i=0; i<4001; i++) {
            listCombo.add(new Map<Object, Object>{
                'WorkType' => workType.Id,
                'ZipCode' => '0000'+String.valueOf(i)
            });
        }
        //XC_LCC114_MassiveAssignmentWorkType.populateWorkTypesForRemoveTransfer(new List<WorkType>{workType},listPc);
    }

    @isTest
    static void populateLogsWrapperTest(){
        XC_LCC114_MassiveAssignmentWorkType.populateLogsWrapper(true);
    }
}