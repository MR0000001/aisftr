/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 19/06/2020
* @description XC_TR_Opportunity_U_CreditCheck 
*/  
public with sharing class XC_TR_Opportunity_U_CreditCheck {
  /**
     * @author Nicola Arrigo
     * @@date Creation 19/06/2020
     * @description Method to check CreditCheck
     * @param mapNew - Map<Id,Opportunity>
     * @param mapOld - Map<Id,Opportunity>
    **/
    public static void creditCheck (Map<id,Opportunity> mapNew,Map<Id,Opportunity>mapOld){
    system.debug('enter credit check');
      List<id> accListId=new List<id>();
      List<Opportunity> oppList=new List<Opportunity>();
      for(Opportunity opp:mapNew.values()){
        if(opp.Amount!=mapOld.get(opp.Id).Amount && 
             (opp.XC_Segment__c=='B2B'||
              opp.XC_Segment__c=='B2G')) 
              {
            //retrieve Account Id
            system.debug('Account id'+' '+opp.AccountId);
            system.debug('Name opp'+''+opp.Name);
            accListId.add(opp.AccountId);
            //retrieve OppToCheck
            oppList.add(opp);
        }
      } 
      if(oppList.isEmpty()){
        return;
      } 
        Map<Id,Account> mappAccount=new Map<Id,Account>([select id, XC_CheckBlacklist__c
                                                         from Account
                                                         where Id IN:accListId]);
        List<XC_CM_ThresholdCreditCheck__mdt> cmList=[select id,XC_LegalEntity__c, XC_Country__c, 
                                                    XC_Productcategoryofinterest__c, XC_Segment__c,XC_GovernancelevelIIthreshold__c,
                                                    XC_GovernancelevelIthreshold__c,XC_Materialitythreshold__c  
                                                  from XC_CM_ThresholdCreditCheck__mdt ];
        Map<Id,XC_CM_ThresholdCreditCheck__mdt> cmMap=cmMap(oppList,cmList);
        List<Opportunity> oppToCreateCase=new List<Opportunity>();
        system.debug(cmMap);
        for(opportunity opp:oppList){
            if(cmMap.get(opp.id)!=null){
                system.debug('trovato CM');
                //record CM
                XC_CM_ThresholdCreditCheck__mdt cm=cmMap.get(opp.id);  
                // record Account
                Account acc=mappAccount.get(opp.AccountId);
                // less than Materialitythreshold
                if(opp.Amount<cm.XC_Materialitythreshold__c){ 
                    system.debug('less than Materialitythreshold');
                    if(acc.XC_CheckBlacklist__c=='OK' ||

					     acc.XC_CheckBlacklist__c=='Customer not present in the blacklist'){
                     opp.XC_CreditCheck_GB__c='OK';   
                    }else if(acc.XC_CheckBlacklist__c=='KO' ||
					         acc.XC_CheckBlacklist__c=='KO - Customer present in the blacklist'){

                               opp.XC_CreditCheck_GB__c='KO';  
                            }
                }
                else if(opp.Amount>=cm.XC_Materialitythreshold__c){
                    system.debug('grether or equals  than Materialitythreshold');
                    opp.XC_CreditCheck_GB__c='TBR';
                    if(opp.Amount>cm.XC_GovernancelevelIIthreshold__c){
                        opp.XC_GovernanceThreshold__c=true;
                    }
                   // List Opp to createCase
                   oppToCreateCase.add(opp);
                } 
            }
        }
       // call method to create case;
       createCase(oppToCreateCase);
  }
  private static Map<Id,XC_CM_ThresholdCreditCheck__mdt> cmMap(List<Opportunity> oppList,List<XC_CM_ThresholdCreditCheck__mdt> cmList){
    system.debug('enter cmMap');
    Map<Id,XC_CM_ThresholdCreditCheck__mdt> cmMap=new Map<Id,XC_CM_ThresholdCreditCheck__mdt>(); 
    for(opportunity opp:oppList){
          for(XC_CM_ThresholdCreditCheck__mdt cm:cmList){             
               if( cm.XC_LegalEntity__c == opp.XC_LegalEntity__c &&
                  cm.XC_Country__c==opp.XC_Country__c &&
                  //cm.XC_Productcategoryofinterest__c==opp.XC_ProductCategoryOfInterest__c &&
                  cm.XC_Segment__c==opp.XC_Segment__c
                ){
                    cmMap.put(opp.Id,cm);
                    system.debug('cm trovato'+' '+cm);
                    break;
                }                
            }
        }
       return cmMap; 
    }
    private static void createCase(List<Opportunity>  oppToCreateCase){
     /* for(Oppportunity opp:oppToCreateCase){
          string s=
      }*/
      string name='XC_Credit_CheckV2';
      List<String> caseSettingNames = new List<String>{name};
      Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
      if(caseSettingsMap.isEmpty() || caseSettingsMap.get(name)==null){
       // XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+Label.XC_CL_ValidationCase);
       // XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Validation Case (Extra) NOT created!');
       system.debug('CaseTypeSetting not found');
        return;
    }
    XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(name);
    List<case>  newCases=new List<case>();
      AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
		 dmlOpts.EmailHeader.TriggerUserEmail = true;
      for(Opportunity opp: oppToCreateCase){
        if( caseSettingsMap.get(name)!=null){
            Case newValidationCase;
            newValidationCase =XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
            newValidationCase.XC_Opportunity__c=opp.id;
            newValidationCase.AccountId=opp.AccountId;
            newValidationCase.ContactId=opp.XC_Contact__c;
			newValidationCase.XC_BusinessLine__c=opp.XC_BusinessLine__c;
			newValidationCase.XC_LegalEntity__c=opp.XC_LegalEntity__c;
            newValidationCase.setOptions(dmlOpts);
            newCases.add(newValidationCase);
        }        
      }
      try{
      // XC_UTIL_DML.insertRecords(newCases);
        insert newCases;
      }catch(DmlException e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
      }
     /* List<XC_CM_CaseReasonRtMapping__mdt> cmCaseRT=[select id,XC_CaseReason__c, XC_CaseRecordType__c,XC_Stream__c,DeveloperName,XC_LegalEntity__c 
                                                      from XC_CM_CaseReasonRtMapping__mdt 
                                                      where XC_CaseReason__c='XCMOT007'];
        Map<string,XC_CM_CaseReasonRtMapping__mdt> rtMap= rtMap(cmCaseRT);                                             
        List<XC_CM_Case_Type_Setting__mdt> cmCaseTypeSetting=[select id,XC_Sub_Cause__c, XC_Sub_Type__c, XC_Case_Reason__c 
                                                              from XC_CM_Case_Type_Setting__mdt where 
                                                              XC_Sub_Type__c='XC192' and 
                                                              XC_Case_Reason__c='XCMOT007' AND 
                                                              XC_Sub_Cause__c='ATCL028' limit 1];*/
             
    }
    /*
    private static Map<string,XC_CM_CaseReasonRtMapping__mdt> rtMap(List<XC_CM_CaseReasonRtMapping__mdt> cmCaseRT){
        Map<string,XC_CM_CaseReasonRtMapping__mdt> rtMap=new Map<string,XC_CM_CaseReasonRtMapping__mdt>();
        for(XC_CM_CaseReasonRtMapping__mdt cm:cmCaseRT){
           string s=cm.XC_Stream__c+'_'+cm.XC_LegalEntity__c;
           rtMap.put(s,cm);
       }
       return rtMap;               
    }*/   
}