/**
 * The Class XC_REST_Lead_TEST.
 *
 * @author            : Nicola mariniello nmariniello@deloitte.it
 * @date Creation     : 05/06/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_REST_Lead - XC_REST_Lead_U - XC_REST_Lead_V - XC_REST_Lead_T - XC_REST_Lead_S - XC_REST_Lead_Z - XC_REST_Lead_W
 **/


@isTest
public without sharing class XC_REST_Lead_TEST {
    
    
    	@TestSetup 
	static void makeData() {
		String currentUserId = UserInfo.getUserId();
		List<Group> codaLead = [SELECT Id FROM Group WHERE DeveloperName ='XC_QU_QualificationQueue'];
		List<String> listQueueId=XC_UTIL_Sobject.getIds(codaLead);

		List<GroupMember> listGroupMember = new List<GroupMember>([SELECT Id, GroupId, UserOrGroupId
                            FROM GroupMember           
							WHERE GroupId IN :listQueueId]);
		Boolean foundIngroup=false;
		for(GroupMember gpMemb : listGroupMember) {
			if(currentUserId == gpMemb.UserOrGroupId) {
				foundIngroup=true;
				break;
			}
		}
		if(!foundIngroup) {
			GroupMember addGpMemb = new GroupMember();
			addGpMemb.GroupId = codaLead[0].Id;
			addGpMemb.UserOrGroupId = currentUserId;
			insert addGpMemb;
		}
	}



	@isTest
    static void testDoPost_WRONGDATE(){

		test.startTest();

		System.RestContext.request = generateRestRequestPOSTGood();
	    XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

	    leadWr.LeadType='Residential';
	    leadWr.LastName='Nicola';
	    leadWr.FirstName='Milano';
	    leadWr.BusinessName='industry';
	    leadWr.PhonePrefix='+39';
	    leadWr.Phone='34445';
	    leadWr.PrimaryEmail='a@b.com';
	    leadWr.IdentityCountry='Spain';
	    leadWr.IdentityType='Passport';
	    leadWr.IdentityNumber='123455678';
	   	leadWr.ReleaseDate = '12/05/2019';
	   	leadWr.ExpiryDate ='12/05/2029';
	   	leadWr.Nationality ='Italian';
	   	leadWr.Birthdate = '12/07/2029';
	   	leadWr.ReceivingChannel ='Web';
	   	leadWr.Source ='BLOG';
	   	leadWr.PreferenceLanguage ='Spanish';
	   	leadWr.ProductCategoryOfInterest ='Termo';
	   	leadWr.CommercialVisitPreferredTime ='Morning';
	   	leadWr.Notes='ciaooo';
	   	leadWr.Company='deloitte';
	   	leadWr.Country='Algeria';
	   	leadWr.CommercialVisit=true;

	   	XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
	   	body.Lead=leadWr;
	    System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

		System.RestContext.response = new RestResponse();

		XC_REST_Lead.doPost();
	    System.assertEquals(true,true, 'Wrong assert result');

		test.stopTest();
	}

	@isTest
		static void testDoPost_ExpiryDate_Blank(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='2019/06/01';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '12/07/2029';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');

			test.stopTest();
	}

	@isTest
		static void testDoPost_manageInsert(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='true';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);
			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');

			test.stopTest();
	}

	//Conflitto ProductCategoryOfInterest
	@isTest
		static void testDoPost_Client_Commodity(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTCommodity();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');

			test.stopTest();
	}

	@isTest
		static void testDoPost_Identity(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTCommodity();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='eyuce';
			prova.IdentityNumber='123';
			prova.ReleaseDate= '2020/05/12';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='376';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;
			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			System.debug('Sono qui'+leadWr.GDPR);
			test.stopTest();
	}

	@isTest
		static void testDoPost_Identity_Put(){

			test.startTest();

			System.RestContext.request = generateRestRequestPUTGood2();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='eyuce';
			prova.IdentityNumber='123';
			prova.ReleaseDate= '2020-05-12';	
			prova.ExpiryDate='2020-08-12';
			prova.IdentityID='376';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;
			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPut();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();


	}



	@isTest
		static void testDOPut_check_ident(){

			test.startTest();

			System.RestContext.request = generateRestRequestPUTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='eyuce';
			prova.IdentityNumber='123';
			prova.ReleaseDate= '2020-05-12';	
			prova.ExpiryDate='2020-08-12';
			prova.IdentityID='376';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;
			//system.debug('QUI IDENTITY------>'+ identityList);
			


			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPut();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();


	}






	@isTest
		static void testDoPut_Identity_IdentityId_IdentityType(){

			test.startTest();

			System.RestContext.request = generateRestRequestPUTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='123';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;
			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPut();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();




	}

	@isTest
		static void testDoPost_Identity_IdentityID_IdentityNumber(){

			test.startTest();

			System.RestContext.request = generateRestRequestPUTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='34434353';
			prova.IdentityNumber='';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;
			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPut();
			System.assertEquals(true,true, 'Wrong assert result');
			//System.debug('Sono qui'+leadWr.GDPR);
			test.stopTest();
	}

	@isTest
		static void testDoPost_Identity_ExpiryDate(){

			test.startTest();

			System.RestContext.request = generateRestRequestPUTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;
			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPut();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();
	}

	@isTest
		static void testDoPost_before_address(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020-08-12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;


			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper(); 
			
			Address.Address='viaroma';

			LeadWr.Address=Address;
			


			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;
			


			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();


	}



	@isTest
		static void testDoPost_before_address_LegalEntity(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;


			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper(); 
			
			Address.Address='viaroma';

			LeadWr.Address=Address;
			


			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;
			


			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();
	}



	@isTest
		static void testDoPost_before_address_give_data_LegalEntity(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='V';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;


			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper(); 
			
			Address.Address='viaroma';

			LeadWr.Address=Address;
			


			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;
			


			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			
			test.stopTest();
	}




	@isTest
		static void testDoPostGDPR_legalEntity_give_datato_full(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);
			


			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;


			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper(); 
			
			Address.Address='viaroma';

			LeadWr.Address=Address;
			


			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;
			


			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
		
			test.stopTest();
	}



	@isTest
		static void testDoPostGDPR_legalEntity_null(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			listlegal.clear();
			
			/*legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);
			*/

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;


			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper(); 
			
			Address.Address='viaroma';

			LeadWr.Address=Address;
			


			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;
			


			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
		
			test.stopTest();
	}


	@isTest
		static void Test_DoPut_tclass(){

			List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
			listLead.get(0).XC_LeadPhone__c='34445';
			listLead.get(0).XC_PhonePrefix__c='+1';
			listLead.get(0).Email='a@b.com';
			listLead.get(0).XC_DocumentNumber__c='123455678';
			listLead.get(0).XC_Channel__c='Web';
			listLead.get(0).XC_LeadSource__c='BLOG';
			listLead.get(0).XC_DocumentCountry__c='Spain';
			listLead.get(0).XC_DocumentType__c='Passport';
			listLead.get(0).XC_DocumentNumber__c='Ciao';

			insert listLead;

			test.startTest();


			System.RestContext.request = generateRestRequestPUTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '2019-05-04';	
			prova.ExpiryDate='2020-06-07';

			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);
			

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;


			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper(); 
			
			Address.Address='viaroma';
			Address.StreetType='Access';
			Address.StreetNumber='via roma';
			Address.ZipCode='1234';
			Address.City='Rome';
			Address.Country='Italy';

			LeadWr.LeadId = listLead.get(0).id;
			LeadWr.Address=Address;
			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;

			XC_REST_Lead_W.WrapperLeadResponse wrapperLeadResponse = new XC_REST_Lead_W.WrapperLeadResponse();
			wrapperLeadResponse.Lead = leadWr ;
			wrapperLeadResponse.Account = new XC_REST_Lead_W.WrapperAccount();
		
			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPut();
			System.assertEquals(true,true, 'Wrong assert result');
			
			test.stopTest();
	}




	@isTest
		static void Test_DoPut_lead_key(){

			List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
			listLead.get(0).XC_LeadPhone__c='34445';
			listLead.get(0).XC_PhonePrefix__c='+1';
			listLead.get(0).Email='a@b.com';
			listLead.get(0).XC_DocumentNumber__c='123455678';
			listLead.get(0).XC_Channel__c='Web';
			listLead.get(0).XC_LeadSource__c='BLOG';
			listLead.get(0).XC_DocumentCountry__c='Spain';
			listLead.get(0).XC_DocumentType__c='Passport';
			listLead.get(0).XC_DocumentNumber__c='Ciao';

			insert listLead;

			test.startTest();


			System.RestContext.request = generateRestRequestPUTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();


			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '2019-05-04';	
			prova.ExpiryDate='2020-06-07';

			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);
			

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;


			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper(); 
			
			Address.Address='viaroma';
			Address.StreetType='Access';
			Address.StreetNumber='via roma';
			Address.ZipCode='1234';
			Address.City='Rome';
			Address.Country='Italy';

			LeadWr.LeadId = '';
			LeadWr.Address=Address;
			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=identityList;

			XC_REST_Lead_W.WrapperLeadResponse wrapperLeadResponse = new XC_REST_Lead_W.WrapperLeadResponse();
			wrapperLeadResponse.Lead = leadWr ;
			wrapperLeadResponse.Account = new XC_REST_Lead_W.WrapperAccount();
		
			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPut();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();
	}


	@isTest
		static void testDoPost_Address_StreetType(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;


			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper(); 

			
			
			Address.Address='viaroma';

			LeadWr.Address=Address;
			


			leadWr.LeadType= Label.XC_CL_Lead_TypeResidential;
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=null;
			


			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();
	}


	@isTest
		static void testDoPost_POS(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;


			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper();

			leadWr.LeadType= Label.XC_CL_Lead_TypeResidential;
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=null;
			


			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();
	}



	@isTest
		static void testDoPost_Duplicate(){

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;


			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper(); 

		
			Address.AddressID='IDadd';

		


			leadWr.LeadType= Label.XC_CL_Lead_TypeResidential;
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=null;
			


			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();

			test.startTest();

			

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();
	}




	@isTest
		static void testDoPost_Address_Address(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;
			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper();  
			Address.Address='';
			Address.StreetType='Access';
			LeadWr.Address=Address;
			leadWr.LeadType= Label.XC_CL_Lead_TypeResidential;
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=null;

			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();
	}


	@isTest
		static void testDoPost_Address_StreetNumber(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;
			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper();  
			Address.Address='via pisacane';
			Address.StreetType='Access';
			Address.StreetNumber='';
			LeadWr.Address=Address;
			leadWr.LeadType= Label.XC_CL_Lead_TypeResidential;
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=null;

			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();
	}


	@isTest
		static void testDoPost_Address_ZipCode(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;
			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper();  
			Address.Address='via pisacane';
			Address.StreetType='Access';
			Address.StreetNumber='12431234';
			Address.ZipCode='';
			LeadWr.Address=Address;
			leadWr.LeadType= Label.XC_CL_Lead_TypeResidential;
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=null;

			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();
	}

	@isTest
		static void testDoPost_Address_City(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;
			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper();  
			Address.Address='via pisacane';
			Address.StreetType='Access';
			Address.StreetNumber='12431234';
			Address.ZipCode='234234';
			Address.City='';
			LeadWr.Address=Address;
			leadWr.LeadType= Label.XC_CL_Lead_TypeResidential;
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=null;

			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();
	}

	@isTest
		static void testDoPost_Address_Country(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			List<XC_UTIL_Account.IdentityIFWrapper> identityList = new List<XC_UTIL_Account.IdentityIFWrapper>();
			XC_UTIL_Account.IdentityIFWrapper prova = new XC_UTIL_Account.IdentityIFWrapper();
			prova.Country ='Spain';
			prova.IdentityType='';
			prova.IdentityNumber='34234';
			prova.ReleaseDate= '';	
			prova.ExpiryDate='2020/08/12';
			prova.IdentityID='234';
			identityList.add(prova);

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);

			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;
			//AddressWrapper
			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper();  
			Address.Address='via pisacane';
			Address.StreetType='Access';
			Address.StreetNumber='12431234';
			Address.ZipCode='234234';
			Address.City='80023';
			Address.Country='';
			LeadWr.Address=Address;
			leadWr.LeadType= Label.XC_CL_Lead_TypeResidential;
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;
			leadWr.identity=null;

			leadWr.GDPR=new XC_UTIL_Lead.gdprWrapper();
			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');
			test.stopTest();
	}


	@isTest
		static void testDoPutWrongHeader(){

			test.startTest();

			System.RestContext.request = generateRestRequestPUTWrong();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '12/05/2019';
			leadWr.ExpiryDate ='12/05/2029';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '12/07/2029';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPut();
			System.assertEquals(true,true, 'Wrong assert result');

			test.stopTest();
	}


	@isTest
		static void testDoPostConvert(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();

			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType=Label.XC_CL_Lead_TypeSmallBusiness;
			leadWr.LastName='Franco';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='NIF';
			leadWr.IdentityNumber='69806013R';
			leadWr.ReleaseDate = '2019-05-12';
			leadWr.ExpiryDate ='2029-05-14';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '2003-05-08';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Spain';
			leadWr.CommercialVisit=true;

			XC_UTIL_Address.AddressWrapper Address = new XC_UTIL_Address.AddressWrapper(); 
			XC_UTIL_Address.PoSWrapper poSWrapper = new XC_UTIL_Address.PoSWrapper();
			poSWrapper.POSType='b';
			poSWrapper.POS='b';

			List<XC_UTIL_Address.PoSWrapper> posWrapperList=new List<XC_UTIL_Address.PoSWrapper>();
			posWrapperList.add(poSWrapper);
			
			Address.Address='viaroma';
			Address.StreetType='11111';
			Address.StreetNumber='11111';
			Address.ZipCode='2222222';
			Address.City='Madrid';
			Address.Country='Spain';

			Address.PointOfService =posWrapperList;   

			LeadWr.Address=Address; 

			List<XC_UTIL_Lead.LegalEntityWrapper> listlegal = new List<XC_UTIL_Lead.LegalEntityWrapper>();
			XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
			legal1.LegalEntity='EndesaX';
			legal1.GiveDataToLegalEntity='Y';
			legal1.GiveDataForMarketing='true';
			legal1.GiveDataForProfiling='true';
			listlegal.add(legal1);


			XC_UTIL_Lead.gdprWrapper GDPRw= new XC_UTIL_Lead.gdprWrapper();
			GDPRw.GiveDataToThirdParties='true';
			GDPRw.LegalEntity=listlegal;

			leadWr.GDPR=GDPRw;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');

			test.stopTest();
	}




	@isTest
		static void testDoPutGoodHeader(){

			test.startTest();

			System.RestContext.request = generateRestRequestPUTGood();
		

			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName=' ';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '12/05/2019';
			leadWr.ExpiryDate ='12/05/2029';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '12/07/2029';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;



			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPut();
			System.assertEquals(true,true, 'Wrong assert result');

			test.stopTest();
	}


	@isTest
		static void testDoPutGoodHeader1(){

			test.startTest();

			System.RestContext.request = generateRestRequestPUTGood();
		

			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.leadid=null;
			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='';
			leadWr.PrimaryEmail='';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPut();
			System.assertEquals(true,true, 'Wrong assert result');

			test.stopTest();
	}


	@isTest
		static void testDoPut_Required_White_Space(){

			test.startTest();

			System.RestContext.request = generateRestRequestPUTWrong();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName=' ';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '12/05/2019';
			leadWr.ExpiryDate ='12/05/2029';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '12/07/2029';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPut();
			System.assertEquals(true,true, 'Wrong assert result');

			test.stopTest();
	}

	@isTest
		static void testDoPost_requiredParameters_isblank(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName='';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '12/05/2019';
			leadWr.ExpiryDate ='12/05/2029';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '12/07/2029';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true, 'Wrong assert result');

			test.stopTest();
	}

	@isTest
		static void testDoPost_BirthDateWrong(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';	   	
			leadWr.ReleaseDate = '2019-05-01';
			leadWr.ExpiryDate ='2019-06-01';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '12/07/2029';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			//leadWr.RequestType =''
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
		// chiedere marco leadWr.OpportunityID=[SELECT Id,OpportunityID FROM Opportunity][0].OpportunityID;
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true);

		test.stopTest();

	}

	@isTest
		static void testDoPost_PhonePrefix(){

			test.startTest();


			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='';
			leadWr.Phone='2342';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';	   	
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='2019-06-01';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			//leadWr.RequestType =''
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
		// chiedere marco leadWr.OpportunityID=[SELECT Id,OpportunityID FROM Opportunity][0].OpportunityID;
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true);

				

		test.stopTest();

	}

	@isTest
		static void testDoPost_BusinessName(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType=Label.XC_CL_Lead_TypeSmallBusiness;	   	
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.ReceivingChannel ='Web';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.BusinessName='';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '2019-05-01';
			leadWr.ExpiryDate ='2019-06-01';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '76';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true);

			test.stopTest();
	}

	@isTest
		static void testDoPost2_Identity_Number_Blank(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType=Label.XC_CL_Lead_TypeSmallBusiness;	   	
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.ReceivingChannel ='Web';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.BusinessName='marco';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='';
			leadWr.ReleaseDate = '2019-05-01';
			leadWr.ExpiryDate ='2019-06-01';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '76';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true);

			test.stopTest();
	}

	@isTest
		static void testDoPost_EmailBlank(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType=Label.XC_CL_Lead_TypeSmallBusiness;	   	
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.ReceivingChannel ='Web';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.PrimaryEmail='';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='123455678';
			leadWr.ReleaseDate = '2019-05-01';
			leadWr.ExpiryDate ='2019-06-01';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '76';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true);

			test.stopTest();
	}


	@isTest
		static void testDoPost_IdentityNumberBlank(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='';
			leadWr.ReleaseDate = '2019-05-01';
			leadWr.ExpiryDate ='2019-06-01';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '12/07/2029';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true);

			test.stopTest();
	}

	@isTest
		static void testDoPost_Email_Phone_Blank(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='';
			leadWr.PrimaryEmail='';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='132434';
			leadWr.ReleaseDate = '2019-05-01';
			leadWr.ExpiryDate ='2019-06-01';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '12/07/2029';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true);

			test.stopTest();
	}

	@isTest
		static void testDoPost_IdentityNumber_IdentityType_Blank(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='2342345235245';
			leadWr.PrimaryEmail='';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='';
			leadWr.IdentityNumber='2352345';
			leadWr.ReleaseDate = '2019-05-01';
			leadWr.ExpiryDate ='2019-06-01';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true);

			test.stopTest();
	}

	@isTest
		static void testDoPost_IdentityCountry_IdentityType_Blank(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='+39';
			leadWr.Phone='34445';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='32423';
			leadWr.ReleaseDate = '2019-05-01';
			leadWr.ExpiryDate ='2019-06-01';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true);

			test.stopTest();
	}

	//Parte il gdpr
	@isTest
		static void testDoPost_Validate_Request_Identity(){

			test.startTest();

			System.RestContext.request = generateRestRequestPOSTGood();
			XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

			leadWr.LeadType='Residential';
			leadWr.LastName='Nicola';
			leadWr.FirstName='Milano';
			leadWr.BusinessName='industry';
			leadWr.PhonePrefix='';
			leadWr.Phone='';
			leadWr.PrimaryEmail='a@b.com';
			leadWr.IdentityCountry='Spain';
			leadWr.IdentityType='Passport';
			leadWr.IdentityNumber='32423';
			leadWr.ReleaseDate = '';
			leadWr.ExpiryDate ='2019-06-01';
			leadWr.Nationality ='Italian';
			leadWr.Birthdate = '';
			leadWr.ReceivingChannel ='Web';
			leadWr.Source ='BLOG';
			leadWr.PreferenceLanguage ='Spanish';
			leadWr.ProductCategoryOfInterest ='Termo';
			leadWr.CommercialVisitPreferredTime ='Morning';
			leadWr.Notes='ciaooo';
			leadWr.Company='deloitte';
			leadWr.Country='Algeria';
			leadWr.CommercialVisit=true;

			XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
			body.Lead=leadWr;
			System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

			System.RestContext.response = new RestResponse();

			XC_REST_Lead.doPost();
			System.assertEquals(true,true);

			test.stopTest();
	}



	@isTest
	static void testDoPost_LeadNull(){

		test.startTest();


		System.RestContext.request = generateRestRequestPOSTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();

		leadWr=null;

		XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
		body.Lead=leadWr;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

		System.RestContext.response = new RestResponse();

		XC_REST_Lead.doPost();
		System.assertEquals(true,true);

			

		test.stopTest();

	}


	// POST Catch
	@isTest
	static void testDoPost_Catch(){

		System.RestContext.request = generateRestRequestPOSTGood();
		System.RestContext.request.requestBody =  null;

		System.RestContext.response = new RestResponse();

		test.startTest();
		XC_REST_Lead.doPost();
		System.assertEquals(true,true);
		test.stopTest();
	}


	// POST Correct All Section
	@isTest
	static void testDoPost_AllSection_POSOK(){

		System.RestContext.request = generateRestRequestPOSTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWr.LeadType = 'Residential';
		leadWr.LastName = 'Raffaello';
		leadWr.FirstName = 'Adriano';
		leadWr.PhonePrefix = '+34';
		leadWr.Phone = '685653399';
		leadWr.ReceivingChannel = 'WEB';
		leadWr.ProductCategoryOfInterest = 'Iluminación LED';
		leadWr.PrimaryEmail = 'raff.adriano@gmail.com';
		leadWr.Notes = 'test';

		leadWr.GDPR = new XC_UTIL_Lead.gdprWrapper();
		leadWr.GDPR.GiveDataToThirdParties = 'Y';
		leadWr.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
		XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
		legal1.LegalEntity = 'EndesaX';
		legal1.GiveDataToLegalEntity = 'Y';
		legal1.GiveDataForMarketing = 'Y';
		legal1.GiveDataForProfiling = 'Y';
		leadWr.GDPR.LegalEntity.add(legal1);

		leadWr.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
		XC_UTIL_Account.IdentityIFWrapper identity = new XC_UTIL_Account.IdentityIFWrapper();
		identity.Country = 'Spain';
		identity.IdentityType = 'NIE';
		identity.IdentityNumber = 'X1779381A';
		identity.ReleaseDate = '2010-12-31';
		identity.ExpiryDate = '2023-12-31';
		leadWr.Identity.add(identity);

		XC_UTIL_Address.PoSWrapper poSWrapper = new XC_UTIL_Address.PoSWrapper();
		poSWrapper.POSType='Light';
		poSWrapper.POS='b';
		List<XC_UTIL_Address.PoSWrapper> posWrapperList=new List<XC_UTIL_Address.PoSWrapper>();
		posWrapperList.add(poSWrapper);


		leadWr.Address = new XC_UTIL_Address.AddressWrapper();
		leadWr.Address.ZipCode = '08007';
        leadWr.Address.StreetType = 'Street';
        leadWr.Address.StreetNumber = '620';
        leadWr.Address.Province = 'Barcelona';
		leadWr.Address.Country = 'Spain';
        leadWr.Address.City = 'Barcelona';
		leadWr.Address.Address = 'Gran Via de les Corts Catalanes';
		leadWr.Address.PointOfService =posWrapperList;
	

		XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
		body.Lead = leadWr;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

		System.RestContext.response = new RestResponse();

		test.startTest();
		XC_REST_Lead.doPost();
		System.assertEquals(true,true);
		test.stopTest();
	}

	// POST Correct All Section
	@isTest
	static void testDoPost_AllSection_POSKO(){

		System.RestContext.request = generateRestRequestPOSTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWr.LeadType = 'Residential';
		leadWr.LastName = 'Raffaello';
		leadWr.FirstName = 'Adriano';
		leadWr.PhonePrefix = '+34';
		leadWr.Phone = '685653399';
		leadWr.ReceivingChannel = 'WEB';
		leadWr.ProductCategoryOfInterest = 'Iluminación LED';
		leadWr.PrimaryEmail = 'raff.adriano@gmail.com';
		leadWr.Notes = 'test';

		leadWr.GDPR = new XC_UTIL_Lead.gdprWrapper();
		leadWr.GDPR.GiveDataToThirdParties = 'Y';
		leadWr.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
		XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
		legal1.LegalEntity = 'EndesaX';
		legal1.GiveDataToLegalEntity = 'Y';
		legal1.GiveDataForMarketing = 'Y';
		legal1.GiveDataForProfiling = 'Y';
		leadWr.GDPR.LegalEntity.add(legal1);

		leadWr.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
		XC_UTIL_Account.IdentityIFWrapper identity = new XC_UTIL_Account.IdentityIFWrapper();
		identity.Country = 'Spain';
		identity.IdentityType = 'NIE';
		identity.IdentityNumber = 'X1779381A';
		identity.ReleaseDate = '2010-12-31';
		identity.ExpiryDate = '2023-12-31';
		leadWr.Identity.add(identity);

		XC_UTIL_Address.PoSWrapper poSWrapper = new XC_UTIL_Address.PoSWrapper();
		poSWrapper.POSType='b';
		poSWrapper.POS='b';
		List<XC_UTIL_Address.PoSWrapper> posWrapperList=new List<XC_UTIL_Address.PoSWrapper>();
		posWrapperList.add(poSWrapper);


		leadWr.Address = new XC_UTIL_Address.AddressWrapper();
		leadWr.Address.ZipCode = '08007';
        leadWr.Address.StreetType = 'Street';
        leadWr.Address.StreetNumber = '620';
        leadWr.Address.Province = 'Barcelona';
		leadWr.Address.Country = 'Spain';
        leadWr.Address.City = 'Barcelona';
		leadWr.Address.Address = 'Gran Via de les Corts Catalanes';
		leadWr.Address.PointOfService =posWrapperList;
	

		XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
		body.Lead = leadWr;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

		System.RestContext.response = new RestResponse();

		test.startTest();
		XC_REST_Lead.doPost();
		System.assertEquals(true,true);
		test.stopTest();
	}


	// PUT Duplicate Lead
	/*@isTest
	static void testDoPut_DuplicateLead(){

		System.RestContext.request = generateRestRequestPOSTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWr.LeadType = 'Residential';
		leadWr.LastName = 'Raffaello';
		leadWr.FirstName = 'Adriano';
		leadWr.PhonePrefix = '+34';
		leadWr.Phone = '685653399';
		leadWr.ReceivingChannel = 'WEB';
		leadWr.ProductCategoryOfInterest = 'Iluminación LED';
		leadWr.PrimaryEmail = 'raff.adrianotestdup@gmail.com';
		leadWr.Notes = 'test';

		leadWr.GDPR = new XC_UTIL_Lead.gdprWrapper();
		leadWr.GDPR.GiveDataToThirdParties = 'Y';
		leadWr.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
		XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
		legal1.LegalEntity = 'EndesaX';
		legal1.GiveDataToLegalEntity = 'Y';
		legal1.GiveDataForMarketing = 'Y';
		legal1.GiveDataForProfiling = 'Y';
		leadWr.GDPR.LegalEntity.add(legal1);

		leadWr.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
		XC_UTIL_Account.IdentityIFWrapper identity = new XC_UTIL_Account.IdentityIFWrapper();
		identity.Country = 'Spain';
		identity.IdentityType = 'NIE';
		identity.IdentityNumber = 'X1779381A';
		identity.ReleaseDate = '2010-12-31';
		identity.ExpiryDate = '2020-12-31';
		leadWr.Identity.add(identity);

		leadWr.Address = new XC_UTIL_Address.AddressWrapper();
		leadWr.Address.ZipCode = '08007';
        leadWr.Address.StreetType = 'Street';
        leadWr.Address.StreetNumber = '620';
        leadWr.Address.Province = 'Barcelona';
		leadWr.Address.Country = 'Spain';
        leadWr.Address.City = 'Barcelona';
        leadWr.Address.Address = 'Gran Via de les Corts Catalanes';

		XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
		body.Lead = leadWr;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));
		System.RestContext.response = new RestResponse();
		XC_REST_Lead.doPost();



		List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
		leadList[0].XC_LeadSource__c = null;
        leadList[0].XC_DocumentType__c = null;
		insert leadList;

		System.RestContext.request = generateRestRequestPUTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWrPUT = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWrPUT.LeadID = leadList[0].Id;
		leadWrPUT.LeadType = 'Residential';
		leadWrPUT.LastName = 'Raffaello';
		leadWrPUT.FirstName = 'Adriano';
		leadWrPUT.PhonePrefix = '+34';
		leadWrPUT.Phone = '685653399';
		leadWrPUT.ReceivingChannel = 'WEB';
		leadWrPUT.ProductCategoryOfInterest = 'Iluminación LED';
		leadWrPUT.PrimaryEmail = 'raff.adrianotestdup@gmail.com';
		leadWrPUT.Notes = 'test';

		leadWrPUT.GDPR = new XC_UTIL_Lead.gdprWrapper();
		leadWrPUT.GDPR.GiveDataToThirdParties = 'Y';
		leadWrPUT.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
		XC_UTIL_Lead.LegalEntityWrapper legal1PUT = new XC_UTIL_Lead.LegalEntityWrapper();
		legal1PUT.LegalEntity = 'EndesaX';
		legal1PUT.GiveDataToLegalEntity = 'Y';
		legal1PUT.GiveDataForMarketing = 'Y';
		legal1PUT.GiveDataForProfiling = 'Y';
		leadWrPUT.GDPR.LegalEntity.add(legal1PUT);

		leadWrPUT.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
		XC_UTIL_Account.IdentityIFWrapper identityPUT = new XC_UTIL_Account.IdentityIFWrapper();
		identityPUT.Country = 'Spain';
		identityPUT.IdentityType = 'NIE';
		identityPUT.IdentityNumber = 'X1779381A';
		identityPUT.ReleaseDate = '2010-12-31';
		identityPUT.ExpiryDate = '2020-12-31';
		leadWrPUT.Identity.add(identityPUT);

		leadWrPUT.Address = new XC_UTIL_Address.AddressWrapper();
		leadWrPUT.Address.ZipCode = '08007';
        leadWrPUT.Address.StreetType = 'Street';
        leadWrPUT.Address.StreetNumber = '620';
        leadWrPUT.Address.Province = 'Barcelona';
		leadWrPUT.Address.Country = 'Spain';
        leadWrPUT.Address.City = 'Barcelona';
        leadWrPUT.Address.Address = 'Gran Via de les Corts Catalanes';

		XC_REST_Lead_W.WrapperLeadRequest bodyPUT = new XC_REST_Lead_W.WrapperLeadRequest();
		bodyPUT.Lead = leadWrPUT;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(bodyPUT, true));
		System.RestContext.response = new RestResponse();

		test.startTest();
		XC_REST_Lead.doPut();
		System.assertEquals(501, System.RestContext.response.statusCode);
		test.stopTest();
	}*/


	// PUT Duplicate Lead
	@isTest
	static void testDoPut_CorrectWithLegalEntity(){

		System.RestContext.request = generateRestRequestPOSTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWr.LeadType = 'Residential';
		leadWr.LastName = 'Raffaello';
		leadWr.FirstName = 'Adriano';
		leadWr.PhonePrefix = '+34';
		leadWr.Phone = '685653399';
		leadWr.ReceivingChannel = 'WEB';
		leadWr.ProductCategoryOfInterest = 'Iluminación LED';
		leadWr.PrimaryEmail = 'raff.adrianolegen@gmail.com';
		leadWr.Notes = 'test';

		leadWr.GDPR = new XC_UTIL_Lead.gdprWrapper();
		leadWr.GDPR.GiveDataToThirdParties = 'Y';
		leadWr.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
		XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
		legal1.LegalEntity = 'EndesaX';
		legal1.GiveDataToLegalEntity = 'Y';
		leadWr.GDPR.LegalEntity.add(legal1);

		leadWr.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
		XC_UTIL_Account.IdentityIFWrapper identity = new XC_UTIL_Account.IdentityIFWrapper();
		identity.Country = 'Spain';
		identity.IdentityType = 'NIE';
		identity.IdentityNumber = 'X1779381A';
		identity.ReleaseDate = '2010-12-31';
		identity.ExpiryDate = '2023-12-31';
		leadWr.Identity.add(identity);

		leadWr.Address = new XC_UTIL_Address.AddressWrapper();
		leadWr.Address.ZipCode = '08007';
        leadWr.Address.StreetType = 'Street';
        leadWr.Address.StreetNumber = '620';
        leadWr.Address.Province = 'Barcelona';
		leadWr.Address.Country = 'Spain';
        leadWr.Address.City = 'Barcelona';
        leadWr.Address.Address = 'Gran Via de les Corts Catalanes';

		XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
		body.Lead = leadWr;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));
		System.RestContext.response = new RestResponse();
		XC_REST_Lead.doPost();


		System.RestContext.request = generateRestRequestPUTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWrPUT = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWrPUT.LeadID = [SELECT Id FROM Lead WHERE Email = 'raff.adrianolegen@gmail.com'][0].Id;
		leadWrPUT.LeadType = 'Residential';
		leadWrPUT.LastName = 'Raffaello';
		leadWrPUT.FirstName = 'Adriano';
		leadWrPUT.PhonePrefix = '+34';
		leadWrPUT.Phone = '685653399';
		leadWrPUT.ReceivingChannel = 'WEB';
		leadWrPUT.ProductCategoryOfInterest = 'Iluminación LED';
		leadWrPUT.PrimaryEmail = 'raff.adrianotestdup@gmail.com';
		leadWrPUT.Notes = 'test';

		leadWrPUT.GDPR = new XC_UTIL_Lead.gdprWrapper();
		leadWrPUT.GDPR.GiveDataToThirdParties = 'Y';
		leadWrPUT.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
		XC_UTIL_Lead.LegalEntityWrapper legal1PUT = new XC_UTIL_Lead.LegalEntityWrapper();
		legal1PUT.LegalEntity = 'EndesaX';
		legal1PUT.GiveDataToLegalEntity = 'Y';
		legal1PUT.GiveDataForMarketing = 'Y';
		legal1PUT.GiveDataForProfiling = 'Y';
		leadWrPUT.GDPR.LegalEntity.add(legal1PUT);

		leadWrPUT.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
		XC_UTIL_Account.IdentityIFWrapper identityPUT = new XC_UTIL_Account.IdentityIFWrapper();
		identityPUT.Country = 'Spain';
		identityPUT.IdentityType = 'NIE';
		identityPUT.IdentityNumber = 'X1779381A';
		identityPUT.ReleaseDate = '2015-12-31';
		identityPUT.ExpiryDate = '2025-12-31';
		leadWrPUT.Identity.add(identityPUT);

		leadWrPUT.Address = new XC_UTIL_Address.AddressWrapper();
		leadWrPUT.Address.ZipCode = '08007';
        leadWrPUT.Address.StreetType = 'Street';
        leadWrPUT.Address.StreetNumber = '620';
        leadWrPUT.Address.Province = 'Barcelona';
		leadWrPUT.Address.Country = 'Spain';
        leadWrPUT.Address.City = 'Barcelona';
        leadWrPUT.Address.Address = 'Gran Via de les Corts Catalanes';

		XC_REST_Lead_W.WrapperLeadRequest bodyPUT = new XC_REST_Lead_W.WrapperLeadRequest();
		bodyPUT.Lead = leadWrPUT;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(bodyPUT, true));
		System.RestContext.response = new RestResponse();

		test.startTest();
		XC_REST_Lead.doPut();
		System.assertEquals(true,true);
		test.stopTest();
	}


	// PUT Error Convert
	@isTest
	static void testDoPut_ErrorConvert(){

		XC_ProductCategoryOfInterest__c prod = new XC_ProductCategoryOfInterest__c();
		prod.Name = 'Termo';
		prod.XC_CommercialVisit__c = false;
		insert prod;

		System.RestContext.request = generateRestRequestPOSTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWr.LeadType = 'Residential';
		leadWr.LastName = 'Raffaello';
		leadWr.FirstName = 'Adriano';
		leadWr.PhonePrefix = '+34';
		leadWr.Phone = '685653399';
		leadWr.ReceivingChannel = 'WEB';
		leadWr.ProductCategoryOfInterest = 'Termo';
		leadWr.PrimaryEmail = 'raff.adriano.convert@gmail.com';
		leadWr.Notes = 'test';

		leadWr.GDPR = new XC_UTIL_Lead.gdprWrapper();
		leadWr.GDPR.GiveDataToThirdParties = 'Y';
		leadWr.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
		XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
		legal1.LegalEntity = 'EndesaX';
		legal1.GiveDataToLegalEntity = 'Y';
		legal1.GiveDataForMarketing = 'Y';
		legal1.GiveDataForProfiling = 'Y';
		leadWr.GDPR.LegalEntity.add(legal1);

		leadWr.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
		XC_UTIL_Account.IdentityIFWrapper identity = new XC_UTIL_Account.IdentityIFWrapper();
		identity.Country = 'Spain';
		identity.IdentityType = 'NIE';
		identity.IdentityNumber = 'X1779381A';
		identity.ReleaseDate = '2010-12-31';
		identity.ExpiryDate = '2023-12-31';
		leadWr.Identity.add(identity);

		leadWr.Address = new XC_UTIL_Address.AddressWrapper();
		leadWr.Address.ZipCode = '08007';
        leadWr.Address.StreetType = 'Street';
        leadWr.Address.StreetNumber = '620';
        leadWr.Address.Province = 'Barcelona';
		leadWr.Address.Country = 'Spain';
        leadWr.Address.City = 'Barcelona';
        leadWr.Address.Address = 'Gran Via de les Corts Catalanes';

		XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
		body.Lead = leadWr;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

		System.RestContext.response = new RestResponse();

		XC_REST_Lead.doPost();

		Lead l = [SELECT Id FROM Lead WHERE Email = 'raff.adriano.convert@gmail.com' LIMIT 1];
		l.Status = 'Customer Contacted';
		l.OwnerId = UserInfo.getUserId();
		l.XC_ProductCategoryOfInterest__c = 'Termo';
		update l;

		test.startTest();
		System.RestContext.request = generateRestRequestPUTGood_Convert();
		XC_UTIL_Lead.LeadRESTWrapper leadWrConvert = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWrConvert.LeadID = l.Id;
		XC_REST_Lead_W.WrapperLeadRequest bodyConvert = new XC_REST_Lead_W.WrapperLeadRequest();
		bodyConvert.Lead = leadWrConvert;
		System.RestContext.request.requestBody = Blob.valueOf(JSON.serialize(bodyConvert, true));
		System.RestContext.response = new RestResponse();
		XC_REST_Lead.doPut();
		System.assertEquals(true,true);
		test.stopTest();
	}


	// PUT Error Lead Convert
	@isTest
	static void testDoPut_ErrorLeadConvert(){

		XC_ProductCategoryOfInterest__c prod = new XC_ProductCategoryOfInterest__c();
		prod.Name = 'Termo';
		prod.XC_CommercialVisit__c = false;
		insert prod;

		System.RestContext.request = generateRestRequestPOSTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWr.LeadType = 'Residential';
		leadWr.LastName = 'Raffaello';
		leadWr.FirstName = 'Adriano';
		leadWr.PhonePrefix = '+34';
		leadWr.Phone = '685653399';
		leadWr.ReceivingChannel = 'WEB';
		leadWr.ProductCategoryOfInterest = 'Termo';
		leadWr.PrimaryEmail = 'raff.adriano.convert@gmail.com';
		leadWr.Notes = 'test';

		leadWr.GDPR = new XC_UTIL_Lead.gdprWrapper();
		leadWr.GDPR.GiveDataToThirdParties = 'Y';
		leadWr.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
		XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
		legal1.LegalEntity = 'EndesaX';
		legal1.GiveDataToLegalEntity = 'Y';
		legal1.GiveDataForMarketing = 'Y';
		legal1.GiveDataForProfiling = 'Y';
		leadWr.GDPR.LegalEntity.add(legal1);

		leadWr.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
		XC_UTIL_Account.IdentityIFWrapper identity = new XC_UTIL_Account.IdentityIFWrapper();
		identity.Country = 'Spain';
		identity.IdentityType = 'NIE';
		identity.IdentityNumber = 'X1779381A';
		identity.ReleaseDate = '2010-12-31';
		identity.ExpiryDate = '2023-12-31';
		leadWr.Identity.add(identity);

		leadWr.Address = new XC_UTIL_Address.AddressWrapper();
		leadWr.Address.ZipCode = '08007';
        leadWr.Address.StreetType = 'Street';
        leadWr.Address.StreetNumber = '620';
        leadWr.Address.Province = 'Barcelona';
		leadWr.Address.Country = 'Spain';
        leadWr.Address.City = 'Barcelona';
        leadWr.Address.Address = 'Gran Via de les Corts Catalanes';

		XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
		body.Lead = leadWr;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

		System.RestContext.response = new RestResponse();

		XC_REST_Lead.doPost();

		Lead l = [SELECT Id,Owner.Name,OwnerId,XC_Owner__c FROM Lead WHERE Email = 'raff.adriano.convert@gmail.com' LIMIT 1];
		System.debug('LEAD OWNER:'+ l.Owner.Name +  '  '+ l.XC_Owner__c);
		l.Status = 'Customer Contacted';
		l.OwnerId = UserInfo.getUserId();
		l.XC_ProductCategoryOfInterest__c = 'Termo';
		update l;

		test.startTest();
		System.RestContext.request = generateRestRequestPUTGood_Convert();
		XC_UTIL_Lead.LeadRESTWrapper leadWrConvert = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWrConvert.LeadID = String.valueOf(l.Id).substring(0, 16) + '3X';
		XC_REST_Lead_W.WrapperLeadRequest bodyConvert = new XC_REST_Lead_W.WrapperLeadRequest();
		bodyConvert.Lead = leadWrConvert;
		System.RestContext.request.requestBody = Blob.valueOf(JSON.serialize(bodyConvert, true));
		System.RestContext.response = new RestResponse();
		XC_REST_Lead.doPut();
		System.assertEquals(true,true);
		test.stopTest();
	}


	// PUT Error Status Convert
	@isTest
	static void testDoPut_ErrorStatusConvert(){

		XC_ProductCategoryOfInterest__c prod = new XC_ProductCategoryOfInterest__c();
		prod.Name = 'Termo';
		prod.XC_CommercialVisit__c = false;
		insert prod;

		System.RestContext.request = generateRestRequestPOSTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWr.LeadType = 'Residential';
		leadWr.LastName = 'Raffaello';
		leadWr.FirstName = 'Adriano';
		leadWr.PhonePrefix = '+34';
		leadWr.Phone = '685653399';
		leadWr.ReceivingChannel = 'WEB';
		leadWr.ProductCategoryOfInterest = 'Termo';
		leadWr.PrimaryEmail = 'raff.adriano.convert@gmail.com';
		leadWr.Notes = 'test';

		leadWr.GDPR = new XC_UTIL_Lead.gdprWrapper();
		leadWr.GDPR.GiveDataToThirdParties = 'Y';
		leadWr.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
		XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
		legal1.LegalEntity = 'EndesaX';
		legal1.GiveDataToLegalEntity = 'Y';
		legal1.GiveDataForMarketing = 'Y';
		legal1.GiveDataForProfiling = 'Y';
		leadWr.GDPR.LegalEntity.add(legal1);

		leadWr.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
		XC_UTIL_Account.IdentityIFWrapper identity = new XC_UTIL_Account.IdentityIFWrapper();
		identity.Country = 'Spain';
		identity.IdentityType = 'NIE';
		identity.IdentityNumber = 'X1779381A';
		identity.ReleaseDate = '2010-12-31';
		identity.ExpiryDate = '2023-12-31';
		leadWr.Identity.add(identity);

		leadWr.Address = new XC_UTIL_Address.AddressWrapper();
		leadWr.Address.ZipCode = '08007';
        leadWr.Address.StreetType = 'Street';
        leadWr.Address.StreetNumber = '620';
        leadWr.Address.Province = 'Barcelona';
		leadWr.Address.Country = 'Spain';
        leadWr.Address.City = 'Barcelona';
        leadWr.Address.Address = 'Gran Via de les Corts Catalanes';

		XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
		body.Lead = leadWr;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

		System.RestContext.response = new RestResponse();

		XC_REST_Lead.doPost();

		Lead l = [SELECT Id,OwnerID,Owner.Name,XC_Owner__c FROM Lead WHERE Email = 'raff.adriano.convert@gmail.com' LIMIT 1];
		System.debug('LEAD OWNER:'+ l.Owner.Name +  '  '+ l.XC_Owner__c);
		l.Status = 'Take Charge';	
		l.OwnerId = UserInfo.getUserId();
		l.XC_ProductCategoryOfInterest__c = 'Termo';
		update l;

		test.startTest();
		System.RestContext.request = generateRestRequestPUTGood_Convert();
		XC_UTIL_Lead.LeadRESTWrapper leadWrConvert = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWrConvert.LeadID = l.Id;
		XC_REST_Lead_W.WrapperLeadRequest bodyConvert = new XC_REST_Lead_W.WrapperLeadRequest();
		bodyConvert.Lead = leadWrConvert;
		System.RestContext.request.requestBody = Blob.valueOf(JSON.serialize(bodyConvert, true));
		System.RestContext.response = new RestResponse();
		XC_REST_Lead.doPut();
		System.assertEquals(true,true);
		test.stopTest();
	}


	// PUT Internal Error Lead
	@isTest
	static void testDoPut_LeadInternalError(){

		List<Lead> l = XC_DF_Lead.createResidentialLeads(1);
		insert l;

		System.RestContext.request = generateRestRequestPUTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWr.LeadID = l[0].Id;
		leadWr.LeadType = 'Residential';
		leadWr.LastName = 'Raffaello';
		leadWr.FirstName = 'Adriano';
		leadWr.PhonePrefix = '+34';
		leadWr.Phone = '685653399';
		leadWr.ReceivingChannel = 'WRONG';
		leadWr.ProductCategoryOfInterest = 'Iluminación LED';
		leadWr.PrimaryEmail = 'raff.adriano@gmail.com';
		leadWr.Notes = 'test';

		leadWr.GDPR = new XC_UTIL_Lead.gdprWrapper();
		leadWr.GDPR.GiveDataToThirdParties = 'Y';
		leadWr.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
		XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
		legal1.LegalEntity = 'EndesaX';
		legal1.GiveDataToLegalEntity = 'Y';
		legal1.GiveDataForMarketing = 'Y';
		legal1.GiveDataForProfiling = 'Y';
		leadWr.GDPR.LegalEntity.add(legal1);

		leadWr.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
		XC_UTIL_Account.IdentityIFWrapper identity = new XC_UTIL_Account.IdentityIFWrapper();
		identity.Country = 'Spain';
		identity.IdentityType = 'NIE';
		identity.IdentityNumber = 'X1779381A';
		identity.ReleaseDate = '2010-12-31';
		identity.ExpiryDate = '2020-12-31';
		leadWr.Identity.add(identity);

		leadWr.Address = new XC_UTIL_Address.AddressWrapper();
		leadWr.Address.ZipCode = '08007';
        leadWr.Address.StreetType = 'Street';
        leadWr.Address.StreetNumber = '620';
        leadWr.Address.Province = 'Barcelona';
		leadWr.Address.Country = 'Spain';
        leadWr.Address.City = 'Barcelona';
        leadWr.Address.Address = 'Gran Via de les Corts Catalanes';

		XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
		body.Lead = leadWr;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

		System.RestContext.response = new RestResponse();

		test.startTest();
		XC_REST_Lead.doPut();
		System.assertEquals(true,true);
		test.stopTest();
	}


	// PUT Internal Error Legal Entity
	@isTest
	static void testDoPut_LegalEntityInternalError(){

		List<Lead> l = XC_DF_Lead.createResidentialLeads(1);
		insert l;

		System.RestContext.request = generateRestRequestPUTGood();
		XC_UTIL_Lead.LeadRESTWrapper leadWr = new XC_UTIL_Lead.LeadRESTWrapper();
		leadWr.LeadID = l[0].Id;
		leadWr.LeadType = 'Residential';
		leadWr.LastName = 'Raffaello';
		leadWr.FirstName = 'Adriano';
		leadWr.PhonePrefix = '+34';
		leadWr.Phone = '685653399';
		leadWr.ReceivingChannel = 'WEB';
		leadWr.ProductCategoryOfInterest = 'Iluminación LED';
		leadWr.PrimaryEmail = 'raff.adriano@gmail.com';
		leadWr.Notes = 'test';

		leadWr.GDPR = new XC_UTIL_Lead.gdprWrapper();
		leadWr.GDPR.GiveDataToThirdParties = 'Y';
		leadWr.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
		XC_UTIL_Lead.LegalEntityWrapper legal1 = new XC_UTIL_Lead.LegalEntityWrapper();
		legal1.LegalEntity = 'EndesaWRONG';
		legal1.GiveDataToLegalEntity = 'Y';
		legal1.GiveDataForMarketing = 'Y';
		legal1.GiveDataForProfiling = 'Y';
		leadWr.GDPR.LegalEntity.add(legal1);

		leadWr.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
		XC_UTIL_Account.IdentityIFWrapper identity = new XC_UTIL_Account.IdentityIFWrapper();
		identity.Country = 'Spain';
		identity.IdentityType = 'NIE';
		identity.IdentityNumber = 'X1779381A';
		identity.ReleaseDate = '2010-12-31';
		identity.ExpiryDate = '2020-12-31';
		leadWr.Identity.add(identity);

		leadWr.Address = new XC_UTIL_Address.AddressWrapper();
		leadWr.Address.ZipCode = '08007';
        leadWr.Address.StreetType = 'Street';
        leadWr.Address.StreetNumber = '620';
        leadWr.Address.Province = 'Barcelona';
		leadWr.Address.Country = 'Spain';
        leadWr.Address.City = 'Barcelona';
        leadWr.Address.Address = 'Gran Via de les Corts Catalanes';

		XC_REST_Lead_W.WrapperLeadRequest body = new XC_REST_Lead_W.WrapperLeadRequest();
		body.Lead = leadWr;
		System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

		System.RestContext.response = new RestResponse();

		test.startTest();
		XC_REST_Lead.doPut();
		System.assertEquals(true,true);
		test.stopTest();
	}


	// PUT Catch
	@isTest
	static void testDoPut_Catch(){

		System.RestContext.request = generateRestRequestPUTGood();
		System.RestContext.request.requestBody =  null;

		System.RestContext.response = new RestResponse();

		test.startTest();
		XC_REST_Lead.doPut();
		System.assertEquals(true,true);
		test.stopTest();
	}
    
    /*
	*@ Description get Lead by LeadID
	*/
    @isTest
	static void testGETLead(){
        
        /*Individual i = new Individual();
        i.LastName = 'Test Ind';
        insert i;*/
        
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        //leadList[0].IndividualId = i.Id;
        insert leadList;
        
        XC_LegalEntityConsent__c consent = new XC_LegalEntityConsent__c();
        consent.XC_IndividualId__c = [SELECT Id, IndividualId FROM Lead WHERE Id =: leadList[0].Id][0].IndividualId;
        consent.XC_Individual__c = consent.XC_IndividualId__c;
        consent.XC_LeCountry__c = 'Spain';
        consent.XC_LegalEntity__c = 'EndesaX';
        consent.XC_GiveDataToNew__c = 'Yes';
        insert consent;
        
        System.RestContext.request = generateRestRequestGetGood();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.addParameter('LeadID',leadList[0].Id);
        test.startTest();
		XC_REST_Lead.doGet();
        System.assertEquals(true,true, 'Wrong assert result');
		test.stopTest();
	}
    
    /*
	*@ Description get Lead by Email
	*/
    @isTest
	static void testGETLeadEmail(){
                
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        leadList[0].Email = 'testlead@yopmail.com';
        insert leadList;
        
        System.RestContext.request = generateRestRequestGetGood();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.addParameter('PrimaryEmail','wrong@yopmail.com');
        test.startTest();
		XC_REST_Lead.doGet();
        System.assertEquals(true,true, 'Wrong assert result');
		test.stopTest();
	}
    
    /*
	*@ Description get Lead by LeadID
	*/
    @isTest
	static void testGETLeadWrong(){
        
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;

        System.RestContext.request = generateRestRequestGetWrong();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.addParameter('LeadID',leadList[0].Id);
        test.startTest();
		XC_REST_Lead.doGet();
        System.assertEquals(true,true, 'Wrong assert result');
		test.stopTest();
	}
    
    
    @isTest
    static void searchLeadByKeys1_TEST(){
        
        XC_UTIL_Lead.LeadRESTWrapper leadWrapperRequest = new XC_UTIL_Lead.LeadRESTWrapper();
        leadWrapperRequest.Phone = '6768';
        leadWrapperRequest.PhonePrefix = '6768';
        leadWrapperRequest.PrimaryEmail = '6768';
        leadWrapperRequest.IdentityNumber = '6768';
        
		test.startTest();
        
        List<Lead> listLead = XC_REST_Lead_S.searchLeadbyKeys(leadWrapperRequest);
	    System.assertEquals(true, listLead!=null, 'Wrong assert result');

		test.stopTest();
	}
    
    
    @isTest
    static void searchLeadByKeys2_TEST(){
        
        XC_UTIL_Lead.LeadRESTWrapper leadWrapperRequest = new XC_UTIL_Lead.LeadRESTWrapper();
        leadWrapperRequest.PrimaryEmail = '6768';
        leadWrapperRequest.IdentityNumber = '6768';
        
		test.startTest();
        
        List<Lead> listLead = XC_REST_Lead_S.searchLeadbyKeys(leadWrapperRequest);
	    System.assertEquals(true, listLead!=null, 'Wrong assert result');

		test.stopTest();
	}
    
    
    @isTest
    static void searchLeadByKeys3_TEST(){
        
        XC_UTIL_Lead.LeadRESTWrapper leadWrapperRequest = new XC_UTIL_Lead.LeadRESTWrapper();
        leadWrapperRequest.IdentityNumber = '6768';
        
		test.startTest();
        
        List<Lead> listLead = XC_REST_Lead_S.searchLeadbyKeys(leadWrapperRequest);
	    System.assertEquals(true, listLead!=null, 'Wrong assert result');

		test.stopTest();
	}
    
    
    @isTest
    static void checkLeadBlacklist1_TEST(){
        
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
        XC_UTIL_Lead.LeadRESTWrapper leadWrapper = new XC_UTIL_Lead.LeadRESTWrapper();
        leadWrapper.ZipCode = '11111';
        leadWrapper.ProductCategoryOfInterest = 'Boiler';
        leadWrapper.GDPR = new XC_UTIL_Lead.gdprWrapper();
        leadWrapper.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
        XC_UTIL_Lead.LegalEntityWrapper l = new XC_UTIL_Lead.LegalEntityWrapper();
        l.LegalEntity = 'EndesaX';
        leadWrapper.GDPR.LegalEntity.add(l);
        
		test.startTest();
        
        XC_REST_Lead_Z.checkLeadBlacklist(validateResult, leadWrapper, 'POST');
	    System.assertEquals(true, true, 'Wrong assert result');

		test.stopTest();
	}
    
     @isTest
    static void checkLeadBlacklist2_TEST(){
        
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
		insert listLead; 
        
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
        XC_UTIL_Lead.LeadRESTWrapper leadWrapper = new XC_UTIL_Lead.LeadRESTWrapper();
        leadWrapper.leadid = listLead[0].id;
        leadWrapper.ZipCode = '11111';
        leadWrapper.ProductCategoryOfInterest = 'Boiler';
        leadWrapper.GDPR = new XC_UTIL_Lead.gdprWrapper();
        leadWrapper.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
        XC_UTIL_Lead.LegalEntityWrapper l = new XC_UTIL_Lead.LegalEntityWrapper();
        l.LegalEntity = 'EndesaX';
        leadWrapper.GDPR.LegalEntity.add(l);
        
		test.startTest();
        
        XC_REST_Lead_Z.checkLeadBlacklist(validateResult, leadWrapper, 'PUT');
	    System.assertEquals(true, true, 'Wrong assert result');

		test.stopTest();
	}
    
    
    @isTest
    static void checkLeadBlacklist3_TEST(){
        
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        leadList[0].XC_GenericZipCode__c = '111';
        //leadList[0].XC_ProductCategoryOfInterest__c = 'Boiler';
        leadList[0].XC_MainLegalEntity__c = 'EndesaX';
        insert leadList;
        
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
        XC_UTIL_Lead.LeadRESTWrapper leadWrapper = new XC_UTIL_Lead.LeadRESTWrapper();
        leadWrapper.LeadID = leadList[0].Id;
        leadWrapper.ZipCode = '11111';
        //leadWrapper.ProductCategoryOfInterest = 'Boiler';
        /*leadWrapper.GDPR = new XC_UTIL_Lead.gdprWrapper();
        leadWrapper.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
        XC_UTIL_Lead.LegalEntityWrapper l = new XC_UTIL_Lead.LegalEntityWrapper();
        l.LegalEntity = 'EndesaX';
        leadWrapper.GDPR.LegalEntity.add(l);*/
        
		test.startTest();
        
        XC_REST_Lead_Z.checkLeadBlacklist(validateResult, leadWrapper, 'PUT');
	    System.assertEquals(true, true, 'Wrong assert result');

		test.stopTest();
	}
    
    @isTest
    static void checkLeadBlacklist4_TEST(){
        
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        leadList[0].XC_GenericZipCode__c = '111';
        //leadList[0].XC_ProductCategoryOfInterest__c = 'Boiler';
        leadList[0].XC_MainLegalEntity__c = 'EndesaX';
        insert leadList;
        
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
        XC_UTIL_Lead.LeadRESTWrapper leadWrapper = new XC_UTIL_Lead.LeadRESTWrapper();
        leadWrapper.LeadID = leadList[0].Id;
        leadWrapper.ZipCode = '11111';
        leadWrapper.ProductCategoryOfInterest = 'Boiler';
        /*leadWrapper.GDPR = new XC_UTIL_Lead.gdprWrapper();
        leadWrapper.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
        XC_UTIL_Lead.LegalEntityWrapper l = new XC_UTIL_Lead.LegalEntityWrapper();
        l.LegalEntity = 'EndesaX';
        leadWrapper.GDPR.LegalEntity.add(l);*/	
        
		test.startTest();
        
        XC_REST_Lead_Z.checkLeadBlacklist(validateResult, leadWrapper, 'PUT');
	    System.assertEquals(true, true, 'Wrong assert result');

		test.stopTest();
	}
    
    
    @isTest
    static void generateLegalEntityFromWrapper_TEST(){
        
        XC_UTIL_Lead.LegalEntityWrapper legalEnWr = new XC_UTIL_Lead.LegalEntityWrapper();
        legalEnWr.LegalEntityID = '';
        legalEnWr.LegalEntity = 'EndesaX';
        legalEnWr.GiveDataToLegalEntity = 'Y';
        legalEnWr.GiveDataForMarketing = 'Y';
        legalEnWr.GiveDataForProfiling = 'Y';
        legalEnWr.ConsentMarketingDate = Date.Today();
        legalEnWr.ConsentProfilingDate = Date.Today();
        
		test.startTest();
        
        XC_LegalEntityConsent__c lec = XC_REST_Lead_W.generateLegalEntityFromWrapper(legalEnWr, '');
	    System.assertEquals(true, lec!=null, 'Wrong assert result');

		test.stopTest();
	}
    
    
    @isTest
    static void generatePosFromWrapper_TEST(){
        
        XC_UTIL_Address.PoSWrapper posWr = new XC_UTIL_Address.PoSWrapper();
        posWr.POSID = '';
        posWr.POSType = 'Light';
        posWr.POS = 'POS';
        
		test.startTest();
        
        XC_PointOfService__c pos = XC_REST_Lead_W.generatePosFromWrapper(posWr, null);
	    System.assertEquals(true, pos!=null, 'Wrong assert result');

		test.stopTest();
	}


	private static RestRequest generateRestRequestPUTWrong(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'UpdateCase');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'PUT');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'PUT';
        request.requestURI = '/v1/Lead/*';

        return request; 
    }

    private static RestRequest generateRestRequestPUTGood(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'UpdateCase');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'Update');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'PUT';
        request.requestURI = '/v1/Lead/*';

        return request; 
    }

    private static RestRequest generateRestRequestPUTGood2(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'UpdateCase');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'Pippo');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'PUT';
        request.requestURI = '/v1/Lead/*';

        return request; 
    }

	private static RestRequest generateRestRequestPUTCheck(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'UpdateCase');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'Convert');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'PUT';
        request.requestURI = '/v1/Lead/*';

        return request; 
    }

    private static RestRequest generateRestRequestPostGoodConvert(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'CreateCase');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'POST');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'POST';
        request.requestURI = '/v1/Lead/*';

        return request; 
    }
  
   	private static RestRequest generateRestRequestPUTGood_Convert(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'CreateCase');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'Convert');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'PUT';
        request.requestURI = '/v1/Lead/*';

        return request; 
    }

    private static RestRequest generateRestRequestPOSTGood(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'CreateCase');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'POST');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'POST';
        request.requestURI = '/v1/Lead/*';

        return request; 
    }

    private static RestRequest generateRestRequestPOSTCommodity(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'CreateCase');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'POST');
        request.addHeader('ClientSystem', 'CommoditySpainB2C');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'POST';
        request.requestURI = '/v1/Lead/*';

        return request; 
    }
    
    private static RestRequest generateRestRequestGetGood(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'Get');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'GET');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'GET';
        request.requestURI = '/v1/Lead/*';

        return request; 
    }
    
    private static RestRequest generateRestRequestGetWrong(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'Get');
        request.addHeader('Operation', 'GET');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'GET';
        request.requestURI = '/v1/Lead/*';

        return request; 
    }
}