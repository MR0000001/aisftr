/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 26/11/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_OneOrg – Util class for LegalEntityOneOrg methods
*/
public  without sharing class XC_Util_LegalEntityOneOrg {
  /**
    * @author Nicola Arrigo - narrigo@deloitte.it 
    * @description Given a single or a List of Legal Entity names establishes if vaiue of 'XC_[legalEntity]__c' in OneOrg__c custom setting is true
    **/
    
    public static List<String> legalEntityAvailable = new List<String>{
        'EndesaX',
        'JuicenetLimited',
        'EnelX',
        'EnelDistribucion',
        'Codensa',
        'EnelXItalia',
        'EnelXNorthAmericaInc',
        'EnelXRomania',
        'EnelXMSP',
        'EnelXMobilityHolding',
        'EnelXMobilityItalia',
        'EnelXMobilitySpain',
        'EnelXMobilityRomania',
        'EnelXMobilityAmerica',
        'EnelXMobilityChile',
        'EnelXMobilityUK'
    };
  
  
  /**
    * @author Nicola Arrigo - narrigo@deloitte.it
    * @creationDate 26/11/2019
    * @description isRightLegalEntity
    * @param legalEntity
    * @return boolean
    */  
        public static Boolean isRightLegalEntity(String legalEntity){ 
        //    XC_UTIL_Debug.debug(DEBUGACTIVE, 'LegalEntity ' + legalEntity);
          system.debug('enterMethod isRightLegalEntity');
            XC_LegalEntityOneOrg__c mc = new XC_LegalEntityOneOrg__c();
            try{
                mc = XC_LegalEntityOneOrg__c.getInstance(UserInfo.getProfileId()); 
                system.debug('authorize for Legal Entity'+' '+legalEntity);
            } 
            catch(Exception e) {
                system.debug('Exception enter'+' '+e);
                return false; 
            }
           // mc = XC_LegalEntityOneOrg__c.getInstance(UserInfo.getProfileId()); 
           // system.debug('mc'+' '+mc);
            if(mc != null && legalEntityAvailable.contains(legalEntity)){
               // Boolean outcome = (Boolean) mc.get('XC_' + legalEntity + '__c');
               Boolean outcome;
               if(legalEntity!='EnelX' && legalEntity!='EnelDistribucion'){
                outcome = (Boolean) mc.get('XC_' + legalEntity + '__c');
                system.debug('enter 1'); 
               }else{
                outcome = (Boolean) mc.get('XC_' + legalEntity +'Chile'+ '__c');
               system.debug('enter 2');
               system.debug('LE'+' '+'XC_' + legalEntity +'Chile'+ '__c');
               } 
               if(null != outcome){
                    return outcome;
                }else{
                    return false;
                }
            }
            return false;
        }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description from e list of Legal Entity, give e mapping between this Legal entity and 
     * the XC_CM_LegalEntity_Configuration__mdt by orgId
     * @param listAllLE 
     * @param segmFilter 
     * @return Map<String,XC_CM_LegalEntity_Configuration__mdt> with (LE+Segment) -> XC_LegalText_Enabled__c mapping
     **/
    public static Map<String,XC_CM_LegalEntity_Configuration__mdt> getOrgConfigLegalEntities(Set<String> listAllLE, Set<String> segmFilter){
      Map<String,XC_CM_LegalEntity_Configuration__mdt> result = new Map<String,XC_CM_LegalEntity_Configuration__mdt>();
      if(listAllLE == null || listAllLE.isEmpty()){
        return result;
      }
      Map<Id,XC_CM_LegalEntity_Configuration__mdt> dataCMlegalEntity = new Map<Id,XC_CM_LegalEntity_Configuration__mdt>([
        SELECT Id, XC_LegalEntity__c, XC_WOValidation_Enabled__c, XC_WOValidationExtra_Enabled__c, XC_LegalText_Enabled__c, XC_Stream__c, XC_RepairCoverageSkipBySubType__c,XC_VatGroup_SequenceSet__c
        ,XC_GetContractBy__c, XC_DisableManualCreationIndemnification__c
        ,XC_ComplexProductActive__c, XC_NotShowZeroPricedProds__c, XC_ZuoraSequenceSetId__c
        FROM XC_CM_LegalEntity_Configuration__mdt 
        WHERE XC_LegalEntity__c IN :listAllLE
          AND XC_Stream__c IN: segmFilter
          AND XC_OrgId__c =: UserInfo.getOrganizationId()
      ]);
      
      String key;
      for(XC_CM_LegalEntity_Configuration__mdt mtd: dataCMlegalEntity.values()){
      	key = mtd.XC_LegalEntity__c + mtd.XC_Stream__c;
        /*if(result.get(key)==null){
          result.put(key, new Map<String,XC_CM_LegalEntity_Configuration__mdt>());
        }*/
        result.put(key, mtd);
      }
      return result;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Retrieves the XC_CM_LegalEntity_Configuration__mdt filtered by Legal Entities and Segments in input and the User OrgId
     * with the information related to the caring flows
     * @param listAllLE 
     * @param segmFilter 
     * @return Map<String,XC_CM_LegalEntity_Configuration__mdt> with (LE+Segment) -> XC_LegalText_Enabled__c row
     **/
    public static Map<String,XC_CM_LegalEntity_Configuration__mdt> getConfigLegalEntityCaringInfo(Set<String> listAllLE, Set<String> segmFilter){
        Map<String,XC_CM_LegalEntity_Configuration__mdt> result = new Map<String,XC_CM_LegalEntity_Configuration__mdt>();
        if(listAllLE == null || listAllLE.isEmpty()){
            return result;
        }
        Map<Id,XC_CM_LegalEntity_Configuration__mdt> dataCMlegalEntity = new Map<Id,XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_LegalEntity__c, XC_Stream__c, XC_EnableRepairButtonOnCase__c
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c IN :listAllLE
            AND XC_Stream__c IN: segmFilter
            AND XC_OrgId__c =: UserInfo.getOrganizationId()
        ]);

        String key;
        for(XC_CM_LegalEntity_Configuration__mdt mtd: dataCMlegalEntity.values()){
            key = mtd.XC_LegalEntity__c + mtd.XC_Stream__c;
            result.put(key, mtd);
        }
        return result;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getDefaultCatalogId
     * @param listAllLE 
     * @param segmFilter 
     * @return Map<String,String> with (LE+Segment) -> CatalogId >> can be empty
     **/
    public static Map<String,String> getDefaultCatalogId(Set<String> listAllLE, Set<String> segmFilter){
      Map<String,String> result = new Map<String,String>();
      if(listAllLE == null || listAllLE.isEmpty()){
        return result;
      }
      Map<Id,XC_CM_LegalEntity_Configuration__mdt> data = new Map<Id,XC_CM_LegalEntity_Configuration__mdt>([
          SELECT Id, XC_LegalEntity__c, XC_Stream__c, XC_DefaultCatalog__c
          FROM XC_CM_LegalEntity_Configuration__mdt 
          WHERE XC_LegalEntity__c IN :listAllLE
          AND XC_Stream__c IN: segmFilter
          AND XC_OrgId__c =: UserInfo.getOrganizationId()
      ]);

      Set<String> catalogNames = new Set<String>();
      for(XC_CM_LegalEntity_Configuration__mdt mtd: data.values()){
        if(String.isNotBlank(mtd.XC_DefaultCatalog__c)){
          catalogNames.add(mtd.XC_DefaultCatalog__c);
        }
      }
      if(catalogNames.isEmpty()){
        return result;
      }

      Map<Id,NE__Catalog__c> catalogs = new Map<Id,NE__Catalog__c>([
        SELECT Id, XC_LIC_Name__c
        FROM NE__Catalog__c
        WHERE XC_LIC_Name__c IN: catalogNames
      ]);

      String key;
      for(XC_CM_LegalEntity_Configuration__mdt mtd: data.values()){
        for(NE__Catalog__c cat : catalogs.values()){
          if(cat.XC_LIC_Name__c == mtd.XC_DefaultCatalog__c){
            key = mtd.XC_LegalEntity__c + mtd.XC_Stream__c;
            result.put(key, cat.Id);
            break;
          }
        }
      }

      return result;
    }
    
}