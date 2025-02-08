public with sharing class CaseService {

    private static Boolean isFromFuture = false;
    private static List<Case> casesList = null;

    public static void TriggerHandler (List<Case> newCases, Map<Id,Case> oldCasesMap) {
        DebugService.printLimits('CaseService', 'TriggerHandler', 'start');
        try {
            if(oldCasesMap == null) {
                CaseCDCManager.manageCDCCase(newCases);
                for(Case newCase : newCases){
                    if(newCase.Start_Day_Access__c!=null){
                        newCase.Start_Time_Access__c = newCase.Start_Day_Access__c.time();
                        newCase.StartDateEntry__c = newCase.Start_Day_Access__c.date();
                    }

                    if(newCase.Finish_Day_Access__c != null){
                        newCase.Finish_Time_Access__c = newCase.Finish_Day_Access__c.time();
                        newCase.FinishDateEntry__c = newCase.Finish_Day_Access__c.date();
                    }

                }
            } else {
                for(Case newCase : newCases){
                    if(newCase.Start_Day_Access__c != oldCasesMap.get(newCase.Id).Start_Day_Access__c){
                        if(newCase.Start_Day_Access__c!=null){
                            newCase.Start_Time_Access__c = newCase.Start_Day_Access__c.time();
                            newCase.StartDateEntry__c = newCase.Start_Day_Access__c.date();
                        }else{
                            newCase.Start_Time_Access__c = null;
                            newCase.StartDateEntry__c = null;
                        }
                    }

                    if(newCase.Finish_Day_Access__c != oldCasesMap.get(newCase.Id).Finish_Day_Access__c){
                        if(newCase.Finish_Day_Access__c != null){
                            newCase.Finish_Time_Access__c = newCase.Finish_Day_Access__c.time();
                            newCase.FinishDateEntry__c = newCase.Finish_Day_Access__c.date();
                        }else{
                            newCase.Finish_Time_Access__c = null;
                            newCase.FinishDateEntry__c = null;
                        }
                    }
                }
            }
        } catch(Exception e) {
            DebugService.printException('CaseService', 'TriggerHandler', e);
            ErrorLogEventHandler.standardExceptionLog(e);
        }
        DebugService.printLimits('CaseService', 'TriggerHandler', 'end');
    }

    public static void splitAddress(List<Case> newCases) {
        DebugService.printLimits('CaseService', 'splitAddress', 'start');
        List<String> splittedAddress;
        System.debug('splitAddress');
        System.debug('Userinfo ' + UserInfo.getProfileId());
        try {
            String profileName = ProfileSelector.getProfileNameById(UserInfo.getProfileId());
            if(profileName != null && profileName.equalsIgnoreCase(System.Label.splitAddress_Profile)) {
                for(Case c : newCases) {
                    splittedAddress = new List<String>();
                    if(c.Origin != null && (c.Origin.equalsIgnoreCase(Label.CASE_ORIGIN_CDC) || c.Origin.equalsIgnoreCase(Label.CASE_ORIGIN_APP)) && c.Street_Address__c != null && !c.Street_Address__c.equalsIgnoreCase('')) { //c.Type != null && c.Type.equalsIgnoreCase(System.Label.splitAddress_Type) &&
                        splittedAddress = c.Street_Address__c.split(',');
                        if(c.Street_Address__c.countMatches(',') == 3) {
                            String numberAddress = splittedAddress[1].trim();
                            List<String> primaryNumberAddress = numberAddress.split('/|-');
                            List<String> splittedNumberLetter = primaryNumberAddress[0].splitByCharacterType();
                            if(splittedNumberLetter.size() == 2) {
                                c.Letter_Address__c = splittedNumberLetter[1];
                            }
                            c.Number_Address__c = Decimal.valueOf(splittedNumberLetter[0]);
                        }
                        c.Street_Address__c = splittedAddress[0];
                    }
                }
            }
        } catch(Exception e) {
            DebugService.printException('CaseService', 'splitAddress', e);

            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        DebugService.printLimits('CaseService', 'splitAddress', 'end');
    }

    public static void updateCasesForEmailExternal(List<String> caseIds, Boolean allOrNone) {
        DebugService.printLimits('CaseService', 'updateCasesForEmailExternal', 'start');
        if(!caseIds.isEmpty()) {
            List<Case> cases = new List<Case>();
            for(String id : caseIds) {
                Case c = new Case();

                c.Id = id;
                c.SendEmail__c = true;
                c.Status = 'Working';
                c.Sub_Status__c = 'In carico a Ente Esterno';

                cases.add(c);
            }
            if(!cases.isEmpty()) CaseSelector.updateCases(cases, allOrNone);
            DebugService.printLimits('CaseService', 'updateCasesForEmailExternal', 'end');
        }
    }

    public static List<Database.SaveResult> updateCases(List<Case> cases, Boolean allOrNone) {
        DebugService.printLimits('CaseService', 'updateCases', 'start');
        List<Database.SaveResult> results;
        if(cases != null && !cases.isEmpty()) {
            System.debug('cases is not null or empty');
            results = CaseSelector.updateCases(cases, allOrNone);
            DebugService.printDatabaseResults('CaseService', 'updateCases', 'cases', results);
            DebugService.printLimits('CaseService', 'updateCases', 'end');
        }
        DebugService.printLimits('CaseService', 'updateCases', 'end');
        return results;
    }

    public static void deleteCases(List<Case> cases, Boolean allOrNone) {
        if(cases != null && !cases.isEmpty()) CaseSelector.deleteCases(cases, allOrNone);
    }

    public static List<ContentVersion> updateCaseFieldsOnNewContentVersions(Map<String, List<ContentVersion>> caseIdCvsMap) {
        DebugService.printLimits('CaseService', 'updateCaseFieldsOnNewContentVersions', 'start');
        List<ContentVersion> allContentVersions = new List<ContentVersion>();

        if(!caseIdCvsMap.isEmpty()) {
            Boolean toModifyCases = false;
            Boolean toUpdateCase = false;
            OrgManagement__c orgSetting = OrgManagement__c.getOrgDefaults();

            List<Case> cases = CaseSelector.getCasesByCaseIds(new List<String>(caseIdCvsMap.keySet()));

            for(Case c : cases) {
                if(c.ProtocolCFUser__c != null) {
                    List<ContentVersion> contentVersions = caseIdCvsMap.get(c.Id);
                    for(ContentVersion cv : contentVersions) {
                        if(Math.abs((c.CreatedDate.getTime() - cv.CreatedDate.getTime())/orgSetting.ms_to_secs__c) <= Integer.valueOf(orgSetting.Time_Attachment_GED__c) && (cv.ContentSize/orgSetting.Bytes_to_MB__c) <= Integer.valueOf(orgSetting.Limit_Attachment_GED__c)) {
                            ContentVersion attachment = new ContentVersion();
                            attachment.Id = cv.Id;
                            attachment.sendAttachmentToGED__c = true;
                            allContentVersions.add(attachment);
                            toModifyCases = true;
                        }/* else {
                            toModifyCases = false;
                        }*/
                    }

                    if(toModifyCases) {
                        if(String.isBlank(c.ID_Protocollo__c) && (!c.ToBeSentGED__c || !c.GEDCasePDF__c)) {
                            c.ToBeSentGED__c = true;
                            c.GEDCasePDF__c = true;

                            toUpdateCase = true;
                        } else if(String.isNotBlank(c.ID_Protocollo__c) && c.All_Content_Versions_Integrated_GED__c) {
                            c.All_Content_Versions_Integrated_GED__c = false;
                            toUpdateCase = true;
                        }
                    }
                }
            }

            System.debug('updateCaseFieldsOnNewContentVersions toUpdateCase ' + toUpdateCase);
            System.debug('updateCaseFieldsOnNewContentVersions toModifyCases ' + toModifyCases);
            if(toUpdateCase) {
                updateCases(cases, false);
            }
        }

        DebugService.printLimits('CaseService', 'updateCaseFieldsOnNewContentVersions', 'end');

        return allContentVersions;
    }

    public static Map<String, String> updateCaseFieldsOnDeleteContentVersions(Map<String, List<ContentVersion>> caseIdCvsMap, List<ContentVersion> contentVersionsBeingDeleted) {
        DebugService.printLimits('CaseService', 'updateCaseFieldsOnDeleteContentVersions', 'start');

        Integer noOfAttachmentsBeingDeleted = contentVersionsBeingDeleted.size();
        Boolean toUpdate = false;
        Boolean isError = false;
        Map<String, String> caseIdError = new Map<String, String>();

        List<Case> cases = CaseSelector.getCasesByCaseIds(new List<String>(caseIdCvsMap.keySet()));

        for(Case c : cases) {
            if(c.ProtocolCFUser__c != null) {
                if(String.isNotBlank(c.ID_Protocollo__c)) {
                    if(caseIdCvsMap.get(c.Id).size() == 1 && contentVersionsBeingDeleted.contains(caseIdCvsMap.get(c.Id)[0])) {
                        isError = true;
                        caseIdError.put(c.Id, System.Label.GED_OnlyContentCannotDelete);
                    } else if(caseIdCvsMap.get(c.Id).size() > 1) {
                        if(noOfAttachmentsBeingDeleted == caseIdCvsMap.get(c.Id).size()) {
                            isError = true;
                            caseIdError.put(c.Id, System.Label.GED_AllContentsCannotDelete);
                        } else if(noOfAttachmentsBeingDeleted < caseIdCvsMap.get(c.Id).size()) {
                            Integer noOfAttachmentsNotGED = 0;
                            for(ContentVersion cv : caseIdCvsMap.get(c.Id)) {
                                if(String.isBlank(cv.NumberGED__c)) {
                                    noOfAttachmentsNotGED++;
                                }
                            }
                            if(noOfAttachmentsNotGED == noOfAttachmentsBeingDeleted && !c.All_Content_Versions_Integrated_GED__c) {
                                toUpdate = true;
                                c.All_Content_Versions_Integrated_GED__c = true;
                            }
                        }
                    }
                } else if(String.isBlank(c.ID_Protocollo__c)) {
                    if(caseIdCvsMap.get(c.Id).size() == 1 && contentVersionsBeingDeleted.contains(caseIdCvsMap.get(c.Id)[0])) {
                        toUpdate = true;
                        c.ToBeSentGED__c = false;
                        c.GEDCasePDF__c = false;
                    }
                }
            }
        }

        System.debug('isError ' + isError);
        System.debug('updateCaseFieldsOnDeleteContentVersions toUpdate ' + toUpdate);
        if(toUpdate) {
            updateCases(cases, false);
        }

        DebugService.printLimits('CaseService', 'updateCaseFieldsOnDeleteContentVersions', 'end');

        return caseIdError;
    }

    public static void processBrogliaccioPull(List<Case> cases) {
        DebugService.printLimits('CaseService', 'processBrogliaccioPull', 'start');
        if(cases != null && !cases.isEmpty()) {
            try {
                Map<String, Case> extBrogliaccioIdCasesMap = createExtBrogliaccioIdCaseMap(cases);

                if(extBrogliaccioIdCasesMap != null && !extBrogliaccioIdCasesMap.isEmpty()) {
                    ResponseBrogliaccioPull responsesBrogliaccioPull = BrogliaccioPullCallout.brogliaccioPullCallout(extBrogliaccioIdCasesMap);

                    if(!responsesBrogliaccioPull?.StatoSegnalazioneResponse?.StatoSegnalazioneResult.isEmpty()) {
                        setCaseFieldsForBrogliaccioPull(extBrogliaccioIdCasesMap, responsesBrogliaccioPull);
                        CaseService.updateCases(extBrogliaccioIdCasesMap.values(), false);
                    }
                }
            } catch(Exception e) {
                System.debug('Exception at CaseService.processBrogliaccioPull ' + e.getMessage());

                ErrorLogEventHandler.standardExceptionLog(e);
            }
        }
        DebugService.printLimits('CaseService', 'processBrogliaccioPull', 'start');
    }

    public static Map<String, Case> createExtBrogliaccioIdCaseMap(List<Case> cases) {
        DebugService.printLimits('CaseService', 'createExtBrogliaccioIdCaseMap', 'start');
        Map<String, Case> extBrogliaccioIdCasesMap = new Map<String, Case>();

        for(Case c : cases) {
            extBrogliaccioIdCasesMap.put(c.ExternalSystemId_Brogliaccio__c, c);
        }

        DebugService.printLimits('CaseService', 'createExtBrogliaccioIdCaseMap', 'end');
        return extBrogliaccioIdCasesMap;
    }

    public static void setCaseFieldsForBrogliaccioPull(Map<String, Case> extBrogliaccioIdCasesMap, ResponseBrogliaccioPull responsesBrogliaccioPull) {
        DebugService.printLimits('CaseService', 'setCaseFieldsForBrogliaccioPull', 'start');
        OrgManagement__c orgSetting = OrgManagement__c.getOrgDefaults();
        BrogliaccioBatch_Pull_Setting__c setting = BrogliaccioBatch_Pull_Setting__c.getValues(System.Label.BrogliaccioPull_StateMajor);
        BrogliaccioBatch_Pull_Setting__c settingMinor = BrogliaccioBatch_Pull_Setting__c.getValues(System.Label.BrogliaccioPull_StateMinor);
        String commandLocalPoliceId = GroupsSelector.getGroupByName(setting.Current_Queue_Dev_Name__c)?.Id;

        for(ResponseBrogliaccioPull.StatoSegnalazioneResult result : responsesBrogliaccioPull.StatoSegnalazioneResponse.StatoSegnalazioneResult) {
            Case c = extBrogliaccioIdCasesMap.get(String.valueOf(result.VerbatelID));
            if(c != null) {
                if(result.Stato == Integer.valueOf(System.Label.BrogliaccioPull_StateMinor)) {
                    if(c.Last_Batch_Date_Time__c == null) c.Last_Batch_Date_Time__c = Datetime.now();
                    c.SkipValidation__c = settingMinor.Skip_Validation__c;
                    c.Sub_Status__c = String.isNotBlank(settingMinor.Sub_Status__c) ? settingMinor.Sub_Status__c : null;
                    c.Comment_User__c += '\n' + System.today().format() + ' ' + System.Label.Brogliaccio_PoliceLocaleCommentUserChiusura;
                } else if(result.Stato == Integer.valueOf(System.Label.BrogliaccioPull_StateMajor)) {
                    if(c.Last_Batch_Date_Time__c == null) c.Last_Batch_Date_Time__c = Datetime.now();
                    c.SkipValidation__c  = setting.Skip_Validation__c;
                    c.Status = String.isNotBlank(setting.Status__c) ? setting.Status__c : null;
                    c.Sub_Status__c = String.isNotBlank(setting.Sub_Status__c) ? setting.Sub_Status__c : null;
                    c.OwnerId =  commandLocalPoliceId;
                    c.Current_Queue__c = String.isNotBlank(setting.Current_Queue__c) ? setting.Current_Queue__c : null;
                    c.Prior_Queue__c = String.isNotBlank(orgSetting.Brogliaccio_Queue__c) ? orgSetting.Brogliaccio_Queue__c : null;
                    c.Rejection__c = setting.Rejection__c;
                    c.Case_Action__c = String.isNotBlank(setting.Case_Action__c) ? setting.Case_Action__c : null;
                    c.Case_Action_Comment__c = String.isNotBlank(setting.Case_Action_Comment__c) ? setting.Case_Action_Comment__c : null;
                    c.Sent_to_External__c = String.isNotBlank(setting.Sent_to_External__c) ? setting.Sent_to_External__c : null;
                    c.ClosedDate__c = (String.isNotBlank(setting.Closed_Date__c) && !setting.Closed_Date__c.equalsIgnoreCase(System.Label.BrogliaccioPull_NullifyField)) ? Date.valueOf(setting.Closed_Date__c) : null;
                    c.Brogliaccio_Reject__c = setting.Brogliaccio_Reject__c;
                    c.Closed_Reason__c =  (String.isNotBlank(setting.Motivo_chiusura__c) && !setting.Motivo_chiusura__c.equalsIgnoreCase(System.Label.BrogliaccioPull_NullifyField)) ? setting.Motivo_chiusura__c : null;
                    c.Comment_User__c += '\n' + System.today().format() + ' ' + System.Label.Brogliaccio_PoliceLocaleCommentUserSegnalazione;
                } else {
                    if(c.Last_Batch_Date_Time__c == null) {
                        c.Last_Batch_Date_Time__c = Datetime.now();
                    } else {
                        extBrogliaccioIdCasesMap.remove(c.ExternalSystemId_Brogliaccio__c);
                    }
                }
            }
        }
        DebugService.printLimits('CaseService', 'setCaseFieldsForBrogliaccioPull', 'end');
    }

    @AuraEnabled
    public static Map<String, BrogliaccioBatch_Setting__c> getBrogliaccioCustomSettingsAndQueue() {
        DebugService.printLimits('CaseService', 'getBrogliaccioCustomSettingsAndQueue', 'start');
        Map<String, BrogliaccioBatch_Setting__c> queueCustomSettingMap = new Map<String, BrogliaccioBatch_Setting__c>();

        BrogliaccioBatch_Setting__c setting = BrogliaccioBatch_Setting__c.getValues('SendToBrogliaccioBatch');

        Group brogliaccioQueue = GroupsSelector.getGroupByName(setting.Group_Dev_Name__c);

        queueCustomSettingMap.put(brogliaccioQueue.Id, setting);

        DebugService.printLimits('CaseService', 'getBrogliaccioCustomSettingsAndQueue', 'end');
        return queueCustomSettingMap;
    }

    public static void setCaseFieldsGEDCase(List<ResponseGEDCase.ListaNumeroProtollo> listaNumeroProtollos, Map<String, Case> caseIdCaseMap) {
        DebugService.printLimits('CaseService', 'setCaseFieldsGEDCase', 'start');
        for(ResponseGEDCase.ListaNumeroProtollo resp : listaNumeroProtollos) {
            Case c = caseIdCaseMap.get(resp.id);
            if(resp.error.errorCode.equalsIgnoreCase(Label.GED_CaseResponseSuccess)) {
                System.debug('In Success');
                c.ErrorGed__c = null;
                c.Protocol_Number__c = String.isNotBlank(resp.tipoProtocollo) ? resp.tipoProtocollo : '';
                c.YearProtocol__c = resp.annoProtocollo != null ? String.valueOf(resp.annoProtocollo) : '';
                c.ID_Protocollo__c = resp.progressivoProtocollo != null ? String.valueOf(resp.progressivoProtocollo) : '';
                c.SenderProtocol__c = String.isNotBlank(resp.codiceMittente) ? resp.codiceMittente : '';

                Datetime gmt =  Datetime.newInstance(resp.dataProtocollo);
                system.debug('gmt -> '+gmt);
                //Integer offset = UserInfo.getTimezone().getOffset(gmt);
                //system.debug('offset -> '+ offset);
                //Datetime localDate = gmt.addSeconds(-offset/1000);
                //system.debug('localDate -> '+ localDate);
                c.DateProtocol__c  = gmt.date();

                Datetime gmt2 = Datetime.newInstance(resp.oraProtocollo);
                system.debug('gmt2 -> ' + gmt2);
                c.TimeProtocol__c = gmt2.time();
                system.debug('c.TimeProtocol__c -> ' + c.TimeProtocol__c);

                //Integer offsetdatetime = UserInfo.getTimezone().getOffset(gmtdatetime);
                //system.debug('offsetdatetime -> '+ offsetdatetime);
                //Datetime localDatedatetime = gmtdatetime.addSeconds(-offsetdatetime/1000);
                //system.debug('localDatedatetime -> ' +localDatedatetime);
                system.debug('gmt.getTime() -> '+ gmt.getTime());
                system.debug('gmt2.getTime() -> '+ gmt2.getTime());

                Datetime gmtdatetime =  Datetime.newInstance(gmt.getTime() + gmt2.getTime());
                system.debug('gmtdatetime -> '+ gmtdatetime);
                c.DateTimeProtocol__c   = gmtdatetime;

            } else {
                System.debug('In Failed');
                c.ErrorGed__c = resp.error.errorCode;
            }
            if(c.Last_Batch_Date_Time_GED__c == null) {
                System.debug('Last_Batch_Date_Time_GED__c is null');
                c.Last_Batch_Date_Time_GED__c = Datetime.now();
            }
            if(c.Status.equalsIgnoreCase(Label.Case_StatusClosed)) {
                System.debug('Case is closed');
                c.SkipValidation__c = true;
            }
        }
        DebugService.printLimits('CaseService', 'setCaseFieldsGEDCase', 'end');
    }

    public static Map<String, Case> getCaseIdCaseMap(List<Case> cases) {
        DebugService.printLimits('CaseService', 'getCaseIdCaseMap', 'start');
        Map<String, Case> caseIdCaseMap = new Map<String, Case>();
        for(Case c : cases) {
            caseIdCaseMap.put(c.Id, c);
        }
        DebugService.printLimits('CaseService', 'getCaseIdCaseMap', 'end');
        return caseIdCaseMap;
    }

    public static void processGEDCases(List<Case> scope) {
        DebugService.printLimits('CaseService', 'processGEDCases', 'start');
        DebugService.printList('CaseService', 'processGEDCases', 'scope', scope);
        List<Case> cases = GEDCaseCallout.gedCaseCallout(scope);
        DebugService.printList('CaseService', 'processGEDCases', 'cases', cases);
        CaseService.updateCases(cases, false);
        DebugService.printLimits('CaseService', 'processGEDCases', 'end');
    }

    public static void updateAllAttachmentsIntegratedGED(List<Case> cases) {
        DebugService.printLimits('CaseService', 'updateAllAttachmentsIntegratedGED', 'start');
        try {
            DebugService.printList('CaseService', 'updateAllAttachmentsIntegratedGED', 'cases', cases, true);

            if(!cases.isEmpty()) {
                System.debug('cases not empty');
                Set<Case> casesToUpdateAllIntegrationGEDTrue = new Set<Case>();
                Map<Case, List<ContentVersion>> caseCVsMap = ContentVersionService.getCaseCvsAllGEDMap(cases);

                for(Case c : caseCVsMap.keySet()) {
                    for(ContentVersion cv : caseCVsMap.get(c)) {
                        if(String.isBlank(cv.NumberGED__c)) {
                            System.debug('Entered number ged not populated ' + c + ' cv: ' + cv);
                            if(casesToUpdateAllIntegrationGEDTrue.contains(c)) {
                                System.debug('Contains case but will be removed: ' + c);
                                casesToUpdateAllIntegrationGEDTrue.remove(c);
                            }
                            break;
                        } else if(String.isNotBlank(cv.NumberGED__c)) {
                            System.debug('Entered number ged populated ' + c + ' cv: ' + cv);
                            casesToUpdateAllIntegrationGEDTrue.add(c);
                        }
                    }
                }

                DebugService.printList('CaseService', 'updateAllAttachmentsIntegratedGED', 'casesToUpdateAllIntegrationGEDTrue', new List<Case>(casesToUpdateAllIntegrationGEDTrue), true);
                if(!casesToUpdateAllIntegrationGEDTrue.isEmpty()) {
                    System.debug('In update');
                    for(Case c : casesToUpdateAllIntegrationGEDTrue) {
                        c.All_Content_Versions_Integrated_GED__c = true;
                    }
                    CaseService.updateCases(new List<Case>(casesToUpdateAllIntegrationGEDTrue), false);
                }
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('CaseService', 'updateAllAttachmentsIntegratedGED', e);
        }
        DebugService.printLimits('CaseService', 'updateAllAttachmentsIntegratedGED', 'end');
    }

    public static List<Case> processGEDUpdateAttachment(List<String> contentVersionIds) {
        DebugService.printLimits('CaseService', 'processGEDUpdateAttachment', 'start');
        List<Case> cases = new List<Case>();
        try {
            List<String> caseIds = ContentVersionService.getCaseIdsFromContentVersionIds(contentVersionIds);
            system.debug('processGEDUpdateAttachment - caseIds -> ' + caseIds);
            if(!caseIds.isEmpty()) {
                Boolean allAttachmentsIntegrated = checkAllAttachmentsIntegratedGED(caseIds);

                cases = CaseSelector.getCasesByCaseIds(caseIds);
                system.debug('processGEDUpdateAttachment - cases -> ' + cases);

                Boolean doUpdate = setAllContentVersionsIntegratedGED(cases, allAttachmentsIntegrated);

                if(doUpdate) {
                    DebugService.printLimits('CaseService', 'processGEDUpdateAttachment', 'return cases');
                    return cases;
                }
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('CaseService', 'processGEDUpdateAttachment', e);
        }
        DebugService.printLimits('CaseService', 'processGEDUpdateAttachment', 'end');
        return new List<Case>();
    }

    public static Boolean checkAllAttachmentsIntegratedGED(List<String> caseIds) {
        DebugService.printLimits('CaseService', 'checkAllAttachmentsIntegratedGED', 'start');
        List<String> contentVersionIds = new List<String>();

        for(ContentDocumentLink cdl : ContentDocumentLinkSelector.getContentDocumentLinksByCaseIds(caseIds)) {
            contentVersionIds.add(cdl.ContentDocument.LatestPublishedVersionId);
        }

        List<AggregateResult> contentVersionResults = ContentVersionSelector.getContentVersionsGEDIntegrationCountByIds(contentVersionIds);

        DebugService.printLimits('CaseService', 'checkAllAttachmentsIntegratedGED', 'end');
        return checkIfCaseNeedsUpdate(contentVersionResults);
    }

    public static Boolean checkIfCaseNeedsUpdate(List<AggregateResult> contentVersionResults) {
        DebugService.printLimits('CaseService', 'checkIfCaseNeedsUpdate', 'start');
        Boolean allAttachmentsIntegrated;

        for(AggregateResult result : contentVersionResults) {
            if(result.get(String.valueOf(ContentVersion.NumberGED__c)) == null) {
                System.debug('NumberOfAttachments not integrated ' + result.get('NumberOfAttachments'));
                allAttachmentsIntegrated = false;
                break;
            }
        }
        allAttachmentsIntegrated = (allAttachmentsIntegrated == null) ? true : allAttachmentsIntegrated;

        DebugService.printLimits('CaseService', 'checkIfCaseNeedsUpdate', 'end');
        return allAttachmentsIntegrated;
    }

    public static Boolean setAllContentVersionsIntegratedGED(List<Case> cases, Boolean allAttachmentsIntegrated) {
        DebugService.printLimits('CaseService', 'setAllContentVersionsIntegratedGED', 'start');
        Boolean doUpdate = false;

        system.debug('setAllContentVersionsIntegratedGED - cases -> ' + cases);
        for(Case c : cases) {
            system.debug('c -> ' + c);
            if(c.All_Content_Versions_Integrated_GED__c && allAttachmentsIntegrated == false) {
                c.All_Content_Versions_Integrated_GED__c = allAttachmentsIntegrated;
                doUpdate = true;
            } else if(c.All_Content_Versions_Integrated_GED__c == false && allAttachmentsIntegrated) {
                c.All_Content_Versions_Integrated_GED__c = allAttachmentsIntegrated;
                doUpdate = true;
            }
            if(c.All_Content_Versions_Integrated_GED__c == true && c.Status.equalsIgnoreCase(Label.Case_StatusClosed)) {
                c.SkipValidation__c = true;
            }
        }
        DebugService.printLimits('CaseService', 'setAllContentVersionsIntegratedGED', 'start');
        return doUpdate;
    }

    public static Boolean processGEDDeleteAttachments(List<String> caseIds) {
        DebugService.printLimits('CaseService', 'processGEDDeleteAttachments', 'start');
        System.debug('caseIds ' + caseIds.size());
        if(!caseIds.isEmpty()) {
            List<String> contentDocumentIds = new List<String>();

            for (ContentDocumentLink cdl : ContentDocumentLinkSelector.getContentDocumentLinksWithPDFCaseByCaseIds(caseIds)) {
                contentDocumentIds.add(cdl.ContentDocumentId);
            }

            System.debug('contentDocumentIds ' + contentDocumentIds.size());
            if(!contentDocumentIds.isEmpty()) {
                DebugService.printLimits('CaseService', 'processGEDDeleteAttachments', 'end');
                return ContentDocumentService.deleteContentDocuments(contentDocumentIds, false);
            }
        }
        DebugService.printLimits('CaseService', 'processGEDDeleteAttachments', 'end return');
        return false;
    }

    public static Map<String, Integer> getCaseIdCvCountNotIntegratedBroglaiccio(Map<String, List<ContentVersion>> caseIdCvsMap) {
        DebugService.printLimits('CaseService', 'getCaseIdCvsCountNotIntegratedBroglaiccio', 'start');
        Map<String, Integer> caseIdCvCount = new Map<String, Integer>();

        for(String cId : caseIdCvsMap.keySet()) {
            caseIdCvCount.put(cId, caseIdCvsMap.get(cId).size());
        }
        DebugService.printLimits('CaseService', 'getCaseIdCvsCountNotIntegratedBroglaiccio', 'end');
        return caseIdCvCount;
    }

    public static Map<Case, List<ContentVersion>> processBrogliaccioUpdateAttachment(List<String> contentVersionIds) {
        DebugService.printLimits('CaseService', 'processBrogliaccioUpdateAttachment', 'start');
        List<Case> cases = new List<Case>();
        Map<Case, List<ContentVersion>> caseCvsAllMap = new Map<Case, List<ContentVersion>>();

        List<String> caseIds = ContentVersionService.getCaseIdsFromContentVersionIds(contentVersionIds);
        DebugService.printList('CaseService', 'processBrogliaccioUpdateAttachment', 'caseIds', caseIds, true);

        if(!caseIds.isEmpty()) {
            cases = CaseSelector.getCasesBrogliaccioByCaseIds(caseIds);
            DebugService.printList('CaseService', 'processBrogliaccioUpdateAttachment', 'cases', cases, true);

            caseCvsAllMap = ContentVersionService.getCaseCvsAllBrogliaccioMap(cases);
            DebugService.printMap('CaseService', 'processBrogliaccioUpdateAttachment', 'caseCvsAllMap', new List<Case>(caseCvsAllMap.keySet()), caseCvsAllMap.values(), true);

            checkAllAttachmentsIntegratedBrogliaccio(caseCvsAllMap);
        }

        DebugService.printLimits('CaseService', 'processBrogliaccioUpdateAttachment', 'end');
        return caseCvsAllMap;
    }

    public static void checkAllAttachmentsIntegratedBrogliaccio(Map<Case, List<ContentVersion>> caseCvsMap) {
        DebugService.printLimits('CaseService', 'checkAllAttachmentsIntegratedBrogliaccio', 'start');
        Boolean doUpdate = false;

        for(Case c : caseCvsMap.keySet()) {
            for(ContentVersion cv : caseCvsMap.get(c)) {
                if(cv.ImgId__c == null && c.All_Content_Versions_Integrated__c) {
                    System.debug('Entered false ' + cv.Id);
                    c.All_Content_Versions_Integrated__c = false;
                    doUpdate = true;
                    break;
                } else if(cv.ImgId__c != null && !c.All_Content_Versions_Integrated__c) {
                    System.debug('Entered true ' + cv.Id + ' img id ' + cv.ImgId__c);
                    c.All_Content_Versions_Integrated__c = true;
                    doUpdate = true;
                }
            }

            System.debug('doUpdate ' + doUpdate);
            if(doUpdate) {
                System.debug('Updating the case ' + c.Id );
                c.SkipValidation__c = true;
            }
        }

        DebugService.printMap('CaseService', 'checkAllAttachmentsIntegratedBrogliaccio', 'caseCvsMap', new List<Case>(caseCvsMap.keySet()), caseCvsMap.values(), true);
        DebugService.printLimits('CaseService', 'checkAllAttachmentsIntegratedBrogliaccio', 'end');
    }

    public static void setCaseFieldsForBrogliaccioNew(BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapper) {
        DebugService.printLimits('CaseService', 'setCaseFieldsForBrogliaccioNew', 'start');
        Map<String, BrogliaccioBatch_Setting__c> queueCustomSettingMap = getBrogliaccioCustomSettingsAndQueue();
        String queueId = new List<String>(queueCustomSettingMap.keySet())[0];
        BrogliaccioBatch_Setting__c setting = queueCustomSettingMap.values();

        for(Case c : brogliaccioCaseListWrapper.cases) {
            if(String.isBlank(c.Sent_to_External__c) || !c.Sent_to_External__c.equalsIgnoreCase(setting.Sent_to_External__c)) {
                c.Sent_to_External__c = System.Label.NotSync;
            }

            if(!brogliaccioCaseListWrapper.isFromComponent && c.Last_Batch_Date_Time__c == null) {
                c.Last_Batch_Date_Time__c = Datetime.now();
            }

            if(c.ExternalSystemId_Brogliaccio__c != null && c.ExternalSystemId_Brogliaccio__c != '0') {
                if(!brogliaccioCaseListWrapper.isFromComponent) {
                    System.debug('Entered in isFromComponent');
                    if(brogliaccioCaseListWrapper.caseIdExternalStatusOldMap.get(c.Id) != null && !brogliaccioCaseListWrapper.caseIdExternalStatusOldMap.get(c.Id).equalsIgnoreCase(setting.Sent_to_External__c)) {
                        System.debug('Entered for caseIdExternalStatusOldMap');
                        c.is_from_batch__c = true;
                        c.Comment_User__c = String.isBlank(c.Comment_User__c) ? '' : c.Comment_User__c + '\n';
                        c.Comment_User__c += System.today().format() + ': ' + System.Label.Brogliaccio_PoliceLocaleCommentUser;
                    } else {
                        c.is_from_batch__c = false;
                    }
                } else {
                    System.debug('Entered in not isFromComponent');
                    c.Comment_User__c = String.isBlank(c.Comment_User__c) ? '' : c.Comment_User__c + '\n';
                    c.Comment_User__c += System.today().format() + ': ' + System.Label.Brogliaccio_PoliceLocaleCommentUser;
                }
                if(c.Status.equalsIgnoreCase(Label.Case_StatusClosed)) {
                    System.debug('case is closed');
                    c.SkipValidation__c = true;
                }
                c.Date_Time_Sent_To_Brogliaccio__c = System.now();
                c.OwnerId = queueId;
                c.Prior_Queue__c = c.Current_Queue__c;
                c.Current_Queue__c = setting.Group_Name__c;
                System.debug('caseIdCvCount ' + brogliaccioCaseListWrapper.caseIdCvCount);
                System.debug('caseIdCvCount get c ' + brogliaccioCaseListWrapper.caseIdCvCount.get(c.Id));
                if(brogliaccioCaseListWrapper.caseIdCvCount.get(c.Id) == 0) {
                    System.debug('entered case id count 0');
                    c.All_Content_Versions_Integrated__c = true;
                }
                c.Status = setting.Status__c;
                c.Sub_Status__c = setting.Sub_Status__c;
                c.Sent_to_External__c = setting.Sent_to_External__c;
                c.Closed_Reason__c = setting.Closed_Reason__c;
                c.Brogliaccio_N_Attachment__c = brogliaccioCaseListWrapper.caseIdCvCount.get(c.Id);
            }
        }
        DebugService.printList('CaseService', 'setCaseFieldsForBrogliaccioNew', 'brogliaccioCaseListWrapper.cases', brogliaccioCaseListWrapper.cases, true);
        DebugService.printLimits('CaseService', 'setCaseFieldsForBrogliaccioNew', 'end');
    }
}