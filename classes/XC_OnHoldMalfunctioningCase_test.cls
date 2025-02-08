/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 12/03/2021
* @description Test class for XC_OnHoldMalfunctioningCase 
*/
@isTest
public class XC_OnHoldMalfunctioningCase_test {
    
    @testSetup 
    static void methodName(){
        
        User u = XC_DF_User.createUserAdmin();
        u.Country__c = 'ITALY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXItalia';
        insert u;
        
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true);
        XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true);
        insert accounts;
        
        List<XC_Address__c> addr = XC_DF_Address.createAddress(accounts);
        XC_TR_Address_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true);
        XC_TR_Address_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true);
        insert addr;
        
        List<Contact> listContact = XC_DF_Contact.createResidentialContacts(accounts);
        XC_TR_Contact_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true);
        XC_TR_Contact_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true);
        insert listContact;        

        
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Malfunctioning');
        insert workTypeToInsert;
        
        Id recordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByName().get('XC_ITA_Management_Case').getRecordTypeId();
        List<Asset> ass=XC_DF_Asset.createAssets(1);
        ass[0].AccountId = accounts[0].Id;
        ass[0].TAM_IsTechnical__c=true;
        ass[0].XC_Segment__c='B2B';
        ass[0].XC_Product_Subtype__c='Charging Station';
        ass[0].XC_LegalEntity__c='EnelXItalia';
        ass[0].XC_Address__c= addr[0].id;
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true);
        XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true);
        insert ass;
        
        system.runAs(u){
            List<Case> listc = XC_DF_Case.createCases(1);
            //listc[0].Status = 'ESTA001';
            listc[0].XC_Subtype__c = 'XC199';
            listc[0].Reason = 'XCMOT002';
            listc[0].Subcause__c = 'ATCL003' ;
            listc[0].ContactId = listContact[0].Id;
            listc[0].AccountId = accounts[0].Id;
            listc[0].RecordTypeId=recordTypeId;
            insert listc;
            //listc[0].EntitlementId=ent.id;
            
            Case child=new Case();
            // child.XC_TechnicalAsset__c= ass[0].id;
            child.XC_Segment__c='B2C';
            child.ParentId=listc[0].id;
            child.XC_LegalEntity__c='EnelXItalia';
            
            child.AccountId=listContact[0].AccountId;
            child.ContactId=listContact[0].id;
            child.RecordTypeId=recordTypeId;
            XC_UTIL_Trigger.stopTriggerInTestClass= true;
            XC_TR_Case_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true);
            XC_TR_Case_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true);
            insert  child;
            XC_TR_Case_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, false);
            XC_TR_Case_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, false);
                
            id rtIdB2B =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();
            listc[0].XC_TechnicalAsset__c= ass[0].id;
            listc[0].XC_BusinessLine__c='eCity';
            listc[0].RecordTypeId=rtIdB2B;
            listc[0].XC_Segment__c='B2B';
            listc[0].XC_LegalEntity__c='EnelXItalia';
            listc[0].XC_Force_Work_Order_creation__c=TRUE;
            update listc;
            
            List<WorkOrder> workOrderList = new List<WorkOrder>();
            WorkOrder workOrderToInsert = new WorkOrder();
            workOrderToInsert.Status='New';
            workOrderToInsert.XC_Segment__c='B2B';
            workOrderToInsert.XC_WorkTypeCategory__c = 'Malfunctioning';
            workOrderToInsert.WorkTypeId = workTypeToInsert.Id;
            workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
            workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
            workOrderToInsert.XC_Address__c = addr[0].Id;
            workOrderToInsert.Street = addr[0].XC_Address__c;
            workOrderToInsert.XC_Digitized__c = true;
            workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
            workOrderToInsert.CaseId=listc[0].id;
            workOrderToInsert.AssetId=ass[0].id;
            workOrderList.add(workOrderToInsert);
            insert workOrderList;       
        }
    }
    
    
    static testMethod void onHoldMalfunctioning(){
        
        Test.startTest();
        User u = [Select id FROM user where XC_legalEntity__c ='EnelXItalia' order by createddate desc limit 1];
        system.runAs(u){

            List<Case> listc=[select id, ParentId from case where RecordType.Name = 'XC_ITA_Management_Case' order by createddate desc limit 1];           
            Case child=listc[0];
            id rtIdB2B2 =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();
            child.XC_BusinessLine__c='eCity';
            child.RecordTypeId=rtIdB2B2;
            update child;
                      
            WorkOrder workOrderToInsert=[select id, status from WorkOrder where caseId=:listc[0].ParentId order by createddate desc limit 1];
            workOrderToInsert.XC_DueDate__c=datetime.now();
            workOrderToInsert.Status='Assigned';
            //START VDB valentina.de.blasio@accenture.com RC 760
            workOrderToInsert.XC_LegalEntity__c='EnelSole';
            workOrderToInsert.XC_WorkTypeCategory__c='Malfunctioning' ;
            workOrderToInsert.XC_Segment__c='B2B';
            workOrderToInsert.StartDate=date.today();
            workOrderToInsert.EndDate=date.today()+1;
            //END VDB valentina.de.blasio@accenture.com RC 760
            update workOrderToInsert;
            
            workOrderToInsert.Status='On Hold';
            update workOrderToInsert;
            workOrderToInsert.Status='In Progress';
            update workOrderToInsert;
            System.assertEquals(true, listc!=null);
            Test.stopTest();
        }
    }
}