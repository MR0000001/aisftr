/**
* @author Valentina De Blasio - valentina.de.blasio@accenture.com
* @date Creation 22/04/2022
* @description XC_TR_Contract_U_UpdateStatus_test class test update status wo and status serviceappoiment 
*/

@isTest
public class XC_TR_Contract_U_UpdateStatus_Test {
        @TestSetup
        static void onSetup() {
        
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1,'Active');
        List<Contact> cont=XC_DF_Contact.createPartnerContacts(accList);
       
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();
        caso.Status = 'ESTA001';
        caso.Reason = 'XCMOT002';
        caso.SubCause__c ='ATCL003';
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
        WorkType wt=XC_DF_WorkType.createWorkType('Delivery'); 
        wt.RecordTypeId = Schema.SObjectType.WorkType.getRecordTypeInfosByDeveloperName().get('CHL').getRecordTypeId();
        wt.XC_LegalEntity__c='Codensa';    
        insert wt;
        
        
        List<WorkOrder> wolist = new list<WorkOrder>();
         WorkOrder wo =new WorkOrder();
           
        wo.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo.XC_Segment__c='B2B';
        wo.XC_LegalEntity__c='EnelSole';
        wo.XC_WorkTypeCategory__c='Malfunctioning';
        wo.XC_WorkTypeLabel__c='Census - Juice Box';
        wo.Description='Test Prova';
        wo.BusinessLine__c='eCity';
        wo.WorkTypeId=wt.id;
        wo.caseId=caso.id; 
        insert wo;
        wolist.add(wo);
        
        
        List<ServiceAppointment>  servApp = XC_DF_ServiceAppointment.createServiceAppointment(wolist);
        servApp[0].country='Italy';
        servApp[0].XC_Segment__c='B2B';
        
        servApp[0].ParentRecordId=wolist[0].id;
        
        insert servApp;
        servApp[0].Status='';
        update servApp;
       
        Opportunity opps = new Opportunity();
        
        opps.XC_ServiceAppointment__c=servApp[0].id;
        opps.XC_WorkOrder__c=wolist[0].id;
        opps.AccountId =accList[0].id ;
        opps.XC_Contact__c = cont[0].id;
        opps.StageName = 'Draft';
        opps.Name='test';
        opps.CloseDate = Date.newInstance(2030, 12, 31);
        opps.XC_Source__c = '';
        opps.XC_ReceivingChannel__c = 'Web';
        opps.XC_LegalEntity__c = '';
        
        insert opps;
        Contract newContract= new Contract();       
        newContract.AccountId = accList[0].Id;
        newContract.StartDate= Date.today();
        newContract.ContractTerm= 1;
        newContract.XC_Signed__c=false;
        newContract.Opportunity__c=opps.id;
        insert newContract;
        opps.ContractId=newContract.Id;
        update opps;
        }
       
        static testMethod void checkstatus() {
        User u = XC_DF_User.createUserAdmin();
       
        
        list<Contract> cont=[select id,XC_Signed__c,Opportunity__r.XC_WorkOrder__c,Opportunity__r.XC_WorkOrder__r.CaseId, Opportunity__r.XC_WorkOrder__r.XC_LegalEntity__c, Opportunity__r.XC_WorkOrder__r.XC_WorkTypeCategory__c, Opportunity__r.XC_WorkOrder__r.XC_Segment__c, Opportunity__r.XC_WorkOrder__r.Case.XC_BusinessLine__c,Opportunity__r.XC_ServiceAppointment__c  
                             from Contract limit 1];           
        System.runAs(u){           
        cont[0].XC_Signed__c=true;
        update cont;
        Test.startTest();
        Map<Id, Contract> mapOld=new  Map<Id, Contract>();
        mapOld.put(cont[0].id,cont[0]);
        Map<Id, Contract> mapnew=new  Map<Id, Contract>();
        mapnew.put(cont[0].id,cont[0]);                
        XC_TR_Contract_U_UpdateStatus.checkStatus(mapOld,mapnew);
        Test.stopTest();
            }
        }
        }