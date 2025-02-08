/**
 * Created by ABOZZANO00 on 06/11/2020.
 */

global without sharing class BatchArticlesManagement implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private static BatchArticlesManagement_Setting__c setting = BatchArticlesManagement_Setting__c.getValues('BatchArticlesManagement');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {

            Datetime refDatetime = System.now().addHours(-Integer.valueOf(setting.hours__c));

            String query = 'SELECT Id, PublishStatus, ArticleNumber, LastModifiedDate, LastModifiedById, AssignedById, AssignedBy.SerialNumber__c, ArchivedById, LastModifiedBy.SerialNumber__c, ArchivedBy.SerialNumber__c, MacrostructureReference__c, ' +
                    'Title, UrlName, KnowledgeArticleId, AssignedBy.UserRole.DeveloperName, ArchivedBy.UserRole.DeveloperName ' +
                    'FROM Knowledge__kav ' +
                    'WHERE PublishStatus !=  \'Online\' AND LastModifiedDate > :refDatetime ' +
                    'AND AssignedBy.UserRole.DeveloperName != \'Super_User\' ' +
                    'AND ((AssignedBy.UserRole.DeveloperName= \'LeaderCC\' AND RecordType.DeveloperName != \'Disposizioni_CC\') ' +
                    'OR AssignedBy.UserRole.DeveloperName != \'LeaderCC\')';

            return Database.getQueryLocator(query);

        } catch (Exception e) {
            throw ErrorLogEventHandler.standardExceptionLog(e);
        }
    }

    global void execute(Database.BatchableContext BC, List<Knowledge__kav> scope) {

        try {

            List <Knowledge__kav> kavDraftList = new List<Knowledge__kav>();
            List <Knowledge__kav> kavArchivedList = new List<Knowledge__kav>();
            List <String> articlesIdReadyForPublish = new List<String>();
            List <String> userSerialNumerList = new List<String>();

            for (Knowledge__kav kav : scope) {
                if (kav.PublishStatus == 'Draft' && kav.AssignedBy.SerialNumber__c != null) {
                    kavDraftList.add(kav);
                    userSerialNumerList.add(String.valueOf(kav.AssignedBy.SerialNumber__c));
                } else if (kav.PublishStatus == 'Archived' && kav.ArchivedBy.SerialNumber__c != null) {
                    kavArchivedList.add(kav);
                    userSerialNumerList.add(String.valueOf(kav.ArchivedBy.SerialNumber__c));
                }
            }

            //TODO Query in Selector
            List <Role__c> techMacroStructureIdList = new List<Role__c>();
            techMacroStructureIdList = [SELECT EmployeeId__r.SerialNumber__c, StructureId__r.TechMacrostructureId__c FROM Role__c WHERE EmployeeId__r.SerialNumber__c = :userSerialNumerList];

            //TODO Query in Selector
            List <MacrostructureAssociation__c> msaList = new List<MacrostructureAssociation__c>();
            msaList = [SELECT Id, SerialNumber__c, Structure__c FROM MacrostructureAssociation__c WHERE SerialNumber__c = :userSerialNumerList];


            //DRAFT
            if (kavDraftList != null && !kavDraftList.isEmpty()) {
                for (Knowledge__kav kav : kavDraftList) {
                    Boolean check0 = false;
                    for (Role__c tms : techMacroStructureIdList) {
                        if (kav.AssignedBy.SerialNumber__c == tms.EmployeeId__r.SerialNumber__c) {
                            if (kav.MacrostructureReference__c == tms.StructureId__r.TechMacrostructureId__c) {
                                check0 = false;
                                break;
                            } else {
                                check0 = true;
                            }
                        }
                    }
                    if (check0) {
                        if (!msaList.isEmpty()) {
                            Boolean checkMsa = false;
                            for (MacrostructureAssociation__c msa : msaList) {
                                system.debug(kav.LastModifiedBy.SerialNumber__c + ' ' + msa.SerialNumber__c);
                                if (kav.AssignedBy.SerialNumber__c == msa.SerialNumber__c) {
                                    checkMsa = true;
                                    System.debug('8');
                                    if (kav.MacrostructureReference__c == msa.Structure__c) {
                                        break;
                                    } else {
                                        KbManagement.PublishingService.deleteDraftArticle(kav.KnowledgeArticleId);
                                    }
                                }
                            }
                            if (!checkMsa) {
                                KbManagement.PublishingService.deleteDraftArticle(kav.KnowledgeArticleId);
                            }
                        } else {
                            KbManagement.PublishingService.deleteDraftArticle(kav.KnowledgeArticleId);
                        }

                    } else if (kav.AssignedBy.UserRole.DeveloperName == 'LeaderCC') {
                        KbManagement.PublishingService.deleteDraftArticle(kav.KnowledgeArticleId);
                    }
                }
            }

            //ARCHIVED
            if (kavArchivedList != null && !kavArchivedList.isEmpty()) {
                for (Knowledge__kav kav : kavArchivedList) {
                    Boolean check0 = false;
                    for (Role__c tms : techMacroStructureIdList) {
                        if (kav.ArchivedBy.SerialNumber__c == tms.EmployeeId__r.SerialNumber__c) {
                            if (kav.MacrostructureReference__c == tms.StructureId__r.TechMacrostructureId__c) {
                                check0 = false;
                                break;
                            } else {
                                check0 = true;
                            }
                        }
                    }
                    if (check0) {
                        if (!msaList.isEmpty()) {
                            Boolean checkMsa = false;
                            for (MacrostructureAssociation__c msa : msaList) {
                                if (kav.ArchivedBy.SerialNumber__c == msa.SerialNumber__c) {
                                    if (kav.MacrostructureReference__c == msa.Structure__c) {
                                        break;
                                    } else {
                                        String articleId = KbManagement.PublishingService.editArchivedArticle(kav.KnowledgeArticleId);
                                        articlesIdReadyForPublish.add(articleId);
                                    }
                                }
                            }
                            if (!checkMsa) {
                                String articleId = KbManagement.PublishingService.editArchivedArticle(kav.KnowledgeArticleId);
                                articlesIdReadyForPublish.add(articleId);
                            }
                        } else {
                            String articleId = KbManagement.PublishingService.editArchivedArticle(kav.KnowledgeArticleId);
                            articlesIdReadyForPublish.add(articleId);
                        }
                    } else if (kav.ArchivedBy.UserRole.DeveloperName == 'LeaderCC') {
                        String articleId = KbManagement.PublishingService.editArchivedArticle(kav.KnowledgeArticleId);
                        articlesIdReadyForPublish.add(articleId);
                    }
                }
            }

            if (articlesIdReadyForPublish != null && !articlesIdReadyForPublish.isEmpty()) {
                List <Knowledge__kav> articlesToBePublish = new List<Knowledge__kav>(
                [
                        SELECT Id, PublishStatus, LastModifiedDate, LastModifiedById, AssignedById, ArchivedById, LastModifiedBy.SerialNumber__c,
                                ArchivedBy.SerialNumber__c, MacrostructureReference__c,
                                Title, UrlName, KnowledgeArticleId, VersionNumber
                        FROM Knowledge__kav
                        WHERE Id IN :articlesIdReadyForPublish
                ]);

                for (Knowledge__kav kav : articlesToBePublish) {
                    KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
                }
            }

        } catch (Exception e) {
            throw ErrorLogEventHandler.standardExceptionLog(e);
        }
    }

    global void finish(Database.BatchableContext BC) {
        try {

        } catch (Exception e) {
            throw ErrorLogEventHandler.standardExceptionLog(e);
        }
    }
    global static void execute(SchedulableContext ctx) {
        try {
            Database.executeBatch(new BatchArticlesManagement(), Integer.valueOf(setting.Batch_Size__c));
        } catch (Exception e) {
            throw ErrorLogEventHandler.standardExceptionLog(e);
        }
    }
}