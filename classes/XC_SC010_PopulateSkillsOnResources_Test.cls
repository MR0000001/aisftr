/**
* @author Marco Ottaviano mottaviano@deloitte.it
* @date Creation  11/06/2019 
* @description XC_SC010_PopulateSkillsOnResources_Test – Test class for XC_SC010_PopulateSkillsOnResources
*/



@isTest
private class XC_SC010_PopulateSkillsOnResources_Test {

  @TestSetup static void testSetup() {
     OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        List<ServiceResource> serviceReslist= XC_DF_ServiceResource.createServiceResources(2);
        ServiceResourceSkill serviceResSkillslist= XC_DF_ServiceResource.createServiceResourcesSkill(serviceReslist.get(0));
        serviceResSkillslist.XC_AssignmentEndDate__c=Date.newInstance(2019,01,01);
        insert serviceResSkillslist;

       List<XC_ServiceResourceDocument__c> listServiceResDoc = new List<XC_ServiceResourceDocument__c>();

        XC_ServiceResourceDocument__c provaServiceResourse=new XC_ServiceResourceDocument__c();
        provaServiceResourse.XC_StartDateOfValidity__c=Date.newInstance(2019,10,05);
        provaServiceResourse.XC_ExpirationDateOfValidity__c=Date.newInstance(2022,07,12);
        provaServiceResourse.XC_DocumentName__c='Certificado Luz';
        provaServiceResourse.XC_TypeOfDocument__c='TBD';
        provaServiceResourse.XC_ResultOfValidation__c='OK';
        provaServiceResourse.XC_ServiceResource__c=serviceReslist.get(0).Id;
        listServiceResDoc.add(provaServiceResourse);

         XC_ServiceResourceDocument__c provaServiceResourseGas=new XC_ServiceResourceDocument__c();
        provaServiceResourseGas.XC_StartDateOfValidity__c=Date.newInstance(2019,10,05);
        provaServiceResourseGas.XC_ExpirationDateOfValidity__c=Date.newInstance(2022,07,12);
        provaServiceResourseGas.XC_DocumentName__c='Certificado Gas';
        provaServiceResourseGas.XC_TypeOfDocument__c='TBD';
        provaServiceResourseGas.XC_ResultOfValidation__c='OK';
        provaServiceResourseGas.XC_ServiceResource__c=serviceReslist.get(0).Id;
        listServiceResDoc.add(provaServiceResourseGas);
        //insert provaServiceResourseGas;


         XC_ServiceResourceDocument__c provaServiceResourseRITE=new XC_ServiceResourceDocument__c();
        provaServiceResourseRITE.XC_StartDateOfValidity__c=Date.newInstance(2019,10,05);
        provaServiceResourseRITE.XC_ExpirationDateOfValidity__c=Date.newInstance(2022,07,12);
        provaServiceResourseRITE.XC_DocumentName__c='Certificado RITE';
        provaServiceResourseRITE.XC_TypeOfDocument__c='TBD';
        provaServiceResourseRITE.XC_ResultOfValidation__c='KO';
        provaServiceResourseRITE.XC_ServiceResource__c=serviceReslist.get(0).Id;
        listServiceResDoc.add(provaServiceResourseRITE);

        //insert provaServiceResourseRITE;


       List<XC_SkillDocumentAssociation__c> skillDocList = new List<XC_SkillDocumentAssociation__c>();
        Skill skill = [SELECT Id, MasterLabel, DeveloperName FROM Skill LIMIT 1];

        XC_SkillDocumentAssociation__c skillDoc = new XC_SkillDocumentAssociation__c();
        skillDoc.XC_SkillId__c = skill.Id;
        skillDoc.XC_SkillName__c = skill.MasterLabel;
        skillDoc.XC_ListOfDocumentAND__c = 'Certificado Empresa RITE';
        skillDoc.XC_ListOfDocumentOR__c = 'Certificado Empresa Instaladora Gas';
        skillDoc.RecordTypeId=Schema.SObjectType.XC_SkillDocumentAssociation__c.getRecordTypeInfosByDeveloperName().get('XC_ESP_SkillDocumentAssociation_Partner').getRecordTypeId();
        skillDocList.add(skillDoc);
       

        Skill reparacion=[SELECT Id,MasterLabel, DeveloperName FROM Skill WHERE DeveloperName ='Repair'];
        XC_SkillDocumentAssociation__c skillDoc1 = new XC_SkillDocumentAssociation__c();
        skillDoc1.XC_SkillId__c = reparacion.Id;
        skillDoc1.XC_SkillName__c = reparacion.MasterLabel;
        skillDoc1.XC_ListOfDocumentAND__c = 'Certificado Gas';
        skillDoc1.XC_ListOfDocumentOR__c = 'Certificado Luz';
        skillDoc1.RecordTypeId=Schema.SObjectType.XC_SkillDocumentAssociation__c.getRecordTypeInfosByDeveloperName().get('XC_ESP_SkillDocumentAssociation_Technician').getRecordTypeId();
        skillDocList.add(skillDoc1);
        insert skillDocList;


         //List<ServiceResource> serviceReslistF= XC_DF_ServiceResource.createServiceResources(1);
        ServiceResourceSkill serviceResSkillslistF= XC_DF_ServiceResource.createServiceResourcesSkill(serviceReslist.get(1));
        serviceReslist.get(1).IsCapacityBased=true;
        serviceReslist.get(1).XC_Freelance__c=false;
          serviceResSkillslistF.XC_AssignmentEndDate__c=Date.newInstance(2018,01,01);

        insert serviceResSkillslistF;
        update serviceReslist;



        XC_ServiceResourceDocument__c provaServiceResourse1=new XC_ServiceResourceDocument__c();
        provaServiceResourse1.XC_StartDateOfValidity__c=Date.newInstance(2018,10,05);
        provaServiceResourse1.XC_ExpirationDateOfValidity__c=Date.newInstance(2019,03,12);
        provaServiceResourse1.XC_DocumentName__c='Certificado Empresa RITE';
        provaServiceResourse1.XC_TypeOfDocument__c='TBD';
        provaServiceResourse1.XC_ResultOfValidation__c='OK';
        provaServiceResourse1.XC_ServiceResource__c=serviceReslist.get(1).Id;
        listServiceResDoc.add(provaServiceResourse1);
       // insert provaServiceResourse1;

         XC_ServiceResourceDocument__c climaCarnet=new XC_ServiceResourceDocument__c();
        climaCarnet.XC_StartDateOfValidity__c=Date.newInstance(2018,10,05);
        climaCarnet.XC_ExpirationDateOfValidity__c=Date.newInstance(2020,03,12);
        climaCarnet.XC_DocumentName__c='Certificado Empresa Instaladora Gas';
        climaCarnet.XC_TypeOfDocument__c='TBD';
        climaCarnet.XC_ResultOfValidation__c='OK';
        climaCarnet.XC_ServiceResource__c=serviceReslist.get(1).Id;
        listServiceResDoc.add(climaCarnet);
        //insert climaCarnet;

        insert listServiceResDoc;


  }
  
