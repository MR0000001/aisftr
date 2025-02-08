@istest
public class XC_TR_WorkOrder_U_AssignSRProv_test {

  @testSetup
  static void setup() {
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1,'Active');
        List<Contact> cont=XC_DF_Contact.createPartnerContacts(accList);
        User u = XC_DF_User.createUserAdmin();
        u.XC_EnabledToSkip__c=true;
        insert u; 
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);     
        insert opp;  
        test.startTest();
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();
        caso.Status = 'ESTA001';
        caso.Reason = 'XCMOT002';
        caso.SubCause__c ='ATCL003';
        caso.XC_Opportunity__c= opp[0].id;
        caso.XC_LegalEntity__c = 'EnelXItalia';
        caso.OwnerId=Userinfo.getUserId();
        caso.AccountId =accList[0].id ;
        caso.ContactId = cont[0].id;
        caso.XC_Type_Intermediary__c = 'TI001';
        caso.Origin='CAN0008';
        caso.XC_Subtype__c='XC199';
        caso.XC_BusinessLine__c='eCity';
        caso.Country__c='Italy';
        caso.XC_Segment__c ='B2B';
        insert caso;
        System.runas(u){  
        List<WorkOrder> wo=XC_DF_WorkOrder.createWorkOrders(1,'Malfunctioning');      
        wo[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo[0].XC_Segment__c='B2B';
        wo[0].XC_LegalEntity__c='EnelSole';
        wo[0].XC_WorkTypeLabel__c='Census - Juice Box';
        wo[0].Description='Test Prova';
        wo[0].caseid=caso.id;
        wo[0].OwnerId=caso.OwnerId;
        wo[0].XC_PreferredPartner__c=accList[0].id;
        insert wo; 
        ServiceResource sr = new ServiceResource();
        sr.Name='test';
        sr.AccountId=accList[0].id;
        sr.IsActive= true;
        sr.RelatedRecordId=u.id;
        sr.ResourceType='T';
        insert sr;
        
        /*ResourcePreference rp = new ResourcePreference();
        rp.PreferenceType='Required';
        rp.RelatedRecordId= wo[0].Id;
        rp.ServiceResourceId= sr.Id;
        insert rp;*/
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(wo);
        insert listSa;     
        test.stopTest();
        }
}
@isTest
public static void insertSRtoProvider() {
  test.startTest();
 List<WorkOrder> listWorder=[Select id from WorkOrder limit 1];
  Map<id,WorkOrder> mapord = new Map<id,WorkOrder>();
  mapord.put(listWorder.get(0).id,listWorder.get(0));
  XC_TR_WorkOrder_U_AssignSRProv.insertSRtoProvider(mapord);
  test.stopTest();
}
}