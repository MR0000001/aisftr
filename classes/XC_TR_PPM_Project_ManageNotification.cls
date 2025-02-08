/**
 * @author Andrea Di Cicco
 * @createddate 24/11/2020
 * @description This class is used to manage PPM notification
 */
public without sharing class XC_TR_PPM_Project_ManageNotification {
    /**
     * @author Andrea Di Cicco
     * @createddate 24/11/2020
     * @param mapNew 
     * @description method to create a customer interaction when a project is created
     */
	public static void projectCreatedCustomerInteraction(Map<Id,project_cloud__Project__c > mapNew){
        Map<Id,project_cloud__Project__c > mapProject = new Map<Id,project_cloud__Project__c >();
        for(project_cloud__Project__c  proj : mapNew.values() ){
            //start federico.manni@accenture.com QW CR ID 710 - MorEfficiency – Gestione comunicazione inizio progetto
            //Boolean checkProject = (proj.XC_Segment__c == 'B2B' || proj.XC_Segment__c == 'B2G') && (proj.XC_Status__c  == 'New' || proj.XC_Status__c  == 'Assigned');
            Boolean checkProject = (proj.XC_Segment__c == 'B2B' || proj.XC_Segment__c == 'B2G') && (proj.XC_Status__c  == 'New' || proj.XC_Status__c  == 'Assigned') && proj.XC_LegalEntity__c != 'EnelSole';
            //end federico.manni@accenture.com QW CR ID 710 - MorEfficiency – Gestione comunicazione inizio progetto
            if(checkProject ){
                mapProject.put(proj.id, proj);
            } 
        }
        if(mapProject.isEmpty()){
            return;
        }
        List<project_cloud__Project__c> projectInfo = retrieveProjectInfo(mapProject.keySet());
                
        List<XC_Customer_Interaction__c> interactionList = new List<XC_Customer_Interaction__c>();
        XC_Customer_Interaction__c customerInter = new XC_Customer_Interaction__c();
        Map<Id,NE__OrderItem__c> orderItemMap = new  Map<Id,NE__OrderItem__c>([SELECT Id, NE__OrderId__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__CatalogItem__r.XC_ProductLine__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name, NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name  FROM  NE__OrderItem__c WHERE NE__Parent_Order_Item__c = null AND NE__OrderId__c IN: XC_UTIL_Sobject.getListFieldValues(projectInfo, 'XC_Configuration__c' )]);
        for(project_cloud__Project__c ppm : projectInfo){
            if(ppm.XC_ConfigurationItem__c != null){    //&& ppm.ccpe_ocp__Opportunity__c != null
                NE__OrderItem__c oi=new NE__OrderItem__c();
                oi=orderItemMap.get(ppm.XC_ConfigurationItem__c);
                /*
                if(ppm.project_cloud__Type__c == 'Provisioning'  && oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Customer Insights' ){
                    customerInter = populateCustomerInteraction(ppm, 'Survey_Onboarding');
                    customerInter.XC_SurveyId__c = 'Survey_Onboarding';
                }*/
				if(ppm.project_cloud__Type__c == 'Maintenance Plan' && oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Distributed Energy'){
                    customerInter = populateCustomerInteraction(ppm, 'Survey_Product_Performance');
                    customerInter.XC_SurveyId__c = 'Survey_Product_Performance';
                }else if (ppm.project_cloud__Type__c == 'Maintenance Plan' && (oi.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || oi.NE__CatalogItem__r.XC_ProductLine__c == 'E400')){
                    customerInter = populateCustomerInteraction(ppm, 'Survey_Maintenance');
                    customerInter.XC_SurveyId__c = 'Survey_Maintenance';
                }
                interactionList.add(customerInter);
            }else if(ppm.XC_Configuration__c != null){ //&& ppm.ccpe_ocp__Opportunity__c != null
                System.debug('@@@@@MAP VALUES');
                System.debug(orderItemMap.values());
                for(NE__OrderItem__c oi: orderItemMap.values()){
                	System.debug('@@@@@NAME CATALOG');
                	System.debug(oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name);
                    System.debug('@@@@@PROJECT TYPE');
                	System.debug(ppm.project_cloud__Type__c);
                    if(ppm.project_cloud__Type__c == 'Provisioning'  && oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Customer Insights' ){
                        customerInter = populateCustomerInteraction(ppm, 'Survey_Onboarding');
                        customerInter.XC_SurveyId__c = 'Survey_Onboarding';
                    }
                    /*
                    else if(ppm.project_cloud__Type__c == 'Maintenance Plan' && oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Distributed Energy'){
                        System.debug('@@@@@@@ENTRATO IF');
                        customerInter = populateCustomerInteraction(ppm, 'Survey_Product_Performance');
                        customerInter.XC_SurveyId__c = 'Survey_Product_Performance';
                    }
					*/
					else if (ppm.project_cloud__Type__c == 'Maintenance Plan' && (oi.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || oi.NE__CatalogItem__r.XC_ProductLine__c == 'E400')){
                        customerInter = populateCustomerInteraction(ppm, 'Survey_Maintenance');
                        customerInter.XC_SurveyId__c = 'Survey_Maintenance';
                    }
                    interactionList.add(customerInter);
                }
                //interactionList.addAll(customerInteractionsFromOrder(ppm, orderItemMap));
            }
        }
        System.debug('@@@@@@Interaction List: '+interactionList);
        XC_UTIL_DML.insertRecords(interactionList);
        //XC_UTIL_DML.insertRecords(populateCustomerInteraction(projectInfo, 'Project_Created'));
    }
    
    @TestVisible private static XC_Customer_Interaction__c populateCustomerInteraction(project_cloud__Project__c ppm, String comunicationType){
                XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
                Contact c = new Contact();
                System.debug('@@@@@@ ppm.ccpe_ocp__Account__c '+ppm.ccpe_ocp__Account__c);
                c=[SELECT Id, Name FROM Contact WHERE AccountId=:ppm.ccpe_ocp__Account__c and XC_PrimaryContact__c=true LIMIT 1];
                System.debug('@@@@@@ c '+c);
                ci.XC_ProjectId__c = ppm.id;
                ci.XC_AdditionalInfo1__c = ppm.Name;
                ci.XC_AdditionalInfo2__c = ppm.XC_ExternalProjectView__c.removeStart('<a href="').removeEnd('" target="_blank">External Project View</a>');
                ci.XC_OpportunityId__c = ppm.ccpe_ocp__Opportunity__c != null? ppm.ccpe_ocp__Opportunity__c : ppm.XC_Configuration__r.NE__OptyId__c;
                ci.XC_ConfigurationItem__c = ppm.XC_ConfigurationItem__c;
                ci.XC_OrderId__c = ppm.XC_Configuration__c;
                if(ppm.XC_ConfigurationItem__c != null){
                    ci.XC_ProductId__c = ppm.XC_ConfigurationItem__r.NE__ProdId__c;
                }
                ci.XC_ContactId__c = ppm.ccpe_ocp__Opportunity__c != null?ppm.ccpe_ocp__Opportunity__r.XC_Contact__c: c.Id;
                ci.XC_AccountId__c = ppm.ccpe_ocp__Account__c;
                ci.XC_Recipient__c = ppm.ccpe_ocp__Opportunity__c != null? ppm.ccpe_ocp__Opportunity__r.XC_Contact__r.Name: null;
                ci.XC_Email__c = ppm.ccpe_ocp__Opportunity__c != null? ppm.ccpe_ocp__Opportunity__r.XC_Contact__r.email : null;
                ci.XC_Preferredlanguageofcontact__c = ppm.ccpe_ocp__Opportunity__c != null ? ppm.ccpe_ocp__Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c : null;
                ci.XC_Channel__c = 'Email';
                ci.XC_Communication_Type__c = comunicationType;
                ci.XC_LegalEntity__c = ppm.XC_LegalEntity__c;
                ci.XC_Segment__c = ppm.XC_Segment__c;
                ci.XC_BusinessLine__c = ppm.ccpe_ocp__Opportunity__c != null? ppm.ccpe_ocp__Opportunity__r.XC_BusinessLine__c: ppm.XC_Configuration__r.NE__OptyId__r.XC_BusinessLine__c;
        return ci;
    }
    

    /**
     * @author Andrea Di Cicco
     * @createddate 24/11/2020
     * @param mapNew 
     * @param mapOld
     * @description method to create a customer interaction when a project is created
     */
    public static void projectSuspendAndCancelledCustomerInteraction(Map<Id,project_cloud__Project__c > mapNew, Map<Id,project_cloud__Project__c > mapOld){
        Map<Id,project_cloud__Project__c > mapProject = new Map<Id,project_cloud__Project__c >();
        List<project_cloud__Project__c> suspendedProject = new List<project_cloud__Project__c>();
        List<project_cloud__Project__c> cancelledProject = new List<project_cloud__Project__c>();
        List<project_cloud__Project__c> closedProject = new List<project_cloud__Project__c>();
        for(project_cloud__Project__c  proj : mapNew.values() ){
            Boolean checkProject = (proj.XC_Segment__c == 'B2B' || proj.XC_Segment__c == 'B2G') && (proj.XC_Status__c  != mapOld.get(proj.id).XC_Status__c) && (proj.XC_Status__c  == 'Cancelled' || proj.XC_Status__c  == 'Suspended' || proj.XC_Status__c == 'Closed');
            if(checkProject){
                mapProject.put(proj.id, proj);
            }
        }
        if(mapProject.isEmpty()){
            return;
        }
        List<project_cloud__Project__c> projectInfo = retrieveProjectInfo(mapProject.keySet());
        List<XC_Customer_Interaction__c> customerInteractionToInsert = new List<XC_Customer_Interaction__c>();
        for(project_cloud__Project__c ppm : projectInfo){
            if(ppm.XC_Status__c  == 'Cancelled'){
                cancelledProject.add(ppm);
            }else if(ppm.XC_Status__c  == 'Suspended'){
                suspendedProject.add(ppm);
            }else if(ppm.XC_Status__c  == 'Closed'){
                closedProject.add(ppm);
            }
        }
        if(!cancelledProject.isEmpty()){
            customerInteractionToInsert.addAll(populateCustomerInteraction(cancelledProject, 'Project_Cancelled'));
        }
        if(!suspendedProject.isEmpty()){
            customerInteractionToInsert.addAll(populateCustomerInteraction(suspendedProject, 'Project_Suspended'));
        }
        if(!closedProject.isEmpty()){
            customerInteractionToInsert.addAll(manageClosedProjectCustomerInteraction(closedProject));
        }
        XC_UTIL_DML.insertRecords(customerInteractionToInsert);
    }

    private static List<project_cloud__Project__c> retrieveProjectInfo(Set<Id> projectId){
        List<project_cloud__Project__c> projectInfo = new List<project_cloud__Project__c>();
        if(Schema.sObjectType.project_cloud__Project__c.isAccessible()){
            projectInfo = [SELECT id, ccpe_ocp__Opportunity__c, XC_Configuration__c, XC_ConfigurationItem__c, 
            XC_ConfigurationItem__r.NE__ProdId__c, XC_Contract__c, ccpe_ocp__Opportunity__r.XC_Contact__c, ccpe_ocp__Opportunity__r.XC_BusinessLine__c, ccpe_ocp__Opportunity__r.XC_Contact__r.Name, ccpe_ocp__Opportunity__r.XC_Contact__r.email, ccpe_ocp__Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c, ccpe_ocp__Account__c, XC_LegalEntity__c, XC_Segment__c, XC_Status__c, project_cloud__Type__c, Name, XC_ExternalProjectView__c,
            XC_Configuration__r.NE__OptyId__c,  XC_Configuration__r.NE__OptyId__r.XC_BusinessLine__c, ccpe_ocp__Account__r.XC_ContactToNotify__c FROM project_cloud__Project__c  WHERE id IN: projectId];
        }
        return projectInfo;
    }

    private static List<XC_Customer_Interaction__c> populateCustomerInteraction(List<project_cloud__Project__c> projectList, String comunicationType){
        List<XC_Customer_Interaction__c> custInteractionList = new List<XC_Customer_Interaction__c>();
        for(project_cloud__Project__c ppm : projectList){
                XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
                ci.XC_ProjectId__c = ppm.id;
                ci.XC_AdditionalInfo1__c = ppm.Name;
                ci.XC_AdditionalInfo2__c = ppm.XC_ExternalProjectView__c.removeStart('<a href="').removeEnd('" target="_blank">External Project View</a>');
                ci.XC_OpportunityId__c = ppm.ccpe_ocp__Opportunity__c != null? ppm.ccpe_ocp__Opportunity__c : ppm.XC_Configuration__r.NE__OptyId__c;
                ci.XC_ConfigurationItem__c = ppm.XC_ConfigurationItem__c;
                ci.XC_OrderId__c = ppm.XC_Configuration__c;
                if(ppm.XC_ConfigurationItem__c != null){
                    ci.XC_ProductId__c = ppm.XC_ConfigurationItem__r.NE__ProdId__c;
                }
                ci.XC_ContactId__c = ppm.ccpe_ocp__Opportunity__c != null?ppm.ccpe_ocp__Opportunity__r.XC_Contact__c: ppm.ccpe_ocp__Account__r.XC_ContactToNotify__c;
                ci.XC_AccountId__c = ppm.ccpe_ocp__Account__c;
                ci.XC_Recipient__c = ppm.ccpe_ocp__Opportunity__c != null? ppm.ccpe_ocp__Opportunity__r.XC_Contact__r.Name: null;
                ci.XC_Email__c = ppm.ccpe_ocp__Opportunity__c != null? ppm.ccpe_ocp__Opportunity__r.XC_Contact__r.email : null;
                ci.XC_Preferredlanguageofcontact__c = ppm.ccpe_ocp__Opportunity__c != null ? ppm.ccpe_ocp__Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c : null;
                ci.XC_Channel__c = 'Email';
                ci.XC_Communication_Type__c = comunicationType;
                ci.XC_LegalEntity__c = ppm.XC_LegalEntity__c;
                ci.XC_Segment__c = ppm.XC_Segment__c;
                ci.XC_BusinessLine__c = ppm.ccpe_ocp__Opportunity__c != null? ppm.ccpe_ocp__Opportunity__r.XC_BusinessLine__c: ppm.XC_Configuration__r.NE__OptyId__r.XC_BusinessLine__c;
                custInteractionList.add(ci);
            
        }
        return custInteractionList;
    }

    private static List<XC_Customer_Interaction__c> manageClosedProjectCustomerInteraction(List<project_cloud__Project__c> projectList){
        List<XC_Customer_Interaction__c> interactionList = new List<XC_Customer_Interaction__c>();
        Map<Id,NE__OrderItem__c> orderItemMap = new  Map<Id,NE__OrderItem__c>([SELECT Id, NE__OrderId__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__CatalogItem__r.XC_ProductLine__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name, NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name  FROM  NE__OrderItem__c WHERE NE__Parent_Order_Item__c = null AND NE__OrderId__c IN: XC_UTIL_Sobject.getListFieldValues(projectList, 'XC_Configuration__c' )]);
        for(project_cloud__Project__c ppm : projectList){
            if(ppm.XC_ConfigurationItem__c != null){ //&& ppm.ccpe_ocp__Opportunity__c != null
                interactionList.addAll(customerInteractionFromConfItem(ppm, orderItemMap.get(ppm.XC_ConfigurationItem__c)));
            }else if(ppm.XC_Configuration__c != null){ //&& ppm.ccpe_ocp__Opportunity__c != null
                interactionList.addAll(customerInteractionsFromOrder(ppm, orderItemMap));
            }
        }
        return interactionList;
    }

    public static List<XC_Customer_Interaction__c> customerInteractionFromConfItem(project_cloud__Project__c ppm, NE__OrderItem__c oi){
        List<XC_Customer_Interaction__c> customerInterList = new List<XC_Customer_Interaction__c>();
        XC_Customer_Interaction__c CIproductPerformance = new XC_Customer_Interaction__c();
        XC_Customer_Interaction__c customerInter = new XC_Customer_Interaction__c();
        List<project_cloud__Project__c> projList = new List<project_cloud__Project__c>();
        projList.add(ppm);
        
        customerInter = populateCustomerInteraction(projList, 'Project_Closed').get(0);
        CIproductPerformance = populateCustomerInteraction(projList, 'Project_Closed').get(0);
        if(ppm.project_cloud__Type__c == 'Provisioning' && oi.NE__CatalogItem__c != null && ( oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name == 'Storage' || oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Distributed Energy' || oi.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || oi.NE__CatalogItem__r.XC_ProductLine__c == 'E400'  )){
            //Survey S2
            customerInter.XC_SurveyId__c = 'Survey_Installation';
            customerInterList.add(customerInter);
            if(ppm.project_cloud__Type__c == 'Provisioning' && oi.NE__CatalogItem__c != null && (oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Distributed Energy')){
            CIproductPerformance.XC_SurveyId__c = 'Survey_Product_Performance';
            customerInterList.add(CIproductPerformance);
            }
        }else if(ppm.project_cloud__Type__c == 'Maintenance Plan' && oi.NE__CatalogItem__c != null){
            if(oi.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || oi.NE__CatalogItem__r.XC_ProductLine__c == 'E400'){
                customerInter.XC_SurveyId__c = 'Survey_Maintenance';
                customerInterList.add(customerInter);
            }/*
            else if(oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name == 'Storage'){
                customerInter.XC_SurveyId__c = 'Survey_Maintenance_Ordinary';
				customerInterList.add(customerInter);
            }else if(  oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name =='Distributed Energy'){
                customerInter.XC_SurveyId__c = 'Survey_Maintenance_Ordinary';
				customerInterList.add(customerInter);
            }*/
        }else if(ppm.project_cloud__Type__c == 'Provisioning' && oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__c != null && oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Customer Insights' ){
            customerInter.XC_SurveyId__c = 'Survey_Onboarding';
            customerInterList.add(customerInter);
        }
        return customerInterList;
    }

    public static List<XC_Customer_Interaction__c> customerInteractionsFromOrder(project_cloud__Project__c ppm, Map<Id,NE__OrderItem__c> orderItemMap){
        List<XC_Customer_Interaction__c> customerInter = new List<XC_Customer_Interaction__c>();
        List<NE__OrderItem__c> orderItemToCheck = new List<NE__OrderItem__c>();
        List<String> surveyList = new List<String>();
        for(NE__OrderItem__c oi : orderItemMap.values()){
            if(ppm.XC_ConfigurationItem__c == oi.Id){
                orderItemToCheck.add(oi);
            }
        }
        for(NE__OrderItem__c oi: orderItemMap.values()){
            if(ppm.project_cloud__Type__c == 'Provisioning' && (oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name == 'Storage' || oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Distributed Energy'||  oi.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || oi.NE__CatalogItem__r.XC_ProductLine__c == 'E400'  )){
                surveyList.add( 'Survey_Installation-' + oi.id);
                if(ppm.project_cloud__Type__c == 'Provisioning' && (oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Distributed Energy')){
                surveyList.add( 'Survey_Product_Performance-' + oi.id);
                }
            }else if(ppm.project_cloud__Type__c == 'Maintenance Plan'){
                if(oi.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || oi.NE__CatalogItem__r.XC_ProductLine__c == 'E400'){
                    surveyList.add( 'Survey_Maintenance-' + oi.id);
                }/*
                else if(oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name == 'Storage'){
                    surveyList.add( 'Survey_Maintenance_Ordinary-' + oi.id);
                }*/
                /*
				else if(oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Distributed Energy'){
                    surveyList.add( 'Survey_Maintenance_Ordinary-' + oi.id);
                    surveyList.add( 'Survey_Product_Performance-' + oi.id);
                }
				*/
            }else if(ppm.project_cloud__Type__c == 'Provisioning' && oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__c != null && oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name =='Customer Insights' ){
                surveyList.add( 'Survey_Onboarding-' + oi.id);
            }
        }
        if(surveyList.isEmpty()){
            List<project_cloud__Project__c> projList = new List<project_cloud__Project__c>();
            projList.add(ppm);
            customerInter.add(populateCustomerInteraction(projList, 'Project_Closed').get(0));
            return customerInter;
        }

        for(String surveyId :surveyList ){
            String surveyName  = surveyId.split('-')[0];
            String confItemId = surveyId.split('-')[1];
            XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
            List<project_cloud__Project__c> projList = new List<project_cloud__Project__c>();
            ppm.XC_ConfigurationItem__c = confItemId;
            projList.add(ppm);
            if(surveyName == 'Survey_Product_Performance'){
                ci = populateCustomerInteraction(projList, 'Survey_Product_Performance').get(0);
            }else{
                ci = populateCustomerInteraction(projList, 'Project_Closed').get(0);
            }
            
            ci.XC_SurveyId__c = surveyName;
            customerInter.add(ci);
        }
        return customerInter;
    }
}