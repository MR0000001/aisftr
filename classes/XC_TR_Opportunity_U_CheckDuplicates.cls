/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
* @date Creation 05/11/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_Opportunity_U_CheckDuplicates – Class to manage oppportunity duplicates
* @modification Federico Amici - Adapted to the new algorithm 
*/ 
public without sharing class XC_TR_Opportunity_U_CheckDuplicates {
    
public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Opportunity_U_CheckDuplicates');

    private static final Integer NOT_DUPLICATE = 0;
    private static final Integer SIMPLE_DUPLICATE = 1;
    private static final Integer DUPLICATE_WITHIN_NHOURS = 2;

    /**
     * @description DuplicateWrapper wrapper.
     */
    public class DuplicateWrapper {
        public Opportunity opp;
        public XC_Address__c a;
        public List<Opportunity> listOppToCheck;
        public Integer numberOfHours;
        public Map<Id,Id> mapUserIdAccountId;
        public String userAccountId;
    }

    /**
     * @description RetCheckDuplicate wrapper.
     */
    public class RetCheckDuplicate {
        public String lookup;
        public String status;
        public String name;
    }

    /**
     * @author : Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com - Riccardo Cossu riccardo.cossu@nttdata.com
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     * @date   : 5 / 11 /2018
     * @description Method for check duplicates opportunity
     */
    public static void checkDuplicateOpportunityUpdate(List<Opportunity> listNew, Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        List<String> fieldList = new List<String>{'XC_ProductCategoryOfInterest__c', 'XC_Address__c'};
        List<Opportunity> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            checkDuplicateOpportunity(listChanged);
        }        
    }
    
    /**
     * @param listNew the list new
     * @description Check duplicate opportunity. 
    **/
    public static void checkDuplicateOpportunity(List<Opportunity> listNew) { 
        
        List<Opportunity> oppListWithAddress = new List<Opportunity>();
        Set<String> legalEntitySet = new Set<String>();
        Set<String> streamSet = new Set<String>();
        for(Opportunity o : listNew) {
            if(/* o.XC_ReceivingChannel__c != 'Web' &&*/ String.isNotBlank(o.XC_Address__c)) {
                oppListWithAddress.add(o);
                legalEntitySet.add(o.XC_LegalEntity__c);
                streamSet.add(o.XC_Segment__c);
            }
        }
        if(oppListWithAddress.isEmpty()) {
            return;
        }

        Map<String, UtilWrapper> cmSkipOpp = getSkipDuplicationInfo(legalEntitySet, streamSet);
        List<Opportunity> listChanged = new List<Opportunity>();
        for(Opportunity o : oppListWithAddress) {
            if(cmSkipOpp.get(o.XC_LegalEntity__c+o.XC_Segment__c) == null || (
                cmSkipOpp.get(o.XC_LegalEntity__c+o.XC_Segment__c) != null && !cmSkipOpp.get(o.XC_LegalEntity__c+o.XC_Segment__c).channelsToSkip.contains(o.XC_ReceivingChannel__c))) {
                    listChanged.add(o);
                }
        }

        Map<Id,XC_CM_Opportunity_Default_Values__mdt> cmMap = new Map<Id,XC_CM_Opportunity_Default_Values__mdt>([
            SELECT XC_Hours_Since_Closure__c 
            FROM XC_CM_Opportunity_Default_Values__mdt 
            WHERE XC_Country__c = 'SPAIN'
        ]);
        
        Integer numberOfHours = Integer.valueOf(cmMap.values()[0].XC_Hours_Since_Closure__c);

        List<String> listProdCat = XC_UTIL_Sobject.getListFieldValues(listChanged, 'XC_ProductCategoryOfInterest__c');
        List<Id> listOptyIds = XC_UTIL_SObject.getIds(listChanged);
        List<String> addressIds = XC_UTIL_Sobject.getListFieldValues(listChanged, 'XC_Address__c');

        /* Map old addresses */
        Map<Id, XC_Address__c> mapAddress = new Map<Id, XC_Address__c>([
            SELECT Id, Name,XC_Category__c, XC_City__c, XC_AddressCountry__c, XC_Door__c, 
            XC_Floor__c, XC_Municipality__c, XC_PostalCode__c, 
            XC_AddressProvince__c, XC_Stair__c, XC_StreetNumber__c, XC_StreetType__c
            FROM XC_Address__c WHERE Id IN :addressIds
        ]);

        XC_TR_Opportunity_U_CheckDuplicates_D.OptyAddressListWrapper wrList = populateOptyAddressWrapperList(listChanged, mapAddress);
        List<Opportunity> listOppToCheck = XC_TR_Opportunity_U_CheckDuplicates_D.getOpportunityByWrapperList(wrList, numberOfHours);

        /*
        List<Id> listCreatedByIds = XC_UTIL_Sobject.getListFieldValues(listOppToCheck, 'CreatedById');
        listCreatedByIds.add(UserInfo.getUserId());
        List<User> userAccountIds = [SELECT XC_AccountId__c FROM User WHERE Id IN :listCreatedByIds];
        Map<Id, Id> mapUserIdAccountId = new Map<Id, Id>();
        for(User u : userAccountIds) {
            mapUserIdAccountId.put(u.Id, u.XC_AccountId__c);
        }*/
        //Id userAccountId = [SELECT XC_AccountId__c FROM User WHERE Id = :UserInfo.getUserId()][0].XC_AccountId__c;

        DuplicateWrapper dupWr = new DuplicateWrapper();
        dupWr.listOppToCheck = listOppToCheck;
        dupWr.numberOfHours = numberOfHours;
        //dupWr.mapUserIdAccountId = mapUserIdAccountId;
        //dupWr.userAccountId = userAccountId;
        //system.debug('dupWr.userAccountId: '+dupWr.userAccountId );

        RetCheckDuplicate retCheck;

        for(Opportunity opp : listChanged){

            dupWr.a = mapAddress.get(opp.XC_Address__c);
            dupWr.opp = opp;
            retCheck = checkIfOptyDuplicate(dupWr);

            if(String.isBlank(retCheck.lookup)){
                continue;
            }

            if(checkIfOptyClosed(retCheck)) {
                system.debug('duplicated - closed');
                opp.XC_DuplicatedOpportunity__c = retCheck.lookup;

            } else {
                //if(checkLeB2BStream(opp.XC_LegalEntity__c, opp.XC_Segment__c)){
                if(cmSkipOpp.get(opp.XC_LegalEntity__c+opp.XC_Segment__c) == null || (
                    cmSkipOpp.get(opp.XC_LegalEntity__c+opp.XC_Segment__c) != null && !cmSkipOpp.get(opp.XC_LegalEntity__c+opp.XC_Segment__c).skipDuplicationOpportunity)) {
                        system.debug('duplicated - not closed');
                        opp.addError(Label.XC_CL_Opportunity_DuplicateFound+' '+retCheck.name);
                }
            }    
        }    

        return; 
    } 
  
    private static Boolean checkIfOptyClosed(RetCheckDuplicate retCheck) {
        return (retCheck.status == Label.XC_CL_Opportunity_ClosedLost || retCheck.status == Label.XC_CL_Opportunity_ClosedWon);
    }

    /**
     * @description Check if opty duplicate.
     * @param dupWr
     * @return the boolean
     */
    private static RetCheckDuplicate checkIfOptyDuplicate(DuplicateWrapper dupWr) {
        
        //Integer retDup = 0;
        RetCheckDuplicate retCheck = new RetCheckDuplicate();

        for(Opportunity o : dupWr.listOppToCheck) {
            if(XC_TR_Opportunity_U_CheckDuplicatesUtil.checkFields(dupWr, o) ) {
                Integer duplicateString = XC_TR_Opportunity_U_CheckDuplicatesUtil.utilityMethod(dupWr, o );
                if(duplicateString == DUPLICATE_WITHIN_NHOURS){
                    system.debug('DUPLICATE_WITHIN_NHOURS');
                    retCheck.lookup = o.Id;
                    retCheck.status = o.StageName;
                    retCheck.name = o.name;
                    return retCheck;

                } else if(duplicateString == SIMPLE_DUPLICATE) {
                    system.debug('SIMPLE_DUPLICATE');
                    retCheck.lookup = o.Id;
                    retCheck.status = o.StageName;
                    retCheck.name = o.name;
                    return retCheck;
                }
            } 
        }

        retCheck.lookup = '';
        return retCheck; 
        
        /*
        if(retDup == SIMPLE_DUPLICATE) {
            retCheck.lookup = opp.Id;
            retCheck.status = opp.StageName;
            return retCheck;

        } else {
            retCheck.lookup = '';
            //retCheck.status = opp.StageName;
          	return retCheck; 
        }
        */
    }

    /**
     * 
     * @description Populate opty address wrapper.
     * @param listOpty the list opty
     * @param mapOldAddress
     * @return wr
     */
    private static XC_TR_Opportunity_U_CheckDuplicates_D.OptyAddressListWrapper populateOptyAddressWrapperList(List<Opportunity> listOpty, Map<Id, XC_Address__c> mapOldAddress) {
        XC_TR_Opportunity_U_CheckDuplicates_D.OptyAddressListWrapper wr = new XC_TR_Opportunity_U_CheckDuplicates_D.OptyAddressListWrapper();

        for(XC_Address__c a : mapOldAddress.values()) {
            wr.addressName.add(a.Name);
            wr.category.add(a.XC_Category__c);
            wr.city.add(a.XC_City__c);
            wr.country.add(a.XC_AddressCountry__c);
            wr.door.add(a.XC_Door__c);
            wr.floor.add(a.XC_Floor__c);
            wr.municipality.add(a.XC_Municipality__c);
            wr.postalCode.add(a.XC_PostalCode__c);
            wr.province.add(a.XC_AddressProvince__c);
            wr.stair.add(a.XC_Stair__c);
            wr.streetNumber.add(a.XC_StreetNumber__c);
            wr.streetType.add(a.XC_StreetType__c);
        }

        for(Opportunity o : listOpty) {
            wr.productCategoryOfInterest.add(o.XC_ProductCategoryOfInterest__c);
            wr.StageName.add(o.StageName);
        }

        return wr;
    }


    /*public static Boolean checkLeB2BStream(String legalEntity, String stream){
        List<XC_CM_CountryLegalEntityAssociation__mdt> legalEntityCategory = [SELECT ID, XC_SkipDuplicationOpportunity__c
                                                                                FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                                WHERE XC_LegalEntity__c = :legalEntity AND XC_Category__c = :stream];

        return legalEntityCategory.isEmpty() ? false : !legalEntityCategory[0].XC_SkipDuplicationOpportunity__c;
    }*/


    /**
     * GetSkipDuplicationInfo.
     *
     * @description Populate opty address wrapper.
     * @param legalEntitySet the set string
     * @param streamSet the set string
     * @return Map<String, UtilWrapper>
     */
    public static Map<String, UtilWrapper> getSkipDuplicationInfo(Set<String> legalEntitySet, Set<String> streamSet) {

        Map<String, UtilWrapper> cmList = new Map<String, UtilWrapper>();

        Map<Id, XC_CM_CountryLegalEntityAssociation__mdt> legalEntityCategory = 
            new Map<Id, XC_CM_CountryLegalEntityAssociation__mdt> ([SELECT Id, XC_LegalEntity__c, XC_Category__c, XC_SkipDuplicationOpportunity__c, XC_SkipDuplOppChannels__c
                                                                    FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                    WHERE XC_LegalEntity__c IN :legalEntitySet AND XC_Category__c IN :streamSet]);

        for(XC_CM_CountryLegalEntityAssociation__mdt cm : legalEntityCategory.values()) {
            UtilWrapper wr = new UtilWrapper();
            wr.skipDuplicationOpportunity = cm.XC_SkipDuplicationOpportunity__c;
            wr.channelsToSkip = (String.isBlank(cm.XC_SkipDuplOppChannels__c)) ? new List<String>() : cm.XC_SkipDuplOppChannels__c.split(';');
            cmList.put(cm.XC_LegalEntity__c+cm.XC_Category__c, wr);
        }

        return cmList;
    }

    public class UtilWrapper {
        public Boolean skipDuplicationOpportunity = false;
        public List<String> channelsToSkip = new List<String>();
    }
}