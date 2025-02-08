/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 10/09/2019
* @description XC_TR_PartnerCoverage_U_FillFields_W – Util Class for Wrapper of XC_TR_PartnerCoverage_U_FillFields
*/

public without sharing class XC_TR_PartnerCoverage_U_FillFields_W {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_PartnerCoverage_U_FillFields');

    /** @description ServiceResourceCoverageWrapper */
    public class ServiceResourceCoverageWrapper {
        public List<String> listServiceResourceIds = new List<String>();
        public Map<String, List<String>> mapAccountServiceResourceIds = new Map<String, List<String>>();
        public Map<String, String> mapServiceResourceAccountId = new Map<String, String>();
    }

    /** @description PopulateSrcMapWrapper */
    public class PopulateSrcMapWrapper {
        public XC_ServiceResourceCoverage__c src;
        public Map<String, String> mapServiceResourceAccountId = new Map<String, String>();
        public List<XC_PartnerCoverage__c> listOld = new List<XC_PartnerCoverage__c>();
        public Map<Id, XC_PartnerCoverage__c> mapPartnerCoverageOld = new Map<Id, XC_PartnerCoverage__c>();
        public Boolean useOld = false;
    }

    /** @description ListServiceCoverageToDeleteWrapper */
    public class ListServiceCoverageToDeleteWrapper {
        public Map<String, List<String>> mapAccountServiceResourceIds = new Map<String, List<String>>();
        public XC_PartnerCoverage__c pc;
        public Map<String, List<String>> mapSrIdListCovIds = new Map<String, List<String>>();
    }

    /** @description ZipCodeCoverageWrapper */
    public class ZipCodeCoverageWrapper {
        public Map<String, List<String>> mapAccountServiceResourceIds = new Map<String, List<String>>();
        public Map<Id, XC_PartnerCoverage__c> mapPartnerCoverageOld = new Map<Id, XC_PartnerCoverage__c>();
        public Boolean useOld = false;
        public XC_PartnerCoverage__c pc;
        public List<String> listZipCodeWorkTypeIds = new List<String>();
        public Map<String, List<String>> mapServiceResourceListZipCodeWt = new Map<String, List<String>>();
        public Map<String, XC_PartnerCoverage__c> mapSrIdPartnerCoverage = new Map<String, XC_PartnerCoverage__c>();
    }

    /** @description CheckedZipCodeWorkTypeWrapper */ 
    public class InputZipCodeWorkTypeWrapper {
        public Boolean useOld = false;
        public List<XC_PartnerCoverage__c> listPartnerCoverage = new List<XC_PartnerCoverage__c>();
        public ServiceResourceCoverageWrapper srcWrapper;
        public Map<Id, XC_PartnerCoverage__c> mapOld = new Map<Id, XC_PartnerCoverage__c>();
    }

    /** @description CheckedZipCodeWorkTypeWrapper */ 
    public class CheckZipCodeWorkTypeWrapper {
        public Map<String, XC_PartnerCoverage__c> mapSrIdPartnerCoverage = new Map<String, XC_PartnerCoverage__c>();
        public Map<String, List<String>> mapSrIdListCovIds = new Map<String, List<String>>();
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to populate list of Service Resource Coverage to delete
     * @date 10/09/2019
     * @param wrapper - ZipCodeCoverageWrapper
    */ 
    public static void populateZipCodeCoverageWrapper(ZipCodeCoverageWrapper wrapper) {
        if( wrapper.mapAccountServiceResourceIds.containsKey(wrapper.pc.XC_Account__c))
        {
        for(String srId : wrapper.mapAccountServiceResourceIds.get(wrapper.pc.XC_Account__c)) {
            if(!wrapper.mapServiceResourceListZipCodeWt.containsKey(srId)) {
                wrapper.mapServiceResourceListZipCodeWt.put(srId, new List<String>());
            }
            wrapper.mapServiceResourceListZipCodeWt.get(srId).add(wrapper.pc.XC_ZipCodeWorkType__c);
            if(wrapper.useOld) {
                wrapper.listZipCodeWorkTypeIds.add(wrapper.mapPartnerCoverageOld.get(wrapper.pc.Id).XC_ZipCodeWorkType__c);
                wrapper.mapSrIdPartnerCoverage.put(srId, wrapper.pc);
            } else {
                wrapper.listZipCodeWorkTypeIds.add(wrapper.pc.XC_ZipCodeWorkType__c);
            }
        }
       }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to populate map for Service Resource Coverage
     * @date 10/09/2019
     * @param wrapper - PopulateSrcMapWrapper
     * @param mapSrIdListCovIds - Map<String, List<String>> 
    */ 
    public static void populateMapServiceResourceCoverage(XC_TR_PartnerCoverage_U_FillFields_W.PopulateSrcMapWrapper wrapper, Map<String, List<String>> mapSrIdListCovIds) { 
        for(XC_PartnerCoverage__c pc : wrapper.listOld){
            if(pc.XC_Account__c == wrapper.mapServiceResourceAccountId.get(wrapper.src.XC_ServiceResourceId__c) && 
                (!wrapper.useOld && pc.XC_ZipCodeWorkType__c == wrapper.src.XC_ZipCodeWorkTypeId__c) ||
                (wrapper.useOld && wrapper.mapPartnerCoverageOld.get(pc.Id).XC_ZipCodeWorkType__c == wrapper.src.XC_ZipCodeWorkTypeId__c)) {
                if(!mapSrIdListCovIds.containsKey(wrapper.src.XC_ServiceResourceId__c)) {
                    mapSrIdListCovIds.put(wrapper.src.XC_ServiceResourceId__c, new List<String>());
                }
                mapSrIdListCovIds.get(wrapper.src.XC_ServiceResourceId__c).add(wrapper.src.Id);
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to populate list of Service Resource Coverage to delete
     * @date 10/09/2019
     * @param listSrCoverageToDelete - List<XC_ServiceResourceCoverage__c>
     * @param wrapper - ListServiceCoverageToDeleteWrapper
    */ 
    public static void populateListServiceCoverageToDelete(List<XC_ServiceResourceCoverage__c> listSrCoverageToDelete, XC_TR_PartnerCoverage_U_FillFields_W.ListServiceCoverageToDeleteWrapper wrapper) { 
        if(wrapper.mapAccountServiceResourceIds.containsKey(wrapper.pc.XC_Account__c)) {
            if(wrapper.mapAccountServiceResourceIds.isEmpty() || wrapper.mapSrIdListCovIds.isEmpty()){
                return;
            }
            for(String srId : wrapper.mapAccountServiceResourceIds.get(wrapper.pc.XC_Account__c)) {
                if(!wrapper.mapSrIdListCovIds.containsKey(srId)){
                    continue;
                }
                for(String srcId : wrapper.mapSrIdListCovIds.get(srId)) {
                    XC_ServiceResourceCoverage__c srcToDelete = new XC_ServiceResourceCoverage__c();
                    srcToDelete.Id = srcId;
                    listSrCoverageToDelete.add(srcToDelete);
                }
            }
        }
    }
	


}