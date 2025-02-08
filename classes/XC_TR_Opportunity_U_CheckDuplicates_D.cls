/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 04/04/2018
* @description DAO for XC_TR_Opportunity_U_CheckDuplicates
*/  
public without sharing class XC_TR_Opportunity_U_CheckDuplicates_D {
    
    /**
     * @description The Class OptyAddressListWrapper.
     */
    public class OptyAddressListWrapper{

        /** The address. */
        public List<String> address = new List<String>();
        
        /** The address name. */
        public List<String> addressName= new List<String>();
        
        /** The category. */
        public List<String> category= new List<String>();
        
        /** The city. */
        public List<String> city= new List<String>();
        
        /** The country. */
        public List<String> country= new List<String>();
        
        /** The door. */
        public List<String> door= new List<String>();
        
        /** The floor. */
        public List<String> floor= new List<String>();
        
        /** The municipality. */
        public List<String> municipality= new List<String>();
        
        /** The postal code. */
        public List<String> postalCode= new List<String>();
        
        /** The province. */
        public List<String> province= new List<String>();
        
        /** The stair. */
        public List<String> stair= new List<String>();
        
        /** The street number. */
        public List<String> streetNumber= new List<String>();
        
        /** The street type. */
        public List<String> streetType= new List<String>();
        
        /** The product category of interest. */
        public Set<String> productCategoryOfInterest= new Set<String>();
        
        /** The stage name. */
        public Set<String> stageName= new Set<String>();


    }
    /** 
    *@author Federico Amici - federico.amici@nttdata.com
    *@param wrapperList 
    *@param hours
    *@return List<Opportunity>
    *@description method to  getOpportunityByWrapperList
    */
    public static List<Opportunity> getOpportunityByWrapperList(OptyAddressListWrapper wrapperList, Integer hours) {

        DateTime dt = Datetime.now().addHours((-1)*hours);
        DateTime now = DateTime.now();

        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([
                                             SELECT id, Name, XC_Address__c, XC_Address__r.ID,XC_ClosureDateTime__c, XC_Address__r.XC_Address__c, XC_Address__r.Name, XC_Address__r.XC_AddressCountry__c, 
                                             XC_Address__r.XC_AddressProvince__c, XC_Address__r.XC_Category__c, XC_Address__r.XC_City__c,
                                             XC_Address__r.XC_Door__c, XC_Address__r.XC_Floor__c, XC_Address__r.XC_Municipality__c, XC_Address__r.XC_PostalCode__c, XC_Address__r.XC_Stair__c, 
                                             XC_Address__r.XC_StreetNumber__c, XC_Address__r.XC_StreetType__c, XC_ClosingUser__r.XC_AccountId__c, CreatedById, CreatedDate,
                                             XC_ProductCategoryOfInterest__c, StageName, XC_ClosingUser__c, AccountId from Opportunity
                                             WHERE XC_ProductCategoryOfInterest__c IN :wrapperList.productCategoryOfInterest AND
                                                    XC_Address__r.Name IN :wrapperList.addressName AND
                                                    XC_Address__r.XC_Door__c IN :wrapperList.door AND 
                                                    XC_Address__r.XC_Floor__c IN :wrapperList.floor AND
                                                    XC_Address__r.XC_AddressCountry__c IN :wrapperList.country AND
                                                    XC_Address__r.XC_AddressProvince__c IN :wrapperList.province AND 
                                                    XC_Address__r.XC_Category__c IN :wrapperList.category AND
                                                    XC_Address__r.XC_City__c IN :wrapperList.city AND
                                                    XC_Address__r.XC_Municipality__c IN :wrapperList.municipality AND
                                                    XC_Address__r.XC_PostalCode__c IN :wrapperList.postalCode AND
                                                    XC_Address__r.XC_Stair__c IN :wrapperList.stair AND
                                                    XC_Address__r.XC_StreetNumber__c IN :wrapperList.streetNumber AND
                                                    XC_Address__r.XC_StreetType__c IN :wrapperList.streetType AND
                                                    (
                                                        ((StageName = :Label.XC_CL_Opportunity_ClosedWon OR StageName = :Label.XC_CL_Opportunity_ClosedLost) AND XC_ClosureDateTime__c > :dt AND XC_ClosureDateTime__c < :now ) OR
                                                        
                                                        (StageName != :Label.XC_CL_Opportunity_ClosedLost AND StageName !=:Label.XC_CL_Opportunity_ClosedWon)
                                                    )
                                                ORDER BY CreatedDate DESC
                                            ]);
        List<Opportunity> listOpportunity = mapOpportunity.values();                                
        return listOpportunity;
    }


}