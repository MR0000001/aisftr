/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 24/01/2020
* @description XC_TR_ServiceTerritoryMember_TEST – Test class for ServiceTerritoryMember Trigger
*/
@isTest
public without sharing class XC_TR_ServiceTerritoryMember_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        ServiceResource srQueried = [SELECT Id, XC_Account__c from ServiceResource limit 1];
        insert XC_DF_User.createUserAdmin();
        User u = [SELECT Id FROM User WHERE FirstName = 'TestUser'];
        ServiceResource serviceRes = new ServiceResource();
        serviceRes.Name = 'Test 2';
        serviceRes.XC_Account__c = srQueried.XC_Account__c;
        serviceRes.IsActive = true;
        serviceRes.IsCapacityBased = true;
        serviceRes.XC_IsManager__c = true;
        serviceRes.XC_LegalEntity__c = 'EndesaX';
        serviceRes.RelatedRecordId = u.Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
        insert serviceRes;
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: sr[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory]; 
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();   
        srtmemb.ServiceTerritoryId = srt[0].Id;
        srtmemb.ServiceResourceId = sr[0].Id;
        srtmemb.TerritoryType = 'P';
        srtmemb.EffectiveStartDate = DateTime.now();
        srtmemb.OperatingHoursId = opH.Id;
        insert srtmemb;
        ServiceTerritoryMember srtmemb2 = new ServiceTerritoryMember();   
        srtmemb2.ServiceTerritoryId = srt[0].Id;
        srtmemb2.ServiceResourceId = serviceRes.Id;
        srtmemb2.TerritoryType = 'P';
        srtmemb2.EffectiveStartDate = DateTime.now().addHours(-2);
        srtmemb2.OperatingHoursId = opH.Id;
        insert srtmemb2;
    }

    @isTest
    static void onUpdate (){
        Test.startTest();
        List<ServiceTerritoryMember> listOfSTM = new List<ServiceTerritoryMember> ([SELECT Id FROM ServiceTerritoryMember]);
        listOfSTM[0].TerritoryType = 'S';
        listOfSTM[0].XC_OperatingHoursNameSR__c = true;
        listOfSTM[1].XC_OperatingHoursNameSR__c = true;
        update listOfSTM;
        List<ServiceTerritoryMember> listOfSTM2 = [SELECT ServiceResourceId, OperatingHours.Name, ServiceResource.XC_LegalEntity__c, XC_OperatingHoursNameSR__c, OperatingHoursId
            FROM ServiceTerritoryMember];
        system.debug('@@@0501@@@a--> ' + listOfSTM2[0].ServiceResource.XC_LegalEntity__c);
        system.debug('@@@0501@@@b--> ' + listOfSTM2[0].OperatingHours.Name);
        System.assert(!listOfSTM.isEmpty());
        Test.stopTest();
    }

    @isTest
    static void onDeleteUndelete (){
        Test.startTest();
        List<ServiceTerritoryMember> listOfSTM = new List<ServiceTerritoryMember> ([SELECT Id FROM ServiceTerritoryMember]);
        delete listOfSTM;
        System.assert(!listOfSTM.isEmpty());
        Test.stopTest();
    }

}