/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 26/06/2020
* @date Modification 
* @description XC_TR_DocumentURL_GenerateCI
*/

public class XC_TR_DocumentURL_GenerateCI { 

    /** 
    * @description 
    * @author  Giuseppe Di Bonito - gdibonito@deloitte.it
    * @date 26/06/2020
	* @description check Document Type number of files match and generate Welcome_Contract Customer Interaction
	*/
	public static void checkDocTypeAndGenerateCI(List<XC_DocumentURL__c> ListNew){

        System.debug('In checkDocTypeAndGenerateCI');
 		Set<Id> ordIds = new Set<Id>();
        
        for(XC_DocumentURL__c docUrl : ListNew){
            ordIds.add(docUrl.XC_Configuration__c);
        }
        System.debug('Order List: ' + ordIds);

        if(ordIds.isEmpty()){
            return;
        }
        //CREDIT ASSIGNMENT GESTITI CON LA SIGNATURE ITEM
        //aggiungere query su order item che hanno generated contract = true. quando i contract to sign sono zero il numero verrà preso dalla size di questa lista. solo per contract
        Map<Id, NE__Order__c> qmap = new Map<Id, NE__Order__c>([
                        SELECT Id, NE__AccountId__c, NE__OptyId__c, XC_LegalEntity__c,
                        NE__OptyId__r.XC_Contact__c, NE__OptyId__r.XC_Contact__r.Name, 
                        NE__OptyId__r.XC_Contact__r.Email, 
                            (SELECT Id FROM NE__Order_Items__r WHERE XC_ContractGenerated__c = true),
                            (SELECT id, Category__c, numberOfFiles__c, XC_Configuration__c
                            FROM Document_Types__r 
                            WHERE //Category__c='SF_CREDIT_ASSIGNMENT_TO_SIGN' OR
                            Category__c='SF_CONTRACT_TO_SIGN' 
                            //OR Category__c='SF_CREDIT_ASSIGNMENT_SIGNED'
                            OR Category__c='SF_CONTRACT_SIGNED')
                        FROM NE__Order__c 
                        WHERE Id in: ordIdS
                        AND RecordType.Name = 'Order']);
        System.debug('Order query map: '+qmap);                

        Map<Id, XC_Customer_Interaction__c> cimap = new Map<Id, XC_Customer_Interaction__c>([
                        SELECT Id, XC_Communication_Type__c, XC_Disabled__c, XC_OrderId__c, XC_Doc_URL_List__c
                        FROM XC_Customer_Interaction__c
                        WHERE XC_Communication_Type__c LIKE 'Welcome_Contract%'
                        AND XC_OrderId__c in: ordIdS]);
        System.debug('Customer Interactions query map: ' + cimap);

        //Map<Id, XC_DocumentType__c> credAssToSignMap = new Map<Id, XC_DocumentType__c>();
        //Map<Id, XC_DocumentType__c> credAssSigned = new Map<Id, XC_DocumentType__c>();
        Map<Id, XC_DocumentType__c> contractToSignMap = new Map<Id, XC_DocumentType__c>();
        Map<Id, XC_DocumentType__c> contractSignedMap = new Map<Id, XC_DocumentType__c>();

        for(NE__Order__c ord : qmap.values()){
            for(XC_DocumentType__c dt : ord.Document_Types__r){
                /*if(dt.Category__c == 'SF_CREDIT_ASSIGNMENT_TO_SIGN'){
                    credAssToSignMap.put(ord.id, dt);
                
                } else if(dt.Category__c == 'SF_CREDIT_ASSIGNMENT_SIGNED'){
                    credAssSigned.put(ord.id, dt);

                } else*/ if(dt.Category__c == 'SF_CONTRACT_TO_SIGN'){
                    contractToSignMap.put(ord.id, dt);

                } else if(dt.Category__c == 'SF_CONTRACT_SIGNED'){
                    contractSignedMap.put(ord.id, dt);

                }
            }
        }

        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        Boolean welcome_contract_already_exists = false;
        for(NE__Order__c ord : qmap.values()){
            if(!cimap.isEmpty()){
            	for(XC_Customer_Interaction__c ci : cimap.values()){
                    if(ord.id == ci.XC_OrderId__c && ci.XC_Disabled__c == false && ci.XC_Doc_URL_List__c != null){
                        welcome_contract_already_exists = true;
                        break;
                    }
                }
            }

            if(welcome_contract_already_exists){
                System.debug('welcome_contract_already_exists TRUE');
                continue;
            
            /*
            // CASE 1 - Credit Assignment and Contract Signed Found
            } else if(credAssSigned.get(ord.id) != null && contractSignedMap.get(ord.id) != null){
                System.debug('Trovati CAS e CS');
                
                //Check if the to_sign documents are present
                if(credAssToSignMap.get(ord.id) == null && contractToSignMap.get(ord.id) == null){
                    Map<String,Object> ciInfo = createCustomerInteraction(ord);
                    interactions.add(ciInfo);

                } else if(credAssToSignMap.get(ord.id) == null){
                    if(contractToSignMap.get(ord.id).numberOfFiles__c <= contractSignedMap.get(ord.id).numberOfFiles__c){
                        Map<String,Object> ciInfo = createCustomerInteraction(ord);
                        interactions.add(ciInfo);
                    }
                } else if(contractToSignMap.get(ord.id) == null){
                    if(credAssToSignMap.get(ord.id).numberOfFiles__c <= credAssSigned.get(ord.id).numberOfFiles__c){
                        Map<String,Object> ciInfo = createCustomerInteraction(ord);
                        interactions.add(ciInfo);
                    }
                }

            // CASE 2 - Credit Assignment Signed Found
            } else if(credAssSigned.get(ord.id) != null){
                System.debug('Trovato CAS');

                //Check if the to_sign document is present
                if(credAssToSignMap.get(ord.id) == null){
                    Map<String,Object> ciInfo = createCustomerInteraction(ord);
                    interactions.add(ciInfo);
                
                } else if(credAssToSignMap.get(ord.id).numberOfFiles__c <= credAssSigned.get(ord.id).numberOfFiles__c){
                    Map<String,Object> ciInfo = createCustomerInteraction(ord);
                    interactions.add(ciInfo);
                }
            */
            // CASE 3 - Contract Signed Found
            } else if(contractSignedMap.get(ord.id) != null){
                System.debug('Trovato CS');

                //Check if the to_sign document is present
                if(contractToSignMap.get(ord.id) == null){
                    if(ord.NE__Order_Items__r.size() == contractSignedMap.get(ord.id).numberOfFiles__c){
                        Map<String,Object> ciInfo = createCustomerInteraction(ord);
                        interactions.add(ciInfo);
                    }

                } else if(contractToSignMap.get(ord.id).numberOfFiles__c <= contractSignedMap.get(ord.id).numberOfFiles__c){
                    Map<String,Object> ciInfo = createCustomerInteraction(ord);
                    interactions.add(ciInfo);
                }
            }
        }

		if(!interactions.isEmpty()){
            populateUrl(interactions);
			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(interactions);
			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
		}
    }

