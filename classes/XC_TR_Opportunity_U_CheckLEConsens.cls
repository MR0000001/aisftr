/**
 * @author Donato Lombardi - dolombardi@deloitte.it
 * @date Creation 15/10/2019
 * @date Modification 07/02/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description Check the information of the Legal Entity Consents from Opportunity
**/

public with sharing class XC_TR_Opportunity_U_CheckLEConsens {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Opportunity_U_CheckLEConsens');

    /**
     * @author Donato Lombardi
     * @date Creation 07/10/2019
     * @description method onAfterInsert
     * @param listNew List<Opportunity>
    */
    public static void checkLE(List<Opportunity> listNew){
        Set<Id> setaccId = new Set<Id>();
        setaccId = retriveAccountId(listNew);
        List<Opportunity> oppList = new List<Opportunity>();
        List<String> listLegalEntity = new List<String>();
        listLegalEntity = retriveLegalEntityFromOpp(listNew);
        List<XC_LegalEntityConsent__c> listLegalEnConsents = new List<XC_LegalEntityConsent__c>();
        listLegalEnConsents = retriveLEConsents(setaccId,listLegalEntity);
        List<Individual> listIndividual = new List<Individual>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listLegalEnConsents.isEmpty()'+listLegalEnConsents.isEmpty());
        if(listLegalEnConsents.isEmpty()){
            //Se non esistono consensi deve creare un nuovo record
            createRecordLE(listNew,setaccId);
        }
    }

    /**
     * @description Method to retrieve account id
     * @param listNew - List<Opportunity>
     * @return Set<Id>
    */
    private static Set<Id> retriveAccountId(list<Opportunity> listNew){
        Set<Id> accId = new Set<Id>();
        for(Opportunity op : listNew){
            accId.add(op.AccountId);
        }
    return accId;
    }

    /**
     * @description Method to retrieve LE
     * @param setaccId - Set<Id>
     * @param listLegalEntity - List<String>
     * @return List<XC_LegalEntityConsent__c>
    */
    private static List<XC_LegalEntityConsent__c> retriveLEConsents(Set<Id> setaccId, List<String> listLegalEntity ){
        List<XC_LegalEntityConsent__c> listLegalEntityCOnsents = new List<XC_LegalEntityConsent__c>();
        if(Schema.sObjectType.XC_LegalEntityConsent__c.isAccessible() && Schema.sObjectType.Contact.isAccessible()){
            listLegalEntityCOnsents = [select id, XC_Individual__r.Contact__r.Account.id, XC_Individual__r.Contact__r.XC_PrimaryContact__c,  XC_Individual__r.XC_LECollectedThirdParties__c   from XC_LegalEntityConsent__c where
            /*XC_Individual__r.XC_LECollectedThirdParties__c IN :listLegalEntity AND */XC_Individual__c in (select IndividualId from Contact where XC_PrimaryContact__c = true and AccountId in :setaccId)];
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listLegalEntityCOnsents'+listLegalEntityCOnsents);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listLegalEntity'+listLegalEntity);
        return listLegalEntityCOnsents;
    }

    /**
     * @description Method to retrieve LE
     * @param listNew - List<Opportunity>
     * @return List<String>
    */
    private static List<String> retriveLegalEntityFromOpp(List<Opportunity> listNew){
        List<String> listLegalEnity = new List<String>();
        for(Opportunity op : listNew){
            listLegalEnity.add(op.XC_LegalEntity__c);
        }
        return listLegalEnity;
    }

    /**
     * @description Method to create LE
     * @param listNew - List<Opportunity>
     * @param setaccId - Set<Id>
    */
    private static void createRecordLE(List<Opportunity> listNew, Set<Id> setaccId){
        List<Individual> listIndividual = new List<Individual>();
        listIndividual = retriveIndividual(setaccId);
        List<XC_LegalEntityConsent__c> listToInsert = new List<XC_LegalEntityConsent__c>();
        List<id> oppIds = XC_UTIL_Sobject.getIds(listNew);
        Map<Id,Opportunity> newMapOpp = new Map<Id,Opportunity>([select id, Account.XC_Country__c, XC_LegalEntity__c from Opportunity where Id IN :oppIds ]);
        for(Opportunity op : newMapOpp.values()){
            XC_LegalEntityConsent__c le = new XC_LegalEntityConsent__c();
            le.XC_CollectionChannelMarketing__c = 'E-Commerce';
            le.XC_CollectionUserMarketing__c = UserInfo.getUserId();
            if (checkIndividual(op,listIndividual) == Null){
                continue;
            }
            le.XC_Individual__c = checkIndividual(op,listIndividual);
            le.XC_GiveDataToNew__c = 'Yes';
            le.XC_LegalEntity__c = op.XC_LegalEntity__c;
            le.XC_LeCountry__c = op.Account.XC_Country__c; // fare la query per prendere il valore
            listToInsert.add(le);
            // Verificare quali campi si devono settare
        }
        if(Schema.sObjectType.XC_LegalEntityConsent__c.isCreateable()&& !listToInsert.isEmpty()) {
            insert(listToInsert);
        }
    }

    /**
     * @description Method to retrieve Individual
     * @param setaccId - Set<Id>
     * @return List<Individual>
    */
    private static List<Individual> retriveIndividual(Set<Id> setaccId){
        Map<Id,Individual> listIndividual = new Map<Id,Individual>([
            SELECT id, (select IndividualId, accountId from Contacts)
            FROM Individual 
            WHERE id IN (SELECT IndividualId
                        FROM Contact
                        WHERE accountId IN : setaccId AND XC_PrimaryContact__c = TRUE)
        ]);
        return listIndividual.values();
    }

    /**
     * @description Method to check Individual
     * @param op - Opportunity
     * @param listIndividual - List<Individual>
     * @return Id
    */
    private static Id checkIndividual(Opportunity op, List<Individual> listIndividual){
        Id indi;
        for(Individual i : listIndividual){
            if(op.AccountId == checkContact(i.Contacts,op)){
                indi = i.id;
                return indi;
            }
        }
        return indi;
    }

    /**
     * @description Method to check Contact
     * @param listCont - List<Contact>
     * @param op - Opportunity
     * @return Id
    */
    private static Id checkContact(List<Contact> listCont, Opportunity op){
        for(Contact c : listCont){
            return c.AccountId;
        }
        return null;
    }

    /**
     * @description Method to check new LE 
     * @param listNew - List<Opportunity>
    */
    public static void checkLEnewV(List<Opportunity> listNew){
        List<String> listLeaglEntity = new List<String>();
        listLeaglEntity = retriveLegalEntityFromOpp(listNew);
        Set<String> streamSet = XC_UTIL_Sobject.getSetIdsStringOnField(listNew, 'XC_Segment__c');
        List<XC_CM_CountryLegalEntityAssociation__mdt> listCm = new List<XC_CM_CountryLegalEntityAssociation__mdt>([
            SELECT XC_LegalEntity__c, XC_Country__c, XC_Category__c, XC_LegalEntityGroup__c
            FROM XC_CM_CountryLegalEntityAssociation__mdt
            WHERE XC_LegalEntity__c IN :listLeaglEntity AND XC_Category__c IN :streamSet
        ]);
        Set<Id> setaccId = new Set<Id>();
        setaccId = retriveAccountId(listNew);
        List<Account> listAccounts = new List<Account>();
        listAccounts = retriveAccounts(setaccId);
        List<Opportunity> newListOpp = new List<Opportunity>();
        newListOpp = matchCMAccount(listNew,listCm,listAccounts);
        if(!newListOpp.isEmpty()){
            createRecordLE(listNew,setaccId);
        }
    }

    /**
     * @description Method to retrieve Account
     * @param accountIds - Set<Id>
     * @return List<Account>
    */
    private static List<Account> retriveAccounts(Set<Id> accountIds){
        List<Account> listAccounts = new List<Account>([
            SELECT ID, XC_GiveDataTo_Group1__c, XC_GiveDataTo_Group2__c 
            FROM ACCOUNT 
            WHERE ID IN:accountIds
        ]);        
        return listAccounts;
    }

    /**
     * @description Method to match Account
     * @param listNew - List<Opportunity>
     * @param listCm - List<XC_CM_CountryLegalEntityAssociation__mdt>
     * @param listAccounts - List<Account>
     * @return List<Opportunity>
    */
    private static List<Opportunity> matchCMAccount(List<Opportunity> listNew, List<XC_CM_CountryLegalEntityAssociation__mdt > listCm, List<Account> listAccounts){
        List<Opportunity> newListOpp = new List<Opportunity>();
        for(Opportunity o : listNew){
            for(XC_CM_CountryLegalEntityAssociation__mdt cm : listCm){
                for(Account a : listAccounts){
                    newListOpp.add(checkField(o,cm,a));
                }
            }
        }
        return newListOpp;
    }

    /**
     * @description Method to check Opp fields
     * @param o - Opportunity
     * @param cm - XC_CM_CountryLegalEntityAssociation__mdt
     * @param a - Account
     * @return Opportunity
    */
    private static Opportunity checkField(Opportunity o, XC_CM_CountryLegalEntityAssociation__mdt cm, Account a){
        if(o.AccountId == a.id && o.XC_LegalEntity__c == cm.XC_LegalEntity__c/*country*/ && o.XC_Segment__c == cm.XC_Category__c){
            if(!(Boolean) a.get('XC_GiveDataTo_'+cm.XC_LegalEntityGroup__c+'__c')){
                return o;
            }
        }
        return null;
    }

}