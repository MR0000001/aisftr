/**
* @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
* @date Creation 27/09/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_Opportunity_U_AssignOpportunity – Class to manage oppportunity assignment
*/ 
public without sharing class XC_TR_Opportunity_U_AssignOpportunity {  

	@future(callout=true)
	public static void getContractAsyncExecution(Map<String,String> infoMap){

		String cups = infoMap.get('cups');
		Opportunity opp = (Opportunity) JSON.Deserialize(infoMap.get('opp'), Opportunity.Class);
		String contractType = infoMap.get('contractType');

		System.debug('cups'+ cups);
		Map<String,Object> callResult = XC_REST_Contract_Outbound.calltogetcontract('', cups);

		if(callResult.isEmpty() || callResult.get('Contract')==null) {
			return; 
		}

		Object contractValues = ((List<Object>)callResult.get('Contract'))[0];
		Map<String,Object> contract = (map<String,Object>)contractValues;

		if(contract == null) {
			return; 
		}
		
		if(contractType=='Gas'){
			opp = updateGasInfo(opp, contract);

		} else if(contractType=='Electric'){
			opp = updateLigthInfo(opp, contract);

		}

		XC_UTIL_Sobject.updateRecord(opp);
	}



	/**
	 * @description The Class ListPartition.
	 */
	public class ListPartition{
		List<Opportunity> oppWith = new List<Opportunity>();
        List<Opportunity> oppWithout = new List<Opportunity>();
	}


	/**
	 * rebaltCUPS
	 *
	 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
	 * @param listToAssign the opportunity list to assign
	 * @description Method to rebalt CUPS contract
	 */ 

	public static void rebaltCUPS(List<Opportunity> listToAssign){ 
		List<String> opportunityId = new List<String>(); 
		for (Opportunity opp : listToAssign){ 
			opportunityId.add(opp.Id);
		}
		
		Map<id,Opportunity> mpOp = new Map<id,Opportunity>([SELECT id,XC_GasContract__c,XC_ElectricContract__c, XC_GasCUPS__c,XC_ElectricCUPS__c,AccountId,Account.IdentityNumber__c, XC_Address__c,XC_Address__r.XC_ElectricCUPS__c, XC_Address__r.XC_GasCUPS__c FROM Opportunity WHERE Id IN:opportunityId]);
		List<Opportunity> oppToChange = mpOp.values();
		Map<String,String> infoMap = new Map<String,String>();

		System.debug('call getContractAsyncExecution');
		for (Opportunity opp : oppToChange){ 

			if(opp.XC_Address__r.XC_ElectricCUPS__c!=null){
				opp.XC_ElectricCUPS__c = opp.XC_Address__r.XC_ElectricCUPS__c;
				infoMap.put('cups', opp.XC_Address__r.XC_ElectricCUPS__c);
				infoMap.put('opp', JSON.serialize(opp));
				infoMap.put('contractType', 'Electric');

				getContractAsyncExecution(infoMap);
				//	opp.XC_ElectricCUPS__c =opp.XC_Address__r.XC_ElectricCUPS__c;
			}

			if(opp.XC_Address__r.XC_GasCUPS__c!=null){
				opp.XC_GasCUPS__c = opp.XC_Address__r.XC_GasCUPS__c;
				infoMap.put('cups', opp.XC_Address__r.XC_GasCUPS__c);
				infoMap.put('opp', JSON.serialize(opp));
				infoMap.put('contractType', 'Gas');

				getContractAsyncExecution(infoMap);
				//opp.XC_GasCUPS__c= opp.XC_Address__r.XC_GasCUPS__c;
			}

			//IMPORTANTE: DA METTERE QUEUABLE QUANDO CI SARA LA CHIAMATA VERA ///////////////////////////////////
			
			

			/*
			if(opp.Account.IdentityNumber__c!=null){
				opp.XC_IdentityNumber__c = opp.Account.IdentityNumber__c;
				if(opp.XC_IdentityNumber__c==wr.identityNumber){
					opp.XC_GasContractOwnerType__c = 'Owner';
					opp.XC_ElectricContractOwnerType__c = 'Owner';

				}
				
		    }*/
		}
		XC_UTIL_Sobject.updateListRecords(oppToChange); 
		
	}

	/**
	 * Assign auto number name.
	 *
	 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
	 * @param listToAssign the list to assign
	 * @description Change Opportunity's Name in Autonumber
	 */

	public static void assignAutoNumberName(List<Opportunity> listToAssign){ 
		List<String> opportunityId = new List<String>(); 
		for (Opportunity opp : listToAssign){ 
			opportunityId.add(opp.Id);
		}
		
		Map<id,Opportunity> mpOp = new Map<id,Opportunity>([SELECT id, XC_OpportunityCode__c FROM Opportunity WHERE Id IN:opportunityId AND XC_Segment__c = 'B2C' /*(XC_Segment__c = 'B2C' OR XC_LegalEntity__c IN ('Codensa','EnelX','EnelDistribucion','EnelXMobilityChile'))*/]);//VDB 170322 CR 758
		List<Opportunity> oppToChange = mpOp.values();
		for (Opportunity opp : oppToChange){ 
			opp.Name = opp.XC_OpportunityCode__c;
		}
		XC_UTIL_Sobject.updateListRecords(oppToChange);
	}



    /**
     * Rebalt scoring.
     *
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @param listToAssign the list to assign
     * @description retrive account scoring and copy it on new opportunity
     */
    /*
	public static void rebaltScoring(List<Opportunity> listToAssign){ 
        List<String> accountIds = XC_UTIL_Sobject.getListFieldValues(listToAssign, 'AccountId');
        Map<Id, Account> mapAccount = getCurrentAccScoreValues(accountIds);

        for (Opportunity opp : listToAssign){
        	if(mapAccount.containsKey(opp.AccountId)){
        		opp.XC_Score__c = mapAccount.get(opp.AccountId).XC_Score__c;
			 	opp.XC_Score_Name__c = mapAccount.get(opp.AccountId).XC_Score_Name__c;
			  	opp.XC_Score_Number__c = mapAccount.get(opp.AccountId).XC_Score_Number__c;
        	}
        } 
    }*/

	/**
	 * @description Gets the current acc score values.
	 * @param accountIds the account ids
	 * @return the current acc score values
	 */
    /*
	public static Map<Id, Account> getCurrentAccScoreValues(List<String> accountIds){
        return new Map<Id,Account>([
        	SELECT Id, XC_Score__c, XC_Score_Name__c, XC_Score_Number__c 
        	FROM Account 
        	WHERE Id IN:accountIds LIMIT 1]);
 	}*/

	/**
     * @author Simone Trenta - strenta@deloitte.it
     * @param opp the opportunity
	 * @param contract the contract
	 * @return the opportunity
     * @description update contract info on opportunity
     */
	private static Opportunity updateGasInfo(Opportunity opp, Map<String,Object> contract){

	 	Map<String, Object> mapField = new Map<String, Object>{ 
			'XC_GasContract__c' => contract.get('ContractNumber'), 
            'XC_GasTariff__c' => contract.get('Tariff'), 
			'XC_GasOwnerCompany__c' => contract.get('OwnerCompany'), 
            'XC_GasMaximumPower__c' => contract.get('MaximumPowerPOD')
		};

		return manageUpdate(opp, mapField);
	}

	/**
     * @author Simone Trenta - strenta@deloitte.it
     * @param opp the opportunity
	 * @param contract the contract
	 * @return the opportunity
     * @description update contract info on opportunity
     */
	private static Opportunity updateLigthInfo(Opportunity opp, Map<String,Object> contract){

		Map<String, Object> mapField = new Map<String, Object>{ 
			'XC_ElectricContract__c' => contract.get('ContractNumber'), 
            'XC_ElectricTariff__c' => contract.get('Tariff'), 
			'XC_ElectricMinimumConsumption__c' => contract.get('MinimumElectricalConsumption'), 
            'XC_ElectricTensionType__c' => contract.get('TensionType'),
			'XC_ElectricContractedPower__c' => contract.get('ContractedPower'), 
			'XC_ElectricOwnerCompany__c' => contract.get('OwnerCompany'), 
            'XC_ElectricCieAuthorizedMaximumPower__c' => contract.get('CIEAuthorizedMaximumPower')
		};

		return manageUpdate(opp, mapField);
	}

	private static Opportunity manageUpdate(Opportunity opp, Map<String,Object> mapField){
		
		for (String field : mapField.keySet()) {
            if ( mapField.get(field)!=null && mapField.get(field)+'' != '') {
                opp.put(field, mapField.get(field));
            }    
        }

		return opp;
	}


}