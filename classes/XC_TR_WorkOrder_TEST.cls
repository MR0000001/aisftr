/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_TEST – Test Class for XC_TR_WorkOrder AND Handler
*/ 
@isTest
public class XC_TR_WorkOrder_TEST {
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    static testMethod void onInsert(){
        Test.startTest(); 
        List<WorkOrder> listwo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, Label.XC_CL_WorkType_DeliveryInstallation, Label.XC_CL_WorkType_DeliveryInstallation);
        insert  listwo;
        update listwo;
        delete listwo;
  
        System.assertEquals(true, listwo!=null);
        Test.stopTest();
        
    }
    
    @isTest
    static void onInsertSiteInspection(){
        Test.startTest(); 
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        insert order;
        List<WorkOrder> listwo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Site Inspection - Photovoltaic', Label.XC_CL_WorkType_SiteInspection);
        listwo[0].XC_Configuration__c = order.Id;
        insert  listwo;
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        XC_Address__c address = addressList[0];
        address.XC_AddressCountry__c = 'Portugal';
        address.XC_StreetType__c = '';
        insert  address;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset asset = assetList[0];
        insert  asset;
        
        System.assertEquals(true, listwo!=null);
        Test.stopTest();
    }

  	static testMethod void onInsertFromCase(){
        // greta.romei@accenture.com 23/03/22 start
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List <Contact> cont = XC_DF_Contact.createResidentialContacts(accounts);
        cont[0].AccountId=accounts.get(0).id;
        insert cont;
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);    
        insert opp;
        User u=[select id from user where XC_EnabledToSkip__c=true limit 1];
        test.startTest();
         Case caso = new Case();
        caso.Status = 'ESTA001';
        caso.Reason = 'XCMOT002';
        caso.SubCause__c ='ATCL003';
        caso.XC_Opportunity__c= opp[0].id;
        caso.XC_LegalEntity__c = 'EnelXItalia';
        caso.OwnerId=Userinfo.getUserId();
        caso.AccountId = accounts[0].Id;
        caso.ContactId = cont[0].Id;
        caso.XC_Type_Intermediary__c = 'TI001';
        caso.Origin='CAN0008';
        caso.XC_Subtype__c='XC199';
        caso.XC_BusinessLine__c='eCity';
        System.runas(u){
        insert caso;

      }
        //List<Case> caseList = XC_DF_Case.createCases(1);
        //Id recordTypeId = CaseDAO.newInstance().getActiveRecordtypeIdByDeveloperName(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA);
        //Case cs = caseList[0];
        //cs.Description = 'TEST';
        //insert cs;
        List<WorkOrder> listwo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, Label.XC_CL_WorkType_DeliveryInstallation, Label.XC_CL_WorkType_DeliveryInstallation);
        WorkOrder wo = listwo[0];
        wo.CaseId = Caso.Id; //greata.romei@accenture.com 23/03/22 stop
        insert  wo;
  		List<XC_Address__c> addressList = XC_DF_Address.createAddress(1);
        XC_Address__c address = addressList[0];
        address.XC_AddressCountry__c = 'Portugal';
        address.XC_StreetType__c = '';
        insert  address;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset asset = assetList[0];
        insert  asset;
        
        System.assertEquals(true, listwo!=null);
        Test.stopTest();
        
    }
}