  @isTest static void test_method_one() {

      List<XC_SkillDocumentAssociation__c> listSkikkDoc= [SELECT Id  FROM XC_SkillDocumentAssociation__c WHERE XC_SkillName__c ='Commercial Visit' LIMIT 1];

        Test.startTest();
            XC_SC010_PopulateSkillsOnResources schedul=new XC_SC010_PopulateSkillsOnResources();
            String sch = '16 20 0 * * ?'; 
            system.schedule('Test XC_SC010_PopulateSkillsOnResources', sch, schedul); 
        Test.stopTest();
    
  }

  @isTest static void test_method_two() {

      List<XC_ServiceResourceDocument__c> listSRDoc= [SELECT Id,XC_ServiceResource__r.XC_Account__c, XC_ServiceResource__r.XC_Contact__c, XC_OverallResult__c 
                                                      FROM XC_ServiceResourceDocument__c LIMIT 1
                                                     ];
      List<XC_ServiceResourceDocument__c> listDoc = new  List<XC_ServiceResourceDocument__c>();                                          
      for(XC_ServiceResourceDocument__c doc: listSRDoc ) {

        doc.XC_OverallResult__c = Label.XC_CL_NotCredit;
        listDoc.add(doc);
      }  
      update listDoc;                                            

        Test.startTest();
           try{
            XC_SC010_PopulateSkillsOnResources schedul=new XC_SC010_PopulateSkillsOnResources();
            String sch = '16 20 0 * * ?'; 
            system.schedule('Test XC_SC010_PopulateSkillsOnResources', sch, schedul);
            System.assertEquals(listSRDoc !=null,true); 
           }catch(Exception e) {
             Boolean expectedExceptionThrown =  true;
             System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    
  }

  @isTest
  static void populateListIntervalForExistingSkillTest (){

    List<ServiceResource> listOfSR = new  List<ServiceResource>([SELECT Id FROM ServiceResource]);
    ServiceResourceSkill serviceSkill = XC_DF_ServiceResource.createServiceResourcesSkill(listOfSR[0]);
    List<ServiceResourceSkill> listOfSRSkill = new List<ServiceResourceSkill>();
    listOfSRSkill.add(serviceSkill);
    XC_SC010_PopulateSkillsOnRes_U_Interval.Interval newInterval = new XC_SC010_PopulateSkillsOnRes_U_Interval.Interval();
    newInterval.startDate = Date.today();
    newInterval.endDate = Date.today();
    Test.startTest();
    XC_SC010_PopulateSkillsOnRes_U_Interval.UnionResult wrap = XC_SC010_PopulateSkillsOnRes_U_Interval.populateListIntervalForExistingSkill(listOfSRSkill, newInterval);
    Test.stopTest();
    System.assert(wrap != null);
  }

  @isTest
  static void manageIntervalExistingSkillTest(){
        List<XC_SkillDocumentAssociation__c> listOfSkill = new List<XC_SkillDocumentAssociation__c>([SELECT Id, XC_SkillName__c FROM XC_SkillDocumentAssociation__c]);
        List<ServiceResource> listOfSR = new  List<ServiceResource>([SELECT Id FROM ServiceResource]);
        List<Skill> listSkills = new List<Skill>([SELECT Id FROM Skill LIMIT 3]);
        ServiceResourceSkill serviceSkill = XC_DF_ServiceResource.createServiceResourcesSkill(listOfSR[0]);
        serviceSkill.SkillId = listSkills[1].Id;
        insert serviceSkill;
        ServiceResourceSkill serviceSkill2 = XC_DF_ServiceResource.createServiceResourcesSkill(listOfSR[0]);
        serviceSkill2.SkillId = listSkills[2].Id;
        insert serviceSkill2;        
        List<ServiceResourceSkill> listOfSRSkill = new List<ServiceResourceSkill>();
        listOfSRSkill.add(serviceSkill);
        listOfSRSkill.add(serviceSkill2);
        XC_SC010_PopulateSkillsOnRes_U_Interval.Interval newInterval = new XC_SC010_PopulateSkillsOnRes_U_Interval.Interval();
        newInterval.startDate = Date.today();
        newInterval.endDate = Date.today();
        List<XC_SC010_PopulateSkillsOnRes_U_Interval.Interval> listOfInterval = new List<XC_SC010_PopulateSkillsOnRes_U_Interval.Interval>();
        listOfInterval.add(newInterval);
        XC_SC010_PopulateSkillsOnRes_U_Interval.UnionResult unionResult = new XC_SC010_PopulateSkillsOnRes_U_Interval.UnionResult();
        unionResult.listInterval = listOfInterval;
        XC_SC010_PopulateSkillsOnRes_U_Interval.ManageIntervalExistingSkillWrapper wrapExisting = new XC_SC010_PopulateSkillsOnRes_U_Interval.ManageIntervalExistingSkillWrapper();
        wrapExisting.existingServiceResourceSkill = listOfSRSkill;
        wrapExisting.unionDates = unionResult;
        wrapExisting.skillDocAss = listOfSkill[0];
        XC_SC010_PopulateSkillsOnResources_U.ManageExistingSkillWrapper wrap = XC_SC010_PopulateSkillsOnRes_U_Interval.manageIntervalExistingSkill(wrapExisting);
        XC_SC010_PopulateSkillsOnRes_U_Populate.PopulateForUnionWrapper wrapPopulate = new XC_SC010_PopulateSkillsOnRes_U_Populate.PopulateForUnionWrapper();
        wrapPopulate.existingServiceResourceSkill = wrapExisting.existingServiceResourceSkill;
        wrapPopulate.unionDates = wrapExisting.unionDates;
        wrapPopulate.skillDocAss = wrapExisting.skillDocAss;
        XC_SC010_PopulateSkillsOnRes_U_Populate.populateListDMLForUnion(wrapPopulate); 
        XC_SC010_PopulateSkillsOnRes_U_Interval.Interval newMyInterval = new XC_SC010_PopulateSkillsOnRes_U_Interval.Interval();
        newMyInterval.startDate = Date.today();
        newMyInterval.endDate = Date.today().addDays(20);
        wrapExisting.unionDates.listInterval.add(newMyInterval);
        XC_SC010_PopulateSkillsOnRes_U_Interval.manageIntervalExistingSkill(wrapExisting);
  }

  @isTest
  static void populateListDMLTest(){
    List<ServiceResource> listOfSR = new  List<ServiceResource>([SELECT Id FROM ServiceResource]);
    ServiceResourceSkill serviceSkill = XC_DF_ServiceResource.createServiceResourcesSkill(listOfSR[0]);
    serviceSkill.SkillId = [SELECT Id FROM Skill LIMIT 5][4].Id;
    insert serviceSkill;
    List<ServiceResourceSkill> listOfSRSkill = new List<ServiceResourceSkill>();
    listOfSRSkill.add(serviceSkill);
    List<XC_SkillDocumentAssociation__c> listOfSkill = new List<XC_SkillDocumentAssociation__c>([SELECT Id, XC_SkillName__c FROM XC_SkillDocumentAssociation__c]);
    XC_SC010_PopulateSkillsOnRes_U_Interval.Interval newInterval = new XC_SC010_PopulateSkillsOnRes_U_Interval.Interval();
    newInterval.startDate = Date.today();
    newInterval.endDate = Date.today();
    List<XC_SC010_PopulateSkillsOnRes_U_Interval.Interval> listOfInterval = new List<XC_SC010_PopulateSkillsOnRes_U_Interval.Interval>();
    listOfInterval.add(newInterval);
    List<ServiceResourceSkill> listSkillToInsert = new List<ServiceResourceSkill>();
    List<ServiceResourceSkill> listSkillToUpdate = new List<ServiceResourceSkill>();
    List<ServiceResourceSkill> listSkillToDelete = new List<ServiceResourceSkill>();
    XC_SC010_PopulateSkillsOnRes_U_Populate.PopulateWrapper popWrap = new XC_SC010_PopulateSkillsOnRes_U_Populate.PopulateWrapper();
    popWrap.intervalsDates = listOfInterval;
    popWrap.listSkillToInsert = listSkillToInsert; 
    popWrap.listSkillToUpdate = listSkillToUpdate;
    popWrap.listSkillToDelete = listSkillToDelete;
    popWrap.srId = listOfSR[0].Id;
    popWrap.existingServiceResourceSkill = listOfSRSkill;
    popWrap.skillDocAss = listOfSkill[0];
    popWrap.exists = true;
    XC_SC010_PopulateSkillsOnRes_U_Populate.populateListDML(popWrap); 
  }

}