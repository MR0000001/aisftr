@Istest
/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @createdDate 06/11/2020
* @description classes. XC_TR_Case_CallYourban
*/
public class XC_TR_Case_CallYourban_Test {

	 @TestSetup
    static void setup(){
		User itAdmin = XC_DF_User.createUserAdmin();
        itAdmin.XC_LegalEntity__c = 'EnelXItalia';
        itAdmin.XC_LegalEntities__c = 'EnelXItalia';
        insert itAdmin;
     }
	 
    testMethod static void callYourban(){
	 User itAdmin = [SELECT Id FROM USER WHERE XC_LegalEntity__c ='EnelXItalia' LIMIT 1];
	  System.runAs(itAdmin) {
		 test.startTest();
		List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
		List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
		cont[0].AccountId=accList.get(0).id;
		accList[0].XC_NDADocumentNeeded__c=true;
		accList[0].XC_ContactToNotify__c=cont[0].id;
		accList[0].XC_Segment__c ='B2B';
		insert accList;
		List <Contract> contr= XC_DF_Contract.createCondominiumContract(accList);
		insert contr; 
		List<XC_Address__c> addr = XC_DF_Address.createAddress(accList);
		insert addr;
		 List<Asset> assCom = XC_DF_Asset.createAssets(1);
			//ass[0].XC_Contract__c= cont[0].id;
			//ass[0].AssetServicedById=accList[0].id;
			assCom[0].XC_Address__c= addr[0].id;
			assCom[0].serialnumber='1823747';
			assCom[0].TAM_PartnerContractId__c='ok';
			assCom[0].TAM_IsTechnical__c= true;
			assCom[0].TAM_IsLogical__c=true;
			assCom[0].AccountId= accList[0].id;
			assCom[0].XC_Segment__c='B2B';
			assCom[0].XC_LegalEntity__c='EnelXItalia';
			insert assCom;
		List<Asset> ass=XC_DF_Asset.createAssets(1);
		ass[0].serialnumber='1823747';
		ass[0].XC_Address__c= addr[0].id;
		ass[0].XC_Contract__c= contr[0].id;
		ass[0].AccountId = accList[0].Id;
		ass[0].XC_Segment__c='B2B';
		ass[0].TAM_IsLogical__c=true;
        ass[0].XC_LegalEntity__c='EnelXItalia';
		ass[0].TAM_CommercialAsset__c=assCom[0].id;
		insert ass;
        List<Asset> ass2=XC_DF_Asset.createAssets(1);
		ass2[0].serialnumber='18237472';
		ass2[0].XC_Address__c= addr[0].id;
		ass2[0].XC_Contract__c= contr[0].id;
		ass2[0].AccountId = accList[0].Id;
		ass2[0].XC_Segment__c='B2B';
		ass2[0].TAM_IsLogical__c=true;
        ass2[0].XC_LegalEntity__c='EnelXItalia';
		ass2[0].TAM_CommercialAsset__c=assCom[0].id;
		insert ass2;  
		List<Case> listCases=XC_DF_Case.createCases(1);
		listCases[0].AccountId= accList[0].id;
		listCases[0].ContactId= cont[0].id;
		listCases[0].AssetId=ass[0].id;
		listCases[0].Reason='XCMOT002';
		listCases[0].SubCause__c='ATCL003';
		listCases[0].XC_Subtype__c='XC199';
		listcases[0].Origin='CAN001';
		XC_WorkOrderActivityPlanItem__c woa=new XC_WorkOrderActivityPlanItem__c();
			woa.XC_WorkType__c='Malfunctioning';
			woa.XC_RecordType__c='XC_ITA_Woli_ManualDialing';
			woa.XC_Country__c='Italy';
			woa.XC_CompletionMode__c='Manual Dialing';
			woa.XC_TechnicianResponse__c='Without Defect/With Defect';
			woa.XC_WorkType__c='Malfunctioning';
			insert woa;
		listCases[0].XC_BusinessLine__c='eCity';
		//listCases[0].XC_TechnicalAsset__c=ass[0].id; 
		listcases[0].XC_Force_Work_Order_creation__c=TRUE;
		listCases[0].XC_Segment__c ='B2B';
          insert listCases;
           case oldCase =  listCases[0].clone(true,false,false,false); 
          Map<id,Case> oldMap=new Map<id,Case>();
          oldMap.put(oldCase.id,oldCase);
          listCases[0].XC_TechnicalAsset__c=ass[0].id;
          listcases[0].XC_Asset_B2B__c=ass[0].id;
          listCases[0].Status='ESTA002';
          update listCases;
      XC_TR_Case_CallYourban.callOnUpdate(listCases,oldMap);
		test.stopTest();
	}
}
    testMethod static void callYourbanInsert(){
         User itAdmin = [SELECT Id FROM USER WHERE XC_LegalEntity__c ='EnelXItalia' LIMIT 1];
	  System.runAs(itAdmin) {
		 test.startTest();
		List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
		List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
		cont[0].AccountId=accList.get(0).id;
		accList[0].XC_NDADocumentNeeded__c=true;
		accList[0].XC_ContactToNotify__c=cont[0].id;
		accList[0].XC_Segment__c ='B2B';
		insert accList;
		List <Contract> contr= XC_DF_Contract.createCondominiumContract(accList);
		insert contr; 
		List<XC_Address__c> addr = XC_DF_Address.createAddress(accList);
		insert addr;
		 List<Asset> assCom = XC_DF_Asset.createAssets(1);
			//ass[0].XC_Contract__c= cont[0].id;
			//ass[0].AssetServicedById=accList[0].id;
			assCom[0].XC_Address__c= addr[0].id;
			assCom[0].serialnumber='1823747';
			assCom[0].TAM_PartnerContractId__c='ok';
			assCom[0].TAM_IsTechnical__c= true;
			assCom[0].TAM_IsLogical__c=true;
			assCom[0].AccountId= accList[0].id;
			assCom[0].XC_Segment__c='B2B';
			assCom[0].XC_LegalEntity__c='EnelXItalia';
			insert assCom;
		List<Asset> ass=XC_DF_Asset.createAssets(1);
		ass[0].serialnumber='1823747';
		ass[0].XC_Address__c= addr[0].id;
		ass[0].XC_Contract__c= contr[0].id;
		ass[0].AccountId = accList[0].Id;
		ass[0].XC_Segment__c='B2B';
		ass[0].TAM_IsLogical__c=true;
        ass[0].XC_LegalEntity__c='EnelXItalia';
		ass[0].TAM_CommercialAsset__c=assCom[0].id;
		insert ass;
        List<Asset> ass2=XC_DF_Asset.createAssets(1);
		ass2[0].serialnumber='18237472';
		ass2[0].XC_Address__c= addr[0].id;
		ass2[0].XC_Contract__c= contr[0].id;
		ass2[0].AccountId = accList[0].Id;
		ass2[0].XC_Segment__c='B2B';
		ass2[0].TAM_IsLogical__c=true;
        ass2[0].XC_LegalEntity__c='EnelXItalia';
		ass2[0].TAM_CommercialAsset__c=assCom[0].id;
		insert ass2;  
        
		XC_WorkOrderActivityPlanItem__c woa=new XC_WorkOrderActivityPlanItem__c();
			woa.XC_WorkType__c='Malfunctioning';
			woa.XC_RecordType__c='XC_ITA_Woli_ManualDialing';
			woa.XC_Country__c='Italy';
			woa.XC_CompletionMode__c='Manual Dialing';
			woa.XC_TechnicianResponse__c='Without Defect/With Defect';
			woa.XC_WorkType__c='Malfunctioning';
			insert woa;
		List<Case> listCases=XC_DF_Case.createCases(1);
		listCases[0].AccountId= accList[0].id;
		listCases[0].ContactId= cont[0].id;
		listCases[0].Reason='XCMOT002';
		listCases[0].SubCause__c='ATCL003';
		listCases[0].XC_Subtype__c='XC199';
		listcases[0].Origin='CAN001';
		listCases[0].XC_BusinessLine__c='eCity';
		listCases[0].XC_TechnicalAsset__c=ass[0].id; 
		listcases[0].XC_Force_Work_Order_creation__c=TRUE;
		listCases[0].XC_Segment__c ='B2B';
          insert listCases;
         XC_TR_Case_CallYourban.callOnInsert(listCases);
    } 
  }
}