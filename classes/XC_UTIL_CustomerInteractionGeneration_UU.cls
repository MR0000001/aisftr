/**

 * @author Giuseppe Di Bonito - gdibonito@deloitte.it
 * @date Creation 09/06/2020
 * @date Modification Dario Tramontin dtramontin@deloitte.it 13/01/2021
 * @description XC_UTIL_CustomerInteractionGeneration_UU
 */
 public class XC_UTIL_CustomerInteractionGeneration_UU { 
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 09/06/2020
 	* @description generate Maintenance_FirstSchedule/SiteInspection_FirstSchedule Customer Interactions (XC_TR_WorkOrder_Handler)
 	*/
	
 	public static void generateCustIntForWorkOrdITA(List<Workorder> ListNew){
 		System.debug('In generateCustIntForWorkOrdITA');
 		
 		List<String> woids = new List<String>();
 		List<Workorder> wos1 = new List<Workorder>();
 		List<Workorder> wos2 = new List<Workorder>();
 		List<Workorder> wos3 = new List<Workorder>();
 		List<Workorder> wos4 = new List<Workorder>();
 		List<Workorder> wos5 = new List<Workorder>();
 		for(Workorder w : ListNew){
 			if(w.XC_WorkTypeCategory__c == 'Planned Maintenance' &&
 			w.Status == 'Assigned' &&
 			w.XC_StatusReason__c == 'To be scheduled'){
 				wos1.add(w);
 				woids.add(w.id);
 			} else if(w.XC_WorkTypeCategory__c == 'Site Inspection' &&
 			 w.Status == 'Assigned' &&
			 w.XC_StatusReason__c == 'To be scheduled' &&
			 w.XC_ProductSubType__c != 'Home Check'){
 				wos2.add(w);
 				woids.add(w.id);
 			
 			} else if((w.XC_WorkTypeCategory__c =='Planned Maintenance' || w.XC_WorkTypeCategory__c=='Maintenance with Substitution') &&
 			w.Status == 'Completed' &&
 			String.isblank(w.XC_External_ID__c)){
 				wos3.add(w);
 				woids.add(w.id);
 			} else if((w.XC_WorkTypeCategory__c == 'Installation' || w.XC_WorkTypeCategory__c == 'Delivery & Installation') &&
 			w.Status == 'Completed' && String.isBlank(w.XC_ProjectPhase__c) && String.isBlank(w.XC_Project_Task__c) &&
 			String.isblank(w.XC_External_ID__c)){
 				wos4.add(w);
 				woids.add(w.id);
 			} else if(w.XC_WorkTypeCategory__c == 'Repair' &&
 			w.Status == 'Completed' &&
 			String.isblank(w.ParentWorkOrderId) &&
 			String.isblank(w.XC_External_ID__c)){
 				wos5.add(w);
 				woids.add(w.id);
 			}
 		}
 		
 		if(woids.isEmpty()){
 			return;
 		}
 		Map<Id, Workorder> womap = new Map<Id, Workorder>([
 			SELECT id, ContactId, AccountId, XC_Opportunity__c, XC_Opportunity__r.XC_BusinessLine__c, Contact.Email, Contact.Name, 
 			XC_LegalEntity__c, XC_Segment__c, XC_Configuration__c, AssetId,
 			(SELECT Id, XC_Communication_Type__c FROM Customer_Interactions__r)
 			FROM Workorder
 			WHERE Id in: woids]);
 		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
 			if(!wos1.isEmpty()){			
 				for(Workorder w : wos1){
 					Map<String,Object> ciInfo = populateCustIntForWorkOrdITA(womap.get(w.id), 'Maintenance_FirstSchedule');
 					interactions.add(ciInfo);
 					//Map<String,Object> ciInfo2 = populateCustIntForWorkOrdITA(womap.get(w.id), 'Maintenance_Reminder');
 					//interactions.add(ciInfo2);
 				}	
 			}
 			if(!wos2.isEmpty()){			
 				for(Workorder w : wos2){
 					Map<String,Object> ciInfo = populateCustIntForWorkOrdITA(womap.get(w.id), 'SiteInspection_FirstSchedule');
 					interactions.add(ciInfo);
 				}	
 			}
 		if(!wos3.isEmpty()){			
 			for(Workorder w : wos3){
 				Map<String,Object> ciInfo = populateCustIntForWorkOrdITA(womap.get(w.id), 'Survey_Post_Maintenance');
 				if(ciInfo != null) {
 					ciInfo.put('SurveyId', 'Survey_Maintenance');
 					interactions.add(ciInfo);
 				}
 			}	
 		}
 		if(!wos4.isEmpty()){			
 			for(Workorder w : wos4){
 				Map<String,Object> ciInfo = populateCustIntForWorkOrdITA(womap.get(w.id), 'Survey_Post_Installation');
 				if(ciInfo != null) {
					System.debug('@@@@@@ OP-BL');
					System.debug(w.XC_Opportunity__r.XC_BusinessLine__c);
 					ciInfo.put('SurveyId', 'Survey_Installation');
 					interactions.add(ciInfo);
 				}
 			}	
 		}
 		if(!wos5.isEmpty()){			
 			for(Workorder w : wos5){
 				Map<String,Object> ciInfo = populateCustIntForWorkOrdITA(womap.get(w.id), 'Survey_Post_Repair');
 				if(ciInfo != null) {
 					ciInfo.put('SurveyId', 'Survey_Repair');
 					interactions.add(ciInfo);
 				}
 			}	
 		}
 		if(!interactions.isEmpty()){
 			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
 			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
 		}
 	}
 	
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 09/06/2020
 	* @description populate Customer Interaction
 	*/
 	public static Map<String,Object> populateCustIntForWorkOrdITA(Workorder w, String communicationType){
 		
 		for(XC_Customer_Interaction__c ci : w.Customer_Interactions__r){
 			if(ci.XC_Communication_Type__c == communicationType){
 				return null;
 			}
 		}
 		
 		Map<String,Object> ciInfo = new Map<String,Object>();
 		ciInfo.put('orderId', w.XC_Configuration__c);
 		ciInfo.put('accountId', w.AccountId);
 		ciInfo.put('customerType', communicationType);
 		ciInfo.put('workorderId', w.Id);
 		ciInfo.put('fullName', w.Contact.Name);
 		ciInfo.put('contactId', w.ContactId);
 		ciInfo.put('skipComunication', false);
 		ciInfo.put('sent', false);
 		ciInfo.put('legalEntity', w.XC_LegalEntity__c);
 		ciInfo.put('email', w.Contact.Email);
 		ciInfo.put('opportunityId', w.XC_Opportunity__c);
 		ciInfo.put('segment', w.XC_Segment__c);
		ciInfo.put('businessLine',w.XC_Opportunity__r.XC_BusinessLine__c);
 		ciInfo.put('assetId', (w.AssetId !=null) ? w.AssetId : null);
 		return ciInfo;
 	}
 
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 11/11/2020
 	* @description generate Maintenance_Reminder Customer Interactions (XC_TR_WorkOrder_Handler insert)
 	*/
 	public static void generateCustIntMaintenanceReminder(List<Workorder> ListNew){
 		System.debug('In generateCustIntMaintenanceReminder');
 		
 		List<String> woids = new List<String>();
 		List<Workorder> wos = new List<Workorder>();
 		for(Workorder w : ListNew){
 			if(w.XC_WorkTypeCategory__c == 'Planned Maintenance' && w.Status == 'New'){
 				wos.add(w);
 				woids.add(w.id);
 			} 
 		}
 		if(woids.isEmpty()){
 			return;
 		}
 		Map<Id, Workorder> womap = new Map<Id, Workorder>([
 			SELECT id, ContactId, AccountId, XC_Opportunity__c, Contact.Email, Contact.Name, 
 			XC_LegalEntity__c, XC_Segment__c, XC_Configuration__c, AssetId, XC_Opportunity__r.XC_BusinessLine__c,
 			(SELECT Id, XC_Communication_Type__c FROM Customer_Interactions__r)
 			FROM Workorder
 			WHERE Id in: woids]);
 		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
 		if(!wos.isEmpty()){			
 			for(Workorder w : wos){
 				Map<String,Object> ciInfo = populateCustIntForWorkOrdITA(womap.get(w.id), 'Maintenance_Reminder');
 				interactions.add(ciInfo);
 			}	
 		}
 		if(!interactions.isEmpty()){
 			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
 			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
 		}
 	}
 	
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 10/06/2020
 	* @description generate ServiceActivation_Maintenance/ServiceActivation_Repair Customer Interactions (XC_TR_Asset_Handler)
 	*/
 	public static void generateCustIntForAssetITA(List<Asset> ListNew){
 		System.debug('In generateCustIntForAssetITA');
 		
 		List<String> asId = new List<String>();
 		List<Asset> as1 = new List<Asset>();
 		List<Asset> as2 = new List<Asset>();
 		for(Asset a : ListNew){
 			if (a.Status == 'Active' &&
 				a.XC_Product_Type__c == 'Coverage' &&
 				a.XC_Product_SubType__c == 'Maintenance' &&
 				String.isblank(a.XC_External_ID__c)){
 					as1.add(a);
 					asId.add(a.id);
 			} else if(a.Status == 'Active' &&
 				a.XC_Product_Type__c == 'Service' &&
 				(a.XC_Product_SubType__c == 'Gas' || 
 				a.XC_Product_SubType__c == 'Electric' ||
 				a.XC_Product_SubType__c == 'Gas and Electricity') &&
 				String.isblank(a.XC_External_ID__c)){
 					as2.add(a);
 					asId.add(a.id);
 			}
 		}
 		
 		if(asId.isEmpty()){
 			return;
 		}
 		Map<Id, Asset> assmap = new Map<Id, Asset>([
 			SELECT ContactId, AccountId, Id, XC_LegalEntity__c, XC_Segment__c, NE__Order_Config__c, XC_Configuration_Item__c, Contact.Name, Contact.Email,
 			(SELECT Id, XC_Communication_Type__c FROM Customer_Interactions__r)
 			FROM Asset
 			WHERE Id in: asId]);
 		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
 		if(!as1.isEmpty()){			
 			for(Asset a : as1){
 				Map<String,Object> ciInfo = populateCustIntForAssetITA(assmap.get(a.id), 'ServiceActivation_Maintenance');
 				if(ciInfo != null){
 					interactions.add(ciInfo);
 				
                 } else{
                     Integer n = asId.indexOf(a.id);
                     asId.remove(n);
                 }
 			}
 		}
 		if(!as2.isEmpty()){			
 			for(Asset a : as2){
 				
 				Map<String,Object> ciInfo = populateCustIntForAssetITA(assmap.get(a.id), 'ServiceActivation_Repair');
 				if(ciInfo != null){
 					interactions.add(ciInfo);
 					
 				} else{
                     Integer n = asId.indexOf(a.id);
                     asId.remove(n);
                 }
 			}	
 		}
 		if(!interactions.isEmpty()){
 			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromAsset(interactions);
 			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
 			generateCustIntServicePromoRenewal(asId);
 		}
 	}
 	
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 09/06/2020
 	* @description populate Customer Interaction
 	*/
 	public static Map<String,Object> populateCustIntForAssetITA(Asset a, String communicationType){
 		
 		for(XC_Customer_Interaction__c ci : a.Customer_Interactions__r){
 			if(ci.XC_Communication_Type__c == communicationType){
 				return null;
 			}
 		}
 		
 		Map<String,Object> ciInfo = new Map<String,Object>();
 		ciInfo.put('orderId', a.NE__Order_Config__c);
 		ciInfo.put('accountId', a.AccountId);
 		ciInfo.put('customerType', communicationType);
 		ciInfo.put('assetId', a.Id);
 		ciInfo.put('fullName', a.Contact.Name);
 		ciInfo.put('contactId', a.ContactId);
 		ciInfo.put('skipComunication', false);
 		ciInfo.put('sent', false);
 		ciInfo.put('legalEntity', a.XC_LegalEntity__c);
 		ciInfo.put('email', a.Contact.Email);
 		ciInfo.put('segment', a.XC_Segment__c);
 		ciInfo.put('orderItemID', a.XC_Configuration_Item__c);
 		return ciInfo;
 	}
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 18/06/2020
 	* @description generate Welcome_Contract Child Customer Interactions
 	*/
 	public static void generateWelcomeContractChild(List<XC_Customer_Interaction__c> ListNew){
 		List<String> ordId = new List<String>();
 		List<XC_Customer_Interaction__c> welcContCiList = new List<XC_Customer_Interaction__c>();
 		for(XC_Customer_Interaction__c ci : ListNew){
 			if(ci.XC_Communication_Type__c == 'Welcome_Contract'){
 				welcContCiList.add(ci);
 				ordId.add(ci.XC_OrderId__c);
 			}
 		}
 		if(welcContCiList.isEmpty()){
 			return;
 		}
 		Map<Id, NE__Order__c> ordmap = new Map<Id, NE__Order__c>([
 			SELECT NE__OptyId__r.XC_Contact__r.Name, NE__AccountId__c, Id, XC_LegalEntity__c, 
 			XC_Segment__c, NE__OptyId__r.XC_Contact__r.Email, NE__OptyId__r.XC_Contact__c, XC_CallType__c, NE__OptyId__r.XC_Contact__r.XC_PhonePrefix__c, NE__OptyId__r.XC_Contact__r.XC_ContactPhone__c, NE__OptyId__r.XC_Contact__r.Phone,
 				(SELECT id, XC_Product_Type__c, NE__Bundle_Configuration__c, NE__Root_Order_Item__c
 				FROM NE__Order_Items__r 
 				WHERE NE__Bundle_Configuration__c = null AND NE__Root_Order_Item__c = null 
 				AND (XC_Product_Type__c = 'Bundle' OR XC_Product_Type__c = 'Equipment' OR XC_Product_Type__c = 'Service' OR XC_Product_Type__c = 'Coverage'))
 			FROM NE__Order__c
 			WHERE Id in: ordId]);

		Map<Id, NE__Order_Item_Attribute__c> attributeMap = new Map<Id, NE__Order_Item_Attribute__c>([
			SELECT NE__Order_Item__r.NE__Bundle_Configuration__c
			FROM NE__Order_Item_Attribute__c
			WHERE NE__Order_Item__r.NE__OrderId__c in: ordId
			AND XC_DeveloperName__c = 'Delivery Method'
			AND NE__Value__c = 'Shipping'
			AND NE__Order_Item__r.XC_Product_Type__c = 'Equipment']);
		
 		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
 		for(XC_Customer_Interaction__c ci : welcContCiList){
 			
 			if(ordmap.get(ci.XC_OrderId__c).NE__Order_Items__r.size() == 1){
 				ci.XC_Communication_Type__c = getCommType(ordmap.get(ci.XC_OrderId__c).NE__Order_Items__r[0], attributeMap.values());
 				ci.XC_ConfigurationItem__c = ordmap.get(ci.XC_OrderId__c).NE__Order_Items__r[0].Id;
 				//siamo in before insert quindi si aggiorna da sola
 			}else{
 				for(NE__OrderItem__c oi : ordmap.get(ci.XC_OrderId__c).NE__Order_Items__r){
 				
 					String commType = getCommType(oi, attributeMap.values());
 					Map<String,Object> ciInfo = populateCustIntForConfigurationItemITA(ordmap.get(ci.XC_OrderId__c), oi.id, commType);
 					if(ciInfo != null){
 						interactions.add(ciInfo);
 					}
				}
			}	

			NE__Order__c ord = ordmap.get(ci.XC_OrderId__c);
            system.debug('TEST: '+ord.XC_CallType__c+' '+ord.NE__OptyId__r.XC_Contact__r.XC_PhonePrefix__c+' '+ord.NE__OptyId__r.XC_Contact__r.XC_ContactPhone__c);
			if(ord.XC_CallType__c == 'Outbound Call' 
				&& !String.isBlank(ord.NE__OptyId__r.XC_Contact__r.XC_PhonePrefix__c) 
				&& !String.isBlank(ord.NE__OptyId__r.XC_Contact__r.XC_ContactPhone__c)
				&& XC_UTIL_CustomerInteractionGeneration_U.isMobilePhone(ord.NE__OptyId__r.XC_Contact__r.XC_PhonePrefix__c, ord.NE__OptyId__r.XC_Contact__r.XC_ContactPhone__c)){

				Map<String,Object> ciInfo = cloneCIonSMS(ci, ord.NE__OptyId__r.XC_Contact__r.Phone);
				if(ciInfo != null){
					interactions.add(ciInfo);
				}
			}
		}

 		if(!interactions.isEmpty()){
 			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(interactions);
 			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
 		}
 	}

 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 18/06/2020
 	* @description get communication type
 	*/
 	private static String getCommType(NE__OrderItem__c oi, list<NE__Order_Item_Attribute__c> attributeMap){
 		
 		String commType;
 		if(oi.XC_Product_Type__c == 'Bundle'){
			for(NE__Order_Item_Attribute__c oia : attributeMap){
				if(oia.NE__Order_Item__r.NE__Bundle_Configuration__c == oi.Id){
					commType = 'Welcome_Contract_Complex_Products_Delivery';
					return commType;
				}
			}
 			commType = 'Welcome_Contract_Complex_Products';
 		} else if(oi.XC_Product_Type__c == 'Equipment'){
 			commType = 'Welcome_Contract_Simple_Products';
 		} else if(oi.XC_Product_Type__c == 'Service' || oi.XC_Product_Type__c == 'Coverage'){
 			commType = 'Welcome_Contract_Services';
 		}
 		return commType;
 	}

 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 18/06/2020
 	* @description populate Customer Interaction
 	*/
 	public static Map<String,Object> populateCustIntForConfigurationItemITA(NE__Order__c ord, String oiid, String communicationType){
 		
 		Map<String,Object> ciInfo = new Map<String,Object>();
 		ciInfo.put('orderId', ord.Id);
 		ciInfo.put('accountId', ord.NE__AccountId__c);
 		ciInfo.put('customerType', communicationType);
 		ciInfo.put('fullName', ord.NE__OptyId__r.XC_Contact__r.Name);
 		ciInfo.put('contactId', ord.NE__OptyId__r.XC_Contact__c);
 		ciInfo.put('skipComunication', false);
 		ciInfo.put('sent', false);
 		ciInfo.put('legalEntity', ord.XC_LegalEntity__c);
 		ciInfo.put('email', ord.NE__OptyId__r.XC_Contact__r.Email);
 		ciInfo.put('segment', ord.XC_Segment__c);
 		ciInfo.put('orderItemID', oiid);
 		return ciInfo;
 	}

 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 18/06/2020
 	* @description generate Customer Interaction For Case Survey ITA (XC_Case_Handler)
 	*/
 	public static void generateCustIntForCaseSurveyITA(List<Case> ListNew){
 		System.debug('In generateCustIntForCaseSurveyITA');
		 
		 List<String> caseId = new List<String>();
		 		 /* logica spostata in XC_TR_CTIInteraction_U_CreateCI ---- ST - 18/12/2020
 		List<Case> csList = new List<Case>();
 		for(Case cs : ListNew){
 			if ((cs.Reason == 'XCMOT001' && cs.SubCause__c == 'ATCL033' && cs.XC_Subtype__c == 'XC157' && cs.XC_CTI_Interaction__c != null) ||
 				(cs.Reason == 'XCMOT001' && cs.SubCause__c == 'ATCL033' && cs.XC_Subtype__c == 'XC166' && cs.XC_CTI_Interaction__c != null) ||
 				(cs.Reason == 'XCMOT001' && cs.SubCause__c == 'ATCL098' && cs.XC_Subtype__c == 'XC158' && cs.XC_CTI_Interaction__c != null)){
 					csList.add(cs);
 					caseId.add(cs.id);
 			}
 		}
 		
 		if(csList.isEmpty()){
 			return;
 		}
 		Map<Id, Case> casemap = new Map<Id, Case>([
 			SELECT ContactId, AccountId, Id, XC_LegalEntity__c, XC_Segment__c, Contact.Name, Contact.Email
 			FROM Case
 			WHERE Id in: caseId]);
 		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
 		for(Case cs : casemap.values()){
 			Map<String,Object> ciInfo = populateCustIntForCaseSurveyITA(cs);
 			interactions.add(ciInfo);
 		}
 		if(!interactions.isEmpty()){
 			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromCases(interactions);
 			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
		 }
		 
		 */
 	}
 	
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 18/06/2020
 	* @description populate Customer Interaction
 	*/
 	public static Map<String,Object> populateCustIntForCaseSurveyITA(Case cs){
 		
 		Map<String,Object> ciInfo = new Map<String,Object>();
 		ciInfo.put('caseId', cs.id);
 		ciInfo.put('accountId', cs.AccountId);
 		ciInfo.put('customerType', 'Survey_Call_Center');
 		ciInfo.put('fullName', cs.Contact.Name);
 		ciInfo.put('contactId', cs.ContactId);
 		ciInfo.put('skipComunication', false);
 		ciInfo.put('sent', false);
 		ciInfo.put('legalEntity', cs.XC_LegalEntity__c);
 		ciInfo.put('email', cs.Contact.Email);
 		ciInfo.put('segment', cs.XC_Segment__c);
 		ciInfo.put('SurveyId', 'Survey_Call_Center');
 		return ciInfo;
	 }
	 
 	/** 
 	* @description 
 	* @author  Simone Trenta - strenta@deloitte.it
 	* @date 18/06/2020
 	* @description populate Customer Interaction
 	*/
 	public static Map<String,Object> populateCustIntForCaseITA(Case cs, String type, String url){
 		
		Map<String,Object> ciInfo = new Map<String,Object>();
		ciInfo.put('caseId', cs.id);
		ciInfo.put('accountId', cs.AccountId);
		ciInfo.put('customerType', type);
		ciInfo.put('fullName', cs.Contact.Name);
		ciInfo.put('contactId', cs.ContactId);
		ciInfo.put('skipComunication', false);
		ciInfo.put('sent', false);
		ciInfo.put('legalEntity', cs.XC_LegalEntity__c);
		ciInfo.put('email', cs.Contact.Email);
		ciInfo.put('segment', cs.XC_Segment__c);
		ciInfo.put('docURL', url);
		return ciInfo;
	}

 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 26/06/2020
 	* @description generateCustIntSurveyPostRepair
 	*/
 	public static List<Map<String,Object>> generateCustIntSurveyPostRepair(List<String> caseIdsForRepairWo){
 		System.debug('In generateCustIntSurveyPostRepair');
 		Map<Id, Workorder> womap = new Map<Id, Workorder>([
 			SELECT id, ContactId, AccountId, XC_Opportunity__c, Contact.Email, Contact.Name, 
 			XC_LegalEntity__c, XC_Segment__c, XC_Configuration__c, 
 			(SELECT Id, XC_Communication_Type__c FROM Customer_Interactions__r)
 			FROM Workorder
 			WHERE CaseId in: caseIdsForRepairWo
 			AND Status = 'Completed'
 			AND XC_WorkTypeCategory__c = 'Repair'
 			AND ParentWorkOrderId = null
 			AND XC_External_ID__c = null]);
 		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
 		if(!womap.isEmpty()){			
 			for(Workorder w : womap.values()){
 				Map<String,Object> ciInfo = populateCustIntSurveyPostRepair(womap.get(w.id), 'Survey_Post_Repair');
 				if(ciInfo != null) {
 					ciInfo.put('SurveyId', 'Survey_Repair');
 					interactions.add(ciInfo);
 				}
 			}	
 		}
 		return interactions;
 	}
 	
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 09/06/2020
 	* @description populate Customer Interaction
 	*/
 	public static Map<String,Object> populateCustIntSurveyPostRepair(Workorder w, String communicationType){
 		
 		for(XC_Customer_Interaction__c ci : w.Customer_Interactions__r){
 			if(ci.XC_Communication_Type__c == communicationType){
 				return null;
 			}
 		}
 		
 		Map<String,Object> ciInfo = new Map<String,Object>();
 		ciInfo.put('orderId', w.XC_Configuration__c);
 		ciInfo.put('accountId', w.AccountId);
 		ciInfo.put('customerType', communicationType);
 		ciInfo.put('workorderId', w.Id);
 		ciInfo.put('fullName', w.Contact.Name);
 		ciInfo.put('contactId', w.ContactId);
 		ciInfo.put('skipComunication', false);
 		ciInfo.put('sent', false);
 		ciInfo.put('legalEntity', w.XC_LegalEntity__c);
 		ciInfo.put('email', w.Contact.Email);
 		ciInfo.put('opportunityId', w.XC_Opportunity__c);
 		ciInfo.put('segment', w.XC_Segment__c);
 		return ciInfo;
 	}
 
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 18/08/2020
 	* @description generate Customer Interaction ServiceAppointment_Confirmed (XC_TR_ServiceAppointment_Handler)
 	*/
 	public static void generateCustIntServiceAppointmentConfirmed(Map<Id, ServiceAppointment> mapOld, Map<Id, ServiceAppointment> mapNew){
 		System.debug('In generateCustIntServiceAppointmentConfirmed');
 		
 		List<String> saIds = new List<String>();
        List<String> parentIds = new List<String>();
 		for(ServiceAppointment saNew : mapNew.values()){
 			if((saNew.XC_WorkTypeCategory__c == 'Site Inspection' || 
 				saNew.XC_WorkTypeCategory__c == 'Planned Maintenance' ||
				(saNew.XC_WorkTypeCategory__c == 'Commercial Visit' && saNew.XC_LegalEntity__c == 'EnelX')||
 				saNew.XC_WorkTypeCategory__c == 'Delivery & Installation') &&
 				saNew.XC_StatusReason__c == 'Assigned to the technician' &&
 				mapOld.get(saNew.Id).XC_StatusReason__c == 'To be scheduled' &&
 				saNew.SchedStartTime > date.TODAY()){
 					saIds.add(saNew.Id);
                    parentIds.add(saNew.ParentRecordId);
 			}
 		}
 		if(saIds.isEmpty()){
 			return;
 		}
 		Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>([
 			SELECT ContactId, AccountId, Id, XC_LegalEntity__c, ParentRecordId, Contact.XC_Segment__c, Contact.Name, Contact.Email, XC_Order__c
 			FROM ServiceAppointment
 			WHERE Id in: saIds]);
 
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([
		   SELECT Id, XC_LegalEntity__c,XC_Segment__c, XC_ProductSubType__c,XC_Configuration__r.NE__CatalogId__r.XC_LIC_Name__c, 
		   		XC_Configuration__r.CreatedBy.ContactId, XC_Configuration_Item__c, XC_Configuration__c, XC_Opportunity__c,
		   		XC_Configuration__r.CreatedBy.Contact.Email,XC_Configuration__r.CreatedBy.Contact.XC_Preferredlanguageofcontact__c, 
		   		XC_Configuration__r.CreatedBy.AccountId
		   FROM WorkOrder
			WHERE Id IN :parentIds AND XC_Configuration__r.NE__CatalogId__r.XC_LIC_Name__c='e-Mobility Automotive' AND (XC_ProductSubType__c ='Wallbox' OR XC_ProductSubType__c ='Home Check')
	   ]);
        
 		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
 		for(ServiceAppointment sa : saMap.values()){
 			Map<String,Object> ciInfo = populateCustIntServiceAppointmentConfirmed(sa);
 			interactions.add(ciInfo);
            
            if(woMap != null && woMap.get(sa.ParentRecordId) != null){
				Map<String,Object> ciInfoDealer = populateCIServiceAppointmentConfirmedDealer(woMap.get(sa.ParentRecordId), sa);
				interactions.add(ciInfoDealer);
			}
 		}
 		if(!interactions.isEmpty()){
 			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
 			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
 		}
 	}
 	
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 18/08/2020
 	* @description populate Customer Interaction
 	*/
 	public static Map<String,Object> populateCustIntServiceAppointmentConfirmed(ServiceAppointment sa){
 		
 		Map<String,Object> ciInfo = new Map<String,Object>();
 		ciInfo.put('workorderId', sa.ParentRecordId);
 		ciInfo.put('accountId', sa.AccountId);
 		ciInfo.put('customerType', 'ServiceAppointment_Confirmed');
 		ciInfo.put('fullName', sa.Contact.Name);
 		ciInfo.put('contactId', sa.ContactId);
 		ciInfo.put('orderId', sa.XC_Order__c);
 		ciInfo.put('serviceAppointmentId', sa.Id);
 		ciInfo.put('skipComunication', false);
 		ciInfo.put('sent', false);
 		ciInfo.put('legalEntity', sa.XC_LegalEntity__c);
 		ciInfo.put('email', sa.Contact.Email);
 		ciInfo.put('segment', sa.Contact.XC_Segment__c);
 		return ciInfo;
 	}
     
    /** 

	* @description 
	* @author  Dario Tramontin - dtramontin@deloitte.it
	* @date 13/01/2021
	* @description populate Customer Interaction for Dealer
	*/
	public static Map<String,Object> populateCIServiceAppointmentConfirmedDealer(WorkOrder wo, ServiceAppointment sa){

		Map<String,Object> ciInfo = new Map<String,Object>();
		ciInfo.put('workorderId', wo.Id);
		ciInfo.put('accountId', wo.XC_Configuration__r.CreatedBy.AccountId);
		ciInfo.put('contactId', wo.XC_Configuration__r.CreatedBy.ContactId );
		ciInfo.put('orderId', wo.XC_Configuration__c);
		ciInfo.put('orderItemID', wo.XC_Configuration_Item__c);
		ciInfo.put('opportunityId', wo.XC_Opportunity__c);
		ciInfo.put('serviceAppointmentId', sa.Id);
		ciInfo.put('email', wo.XC_Configuration__r.CreatedBy.Contact.Email);
		ciInfo.put('preferredlanguage', XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(wo.XC_Configuration__r.CreatedBy.Contact.XC_Preferredlanguageofcontact__c));
		ciInfo.put('legalEntity', wo.XC_LegalEntity__c);
		ciInfo.put('segment', wo.XC_Segment__c);	
		ciInfo.put('customerType', 'ServiceAppointment_Confirmed_Dealer');
		ciInfo.put('skipComunication', false);
		ciInfo.put('sent', false);
		
		return ciInfo;
	}
 
 
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 18/08/2020
 	* @description generate ServicePromo_Renewal Customer Interactions (XC_TR_Asset_Handler)
 	*/
 	public static void generateCustIntServicePromoRenewal(List<String> asId){
 		System.debug('In generateCustIntServicePromoRenewal');
 		
 		Map<Id, Asset> assmap = new Map<Id, Asset>([
 			SELECT ContactId, AccountId, Id, XC_LegalEntity__c, XC_Segment__c, NE__Order_Config__c, XC_Configuration_Item__c, Contact.Name, Contact.Email,
 			(SELECT Id, XC_Communication_Type__c FROM Customer_Interactions__r),
 			(SELECT Id, NE__Reason__c, NE__End_Date__c FROM NE__Asset_Discount__r 
 			WHERE NE__End_Date__c > TODAY)
 			FROM Asset
 			WHERE Id in: asId]);
 
 		List<Asset> asList = new List<Asset>();
 		for(Asset a : assmap.values()){
 			if(!a.NE__Asset_Discount__r.isEmpty()){
 				asList.add(a);
 			}
 		}
 		if(asList.isEmpty()){
 			return;
 		}
 		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
 		for(Asset a : asList){
 			Map<String,Object> ciInfo = populateCustIntServicePromoRenewal(assmap.get(a.id), 'ServicePromo_Renewal');
 			if(ciInfo != null){
 				interactions.add(ciInfo);
 			}
 		}	
 		if(!interactions.isEmpty()){
 			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromAsset(interactions);
 			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
 		}
 	}
 	
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 18/08/2020
 	* @description populate Customer Interaction
 	*/
 	public static Map<String,Object> populateCustIntServicePromoRenewal(Asset a, String communicationType){
 		
 		for(XC_Customer_Interaction__c ci : a.Customer_Interactions__r){
 			if(ci.XC_Communication_Type__c == communicationType){
 				return null;
 			}
 		}
 		
 		Map<String,Object> ciInfo = new Map<String,Object>();
 		ciInfo.put('orderId', a.NE__Order_Config__c);
 		ciInfo.put('accountId', a.AccountId);
 		ciInfo.put('customerType', communicationType);
 		ciInfo.put('assetId', a.Id);
 		ciInfo.put('fullName', a.Contact.Name);
 		ciInfo.put('contactId', a.ContactId);
 		ciInfo.put('skipComunication', false);
 		ciInfo.put('sent', false);
 		ciInfo.put('legalEntity', a.XC_LegalEntity__c);
 		ciInfo.put('email', a.Contact.Email);
 		ciInfo.put('segment', a.XC_Segment__c);
 		ciInfo.put('orderItemID', a.XC_Configuration_Item__c);
 		return ciInfo;
 	}
 
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 18/08/2020
 	* @description generate Orders_Pickup_NoStock_EnelX Customer Interactions (XC_TR_ProvisioningStep_Handler)
 	*/
 	public static void generateOrdersPickupNoStockEnelX(Map<Id, XC_Provisioning_Step__c> mapOld, Map<Id, XC_Provisioning_Step__c> mapNew){
 		System.debug('In generateOrdersPickupNoStockEnelX');
 		
 		List<String> psIds = new List<String>();
 		for(XC_Provisioning_Step__c ps : mapNew.values()){
 			if(ps.XC_StepLabel__c == 'Product Reservation' 
 			&& ps.XC_Status__c == 'Completed KO' 
 			&& mapOld.get(ps.id).XC_Status__c != 'Completed KO' 
 			&& ps.XC_ErrorMessage__c == 'The end date on Product is less than today'){
 				psIds.add(ps.Id);
 			}
 		}
 		Map<Id, XC_Provisioning_Step__c> psmap = new Map<Id, XC_Provisioning_Step__c>([
 			SELECT XC_Configuration_Item__c, 
 			XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Contact__c, 
 			XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Name, 
 			XC_Configuration_Item__r.NE__OrderId__c,
 			XC_Configuration_Item__r.NE__Account__c, 
 			XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Email, 
 			XC_Configuration_Item__r.XC_LegalEntityFormula__c, 
 			XC_Configuration_Item__r.XC_Segment__c
 			FROM XC_Provisioning_Step__c
 			WHERE Id in: psIds]);
 
 		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
 		for(XC_Provisioning_Step__c ps : psmap.values()){
 			Map<String,Object> ciInfo = populateCustIntOrdersPickupNoStockEnelX(ps);
 			if(ciInfo != null){
 				interactions.add(ciInfo);
 			}
 		}	
 		if(!interactions.isEmpty()){
 			generateCaseTechnicalAssistance(interactions);
 			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(interactions);
 			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
 		}
 	}
 	
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 18/08/2020
 	* @description populate Customer Interaction
 	*/
 	public static Map<String,Object> populateCustIntOrdersPickupNoStockEnelX(XC_Provisioning_Step__c ps){
 		
 		Map<String,Object> ciInfo = new Map<String,Object>();
 		ciInfo.put('orderId', ps.XC_Configuration_Item__r.NE__OrderId__c);
 		ciInfo.put('accountId', ps.XC_Configuration_Item__r.NE__Account__c);
 		ciInfo.put('customerType', 'Orders_Pickup_NoStock_EnelX');
 		ciInfo.put('fullName', ps.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Name);
 		ciInfo.put('contactId', ps.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Contact__c);
 		ciInfo.put('skipComunication', false);
 		ciInfo.put('sent', false);
 		ciInfo.put('legalEntity', ps.XC_Configuration_Item__r.XC_LegalEntityFormula__c);
 		ciInfo.put('email', ps.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Email);
 		ciInfo.put('segment', ps.XC_Configuration_Item__r.XC_Segment__c);
 		ciInfo.put('orderItemID', ps.XC_Configuration_Item__c);
 		return ciInfo;
 	}
 
 	public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_CustomerInteractionGeneration_UU.generateCaseTechnicalAssistance');
 	
 	/** 
 	* @description 
 	* @author  Giuseppe Di Bonito - gdibonito@deloitte.it
 	* @date 13/10/2020
 	* @description generate case for 'Orders_Pickup_NoStock_EnelX' customer interaction
 	*/
 	public static void generateCaseTechnicalAssistance(List<Map<String,Object>> interactions){ 
 		
 		List<String> caseSettingNames = new List<String>{Label.XC_CL_TechnicalAssistanceCase};
 		Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
 		if(caseSettingsMap.isEmpty() || caseSettingsMap.get(Label.XC_CL_TechnicalAssistanceCase)==null){
             XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+Label.XC_CL_TechnicalAssistanceCase); 
             return;
         }
         XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_TechnicalAssistanceCase); 
 		List<Case> newCases = new List<Case>();
         AssignmentRule AR = new AssignmentRule();
         AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
         Database.DMLOptions dmlOpts = new Database.DMLOptions();
         dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
 
         for(Map<String,Object> interaction : interactions){
 			Case newTecnicalCase;
 			newTecnicalCase = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
 			newTecnicalCase.XC_Order__c = String.valueOf(interaction.get('orderId'));
 			newTecnicalCase.AccountId = String.valueOf(interaction.get('accountId'));
 			newTecnicalCase.ContactId = String.valueOf(interaction.get('contactId'));
 			newTecnicalCase.XC_Segment__c = String.valueOf(interaction.get('segment'));
 			newTecnicalCase.XC_LegalEntity__c = String.valueOf(interaction.get('legalEntity'));
 			//Setting the DMLOption on Case instance > TO RUN Assignment Rules (ESCEP-2257 [MC 20191121])
 			newTecnicalCase.setOptions(dmlOpts);
 			newCases.add(newTecnicalCase);
 		}
 		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ newCases to create = ' + newCases+ ' - # newCases=' +newCases.size());
         List<XC_UTIL_SObject.WrapperResult> insCasesResults = XC_UTIL_DML.insertRecords(newCases);
 		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Insert Validation Case results = ' + insCasesResults);
	 }
	 
 	/** 
 	* @description cloneCIonSMS
 	* @author  Simone Trenta
 	*/
	public static Map<String,Object> cloneCIonSMS(XC_Customer_Interaction__c ci, String phone){
        
		Map<String,Object> ciInfo = new Map<String,Object>();
		ciInfo.put('customerType', ci.XC_Communication_Type__c);
		ciInfo.put('orderId', ci.XC_OrderId__c);
		ciInfo.put('accountId', ci.XC_AccountId__c);
		ciInfo.put('fullName', ci.XC_Recipient__c);
		ciInfo.put('contactId', ci.XC_ContactId__c);
		ciInfo.put('skipComunication', false);
		ciInfo.put('sent', false);
		ciInfo.put('legalEntity', ci.XC_LegalEntity__c);
		ciInfo.put('businessLine', 'eHome');
		ciInfo.put('phone', phone);
		return ciInfo; 
	}

	/** 
    *@author Giuseppe Di Bonito
    *@description set CC on the customer Interaction Document_Near_Expiration
    *@param listNew
    **/
    public static void setCCRecipientPartnerContact(List<XC_Customer_Interaction__c> listNew){ 
        List<XC_Customer_Interaction__c> ciNearExp = new List<XC_Customer_Interaction__c>();
        Set<Id> ciNearExpAccountID = new Set<Id>();
        for(XC_Customer_Interaction__c ci : listNew){
            if(ci.XC_Communication_Type__c == 'Document_Near_Expiration'){
                ciNearExp.add(ci);
                ciNearExpAccountID.add(ci.XC_AccountId__c);
            }
        }
        if(ciNearExpAccountID.isEmpty()){
            return;
        }
        Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT Id, AccountId, XC_ContractManagerEmail__c 
                                                                FROM Contract 
                                                                WHERE AccountId IN: ciNearExpAccountID
                                                                AND XC_ContractManagerEmail__c != null]);
        if(contractMap.isEmpty()){
            return;
        }
        System.debug('##contractMap: '+contractMap);

        //Creo una mappa che associa a ogni AccountID il set delle Email ad esso collegato
        Map<Id, Set<String>> accEmailAssociation = new Map<Id, Set<String>>();
        for(Id accId : ciNearExpAccountID){
            Set<String> emailSet = new Set<String>();
            for(Contract contr : contractMap.values()){
                if(accId == contr.AccountId){
                    emailSet.add(contr.XC_ContractManagerEmail__c);
                }
            }
            accEmailAssociation.put(accId, emailSet);
        }
        System.debug('##accEmailAssociation: '+accEmailAssociation);

        //Trasformo il set di Email in un'unica stringa
        Map<Id, String> accRecipient = new Map<Id, String>();
        for(Id accId : accEmailAssociation.keyset()){
            String emailConcat = '';
            for(String email : accEmailAssociation.get(accId)){
                if(emailConcat == ''){
                    emailConcat += email;
                
                } else {
                    emailConcat += ';' + email;
                }
            }
        }
        System.debug('##accRecipient: '+accRecipient);

        //Associo le Email alle Customer Interaction
        for(XC_Customer_Interaction__c ci : ciNearExp){
            for(Id accId : accRecipient.keyset()){
                if(accId == ci.XC_AccountId__c){
                    ci.XC_CCRecipients__c = accRecipient.get(accId);  
                }
            }
        }
    }
 }