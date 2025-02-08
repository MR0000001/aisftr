/**
     * @author Giulia Sciammarella
     * @description 
     * @param listNew 
     * @return void
    **/


    @IsTest
    public with sharing class XC_TR_Opportunity_Weight_Test {
    
        static testMethod void SFMautomathism(){
            List<Opportunity> listopp = XC_DF_Opportunity.createOpportunity(1,false);
            date startDate = date.newInstance(2020, 12, 17);
            date endDate = date.newInstance(2025, 12, 17);
            date qualifiedDate = date.Today();
            date acceptedDate=date.Today(); 
            date closeDate =date.Today();
            date deadlineDate =date.Today();
            listopp[0].RecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_Colombia').getRecordTypeId();
            listopp[0].XC_LegalEntity__c = 'Codensa';
            listopp[0].Name ='Opportunity di Test';
            listopp[0].CloseDate=closeDate;
            listopp[0].XC_PipelineStatus__c= 'Opportunity Assigned';
            listOpp[0].XC_BusinessLine__c='eCity';
            listOpp[0].XC_WeighteCity__c ='50';
            listOpp[0].XC_IndustrialKPI__c ='Work Contract';
            listOpp[0].XC_ProductCategoryOfInterest__c ='Architectural Lighting';
            listOpp[0].XC_ProductCategory__c='Optimize';
            listOpp[0].XC_IndustrialKPIfullLife__c =1;
            listOpp[0].XC_BusinessModel__c = 'Spot Sale';
            listOpp[0].StageName ='Draft';
            listOpp[0].XC_OpportunityDescription__c ='test';
            listOpp[0].XC_ModeOfEngagement__c ='Tender';
            listOpp[0].XC_KindofCustomer__c ='Test';
            listOpp[0].XC_TechnologyeCity__c ='Custom Work';
            listOpp[0].XC_ContractualRevenueStartDate__c= startDate;
            listOpp[0].XC_ContractualRevenueEndDate__c=endDate;
            listOpp[0].XC_DeadlineForProposalSubmission__c=deadlineDate;
            listOpp[0].XC_ExpectedAcceptedProposalDate__c=acceptedDate;
            listOpp[0].XC_QualifiedPotentialOpportunityDate__c = qualifiedDate;
            listOpp[0].XC_OpportunityAssignedDate__c = qualifiedDate;

            listOpp[0].XC_Segment__c = 'B2G';
            listOpp[0].XC_BillingModel__c ='By Milestone';
            listOpp[0].XC_SalesChannel__c ='Enel X KAM';
           	listOpp[0].XC_Source__c ='Commodity';
            
            Map<Id,Opportunity> mapOld = new Map<Id,Opportunity>();
            for(Opportunity op : listopp){
                mapOld.put(op.id,op);
            }
            
            List<Account> accs=[select id,XC_Segment__c from Account where id =: listOpp[0].accountid];
            accs[0].XC_Segment__c ='B2G';
            update accs[0];
            
            List<Opportunity> toInsert = new List<Opportunity>();
            for(Opportunity o:mapOld.values()){
                Opportunity opp = new Opportunity(RecordTypeId = o.RecordTypeId, AccountId = accs[0].Id,XC_LegalEntity__c = o.XC_LegalEntity__c,XC_PipelineStatus__c=o.XC_PipelineStatus__c,XC_BusinessLine__c=o.XC_BusinessLine__c,
                XC_WeighteCity__c=o.XC_WeighteCity__c,XC_IndustrialKPI__c=o.XC_IndustrialKPI__c,XC_ExpectedAcceptedProposalDate__c=o.XC_ExpectedAcceptedProposalDate__c,XC_QualifiedPotentialOpportunityDate__c=o.XC_QualifiedPotentialOpportunityDate__c,
                XC_IndustrialKPIfullLife__c=o.XC_IndustrialKPIfullLife__c, XC_ProductCategoryOfInterest__c=o.XC_ProductCategoryOfInterest__c,XC_ContractualRevenueStartDate__c=o.XC_ContractualRevenueStartDate__c,XC_ContractualRevenueEndDate__c=o.XC_ContractualRevenueEndDate__c,XC_DeadlineForProposalSubmission__c=o.XC_DeadlineForProposalSubmission__c,
                XC_ProductCategory__c=o.XC_ProductCategory__c,XC_BusinessModel__c=o.XC_BusinessModel__c,Name =o.Name, CloseDate=o.CloseDate,
                XC_Segment__c=o.XC_Segment__c,StageName=o.StageName,XC_OpportunityDescription__c=o.XC_OpportunityDescription__c,XC_ModeOfEngagement__c=o.XC_ModeOfEngagement__c,XC_KindofCustomer__c=o.XC_KindofCustomer__c/*,XC_TechnologyeCity__c=o.XC_TechnologyeCity__c*/);
                toInsert.add(opp);
            }
            insert toInsert;
            toInsert[0].XC_PipelineStatus__c= 'Signed Contract';
            update toInsert;
            
            
            List<Opportunity> listNew = new List<Opportunity>();    
            for(Opportunity o : toInsert){
                listNew.add(o);
            }        
            XC_TR_Opportunity_WeightFields.changePipelineFields(listNew,mapOld);

            toInsert[0].XC_PipelineStatus__c='Permitting';
            update toInsert;     
            XC_TR_Opportunity_WeightFields.changePipelineFields(listNew,mapOld);

            toInsert[0].XC_PipelineStatus__c='Commercial Operation Date';
            update toInsert;
            XC_TR_Opportunity_WeightFields.changePipelineFields(listNew,mapOld);

            toInsert[0].XC_PipelineStatus__c='Abandoned';
            update toInsert;
            XC_TR_Opportunity_WeightFields.changePipelineFields(listNew,mapOld);

            toInsert[0].XC_ProductCategoryOfInterest__c='Smart Lighting';
            toInsert[0].XC_IndustrialKPI__c='Work Contract';
            update toInsert;
            XC_TR_Opportunity_WeightFields.changePipelineFields(listNew,mapOld);

            listOpp[0].XC_BusinessLine__c='eIndustry';
            listOpp[0].XC_WeighteCity__c ='50';
            listOpp[0].XC_IndustrialKPI__c ='MW installed in the year';
            listOpp[0].XC_ProductCategoryOfInterest__c ='PV';
            listOpp[0].XC_ProductCategory__c='Supply';
            listOpp[0].XC_IndustrialKPIfullLife__c =1;
            listOpp[0].XC_BusinessModel__c = 'Spot Sale';
            listOpp[0].XC_PaymentMethod__c ='Cash';
            listOpp[0].XC_BillingModel__c ='By Milestone';
            listOpp[0].XC_SalesChannel__c ='Enel X KAM';
            listOpp[0].XC_Source__c='Facebook';
            listOpp[0].XC_WeighteIndustry__c='10';
            listOpp[0].XC_PipelineStatus__c ='Signed Contract';
            XC_TR_Opportunity_WeightFields.changePipelineFields(listNew,mapOld);


            XC_TR_Opportunity_WeightFields.industrialKPIfield(listNew);
            XC_TR_Opportunity_WeightFields.industrialKPIfieldUpdate(listNew);
            }
            
            
            
        }