/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 29/06/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_QualityCheckKPI – Class to manage Quality Check KPI custom setting
 */

public without sharing class XC_UTIL_QualityCheckKPI {

    public static final String NC = 'NC';
    public static final String High = 'High';
    public static final String Medium = 'Medium';
    public static final String Low = 'Low';

    public class CSWrappers {
        public List<CSWrapper> css; 
       
        public CSWrappers(List<CSWrapper> css) {
            this.css = css;
        }

        public List<String> getFields() {
            List<String> fields = new List<String>();
            for(CSWrapper w : css) {
                fields.add(w.field);
            }
            return fields;
        }
    }
         
    public class CSWrapper {
        public String field; 
        public String priority; 
        public Integer points;
        
        public CSWrapper(String field, String priority, Decimal points) {
            this.field = field;
            this.priority = priority;
            this.points = Integer.valueOf(points);
        }
    }
  
    public class BonusMalus {
        public Integer highpriority;
        public Integer mediumpriority;
        public Integer lowpriority;
        public Integer totalpriority;
       
        
        public BonusMalus(Decimal highpriority, Decimal mediumpriority, Decimal lowpriority, Decimal totalpriority){
            this.highpriority = Integer.valueOf(highpriority);
            this.mediumpriority = Integer.valueOf(mediumpriority);
            this.lowpriority = Integer.valueOf(lowpriority);
            this.totalpriority = Integer.valueOf(totalpriority);
                     
            
        }
        
    }
    
    
    /**
    @author Alessandro Catto - alessandro11.catto@nttdata.com
    *@description 
    *@param country
    *@return set of products available for the inputs
    **/
    public static BonusMalus getBonusMalus(String qualityCheckId, String country) {
        Integer bonusMalus = 0;
        Integer highMalus = 0;
        Integer mediumMalus = 0;
        Integer lowMalus = 0;
        
        XC_CS011_SafetyPointsLicenseSettings__c licenseCS = XC_UTIL_SafetyPointsLicenseManagement.getSpecificSafetyPointsLicenseSettings(country);
        Integer nullAccessMalus = Integer.valueOf(licenseCS.XC_CheckQualityNullAccessMalus__c);
        Integer malus = Integer.valueOf(licenseCS.XC_KPI_QualityCheck_Malus_Threshold__c);
        Integer bonus = Integer.valueOf(licenseCS.XC_KPI_QualityCheck_Bonus__c);
        CSWrappers wrappers = wrapSettings(country);
        List<String> fields = wrappers.getFields();
        fields.add('XC_NullAccess__c');
        String query = 'SELECT ' + String.join(fields, ', ') + ' FROM XC_B2BG_QualityCheck__c WHERE Id = :qualityCheckId';
        XC_B2BG_QualityCheck__c qualityCheck = (XC_B2BG_QualityCheck__c) Database.query(query)?.get(0);
        Map<String,String> fieldValuesMap = new Map<String,String>();
          if(qualityCheck.XC_NullAccess__c == True){
           bonusMalus +=  nullAccessMalus; 
        }
        else{
        for(CSWrapper w : wrappers.css) {
            if(NC.equals(qualityCheck.get(w.field))) {
                bonusMalus += w.points;
                system.debug('test' + bonusMalus);
                if(High.equals(w.priority)){
                    highMalus +=w.points;
                    
               }
              if(Medium.equals(w.priority)){
                    mediumMalus +=w.points;
                    
               }
                if(Low.equals(w.priority)){
                    lowMalus +=w.points;
                    
               }
            }
        }
      
        
       
            system.debug('Test2' + bonusMalus);
            //TODO - check limits and bonuses using custom settings
            if(!fields.isEmpty() && bonusMalus == 0) {          
                System.debug('Test3' + bonusMalus);
                bonusMalus = bonus;
            }
            if(bonusMalus < malus) {
                bonusMalus = malus;
                System.debug('Test4' + bonusMalus);
            }
         }
        
        System.debug('Test5' + bonusMalus);
        BonusMalus totalbonus = new BonusMalus(highMalus, mediumMalus, lowMalus, bonusMalus);
        return totalbonus;
    }
    
    public static CSWrappers wrapSettings(String country) {
        List<CSWrapper> wrappers = new List<CSWrapper>();
        List<XC_CS017_KPIQualityCheck__c> qcSettings = XC_CS017_KPIQualityCheck__c.getAll().values();
        for(XC_CS017_KPIQualityCheck__c qc : qcSettings) {
            if(country.equals(qc.XC_Country__c)) {
                for(String f : getFields(qc.XC_FieldSet__c)) {
                    wrappers.add(new CSWrapper(f, qc.XC_Priority__c, qc.XC_Points__c));
                }
            }
        }
        
        return new CSWrappers(wrappers);
    }


    public static List<String> getFields(String fsName) {
        List<String> fieldAPINames = new List<String>();
        List<Schema.FieldSetMember> fieldSetMembers = Schema.getGlobalDescribe().get('XC_B2BG_QualityCheck__c').getDescribe().FieldSets.getMap().get(fsName).getFields(); 
        for(Schema.FieldSetMember fsm : fieldSetMembers) {
            fieldAPINames.add(fsm.getFieldPath());
        }
        return fieldAPINames;
    }
}