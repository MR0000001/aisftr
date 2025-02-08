/**
* @author dpalamides
* @date 12/11/2019
* @description classes.Constants
*/ 
public without sharing class Constants {
    public static final String TEST = 'TEST';
    public static final String SPAIN = 'Spain';
    public static final String UNITED_STATES = 'United States';
    public static final String UNITED_KINGDOM = 'United Kingdom';
    public static final String CHILE = 'Chile';
    public static final String COLOMBIA = 'Colombia';
    public static final String ITALY = 'Italy';
    public static final String ROMANIA ='Romania';
	public static final String BRAZIL = 'Brazil'; //ACERRA 09.12.2021 ADOPTION BRAZIL																				  

    public static final String ENEL_X_CHILE = 'EnelX';
    public static final String ENEL_DISTRIBUCION_CHILE = 'EnelDistribucion';
    public static final String CODENSA = 'Codensa';
	public static final String CANADA = 'Canada'; //LAZZAROTTI 19.07.2022 ADOPTION USA
	//[BEGIN ACERRA 09.12.2021 ADOPTION BRAZIL]										   
    public static final Map<String,String> COUNTRY_ISO_CODES = new Map<String,String>
                                                                {
                                                                        SPAIN           => 'ESP',
                                                                        UNITED_STATES   => 'USA',
                                                                        UNITED_KINGDOM  => 'GBR',
                                                                        CHILE           => 'CHL',
                                                                        COLOMBIA        => 'COL',
                                                                        ITALY           => 'ITA',
                                                                        ROMANIA         => 'ROU',
                                                                        BRAZIL          => 'BRA',					
																		CANADA          => 'CAN'
                                                                };
    //[END ACERRA 09.12.2021 ADOPTION BRAZIL]
    public static final String LEGAL_TEXT_STATIC_RESOURCE_NAME = 'XC_SR_LegalText';
    
   /**
    * @author Nicola Arrigo
    * @date Creation 21/11/2019
    * @description This method is used to retrieve the information about the user, and it's a centrilized query for the user. It's optimized to be performed only one time per transaction
    */ 
  public static User userInContext{
        get{
            User usc = userInContext;
            if( userInContext == null ){
                usc = [ SELECT Id,XC_AccountId__c, AccountId, XC_LegalEntity__c, Country__c,XC_EnabledToSkip__c FROM USER WHERE  Id =: UserInfo.getUserId()];
            }
            userInContext = usc;
            return usc;
        }
        private set;
    }

        /**
    * @author Nicola Arrigo 
    * @date Creation 21/11/2019
    * @description This method is used to retrieve the metadata configuration about the SKIP RULES for the 25 core obejcts
    */ 
    public static Map<String,XC_CM_OneOrgFW__mdt> coreSkipTrigger {
        get{
            if( coreSkipTrigger == null ){
                coreSkipTrigger = new Map<String,XC_CM_OneOrgFW__mdt>();
                for( XC_CM_OneOrgFW__mdt mst: [ SELECT Id, QualifiedApiName, XC_SkipTrigger__c, XC_SkipValidation__c, XC_SkipProcessBuilder__c, XC_SkipFlow__c, 
                                                             XC_SkipWorkFlowRule__c, XC_IsActive__c 
                                                      FROM   XC_CM_OneOrgFW__mdt  
                                                      WHERE  XC_IsActive__c = true 
                                                      LIMIT 5000]){
                    coreSkipTrigger.put(mst.QualifiedApiName , mst );
                }
            }
            return coreSkipTrigger;
        }
        private set;
    }
     /*
    ** The following is the constants configuration for the metadata where are the rules evaluated to skip the execution of triggers
    */
    public final static string MDT_SKIP_ACCOUNT              = 'Account';
    public final static string MDT_SKIP_CONTACT              = 'Contact';
    public final static string MDT_SKIP_CONTRACT             = 'Contract';
    public final static string MDT_SKIP_ADDRESS              = 'Address';
    public final static string MDT_SKIP_BILLPROFILE          = 'Billing_Profile';
    public final static string MDT_SKIP_CASE                 = 'Case';
    public final static string MDT_SKIP_ASSET                = 'Asset';
    public final static string MDT_SKIP_WORKORDER            = 'Work_Order';  
    public final static string MDT_SKIP_SERVICEAPP           = 'Service_Appointment';
    public final static string MDT_SKIP_SERVICERESOURCE      = 'Service_Resource';
    public final static string MDT_SKIP_SERVICETERR          = 'Service_Territory'; 
    public final static string MDT_SKIP_LEAD                 = 'Lead';  
    public final static string MDT_SKIP_INDIVIDUAL           = 'Individual';
    public final static string MDT_LEGAL_ENTITY_CONSENT      = 'Legal_Entity_Consent';
    public final static string MDT_SKIP_WOLI                 = 'Work_Order_Line_Item';
    public final static string MDT_SKIP_ORDER                = 'Configuration';
    public final static string MDT_SKIP_ORDITEM              = 'Configuration_Item';
    public final static string MDT_SKIP_OPPORTUNITY          = 'Opportunity';
    public final static string MDT_SKIP_WBE_TRACKING         = 'WbeTracking';
    public final static string MDT_SKIP_PERSONAL_DOCUMENT    = 'Personal_Document';
    public final static string MDT_SKIP_ASSIGNEDRESOURCES    = 'AssignedResource';
    public final static string MDT_SKIP_TECHNICALSHEET       = 'Technical_Sheet';
    public final static string MDT_SKIP_SERVRESCOVERAGE      = 'Service_Resource_Coverage';
    public final static string MDT_SKIP_PARTNERCOVERAGE      = 'Partner_Coverage';
    public final static string MDT_SKIP_CATALOGITEM          = 'Catalog_Item';
    public final static string MDT_SKIP_AFFILIATEBENEFICIARY = 'Affiliate_and_Beneficiary'; //[DeAv 20210915 - CR NR1857]
    public final static string MDT_SKIP_FORM_CASE            = 'Form_Case';  //[20220224 - NR2357]

    public final static string PPM_PROJECT_TASK_TYPE_BILLING           = 'Billing Payment';
    public final static string PPM_PROJECT_TASK_REASON_MILESTONE       = 'Milestone';

    public final static String OPP_STAGE_INPROGRESS = 'In Progress';
    public final static String PROJECTTASK_PLANNED='planned';

    // [ BEGIN, gaurav.tejpal@accenture.com, 06/01/2022,FUNZIONALITÀ TASTO RECLAMO , NR2255,ENEL X-r12]
    public final static String ORIGIN='CAN013';
    public final static String XC_SEGMENT='B2G';
    public final static String REASON='XCMOT008';
    public final static String XC_SUBTYPE='XC279';
    public final static String SUBCAUSE='ATCL099';
    // [ END, gaurav.tejpal@accenture.com, 06/01/2022,FUNZIONALITÀ TASTO RECLAMO , NR2255,ENEL X-r12]  
    
    //[ BEGIN, gaurav.tejpal@accenture.com, 06/04/2022,Enel X - Multiple sales]
   public final static String ORDER_PAYMENT_METHOD_TYPE='Commodity Bill';
   public final static String ORDER_PRODUCT_TYPE='Bundle';
    //[ END, gaurav.tejpal@accenture.com, 06/04/2022,Enel X - Multiple sales]
}