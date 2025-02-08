/**
 * @description       : Apex controller for TA_LCP253_DynamicPageBuilder
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 08-06-2021
 * @last modified by  : benjamin.geronimo
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   13-05-2021   benjamin.geronimo   Initial Version
**/

public without sharing class TA_LCC253_DynamicPageBuilder {

    public class InfoBag {
        @AuraEnabled
        public Map<String, Map<String, String>> generalInfoMap  {get; set;}
        @AuraEnabled
        public List<SectionWrapper>             sectionWrappers {get; set;}
    }

    // public class GeneralInfoWrapper {
    //     @AuraEnabled
    //     public String   field   {get; set;}
    //     @AuraEnabled
    //     public String   value   {get; set;}

    //     public GeneralInfoWrapper(String field, String value) {
    //         this.field = field;
    //         this.value = value;
    //     }
    // }

    public class SectionWrapper {
        @AuraEnabled
        public String               cmpName {get; set;}
        @AuraEnabled
        public List<ParamWrapper>   params  {get; set;}

        public SectionWrapper(String cmpName, List<ParamWrapper> params) {
            this.cmpName = cmpName;
            this.params = params;
        }
    }

    public class ParamWrapper {
        @AuraEnabled
        public String   key     {get; set;}
        @AuraEnabled
        public Object   value   {get; set;}

        public ParamWrapper(String key, Object value) {
            this.key = key;
            this.value = value;
        }
    }

    /**
    * @description 
    * @author benjamin.geronimo | 13-05-2021 
    * @param pageName 
    * @return InfoBag 
    **/
    @AuraEnabled
    public static InfoBag getPageConfigurations( String pageName ) {
        InfoBag infoBag = new InfoBag();
        infoBag.generalInfoMap = new Map<String, Map<String, String>>();
        infoBag.sectionWrappers = new List<SectionWrapper>();
        try {
            String currentUserPermissionSetName;
            if(Test.isRunningTest()){
                currentUserPermissionSetName = 'B2C_Italy_Set';
            } else {
                Id currentUserProfileId = UserInfo.getUserId();
                List<PermissionSetAssignment> currentUserPermissionSetList = [SELECT PermissionSet.Name
                                                                                FROM PermissionSetAssignment
                                                                                WHERE AssigneeId =: currentUserProfileId
                                                                                    AND PermissionSet.Description = 'TA_Configuration_Language'];

                if(!currentUserPermissionSetList.isEmpty()) {
                    currentUserPermissionSetName = currentUserPermissionSetList[0].PermissionSet.Name;
                }
            }

            String phase = '';
            switch on pageName {
                when 'Home' {		
                    phase = 'HomePage';
                }	
                when 'Custom Calendar' {	
                    phase = 'Calendar';
                }
                when else {		  // default block
                    phase = 'HomePage';
                }
            }

            // currentUserPermissionSetName = 'B2C_Italy_Set'; //for testing

            system.debug('>_> phase : ' + phase);
            system.debug('>_> currentUserPermissionSetName : ' + currentUserPermissionSetName);

            if( phase != '' )
            {
                List<TA_Capability_Configuration__c> cbConfigurations = [
                    SELECT  Id,
                            TA_DeveloperName__c,
                            TA_JSON_Param__c,
                            TA_Index__c,
                            TA_Value__c
                    FROM    TA_Capability_Configuration__c
                    WHERE   TA_Type__c =: 'Layout'
                        AND TA_Active__c = true
                        AND TA_Phase__r.TA_DeveloperName__c =: phase
                        AND TA_Configuration_Set__c =: currentUserPermissionSetName
                    ORDER BY TA_Index__c ASC
                ];

                system.debug('>_> cbConfigurations : ' + cbConfigurations);

                if(!cbConfigurations.isEmpty()) {
                    for(TA_Capability_Configuration__c cbConfig : cbConfigurations) {
                        List<ParamWrapper> paramWraps = new List<ParamWrapper>();
                        paramWraps.add(new ParamWrapper('cmpName', cbConfig.TA_Value__c));
                        paramWraps.add(new ParamWrapper('fieldSet', cbConfig.TA_JSON_Param__c));

                        infoBag.sectionWrappers.add(new SectionWrapper(cbConfig.TA_DeveloperName__c, paramWraps));
                        
                    }
                } else {
                    System.debug('[TA_LCC253_DynamicPageBuilder] getPageConfigurations - no TA_Capability_Configuration__c founds.');
                }
            } else {
                System.debug('[TA_LCC253_DynamicPageBuilder] getPageConfigurations - Invalid phase name.');
            }
            

        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_LCC253_DynamicPageBuilder] getPageConfigurations - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC253_DynamicPageBuilder', 'getPageConfigurations', errorMessage, 0, errorMessage, null);
        }
        return infoBag;
    }

}