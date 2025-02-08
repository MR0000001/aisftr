/**
* @author Giuseppe Di Bonito gdibonito@deloitte.it
* @date Creation 08/05/2020
* @date Modification 
* @description XC_TR_DocumentType_Handler – Handler for XC_TR_DocumentType Trigger
*/ 
public with sharing class XC_TR_DocumentType_U_SendEmail { 

    /**
    * @description onUpdate
    * @param mapOld - Map<Id, SObject> 
    * @param mapNew - Map<Id, SObject>
    **/
    public static void onUpdate(List<XC_DocumentType__c> listnew) { 
        System.debug('$$ listnew: '+listnew);
        List<XC_DocumentType__c> docTypS = new List<XC_DocumentType__c>();
        List<String> ordIdS = new List<String>();
        List<String> dossierIdS = new List<String>();
        for(XC_DocumentType__c dt : listnew){
            if(!String.isBlank(dt.XC_DossierId__c)){
                docTypS.add(dt);
                dossierIdS.add(dt.XC_DossierId__c);
                ordIdS.add(dt.XC_Configuration__c);
            }
        }
        if(docTypS.isEmpty()){
            System.debug('$$EXIT NO DOSSIER ID');
            return;
        }

        Map<Id, NE__Order__c> qmap = new Map<Id, NE__Order__c>([
                        SELECT Id, NE__AccountId__c, NE__OptyId__c, XC_LegalEntity__c,
                        NE__OptyId__r.XC_Contact__c, NE__OptyId__r.XC_Contact__r.Name, 
                        NE__OptyId__r.XC_Contact__r.Email,
                            (SELECT id, Category__c, numberOfFiles__c, XC_Configuration__c
                            FROM Document_Types__r 
                            WHERE Category__c='SF_CREDIT_ASSIGNMENT_TO_SIGN'
                            OR Category__c='SF_CONTRACT_TO_SIGN')
                        FROM NE__Order__c 
                        WHERE Id in: ordIdS]);
        System.debug('$$ qmap: '+qmap);
        
        list<string> oppid = new list<string>();
        for(NE__Order__c o : qmap.values()){
            oppid.add(o.NE__OptyId__c);
        }
        Map<Id, Opportunity> oppmap = new Map<Id, Opportunity>([
                        SELECT Id, XC_Contact__c, XC_Contact__r.Name, 
                        XC_Contact__r.Email
                        FROM Opportunity 
                        WHERE Id in: oppid]);
        System.debug('$$ oppmap: '+oppmap);
        
        list<string> contid = new list<string>();
        for(Opportunity o : oppmap.values()){
            contid.add(o.XC_Contact__c);
        }
        
        Map<Id, Contact> contmap = new Map<Id, Contact>([
                        SELECT Id, Name, Email
                        FROM Contact 
                        WHERE Id in: contid]);
        System.debug('$$ contmap: '+contmap);
        
        //DeAv Fix INC000091779525 START
        /*Map<Id, XC_DocumentType__c> docmap = new Map<Id, XC_DocumentType__c>([
                            SELECT id, Category__c, numberOfFiles__c, XC_Configuration__c
                            FROM XC_DocumentType__c 
                            WHERE XC_Configuration__c in: ordIdS
                            AND(Category__c='SF_CREDIT_ASSIGNMENT_TO_SIGN'
                            OR Category__c='SF_CONTRACT_TO_SIGN')]);*/
        Map<Id, XC_DocumentType__c> docmap = new Map<Id, XC_DocumentType__c>();
        List<String> ordIdsNotNull = new List<String>();
        for(Integer i=0; i<ordIdS.size(); i++){
            if(String.isNotBlank(ordIdS[i])){
                ordIdsNotNull.add(ordIdS[i]);
            } 
        }
        if(!ordIdsNotNull.isEmpty()){
            List<XC_DocumentType__c> doclist = [SELECT id, Category__c, numberOfFiles__c, XC_Configuration__c
                                                FROM XC_DocumentType__c 
                                                WHERE XC_Configuration__c in: ordIdsNotNull
                                                        AND(Category__c='SF_CREDIT_ASSIGNMENT_TO_SIGN'
                                                        OR Category__c='SF_CONTRACT_TO_SIGN')];
            for(XC_DocumentType__c dt : doclist){
                docmap.put(dt.Id, dt);
            }
        }
        //DeAv Fix INC000091779525 END
        System.debug('$$ docmap: '+docmap);

        for(NE__Order__c o : qmap.values()){
            o.NE__OptyId__r.XC_Contact__c = oppmap.get(o.NE__OptyId__c).XC_Contact__c;
            o.NE__OptyId__r.XC_Contact__r.Email = contmap.get(o.NE__OptyId__r.XC_Contact__c).Email; 
        }
        
        Map<String, List<XC_DocumentType__c>> docNum = new Map<String, List<XC_DocumentType__c>>();
        for(String ordId : ordIdS){
            List<XC_DocumentType__c> dtlist = new List<XC_DocumentType__c>();
            for(XC_DocumentType__c dt : docmap.values()){       
                if(ordId == dt.XC_Configuration__c){
                    dtlist.add(dt);
                }
            }
            for(XC_DocumentType__c dt : docTypS){       
                if(ordId == dt.XC_Configuration__c){
                    dtlist.add(dt);
                }
            }
            docNum.put(ordId, dtlist);
        }
 
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        
        for(List<XC_DocumentType__c> ldt : docNum.values()){
            
            XC_DocumentType__c docToSign1;
            XC_DocumentType__c docSigned1;
            XC_DocumentType__c docToSign2;
            XC_DocumentType__c docSigned2;
            
            for (XC_DocumentType__c d: ldt){
                if(d.category__c == 'SF_CREDIT_ASSIGNMENT_TO_SIGN'){
                    docToSign1 = d;
                }
                if(d.category__c == 'SF_CREDIT_ASSIGNMENT_SIGNED'){
                    docSigned1 = d;
                }
                if(d.category__c == 'SF_CONTRACT_TO_SIGN'){
                    docToSign2 = d;
                }
                if(d.category__c == 'SF_CONTRACT_SIGNED'){
                    docSigned2 = d;
                }
            }
            /*System.debug('dts1.category: ' + docToSign1.Category__c);
            System.debug('dts1.numberOfFiles: ' + docToSign1.numberOfFiles__c);
            System.debug('ds1.category: ' + docSigned1.Category__c);
            System.debug('ds1.numberOfFiles: ' + docSigned1.numberOfFiles__c);
            System.debug('dts2.category: ' + docToSign2.Category__c);
            System.debug('dts2.numberOfFiles: ' + docToSign2.numberOfFiles__c);
            System.debug('ds2.category: ' + docSigned2.Category__c);
            System.debug('ds2.numberOfFiles: ' + docSigned2.numberOfFiles__c);*/
            if(docToSign1 != null && docSigned1 != null && docToSign1.numberOfFiles__c <= docSigned1.numberOfFiles__c 
               && docToSign2 != null && docSigned2 != null && docToSign2.numberOfFiles__c <= docSigned2.numberOfFiles__c){
                   Map<String,Object> ciInfo = createCustomerInteraction(qmap.get(docSigned1.XC_Configuration__c), contmap.get(qmap.get(docSigned1.XC_Configuration__c).NE__OptyId__r.XC_Contact__c).Name, docSigned1.XC_DossierId__c);
                   interactions.add(ciInfo);
               } else if(docToSign1 != null && docSigned1 != null && docToSign1.numberOfFiles__c <= docSigned1.numberOfFiles__c){
                   Map<String,Object> ciInfo = createCustomerInteraction(qmap.get(docSigned1.XC_Configuration__c), contmap.get(qmap.get(docSigned1.XC_Configuration__c).NE__OptyId__r.XC_Contact__c).Name, docSigned1.XC_DossierId__c);
                   interactions.add(ciInfo);
               } else if(docToSign2 != null && docSigned2 != null && docToSign2.numberOfFiles__c <= docSigned2.numberOfFiles__c){
                   Map<String,Object> ciInfo = createCustomerInteraction(qmap.get(docSigned2.XC_Configuration__c), contmap.get(qmap.get(docSigned2.XC_Configuration__c).NE__OptyId__r.XC_Contact__c).Name, docSigned2.XC_DossierId__c);
                   interactions.add(ciInfo);
               } else {
                   continue;
               }
  		}
                         
        /*for(XC_DocumentType__c dt : docTypS){
            System.debug('$$ cat 1: '+dt.Category__c);
            for(XC_DocumentType__c dt2 : docmap.values()){
                System.debug('$$ cat 2: '+dt2.Category__c);
                if((dt2.Category__c == 'SF_CREDIT_ASSIGNMENT_TO_SIGN' && dt.Category__c == 'SF_CREDIT_ASSIGNMENT_SIGNED') || (dt2.Category__c == 'SF_CONTRACT_TO_SIGN' && dt.Category__c == 'SF_CONTRACT_SIGNED')) {
                    System.debug('$$ MATCH');
                    Map<String,Object> ciInfo = createCustomerInteraction(qmap.get(dt2.XC_Configuration__c), contmap.get(qmap.get(dt2.XC_Configuration__c).NE__OptyId__r.XC_Contact__c).Name, dt.XC_DossierId__c);
                    interactions.add(ciInfo);
                }
            }
        }     */
                         
		System.debug('$$ interactions :'+interactions);
		if(!interactions.isEmpty()){
            populateUrl(interactions, dossierIdS);
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
	public static Map<String,Object> createCustomerInteraction(NE__Order__c configuration, String contName, String dossId){
        
		Map<String,Object> ciInfo = new Map<String,Object>();
		ciInfo.put('customerType', 'Welcome_Contract');
		ciInfo.put('orderId', configuration.Id);
		ciInfo.put('accountId', configuration.NE__AccountId__c);
		ciInfo.put('fullName', contName);
		ciInfo.put('contactId', configuration.NE__OptyId__r.XC_Contact__c);
		ciInfo.put('skipComunication', false);
		ciInfo.put('sent', false);
		ciInfo.put('legalEntity', configuration.XC_LegalEntity__c);
        ciInfo.put('email', configuration.NE__OptyId__r.XC_Contact__r.Email);
        ciInfo.put('businessLine', 'eHome');
        ciInfo.put('dossId', dossId);
        
        System.debug('$$ ciInfo :'+ciInfo);
        return ciInfo;
    }

     /*
	 * @author Giuseppe Di Bonito - gdibonito@deloitte.it
	 * @param listNew
	 * @date Creation 09/05/2020
	 * @description fill the url
	 */
	public static void populateUrl(List<Map<String,Object>> interactions, List<String> dossierIdS){

        Map<Id, XC_DocumentSignature__c> dsmap = new Map<Id, XC_DocumentSignature__c>([
                        SELECT id, XC_DossierId__c,
                            (SELECT id, XC_Purl__c, XC_Category__c
                            FROM DocumentSignatureItems__r)
                        FROM XC_DocumentSignature__c
                        WHERE XC_DossierId__c in: dossierIdS]);
		System.debug('$$ dsmap: '+dsmap);
        
        list<string> dsid = new list<string>();
        for(XC_DocumentSignature__c ds : dsmap.values()){
            dsid.add(ds.id);
        }
        Map<Id, XC_DocumentSignatureItem__c> dsiquerymap = new Map<Id, XC_DocumentSignatureItem__c>([
                        SELECT id, XC_Purl__c, XC_Category__c, XC_DocumentSignature__c
                        FROM XC_DocumentSignatureItem__c
                        WHERE XC_DocumentSignature__c in: dsid]);
		System.debug('$$ dsiquerymap: '+dsiquerymap);
        
        
        Map<Object, List<XC_DocumentSignatureItem__c>> dsimap = new Map<Object, List<XC_DocumentSignatureItem__c>>();
        for(XC_DocumentSignature__c ds : dsmap.values()){
            List<XC_DocumentSignatureItem__c> dsilist = new List<XC_DocumentSignatureItem__c>();
            for(XC_DocumentSignatureItem__c dsi : dsiquerymap.values()){
                if(dsi.XC_DocumentSignature__c == ds.id){
                    dsilist.add(dsi);
                }
            }
            dsimap.put(ds.XC_DossierId__c, dsilist);
        }
     
        for(Map<String,Object> ciInfo : interactions){
            String docURL ='';
            for(XC_DocumentSignatureItem__c dsi : dsimap.get(ciInfo.get('dossId'))){
                if(!String.isblank(dsi.XC_Purl__c) && dsi.XC_Purl__c!=null){
                  docURL += dsi.XC_Purl__c + ',';   
                }
            } 
            ciInfo.put('docURL', docURL.removeEnd(','));
        }
    }
}