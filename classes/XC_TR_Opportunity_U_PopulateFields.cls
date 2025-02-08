/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 16/04/2019
 * @date Modification 06/06/2019 modified to populate pricing region from address - Simone Trenta strenta@deloitte.it
 * @date Modification 30/07/2019 modified for Zuora multi-entity Management - Nicola Mariniello nmariniello@deloitte.it & Luisana Rocco lrocco@deloitte.it
 * @description XC_TR_Opportunity_U_PopulateFields – Populate fields for Opportunity
 */


public without sharing class XC_TR_Opportunity_U_PopulateFields {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Opportunity_U_PopulateFields');

    //DeAv 19/03/2022 CR758 START
    public static final Map<String,String> CONTRACT_TYPE_MAP = new Map<String,String>{
        'Spot Sales works'                           => 'Construction and service contracts',
        'Asset renting'                              => 'Simple Contracts',
        'Capex Intensive Projects with energy ESCO'  => 'Commodity, construction and service contracts',
        'Cold Ironing'                               => 'Construction and service contracts',
        'Contracts of just Energy'                   => 'B2G Standard Contracts',
        'Extracanone works PF_Gare_Consip'           => 'Extra works of commodity, construction and service contracts',
        'Green Ports'                                => 'Construction and service contracts',
        'Integrated offer Investiments on assets_OM' => 'B2G Standard Contracts',
        'Investiments on owned assets'               => 'B2G Standard Contracts',
        'Investiments on owned assets ERP'           => 'B2G Standard Contracts',
        'Investiments on third parties assets'       => 'Commodity, construction and service contracts',
        'OM Projects with energy'                    => 'Commodity, construction and service contracts',
        'OM Projects without energy'                 => 'B2G Standard Contracts',
        'Simple contracts'                           => 'Simple Contracts',
        'Spot Sales material supply'                 => 'Simple Contracts',
        'Spot Sales Works_OM'                        => 'Construction and service contracts',
        'Spot Sales works with deferred payment'     => 'Accrued Plans',
        'Capex Intensive Projects without energy'    => 'B2G Standard Contracts'
    };
    //DeAv 19/03/2022 CR758 END
 
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 16/04/2019
    * @description Populate fields for Opportunity
    * @param listNew - List Opportunity to Insert
    */
    public static void populateFields(List<Opportunity> listNew) {
        Map<Id, User> runningUserMap = new Map<Id, User>([SELECT Id, XC_LegalEntity__c FROM User WHERE Id = :UserInfo.getUserId()]);
        User runningUser;
        Boolean userRetrieved = false;
        if(!runningUserMap.values().isEmpty()) {
            runningUser = runningUserMap.values()[0];
            userRetrieved = true;
        }
        List<Id> accountIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'AccountId');
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT XC_SohoType__c, XC_Segment__c, XC_Zone__c FROM Account WHERE Id IN: accountIds]);
        Set<String> countrySet = XC_UTIL_Sobject.getSetIdsStringOnField(listNew, 'XC_ActivationCountry__c');
        Map<String, String> countryCurrencyMap = new Map<String, String>();
        if(!countrySet.isEmpty()) {
            Map<Id, XC_CM_CountryISOCodeAssociation__mdt> countryMap = new Map<Id, XC_CM_CountryISOCodeAssociation__mdt>([
                                                                                        SELECT Id, XC_Country__c, XC_Currency__c
                                                                                        FROM XC_CM_CountryISOCodeAssociation__mdt
                                                                                        WHERE XC_Country__c IN: countrySet AND XC_Currency__c != null]);
            for(XC_CM_CountryISOCodeAssociation__mdt elem : countryMap.values()) {
                countryCurrencyMap.put(elem.XC_Country__c, elem.XC_Currency__c);
            }
        }
        Map<String,Opportunity> mapOppAdd = new Map<String,Opportunity>(); 
        Set<String> legalEntitySet = new Set<String>();
        Set<String> streamSet = new Set<String>();
        for(Opportunity opp : listNew){ 
            opp.XC_Lead__c = opp.XC_LeadId__c;
            System.debug('OPTY SEGM'+ opp.XC_Segment__c);
            opp.XC_Segment__c = accMap.get(opp.AccountId).XC_Segment__c;
            
            if(String.isBlank(opp.XC_LegalEntity__c) && userRetrieved) {
                opp.XC_LegalEntity__c = runningUser.XC_LegalEntity__c;
            }
            opp.XC_Currency__c = (String.isNotBlank(opp.XC_ActivationCountry__c) && countryCurrencyMap.containsKey(opp.XC_ActivationCountry__c)) ? countryCurrencyMap.get(opp.XC_ActivationCountry__c) : ((opp.XC_LegalEntity__c == 'EnelXMSP') ? 'EUR' : null);
            if(opp.XC_BillingModel__c == 'Capex'){
                opp.XC_InvestmentCapex_GB__c = 100;
            }
            setSkipRisk(opp, accMap);
            legalEntitySet.add(opp.XC_LegalEntity__c);
            streamSet.add(opp.XC_Segment__c);
            mapOppAdd.put(opp.XC_Address__c, opp);
            //DeAv Fix Zone CR758 08.06.2022 START
            List<String> segmentList = new List<String>{'B2B', 'B2G'};
            if('B2C'.equalsIgnoreCase(opp.XC_Segment__c) || (segmentList.contains(opp.XC_Segment__c) && opp.XC_Zone__c == null)){
                opp.XC_Zone__c = accMap.get(opp.AccountId).XC_Zone__c;
            }
            //DeAv Fix Zone CR758 08.06.2022 END
            
        } 
        for(XC_Address__c add : XC_TR_Opportunity_U_PopulateFields_D.getAddrFields(mapOppAdd.keySet())){
            if(String.isNotBlank(add.XC_PricinRegion__c)) {
                mapOppAdd.get(add.id).XC_PrincingRegion__c = add.XC_PricinRegion__c;
            }
        }
        populateCountryRecordType(listNew, legalEntitySet, streamSet);
    }

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it & Luisana Rocco lrocco@deloitte.it
     * @date Creation 18/09/2019
     * @description Populate skipRisk field
     * @param opp - Opportunity
     * @param accMap - Map with AccountId as key and Account as value 
     */
    public static void setSkipRisk(Opportunity opp, Map<Id, Account> accMap) {
        if(accMap.get(opp.AccountId) != null && (accMap.get(opp.AccountId).XC_SohoType__c != 'Soho' && !String.isBlank(accMap.get(opp.AccountId).XC_SohoType__c))){
            opp.XC_SkipRisk__c = true; 
        } 
    }

    /**
     * @author Nicola Mariniello nmariniello@deloitte.it & Luisana Rocco lrocco@deloitte.it
     * @date Creation 30/07/2019
     * @description Populate Country for Opportunity
     * @param listNew - List Opportunity to Insert
     */
    public static void populateCountryRecordType(List<Opportunity> listNew, Set<String> legalEntitySet, Set<String> streamSet) {
        Map<String, XC_SegmentUtilities.RTConfigWrapper> recordTypesMap = XC_SegmentUtilities.getLegEntityConfig(legalEntitySet, streamSet);
        for(Opportunity opp : listNew){
            if(opp.XC_OpportunityType__c != null && opp.XC_OpportunityType__c == 'Business Plan'){
                if(recordTypesMap.get(opp.XC_LegalEntity__c+opp.XC_Segment__c) != null) {
                    opp.XC_Country__c = recordTypesMap.get(opp.XC_LegalEntity__c + opp.XC_Segment__c).country;
                    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypesMap.get(opp.XC_LegalEntity__c+opp.XC_Segment__c).opportunityRTBP).getRecordTypeId();
                }
            }else{
                if(recordTypesMap.get(opp.XC_LegalEntity__c+opp.XC_Segment__c) != null) {
                    opp.XC_Country__c = recordTypesMap.get(opp.XC_LegalEntity__c + opp.XC_Segment__c).country;
                    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypesMap.get(opp.XC_LegalEntity__c+opp.XC_Segment__c).opportunityRT).getRecordTypeId();
                }
            }
        }
    }

    /**
    * @author Dario Tramontin dtramontin@deloitte.it
    * @date Creation 04/12/2019
    * @description Encrypt Id
    * @param listNew - List Opportunity
    */
    public static void encryptOpportunityIds(List<Opportunity> listNew) {
        System.debug('Debug IN Opportunity_U_PopulateFields - encryptOpportunityIds ');
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        for(Opportunity opp: listNew){
            Opportunity oppUpdate= new Opportunity(Id=opp.Id);
            oppUpdate.XC_EncryptedId__c = XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(opp.Id);
            oppToUpdate.add(oppUpdate);
        }
        XC_UTIL_Sobject.updateListRecords(oppToUpdate); 
    }

    /**
    * @date Creation 18/01/2021
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Updates Code, Platform, and Product fields from Lead to Opportunity
    * @param listNew - List<Opportunity> 
    * @param mapOld - Map<Id,Opportunity>
    * @param mapNew - Map<Id,Opportunity>
    */
    public static void changeCampaignField(List<Opportunity> listNew, Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        List<String> fieldList = new List<String>{'XC_Lead__c'};
        List<Opportunity> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            Map<Id, Lead> mapLeadInfo = new Map<Id, Lead>([
                SELECT Id, Status, XC_CampaignCode__c, XC_CampaignPlatform__c, XC_CampaignProduct__c, XC_ForceConversion__c
                FROM Lead
                WHERE Id IN :XC_UTIL_Sobject.getListFieldValues(listChanged, 'XC_Lead__c')
            ]);
            Map<Id,NE__Order__c> mapChildOrderOpty = new Map<Id,NE__Order__c>([
                SELECT Id, NE__OptyId__c
                FROM NE__Order__c
                WHERE NE__OptyId__c != NULL 
                    AND  RecordType.Name = 'Order'
                    AND NE__Type__c = 'InOrder'
                    AND NE__OptyId__c IN :XC_UTIL_Sobject.getListFieldValues(listChanged, 'Id')
            ]);
            
            List<NE__Order__c> listOrderToUpdate = new List<NE__Order__c>();
            List<Lead> listLeadToUpdate = new List<Lead>();
            for(Opportunity op : listChanged) {
                String keyLead = op.XC_Lead__c;
                Boolean fillCampaignFields = mapLeadInfo.containsKey(keyLead) && String.isNotBlank(mapLeadInfo.get(keyLead).XC_CampaignCode__c) && String.isNotBlank(mapLeadInfo.get(keyLead).XC_CampaignPlatform__c) && String.isNotBlank(mapLeadInfo.get(keyLead).XC_CampaignProduct__c);
                Boolean updateLeadStatus = mapLeadInfo.containsKey(keyLead) && mapLeadInfo.get(keyLead).Status != Label.XC_CL_Lead_ClosedConverted;
                if(fillCampaignFields) {
                    Lead ld = mapLeadInfo.get(keyLead);
                    op.XC_CampaignCode__c = ld.XC_CampaignCode__c;
                    op.XC_CampaignProduct__c = ld.XC_CampaignProduct__c;
                    op.XC_CampaignPlatform__c = ld.XC_CampaignPlatform__c;
                    for(NE__Order__c ord : mapChildOrderOpty.values()) {
                        if(ord.NE__OptyId__c == op.Id){
                            ord.XC_CampaignPlatform__c = ld.XC_CampaignPlatform__c;
                            ord.XC_CampaignProduct__c = ld.XC_CampaignProduct__c;
                            ord.XC_CampaignCode__c = ld.XC_CampaignCode__c;
                            listOrderToUpdate.add(ord);
                            break; 
                        }
                    }
                }
                if(updateLeadStatus) {
                    listLeadToUpdate.add(new Lead(
                        Id = mapLeadInfo.get(keyLead).Id,
                        Status = Label.XC_CL_Lead_ClosedConverted,
                        XC_ForceConversion__c = true
                    ));
                }
            }
            XC_UTIL_Sobject.updateListRecords(listOrderToUpdate);
            XC_UTIL_Sobject.updateListRecords(listLeadToUpdate);
        }
    }

    /**
    * @author Marina Ciavarra - mciavarra@deloitte.it
    * @date Creation 17/05/2021
    * @description Populate field XC_ShippingCostArea__c for Opportunity
    * @param listNew - List Opportunity to Insert
    */
    public static void populateShippingCostArea(List<Opportunity> listNew) {
        Set<Id> addressIds = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'XC_Address__c');
		Map< Id, XC_Address__c> mapAddress = new Map<Id,XC_Address__c>([SELECT id, XC_AddressCountry__c, XC_City__c, 
                                                                    XC_PostalCode__c, XC_AddressProvince__c,  
                                                                    XC_Municipality__c, XC_Region__c
                                                                    FROM XC_Address__c 
                                                                    WHERE id IN :addressIds]);
									
		Map<String, String> mapCmtObjectField = new Map<String, String> {   'City' => 'XC_City__c', 
																			'ZipCode' => 'XC_PostalCode__c',
																			'Country' => 'XC_AddressCountry__c',
																			'Province' => 'XC_AddressProvince__c',
																			'Municipality' => 'XC_Municipality__c',
																			'Region' => 'XC_Region__c'
																			};
		if(!mapAddress.isEmpty()){
			List <String> listCountry = populateListCountry (mapAddress);
			Map<Id, XC_CM_CountryISOCodeAssociation__mdt> countryMap = new Map<Id, XC_CM_CountryISOCodeAssociation__mdt>([
																							SELECT Id, XC_Country__c, XC_AreaFieldIdentifier__c
																							FROM XC_CM_CountryISOCodeAssociation__mdt
																							WHERE XC_Country__c IN: listCountry]);
			if(!countryMap.isEmpty()){
				Map<String, String> mapCountryAFI = populateMapCountryAFI(countryMap);
				List<String> keyValueList = new List<String>();
				for(String strCountry : mapCountryAFI.keySet()){
					for(Id addId : mapAddress.keySet()){
						if(mapAddress.get(addId).XC_AddressCountry__c == strCountry){
							keyValueList.add((String) mapAddress.get(addId).get(mapCmtObjectField.get(mapCountryAFI.get(strCountry))));
						}    
					}
				}
			
				Map<Id, XC_ShippingCostZone__c> mapShipCost = new Map<Id, XC_ShippingCostZone__c>([ SELECT Id, XC_Area__c , XC_Country__c, XC_KeyValue__c
																						FROM XC_ShippingCostZone__c
																						WHERE XC_Country__c IN : listCountry  and XC_KeyValue__c IN : keyValueList]);
				
				
				if(!mapShipCost.isEmpty()){
					for(Opportunity o : listNew) {
						String country = mapAddress.get(o.XC_Address__c).XC_AddressCountry__c;
						String key = (String) mapAddress.get(o.XC_Address__c).get(mapCmtObjectField.get(mapCountryAFI.get(country)));
						for(XC_ShippingCostZone__c zone : mapShipCost.values()){
							if(zone.XC_Country__c == country && zone.XC_KeyValue__c == key ){
								o.XC_ShippingCostArea__c = zone.XC_Area__c;
							}
						}
					}
				}
			}
		}
	}

    private static List <String> populateListCountry (Map< Id, XC_Address__c> mapAddress){
        List <String> listCountry = new List <String>();
        for(XC_Address__c addr: mapAddress.values()){
            listCountry.add(addr.XC_AddressCountry__c);
        }
        return listCountry;
    }

    private static Map<String, String> populateMapCountryAFI (Map<Id, XC_CM_CountryISOCodeAssociation__mdt> countryMap){
        Map<String, String> mapCountryAFI = new Map<String, String>();
        for(XC_CM_CountryISOCodeAssociation__mdt cmdt : countryMap.values()){
            if((mapCountryAFI.isEmpty() || !mapCountryAFI.containsKey(cmdt.XC_Country__c)) && cmdt.XC_AreaFieldIdentifier__c!= null)
                mapCountryAFI.put(cmdt.XC_Country__c, cmdt.XC_AreaFieldIdentifier__c);
        }
        return mapCountryAFI;
    }
    

