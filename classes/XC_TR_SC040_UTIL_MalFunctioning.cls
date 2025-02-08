/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 08/032/2021
* @description XC_SC040_UTIL_Malfunctioning – Schedulable used to automatically retrive Milestone data from a case 
*/

public with sharing class XC_TR_SC040_UTIL_MalFunctioning implements Queueable {
 
    public Set<Id> caseIds;

    public XC_TR_SC040_UTIL_MalFunctioning(Set<Id> caseIds){
        this.caseIds = caseIds ;  
    } 
    public void execute(QueueableContext context){
      list<case>  newCase = [select Id, IsDeleted, MasterRecordId, CaseNumber, ContactId, AccountId, AssetId, ProductId, EntitlementId, 
                                SourceId, BusinessHoursId, ParentId, SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany, 
                            Type, RecordTypeId, Status, Reason, Origin, Language, Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, 
                            CurrencyIsoCode, OwnerId, IsClosedOnCreate, SlaStartDate, 
                            SlaExitDate, IsStopped, StopStartDate, CreatedDate, 
                            CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ContactPhone, ContactMobile, ContactEmail, 
                            ContactFax, Comments, LastViewedDate, LastReferencedDate, MilestoneStatus, 
                            NE__EngineeringReqNumber__c, NE__PotentialLiability__c, NE__Product__c, NE__SLAViolation__c, AmountPaid__c, 
                            ArrivedHour__c, AssetRelation__c, XC_Result__c, BalanceDispute__c, BalanceInDispute__c, CaseRemarks__c, Channel_Type__c, 
                            CloseBySystem__c, Commitment_date__c, ContactPhone__c, Country__c, CustomerResponse__c, DateSentFile__c, EffectiveDate__c, EndDateTaskPE__c, EstimatedStandardizationTime__c, 
                            Flag__c, Inadmissibility__c, LetterCorrelative__c, LetterType__c, NotificationChannel__c, NotificationEmail__c, NotifiedAct__c, NumberCaseOld__c, 
                            PaymentDate__c, PlannedEndDate__c, XC_KO_Reasons__c, Refund__c, Responsible__c, Rolebox__c, TraceErrorInservice__c, 
                            TypeClose__c, Type_Notification__c, Type_of_claim__c, XC_Contact_Preferred_Time__c, XC_CustomerInteraction__c, 
                            XC_Customer_Interaction__c, XC_IsCloned__c, XC_Opportunity__c, XC_OrderItem__c, XC_Order__c, 
                            XC_ProductCategoryOfInterest__c, XC_ReclamationCounter__c, XC_SuppliedEmail__c, XC_WorkOrder__c, SubCause__c, 
                            XC_Subtype__c, XC_SurveyExID__c, SubcausePE__c, User_Queue__c, XC_IndemnificationReason__c, XC_ReasonComplianceResult__c, XC_SurveyId__c, XC_External_ID__c, XC_WorkOrderValidation__c, XC_OriginChannel__c, XC_ApprovalStatus__c, XC_SentToZuora__c, XC_Receiving_Channel__c, XC_Invoice__c, XC_Resolution__c, XC_CTI_Interaction__c, XC_Address__c, XC_AssetAttached__c, XC_Communication_Date__c, XC_SubStatus__c, XC_Customer_Vision__c, XC_Amount__c, XC_Automatic_Refund__c, XC_Deprovisioning_Launched_from_Commodit__c, XC_Billing_Profile_Line_Item__c, XC_Case_Comments__c, XC_WithoutRepair__c, XC_LegalEntity__c, XC_ComplianceMaster__c, XC_Urgent__c, XC_WithCommitment__c, XC_EnelXcounter__c, XC_CustomerCounter__c, XC_OthersCounter__c, XC_TotalCounter__c, XC_Type_Intermediary__c, XC_Channel_Attribute__c, XC_ClaimType__c, XC_SendStatus__c, XC_ErrorMessage__c, XC_NumberOfValidations__c, XC_FirstCheckOnCompliance__c, XC_CompliantApplicable__c, XC_SalesChannel__c, XC_Date_of_incident__c, XC_Code_of_incidence__c, XC_Maximum_Date_of_Resolution__c, XC_ProvisioningStep__c, XC_Asset_Family__c, XC_B2B_COL_Region__c, Attention__c, NotificationAddressPE__c, PointofDelivery__c, ReasonClosure__c, XC_ComplianceApplicable__c, XC_ComplianceResult__c, XC_ReasonCancellation__c, XC_Description__c, project_cloud__Project_Phase__c, project_cloud__Project_Task__c, project_cloud__Project__c, project_cloud__Worked_Hours__c, ccpe_r__Cost__c, ccpe_r__Rate__c, ccpe_r__Utilization_Category__c, XC_CTICallRecording__c, XC_AssetListDetails__c, XC_Segment__c, XC_OrderSubtype__c, XC_PenaltyAmount__c, XC_RefundAmount__c, XC_PurchaseOptionAmount__c, XC_ConfigurationItemIncentive__c, XC_EnergyContractedPower__c, XC_EnergyVasContractNumberOfDays__c, XC_AutomaticDeactivationError__c, XC_Configuration__c, XC_OneClickID__c, XC_Force_Work_Order_creation__c, XC_Asset_B2B__c, XC_TechnicalAsset__c, XC_BusinessLine__c, XC_CallerType__c, XC_CreditMemo__c, Approved__c, XC_SubstatusNote__c, XC_NeedInternalCheck__c, XC_SerialNumber__c, XC_ContactName__c, XC_ContactSurname__c, XC_CompanyName__c, XC_ContactEmail__c, XC_ContactPhone__c, XC_GeolocalizationCountry__c, XC_DocumentID__c, XC_WithCaseChildren__c, XC_DefectDescription__c, XC_DefectType__c, XC_FaultType__c,XC_automaticClosure__c, XC_LastQueue__c, XC_VerificationDate__c, XC_ClienteCorporate__c, XC_Email__c, XC_NomeChiamante__c, XC_RecipientsRequest__c, XC_NonComplianceFound__c, XC_NonComplianceWorkOrder__c, XC_UpdateNonCompliancePenalty__c, XC_VerificationInstitution__c, XC_CongaDynamicAPI__c, XC_CongaStaticAPI__c, XC_Generate_Case_Document__c, XC_WorkOrderLineItem__c, XC_LocalDistributors__c, XC_PriceRequiredForConnection__c, XC_CustomerWorksEndDate__c, 
                            XC_LcLsuspended__c, XC_SuspensionDate__c, XC_DataPropoga__c, XC_DataRipresaLavori__c,XC_AssetSubType__c  
  from case
                                where id in:caseIds];
                        system.debug('enter onInsertCase');
                        Map<id,CaseMilestone> retrieveCaseMilestoneMap=new Map<id,CaseMilestone>();
                        //List<id> techAssetListId=new List<id>();
                        List<CaseMilestone> liCMList = new List<CaseMilestone>();
                        List<Case> caseToCreateWo=new List<case>();
                        List<id> assetId=new List<id>();
                        List<id> caseIdList=new List<id>();
                        system.debug('NewCaseTest ' + newCase );
                        Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration= XC_TR_Case_U_CaseRepair_B2BG.mapCaseRepairConfiguration();
                        if(mapCaseRepairConfiguration.values().size()>0){
                            Map<string,case> mapCaseB2B=new Map<string,case>();
                            for(case c:newCase){
                                   // caseToCreateWo.add(c);
                                    assetId.add(c.XC_TechnicalAsset__c);
                                   caseIdList.add(c.id);
                                  mapCaseB2B.put(c.XC_TechnicalAsset__c,c);
                              }
                            } 
                            if(caseIdList.size()==0){
                                return;
                            }
                          /*check on Wo 
                            List<WorkOrder> listWo=[select id,CaseId from WorkOrder
                                                    where ((Status!='Canceled' and status!='Completed') and XC_WorkTypeCategory__c='Malfunctioning' and CaseId IN:caseIdList)
                                                   ];
                            system.debug('ListWo Size related to the case '+listWo.size());
                            Map<Case,WorkOrder> mapWOByCase=mapWOByCase(caseToCreateWo,listWo);*/
                            if(caseIdList.size()>0 && Schema.sObjectType.CaseMilestone.isAccessible()){
                                liCMList=[SELECT id, Caseid, StartDate, TargetDate, TargetResponseInMins FROM CaseMilestone WHERE Caseid in :caseIdList ORDER BY TargetDate desc];
                            }
                            system.debug('liCMList '+liCMList);    
                            //check on contract
                            if(assetId.size()>0){
                                Map<id,Asset> technicalAssetMap=new Map<id,Asset>([select id,XC_Contract__c,AssetServicedById,XC_Address__c,TAM_PartnerContractId__c,TAM_PartnerContract__c,TAM_CommercialAsset__c,
                                                                                   TAM_CommercialAsset__r.NE__Order_Config__r.NE__OptyId__c,TAM_IsLogical__c, TAM_PartnerContract__r.XC_ContractAccount__c
                                                                                   from Asset
                                                                                   where id IN:assetId]);
                              //  system.debug('CaseTocreateWo List'+caseToCreateWo);
                                
                                //List<case> caseWithoutWO=checkErrorWO(mapWOByCase,caseToCreateWo);
                               // system.debug('caseWithoutWO '+caseWithoutWO);
                               // List<Case> caseNew=checkError(technicalAssetMap,caseWithoutWO) ;
                                system.debug('newCase '+newCase);
                                if(newCase.size()>0){
                                    system.debug('enter if condition caseNew sice greater than 0');
                                    if(liCMList.size()>0){
                                        retrieveCaseMilestoneMap= XC_TR_WoMalFunctioning.retrieveCaseMilestoneMap(liCMList,newCase);
                                    }
                                    Map<string,List<Case>> mapB2CcaseList=XC_TR_WoMalFunctioning.mapB2CcaseList(assetId);
                                    system.debug('caseMapB2C'+' '+mapB2CcaseList);
                                   if(mapB2CcaseList.values().size()>0){
                                     XC_TR_WoMalFunctioning.relateParent(newCase,mapB2CcaseList);
                                    }
                                    //relateParent( List<Case> caseNew,map<string,List<Case>> mapB2CcaseList);
                                    XC_TR_WoMalFunctioning.createWO(newCase,technicalAssetMap,retrieveCaseMilestoneMap);
                                }
                            }

    }
        /**
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
   /* public void finish(Database.QueueableContext bc) {
        System.debug('PROJECT TASK EMAIL NOTIFICATION ENDED');
    }*/
}