    /*
	 * @author Giuseppe Di Bonito - gdibonito@deloitte.it
	 * @param listNew
	 * @date Creation 08/05/2020
	 * @description creates the customer interaction 
	 */
	public static Map<String,Object> createCustomerInteraction(NE__Order__c configuration){

		Map<String,Object> ciInfo = new Map<String,Object>();
		ciInfo.put('customerType', 'Welcome_Contract');
		ciInfo.put('orderId', configuration.Id);
		ciInfo.put('accountId', configuration.NE__AccountId__c);
		ciInfo.put('fullName', configuration.NE__OptyId__r.XC_Contact__r.Name);
		ciInfo.put('contactId', configuration.NE__OptyId__r.XC_Contact__c);
		ciInfo.put('skipComunication', false);
		ciInfo.put('sent', false);
		ciInfo.put('legalEntity', configuration.XC_LegalEntity__c);
        ciInfo.put('email', configuration.NE__OptyId__r.XC_Contact__r.Email);
        ciInfo.put('businessLine', 'eHome');
        
        return ciInfo;
    }

     /*
	 * @author Giuseppe Di Bonito - gdibonito@deloitte.it
	 * @param listNew
	 * @date Creation 09/05/2020
	 * @description fill the url
	 */
	public static void populateUrl(List<Map<String,Object>> interactions){

        Set<Id> ordIds = new Set<Id>();
        
        for(Map<String,Object> ciInfo : interactions){
            ordIds.add(String.valueOf(ciInfo.get('orderId')));
        }
        
        Map<Id, XC_DocumentURL__c> docUrlMap = new Map<Id, XC_DocumentURL__c>([
                        SELECT id, XC_Configuration__c, XC_Url__c
                        FROM XC_DocumentURL__c
                        WHERE XC_Configuration__c in: ordIds
                        AND /*(XC_Category_Signed__c = 'SF_CREDIT_ASSIGNMENT_SIGNED'
                        OR*/ XC_Category_Signed__c = 'SF_CONTRACT_SIGNED'/*)*/]);
     
        for(Map<String,Object> ciInfo : interactions){
            String docURL = '';
            for(XC_DocumentURL__c du : docUrlMap.values()){
                if(du.XC_Configuration__c == ciInfo.get('orderId') && !String.isblank(du.XC_Url__c) && du.XC_Url__c != null){
                    docURL += du.XC_Url__c + ','; 
                }
            } 
            ciInfo.put('docURL', docURL.removeEnd(','));
        }
    }
}