/**
    * @author Calogero Perconti - cperconti@deloitte.it
    * @date Creation 08/10/2021
    * @description Populate field XC_Zone__c for Opportunity
    * @param listNew - List Opportunity to Insert
    */
    public static void populateZone(List<Opportunity> listNew) {
    set<Id> accId = new set<Id>();
    for(Opportunity op : listnew){
        if(String.isNotBlank(op.AccountId)){
        accId.add(op.AccountId);
        }
    }
    if(accId.isEmpty()){
        return ;
    }
    Map<Id, Account> mapAcc = new Map<Id, Account>([
        SELECT Id, XC_Zone__c
        FROM Account
        WHERE Id IN :accId
    ]);
    for(Opportunity opc:listnew){
        if(mapAcc.get(opc.AccountId)!= null){
            //DeAv Fix Zone CR758 08.06.2022 START
            List<String> segmentList = new List<String>{'B2B', 'B2G'};
            if('B2C'.equalsIgnoreCase(opc.XC_Segment__c) || (segmentList.contains(opc.XC_Segment__c) && opc.XC_Zone__c == null)){
                opc.XC_Zone__c = mapAcc.get(opc.AccountId).XC_Zone__c;
            }
            //DeAv Fix Zone CR758 08.06.2022 END          
            
        }
    }
}

    /**
    * @author Denise Avolio - denise.avolio@accenture.com 
    * @date Creation 19/03/2022
    * @description Populate field ContractType for Opportunity CR758
    * @param listNew - List Opportunity to Insert
    */
    public static void populateContractType(List<Opportunity> listNew) {

        List<String> legEntItaly = new List<String>{'EnelXItalia', 'EnelSole'};             
        for(Opportunity opp : listNew){
            if('B2C'.equalsIgnoreCase(opp.XC_Segment__c)){
                return;
            }else if('eCity'.equalsIgnoreCase(opp.XC_BusinessLine__c) && legEntItaly.contains(opp.XC_LegalEntity__c)){
                for(String commContrType : CONTRACT_TYPE_MAP.keySet()){
                    if(commContrType.equalsIgnoreCase(opp.XC_Commercial_Contract_Type__c)){
                        opp.XC_ContractType__c = CONTRACT_TYPE_MAP.get(commContrType);
                    }
                }
            }else{
                opp.XC_ContractType__c = 'Simple contracts';
            }
        }
    }

    /**
    * @author Denise Avolio - denise.avolio@accenture.com 
    * @date Creation 19/03/2022
    * @description Populate field ContractType for Opportunity CR758
    * @param listNew - listNew of Opportunity to update
    * @param mapOld  - old Opportunity values
    * @param mapNew  - new Opportunity values
    */
    public static void populateContractTypeOnUpdate(List<Opportunity> listNew, Map<Id, Opportunity> mapOld, Map<Id, Opportunity> mapNew) {
        
        List<String> fieldList = new List<String>{'XC_Commercial_Contract_Type__c'};
        List<Opportunity> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);        
        if(listChanged.isEmpty()){
            return;
        }
        populateContractType(listChanged);
    }
}