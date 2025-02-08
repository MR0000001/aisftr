/*
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 07/10/2020
* @description XC_LCC114_MassiveAssignmentWorkType_U – Util Class for XC_LCC114_MassiveAssignmentWorkType
* @history
* Modified by Nicolo' Fodera, Lorenzo Evangelisti, Baba Goudiaby on 07.2022 - Refactoring
*/

public without sharing class XC_LCC114_MassiveAssignmentWorkType_U {



    /* Nicolò Foderà - nicolo.fodera@enel.com Added [start]*/
    /**
     * @author Nicolò Foderà - nicolo.fodera@enel.com
     * @date Creation 30/05/2022
     * @description Queueable to add Partner Coverages && Service Resource Coverages
    */
    public class XC_Queueable_AddPartnerCoveragesAndSRCoverages implements Queueable {
        private List<Object> comboListInput;
        private String partnerId;
        private Integer scopeSize = 200;
        private String legalEntity;
        private String logId;
        private XC_MassiveAssignWorkTypeOperationStatus__c log;

        /**
         * @author Nicolò Foderà - nicolo.fodera@enel.com
         * @date Creation 30/05/2022
         * @description Constructor with 4 params
         * @param comboListInput - List<Object>
         * @param partnerId - String
         * @param legalEntity - String
         * @param scopeSize - Integer
         * @param logId - String
        */
        public XC_Queueable_AddPartnerCoveragesAndSRCoverages(List<Object> comboListInput, String partnerId, String legalEntity, Integer scopeSize, String logId) {
            this.comboListInput = comboListInput;
            this.partnerId = partnerId;
            this.scopeSize = scopeSize;
            this.legalEntity = legalEntity;
            this.logId = logId;

        }

        /**
         * @author Nicolò Foderà - nicolo.fodera@enel.com
         * @date Creation 30/05/2022
         * @description Execute method to add Partner Coverages && Service Resource Coverages
        */
        public void execute(QueueableContext context) {

            try {

                this.log = getStatusLogById(this.logId);
                fillStatusLogQueueableJobId(this.log, context);
				
				fillActiveServiceResourceNumbOnStatusLog(this.log, this.partnerId, null);

                /*SCOPE ***************************** START*/
                //Define comboList scope of this thread according to this.scopeSize [comboListToProcessNow]
                List<Object> comboListToProcessNow = new List<Object>();
                List<Object> comboListToProcessLater = new List<Object>();
                for (Object obj : this.comboListInput) {
                    if (comboListToProcessNow.size() < this.scopeSize) { 
                        //NicoloFodera 20220715 Added [start]
                        Map<Object, Object> comboObject = (Map<Object, Object>)obj; 
                        comboObject.put('ZipCode', normalizeZipCode((String)comboObject.get('ZipCode')));
                        //NicoloFodera 20220715 Added [end]
                        comboListToProcessNow.add((Object)comboObject);
                    } else {
                        comboListToProcessLater.add(obj);
                    }
                }
                /*SCOPE ***************************** END*/

                List<XC_PartnerCoverage__c> listPcToProcess = getPartnerCoveragesFromComboList(comboListToProcessNow, this.partnerId, this.legalEntity);


                /*PARTNER COVERAGES INSERT ***************************** START*/
                Map<String,XC_PartnerCoverage__c> mapPcProcessedOk = processAndInsertPartnerCoverages(listPcToProcess, this.log);
                /*PARTNER COVERAGES INSERT ***************************** END*/

                /*SERVICE RESOURCE COVERAGES INSERT ***************************** START*/
                processAndInsertServiceResourceCoverages(mapPcProcessedOk.values(), this.log, this.partnerId);
                /*SERVICE RESOURCE COVERAGES INSERT ***************************** END*/

                /*UPDATE LOG ***************************** START*/
                if (comboListToProcessLater.size() == 0) {
                    fillFinalStatusLog(this.log);
                }
                System.debug('Log to be updated: ' + this.log);
                XC_UTIL_Sobject.updateRecord(this.log);
                /*UPDATE LOG ***************************** END*/

                /*NEXT QUEUEABLE ***************************** START*/
                if (comboListToProcessLater.size() != 0) {
                    System.enqueueJob(new XC_Queueable_AddPartnerCoveragesAndSRCoverages(comboListToProcessLater, this.partnerId, this.legalEntity, this.scopeSize, this.log.Id));
                }
                /*NEXT QUEUEABLE ***************************** END*/

            } catch (Exception e) {
                if (this.log != null) {
                    saveStatusLogException(this.log, e);
                }
            }
        }
    }
    


    /*NicoloFodera Added 20220707 - EXSFDCSL-290 extend max limit  [start]*/
    /**
     * @author Nicolò Foderà - nicolo.fodera@enel.com
     * @date Creation 07/07/2022
     * @description Queueable to remove Partner Coverages && Service Resource Coverages
    */
    public class XC_Queueable_RemovePartnerCoveragesAndSRCoverages implements Queueable {
        private Set<Id> partnerCoverageIdsInput;
        private String partnerId;
        private Integer scopeSize = 200;
        private String legalEntity;
        private String logId;

        private XC_MassiveAssignWorkTypeOperationStatus__c log;

        /**
         * @author Nicolò Foderà - nicolo.fodera@enel.com
         * @date Creation 07/07/2022
         * @description Constructor with 4 params
         * @param partnerCoverageIdsInput - Set<Id>
         * @param partnerId - String
         * @param legalEntity - String
         * @param scopeSize - Integer
         * @param logId - String
        */
        public XC_Queueable_RemovePartnerCoveragesAndSRCoverages(Set<Id> partnerCoverageIdsInput, String partnerId, String legalEntity, Integer scopeSize, String logId) {
            this.partnerCoverageIdsInput = partnerCoverageIdsInput;
            this.partnerId = partnerId;
            this.scopeSize = scopeSize;
            this.legalEntity = legalEntity;
            this.logId = logId;
        }


        /**
         * @author Nicolò Foderà - nicolo.fodera@enel.com
         * @date Creation 07/07/2022
         * @description Execute method to remove Partner Coverages && Service Resource Coverages
        */
        public void execute(QueueableContext context) {

            try {
                this.log = getStatusLogById(this.logId);
                fillStatusLogQueueableJobId(this.log, context);
				
				fillActiveServiceResourceNumbOnStatusLog(this.log, this.partnerId, null);

                /*SCOPE ***************************** START*/
                //Define partnerCoverage ids scope of this thread according to this.scopeSize [partnerCoverageIdsToProcessNow]
                Set<Id> partnerCoverageIdsToProcessNow = new Set<Id>();
                Set<Id> partnerCoverageIdsToProcessLater = new Set<Id>();
                for (Id obj : this.partnerCoverageIdsInput) {
                    if (partnerCoverageIdsToProcessNow.size() < this.scopeSize) {
                        partnerCoverageIdsToProcessNow.add(obj);
                    } else {
                        partnerCoverageIdsToProcessLater.add(obj);
                    }
                }
                /*SCOPE ***************************** END*/

                List<XC_PartnerCoverage__c> partnerCoveragesToProcessNow = getPartnerCoveragesByIds(partnerCoverageIdsToProcessNow);


                /*PARTNER COVERAGES DELETE ***************************** START*/
                List<XC_PartnerCoverage__c> partnerCoverageProcessedOK = processAndDeletePartnerCoverages(partnerCoveragesToProcessNow, this.log);
                /*PARTNER COVERAGES DELETE ***************************** END*/

                /*SERVICE RESOURCE COVERAGES DELETE ********* START*/
                processAndDeleteServiceResourceCoverages(partnerCoverageProcessedOK, this.log, this.partnerId);
                /*SERVICE RESOURCE COVERAGES DELETE ********** END*/

                /*UPDATE LOG ***************************** START*/
                if (partnerCoverageIdsToProcessLater.size() == 0) {
                    fillFinalStatusLog(this.log);
                }
                XC_UTIL_Sobject.updateRecord(this.log);
                /*UPDATE LOG ***************************** END*/

                /*NEXT QUEUEABLE ***************************** START*/
                if (partnerCoverageIdsToProcessLater.size() != 0) {
                    System.enqueueJob(new XC_Queueable_RemovePartnerCoveragesAndSRCoverages(partnerCoverageIdsToProcessLater, this.partnerId, this.legalEntity, this.scopeSize, this.log.Id));
                }
                /*NEXT QUEUEABLE ***************************** END*/

            } catch (Exception e) {
                if (this.log != null) {
                    saveStatusLogException(this.log, e);
                }
            }
        }
    }
    


    /*NicoloFodera Added 20220713 - EXSFDCSL-290 extend max limit  [start]*/
    /**
     * @author Nicolò Foderà - nicolo.fodera@enel.com
     * @date Creation 13/07/2022
     * @description Queueable to transfer Partner Coverages && Service Resource Coverages
    */
    public class XC_Queueable_TransferPartnerCoveragesAndSRCoverages implements Queueable {
        private Set<Id> partnerCoverageIdsInput;
        private String partnerId;
        private String destinationPartnerId;
        private Integer scopeSize = 200;
        private String legalEntity;
        private String logId;

        private XC_MassiveAssignWorkTypeOperationStatus__c log;

        /**
         * @author Nicolò Foderà - nicolo.fodera@enel.com
         * @date Creation 13/07/2022
         * @description Constructor with 5 params
         * @param partnerCoverageIdsInput - Set<Id>
         * @param partnerId - String
         * @param destinationPartnerId - String
         * @param legalEntity - String
         * @param scopeSize - Integer
         * @param logId - String
        */
        public XC_Queueable_TransferPartnerCoveragesAndSRCoverages(Set<Id> partnerCoverageIdsInput, String partnerId, String destinationPartnerId, String legalEntity, Integer scopeSize, String logId) {
            this.partnerCoverageIdsInput = partnerCoverageIdsInput;
            this.partnerId = partnerId;
            this.destinationPartnerId = destinationPartnerId;
            this.scopeSize = scopeSize;
            this.legalEntity = legalEntity;
            this.logId = logId;
        }

        /**
         * @author Nicolò Foderà - nicolo.fodera@enel.com
         * @date Creation 13/07/2022
         * @description Execute method to transfer Partner Coverages && Service Resource Coverages
        */
        public void execute(QueueableContext context) {
            try {
                this.log = getStatusLogById(this.logId);
                fillStatusLogQueueableJobId(this.log, context);
				
				fillActiveServiceResourceNumbOnStatusLog(this.log, this.partnerId, this.destinationPartnerId);

                /*SCOPE ***************************** START*/
                //Define partnerCoverage ids scope of this thread according to this.scopeSize [partnerCoverageIdsToProcessNow]
                Set<Id> partnerCoverageIdsToProcessNow = new Set<Id>();
                Set<Id> partnerCoverageIdsToProcessLater = new Set<Id>();
                for (Id obj : this.partnerCoverageIdsInput) {
                    if (partnerCoverageIdsToProcessNow.size() < this.scopeSize) {
                        partnerCoverageIdsToProcessNow.add(obj);
                    } else {
                        partnerCoverageIdsToProcessLater.add(obj);
                    }
                }
                /*SCOPE ***************************** END*/


                List<XC_PartnerCoverage__c> sourcePartnerCoverages = getPartnerCoveragesByIds(partnerCoverageIdsToProcessNow);

                List<Object> destinationPartnerComboList = getComboListFromPartnerCoverages(sourcePartnerCoverages);
                List<XC_PartnerCoverage__c> destinationPartnerCoverages = getPartnerCoveragesFromComboList(destinationPartnerComboList, this.destinationPartnerId, this.legalEntity);

                /*PARTNER COVERAGES INSERT on DESTINATION PARTNER ***************************** START*/
                Map<String,XC_PartnerCoverage__c> mapPcInsertedSuccessfully = processAndInsertPartnerCoverages(destinationPartnerCoverages, this.log);
                /*PARTNER COVERAGES INSERT on DESTINATION PARTNER***************************** END*/

                /*SERVICE RESOURCE COVERAGES INSERT on DESTINATION PARTNER***************************** START*/
                processAndInsertServiceResourceCoverages(mapPcInsertedSuccessfully.values(), this.log, this.destinationPartnerId);
                /*SERVICE RESOURCE COVERAGES INSERT on DESTINATION PARTNER***************************** END*/

                List<XC_PartnerCoverage__c> sourcePartnerCoveragesToBeDeleted = new List<XC_PartnerCoverage__c>();
                for (XC_PartnerCoverage__c partnerCoverage : sourcePartnerCoverages){
                    if (mapPcInsertedSuccessfully.containsKey(partnerCoverage.XC_ExternalId__c)){
                        sourcePartnerCoveragesToBeDeleted.add(partnerCoverage);
                    }else {
                        this.log.XC_ProcessedPartnerCoveragesKO__c++;
                    }
                }
                /*PARTNER COVERAGES DELETE on SOURCE PARTNER ***************************** START*/
                List<XC_PartnerCoverage__c> partnerCoverageDeletedSuccessfully = processAndDeletePartnerCoverages(sourcePartnerCoveragesToBeDeleted, this.log);
                /*PARTNER COVERAGES DELETE on SOURCE PARTNER ***************************** END*/
            
                /*SERVICE RESOURCE COVERAGES DELETE on SOURCE PARTNER ********* START*/
                processAndDeleteServiceResourceCoverages(partnerCoverageDeletedSuccessfully, this.log, this.partnerId);
                /*SERVICE RESOURCE COVERAGES DELETE on SOURCE PARTNER ********** END*/

                /*UPDATE LOG ***************************** START*/
                if (partnerCoverageIdsToProcessLater.size() == 0) {
                    fillFinalStatusLog(this.log);
                }
                System.debug('Log to be updated: ' + this.log);
                XC_UTIL_Sobject.updateRecord(this.log);
                /*UPDATE LOG ***************************** END*/

                /*NEXT QUEUEABLE ***************************** START*/
                if (partnerCoverageIdsToProcessLater.size() != 0) {
                    System.enqueueJob(new XC_Queueable_TransferPartnerCoveragesAndSRCoverages(partnerCoverageIdsToProcessLater, this.partnerId, this.destinationPartnerId, this.legalEntity, this.scopeSize, this.log.Id));
                }
                /*NEXT QUEUEABLE ***************************** END*/

            } catch (Exception e) {
                if (this.log != null) {
                    saveStatusLogException(this.log,e);
                }

            }
        }
    }


    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 07/10/2020
     * @description Queueable to insert Service Resource Coverage
    */
    public class XC_Queueable_CreateSRC implements Queueable {

        private List<XC_ServiceResourceCoverage__c> listCoveragesToInsert = new List<XC_ServiceResourceCoverage__c>();

        /**
         * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
         * @date Creation 07/10/2020
         * @description Constructor with params
         * @param listInput - List<XC_ServiceResourceCoverage__c>
        */
        public XC_Queueable_CreateSRC(List<XC_ServiceResourceCoverage__c> listInput) {
            this.listCoveragesToInsert = listInput;
        }

        /**
         * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
         * @date Creation 07/10/2020
         * @description Constructor without params
        */
        public XC_Queueable_CreateSRC() {
            this.listCoveragesToInsert = new List<XC_ServiceResourceCoverage__c>();
        }

        /**
         * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
         * @date Creation 07/10/2020
         * @description Execute method to create SRC
        */
        public void execute(QueueableContext context) {
            XC_UTIL_Sobject.insertListRecords(this.listCoveragesToInsert, false);
        }

    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 13/10/2020
     * @description Method to create SRC from PC
     * @param listPcs - List<XC_PartnerCoverage__c>
     * @param accountId - String
     * @return List Service Resource Coverages
    */
    public static List<XC_ServiceResourceCoverage__c> createSRCs(List<XC_PartnerCoverage__c> listPcs, String accountId) {
        List<ServiceResource> listSr = getActiveServiceResourceByAccountId(accountId);
        List<XC_ServiceResourceCoverage__c> listSRC = new List<XC_ServiceResourceCoverage__c>();
        for (XC_PartnerCoverage__c pc : listPcs) {
            for (ServiceResource sr : listSr) {
                XC_ServiceResourceCoverage__c src = new XC_ServiceResourceCoverage__c();
                src.XC_ServiceResourceId__c = sr.Id;
                src.XC_ZipCodeWorkTypeId__c = pc.XC_ZipCodeWorkType__c;
                src.XC_WorkTypeId__c = pc.XC_WorkType__c;
                src.XC_InheritedFromParent__c = true;
                src.XC_ZipCodeText__c = pc.XC_ZipCode__c;
                src.XC_WorkTypeId__c = pc.XC_WorkType__c;
                src.XC_ExternalIdForDuplication__c = sr.Id + '_' + pc.XC_ZipCode__c + '_' + pc.XC_WorkType__c;
                listSRC.add(src);
            }
        }
        return listSRC;
    }

    /**
     * @author Baba Goudiaby - (baba.goudiaby@webresults.it)
     * @since 08/07/2022
     * @description Generate an status log massive assignment for different operations
     * @param operation - Type of operation (Add, remove)
     * @param status -  initial status for the log
     * @param accountId - account that should be related
     * @param destinationAccountId - destination account for transfer operation
     * @param inputSize - number of elements to be processed
     * @return Status log object XC_MassiveAssignWorkTypeOperationStatus__c
     */
    public static XC_MassiveAssignWorkTypeOperationStatus__c initStatusLog(String operation, String status, String accountId, String destinationAccountId, Integer inputSize) {
        // Initialize status log with some default values
        XC_MassiveAssignWorkTypeOperationStatus__c statusLog = new XC_MassiveAssignWorkTypeOperationStatus__c();
        statusLog.XC_Operation__c = operation;
        statusLog.XC_Status__c = status;
        statusLog.XC_InputCoverages__c = inputSize;
        statusLog.XC_ProcessedPartnerCoveragesKO__c = 0;
        statusLog.XC_PartnerCoveragesDeleted__c = 0;
        statusLog.XC_ProcessedServiceResourceCoveragesKO__c = 0;
        statusLog.XC_PartnerCoveragesInserted__c = 0;
        statusLog.XC_PartnerCoveragesAlreadyExisting__c = 0;
        statusLog.XC_ServiceResCoveragesInserted__c = 0;
        statusLog.XC_ServiceResCoveragesAlreadyExisting__c = 0;
        statusLog.XC_ServiceResCoveragesDeleted__c = 0;
        statusLog.XC_Account__c = accountId;
        statusLog.XC_DestinationAccount__c = destinationAccountId; // NicoloFodera 20220715 Changed -> uncommented
        XC_UTIL_Sobject.insertRecord(statusLog);

        return statusLog;
    }


    /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 13/07/2022
     * @description Return the XC_MassiveAssignWorkTypeOperationStatus__c record queried by id
     * @param statusLogId -  initial status for the log
     * @return Status log object XC_MassiveAssignWorkTypeOperationStatus__c
     */
    public static XC_MassiveAssignWorkTypeOperationStatus__c getStatusLogById(Id statusLogId) {
        return [SELECT Id, XC_JobId__c, XC_Operation__c, XC_Status__c,
                        XC_InputCoverages__c, XC_ProcessedPartnerCoveragesKO__c,
                        XC_PartnerCoveragesInserted__c, XC_ProcessedServiceResourceCoveragesKO__c,
                        XC_ServiceResCoveragesInserted__c, XC_PartnerCoveragesAlreadyExisting__c,
                        XC_ServiceResCoveragesAlreadyExisting__c,XC_PartnerCoveragesDeleted__c,
                        XC_ServiceResCoveragesDeleted__c, XC_ActiveServiceResourcesOnAccount__c,
                        XC_ActiveServiceResourcesOnDestAccount__c
                FROM XC_MassiveAssignWorkTypeOperationStatus__c
                WHERE Id = :statusLogId
        ];
    }

    /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 13/07/2022
     * @description Fill the status log with queueable jobId
     * @param statusLog -  status log record
     * @param context -  queueable context
     */
    public static void fillStatusLogQueueableJobId(XC_MassiveAssignWorkTypeOperationStatus__c statusLog, QueueableContext context) {
        if (statusLog != null && statusLog.XC_JobId__c == null) {
            statusLog.XC_JobId__c = context.getJobId();
        }
    }

    /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 13/07/2022
     * @description Return comboList from partnerCoverages
     * @param partnerCoverages -  List<XC_PartnerCoverage__c> partnerCoverages
     * @return list of combo - combination WorkType / ZipCode
     */
    public static List<Object> getComboListFromPartnerCoverages(List<XC_PartnerCoverage__c> partnerCoverages) {

        List<Map<Object, Object>> comboList = new List<Map<Object, Object>>();
        for (XC_PartnerCoverage__c pc : partnerCoverages) {
            Map<Object, Object> comboObject = new Map<Object, Object>();
            comboObject.put('WorkType', pc.XC_WorkType__c);
            comboObject.put('ZipCode', pc.XC_ZipCode__c);
            comboList.add(comboObject);
        }
        return comboList;
    }

    /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 13/07/2022
     * @description Return partnerCoverages from comboList
     * @param comboListToProcessNow - comboList
     * @param partnerId - Partner Account selected
     * @param legalEntity - Legal Entity
     * @return List of Partner Coverages from combo WorkType / ZipCode
     */
    public static List<XC_PartnerCoverage__c> getPartnerCoveragesFromComboList(List<Object> comboListToProcessNow, String partnerId, String legalEntity) {
        //PC1] Define partner coverages to be processed [listPcToProcess]
        List<XC_PartnerCoverage__c> listPcToProcess = new List<XC_PartnerCoverage__c> ();
        Map<Id, WorkType> mapWorkTypeToQueried = new Map<Id, WorkType>([
                SELECT Id, Name, XC_Segment__c
                FROM WorkType
                WHERE XC_LegalEntity__c = :legalEntity
        ]);
        for (Object obj : comboListToProcessNow) {
            Map<Object, Object> mapString = (Map<Object, Object>) obj;
            String workType = (String) mapString.get('WorkType');
            String zipCode = (String) mapString.get('ZipCode');
            String externalId = partnerId + '_' + zipCode + '_' + workType;
            listPcToProcess.add(
                    new XC_PartnerCoverage__c(
                            XC_Account__c = partnerId,
                            XC_WorkType__c = workType,
                            XC_ZipCode__c = zipCode,
                            XC_WorkTypeLabel__c = mapWorkTypeToQueried.get(workType).Name,
                            XC_ExternalIdForDuplication__c = externalId,
                            XC_BlockResourceCoverageCreation__c = true
                    )
            );
        }
        return listPcToProcess;
    }

    /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 13/07/2022
     * @description Add Operation / Insert partnerCoverages and update status log, return the number of insert errors
     * @param listPcToProcess List Partner Coverage to process
     * @param log Log Status
     * @return Map of Partner Coverages
     */
    public static Map<String,XC_PartnerCoverage__c> processAndInsertPartnerCoverages(List<XC_PartnerCoverage__c> listPcToProcess, XC_MassiveAssignWorkTypeOperationStatus__c log) {
        Map<String,XC_PartnerCoverage__c> mapPcProcessedOk = new Map<String,XC_PartnerCoverage__c> ();

        //PC2]Define partner coverages to be inserted [listPcToInsert] (discard already existing partner coverages)
        Set<String> setPcToProcessExternalId = new Set<String>();
        for (XC_PartnerCoverage__c pc : listPcToProcess) {
            setPcToProcessExternalId.add(pc.XC_ExternalIdForDuplication__c);
        }

        List<XC_PartnerCoverage__c> listPcToInsert = new List<XC_PartnerCoverage__c>();
        List<XC_PartnerCoverage__c> listExistingPc = new List<XC_PartnerCoverage__c>([
                SELECT Id, XC_ExternalIdForDuplication__c
                FROM XC_PartnerCoverage__c
                WHERE XC_ExternalIdForDuplication__c IN :setPcToProcessExternalId
        ]);

        Set<String> setExistingExtIds = new Set<String>();
        for (XC_PartnerCoverage__c pc : listExistingPc) {
            setExistingExtIds.add(pc.XC_ExternalIdForDuplication__c);
        }

        for (XC_PartnerCoverage__c pc : listPcToProcess) {
            if (!setExistingExtIds.contains(pc.XC_ExternalIdForDuplication__c)) {
                setExistingExtIds.add(pc.XC_ExternalIdForDuplication__c);
                listPcToInsert.add(pc);
            } else {
                log.XC_PartnerCoveragesAlreadyExisting__c++;
                mapPcProcessedOk.put(pc.XC_ZipCode__c+'_'+pc.XC_WorkType__c,pc);
            }
        }

        //PC3] Insert insertListRecords (we need to manage AllOrNone mode)
        System.debug(LoggingLevel.FINER, 'List to insert Pc Queue' + listPcToInsert.size());
        if (!listPcToInsert.isEmpty()) { // avoid false increment of XC_ProcessedPartnerCoveragesOK__c
            List<XC_UTIL_Sobject.WrapperResult> listPcInserted = XC_UTIL_Sobject.insertListRecords(listPcToInsert, false);
            List<XC_ExceptionLog__c> exceptionLogsPc = new List<XC_ExceptionLog__c>();
            for (XC_UTIL_Sobject.WrapperResult wr : listPcInserted) {
                if (wr.success) {
                    log.XC_PartnerCoveragesInserted__c++;// +1 inserted for every coverage inserted correctly
                } else {
                    log.XC_ProcessedPartnerCoveragesKO__c++; // +1 KO for every coverage not inserted
                    exceptionLogsPc.add(new XC_ExceptionLog__c(XC_MassiveAssignWorkTypeOperationStatus__c = log.Id, XC_MessageException__c = wr.errorMessage, XC_RecordId__c = wr.errorObjectId));
                }
            }
            if (!exceptionLogsPc.isEmpty()) {
                XC_UTIL_Sobject.insertListRecords(exceptionLogsPc, false);
            }
            for (XC_PartnerCoverage__c pc : listPcToInsert) {
                if (String.isNotBlank(pc?.Id)) {
                    mapPcProcessedOk.put(pc.XC_ZipCode__c+'_'+pc.XC_WorkType__c,pc);
                }
            }
        }
        return mapPcProcessedOk;
    }

    /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 13/07/2022
     * @description Insert serviceResourceCoverages and update status log
     */
    public static void processAndInsertServiceResourceCoverages(List<XC_PartnerCoverage__c> listPcToProcess, XC_MassiveAssignWorkTypeOperationStatus__c log, String partnerId) {
        //SRC1] Define service resource coverages to be processed [listSrcToProcess] starting from listPcToProcess
        List<XC_ServiceResourceCoverage__c> listSrcToProcess = XC_LCC114_MassiveAssignmentWorkType_U.createSRCs(listPcToProcess, partnerId);
        Set<String> setSrcToProcessExternalId = new Set<String>();

        for (XC_ServiceResourceCoverage__c src : listSrcToProcess) {
            setSrcToProcessExternalId.add(src.XC_ExternalIdForDuplication__c);
        }

        //SRC2] Define SRCs External Ids that already exist
        //SRC2] Define service resource coverages to be inserted [listSrcToInsert] (discard already existing service resource coverages)
        Set<String> setExistingSrcExtIds = new Set<String>();
        List<XC_ServiceResourceCoverage__c> listSrcToInsert = new List<XC_ServiceResourceCoverage__c>();
        List<XC_ServiceResourceCoverage__c> listExistingSrc = getServiceResourceCoveragesByExternalIds(setSrcToProcessExternalId);

        for (XC_ServiceResourceCoverage__c src : listExistingSrc) {
            setExistingSrcExtIds.add(src.XC_ExternalIdForDuplication__c);
        }

        for (XC_ServiceResourceCoverage__c src : listSrcToProcess) {
            if (!setExistingSrcExtIds.contains(src.XC_ExternalIdForDuplication__c)) {
                setExistingSrcExtIds.add(src.XC_ExternalIdForDuplication__c);
                listSrcToInsert.add(src);
            } else {
                log.XC_ServiceResCoveragesAlreadyExisting__c++;
            }
        }

        //SRC3] Insert SRCs
        System.debug(LoggingLevel.FINER, 'List to insert Src Queue' + listSrcToInsert.size());
        if (!listSrcToInsert.isEmpty()) { // avoid false increment of XC_ProcessedServiceResourceCoveragesOK__c
            List<XC_UTIL_Sobject.WrapperResult> listSrcInserted = XC_UTIL_Sobject.insertListRecords(listSrcToInsert, false);
            List<XC_ExceptionLog__c> exceptionLogsSrc = new List<XC_ExceptionLog__c>();
            for (XC_UTIL_Sobject.WrapperResult wr : listSrcInserted) {
                if (wr.success) {
                    log.XC_ServiceResCoveragesInserted__c++; // +1 inserted for every coverage inserted correctly
                } else {
                    log.XC_ProcessedServiceResourceCoveragesKO__c++; // +1 KO for every coverage not inserted
                    exceptionLogsSrc.add(new XC_ExceptionLog__c(XC_MassiveAssignWorkTypeOperationStatus__c = log.Id, XC_MessageException__c = wr.errorMessage, XC_RecordId__c = wr.errorObjectId));
                }
            }
            if (!exceptionLogsSrc.isEmpty()) {
                XC_UTIL_Sobject.insertListRecords(exceptionLogsSrc, false);
            }
        }
    }

    /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 13/07/2022
     * @description Delete partnerCoverages and update status log
     * @return List of Partner coverages
     */
    public static List<XC_PartnerCoverage__c> processAndDeletePartnerCoverages(List<XC_PartnerCoverage__c> partnerCoveragesToProcessNow, XC_MassiveAssignWorkTypeOperationStatus__c log) {
        Map<Id, XC_PartnerCoverage__c> mapIdPartnerCoverage = new Map<Id, XC_PartnerCoverage__c>();
        List<XC_PartnerCoverage__c> listPcProcessedOk = new List<XC_PartnerCoverage__c>();

        //PC1] Update partner coverages XC_BlockResourceCoverageCreation__c
        for (XC_PartnerCoverage__c pc : partnerCoveragesToProcessNow) {
            mapIdPartnerCoverage.put(pc.Id, pc);
            pc.XC_BlockResourceCoverageCreation__c = true;
        }

        XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        List<XC_UTIL_Sobject.WrapperResult> listResultWrapper = XC_UTIL_Sobject.updateListRecords(partnerCoveragesToProcessNow, false);
        XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);

        //PC2] Delete partner coverages XC_BlockResourceCoverageCreation__c
        System.debug(LoggingLevel.FINER, 'List to delete Pc Queue' + partnerCoveragesToProcessNow.size());
        if (!partnerCoveragesToProcessNow.isEmpty()) { // avoid false increment
            listResultWrapper = XC_UTIL_Sobject.deleteListRecords(partnerCoveragesToProcessNow, false);
            List<XC_ExceptionLog__c> exceptionLogsPc = new List<XC_ExceptionLog__c>();
            for (XC_UTIL_Sobject.WrapperResult wr : listResultWrapper) {
                if (wr.success) {
                    log.XC_PartnerCoveragesDeleted__c++;// +1 inserted for every coverage deleted correctly
                    if (mapIdPartnerCoverage.get(wr.recordId) != null) {
                        listPcProcessedOk.add(mapIdPartnerCoverage.get(wr.recordId));
                    }
                } else {
                    log.XC_ProcessedPartnerCoveragesKO__c++; // +1 KO for every coverage not deleted
                    exceptionLogsPc.add(new XC_ExceptionLog__c(XC_MassiveAssignWorkTypeOperationStatus__c = log.Id, XC_MessageException__c = wr.errorMessage, XC_RecordId__c = wr.errorObjectId));
                }
            }
            if (!exceptionLogsPc.isEmpty()) {
                XC_UTIL_Sobject.insertListRecords(exceptionLogsPc, false);
            }
        }
        return listPcProcessedOk;
    }

    /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 13/07/2022
     * @description Delete serviceResourceCoverages and update status log
     */
    public static void processAndDeleteServiceResourceCoverages(List<XC_PartnerCoverage__c> partnerCoveragesToProcessNow, XC_MassiveAssignWorkTypeOperationStatus__c log, String partnerId) {
        //RETRIEVE SRCs RELATED TO ACTIVE USERS AND DELETE THEM
        List<ServiceResource> listSr = getActiveServiceResourceByAccountId(partnerId);

        Set<String> listExternalIdSrc = new Set<String>();
        for (XC_PartnerCoverage__c pc : partnerCoveragesToProcessNow) {
            for (ServiceResource sr : listSr) {
                listExternalIdSrc.add(sr.Id + '_' + pc.XC_ZipCode__c + '_' + pc.XC_WorkType__c);
            }
        }
        List<XC_ServiceResourceCoverage__c> listSrcToDelete = getServiceResourceCoveragesByExternalIds(listExternalIdSrc);
        System.debug(LoggingLevel.FINER, 'List to delete Src Queue' + listSrcToDelete.size());
        if (!listSrcToDelete.isEmpty()) {
            List<XC_UTIL_Sobject.WrapperResult> listResultWrapper = XC_UTIL_Sobject.deleteListRecords(listSrcToDelete);
            List<XC_ExceptionLog__c> exceptionLogsSrc = new List<XC_ExceptionLog__c>();
            for (XC_UTIL_Sobject.WrapperResult wr : listResultWrapper) {
                if (wr.success) {
                    log.XC_ServiceResCoveragesDeleted__c++;// +1 inserted for every coverage deleted correctly
                } else {
                    log.XC_ProcessedServiceResourceCoveragesKO__c++; // +1 KO for every coverage not deleted
                    exceptionLogsSrc.add(new XC_ExceptionLog__c(XC_MassiveAssignWorkTypeOperationStatus__c = log.Id, XC_MessageException__c = wr.errorMessage, XC_RecordId__c = wr.errorObjectId));
                }
            }
            if (!exceptionLogsSrc.isEmpty()) {
                XC_UTIL_Sobject.insertListRecords(exceptionLogsSrc, false);
            }
        }
    }

    /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 13/07/2022
     * @description Retrieve partnerCoverages by ids
     * @param partnerCoverageIdsToProcessNow Set of Ids Partner Coverages to process
     * @return List of Partner coverages
     */
    public static List<XC_PartnerCoverage__c> getPartnerCoveragesByIds(Set<Id> partnerCoverageIdsToProcessNow) {
        return new List<XC_PartnerCoverage__c>([
                SELECT Id, XC_BlockResourceCoverageCreation__c, XC_WorkType__c, XC_WorkTypeLabel__c, XC_ZipCode__c, XC_ExternalId__c
                FROM XC_PartnerCoverage__c
                WHERE Id IN :partnerCoverageIdsToProcessNow
        ]);
    }

    /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 13/07/2022
     * @description Fill status log with final info
     */
    public static void fillFinalStatusLog(XC_MassiveAssignWorkTypeOperationStatus__c log) {
        if (log.XC_ProcessedPartnerCoveragesKO__c + log.XC_ProcessedServiceResourceCoveragesKO__c == 0) {
            log.XC_Status__c = 'Completed';
            log.XC_Message__c = 'Operation successfully completed';
        } else {
            log.XC_Status__c = 'Completed with errors';
            log.XC_Message__c = 'Operation completed, but some coverages were affected by error. Please, check Exception Logs';
        }
    }

    /**
     * @author Baba Goudiaby - (baba.goudiaby@webresults.it)
     * @since 14/07/2022
     * @description Update log with exception
     */
    public static void saveStatusLogException(XC_MassiveAssignWorkTypeOperationStatus__c log, Exception massiveWorkTypeException) {
        log.XC_Message__c = massiveWorkTypeException.getMessage() + ' - ' + massiveWorkTypeException.getStackTraceString();
        log.XC_Status__c = 'Failed';
        XC_UTIL_Sobject.updateRecord(log);
    }
    
   /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 15/07/2022
     * @description Normalize truncated zipcode
     */
    public static String normalizeZipCode(String startZipCode){
        return  startZipCode.length() == 1 ? '0000'+startZipCode : (
                               startZipCode.length() == 2 ? '000'+startZipCode : (
                                   startZipCode.length() == 3 ? '00'+startZipCode : (
                                       startZipCode.length() == 4 ? '0'+startZipCode : startZipCode
                ))); 
    }
	
	
	 /**
     * @author Nicolo Fodera - (nicolo.fodera@enel.com)
     * @since 22/07/2022
     * @description Populate number of active service resources on status log
     */
    public static void fillActiveServiceResourceNumbOnStatusLog(XC_MassiveAssignWorkTypeOperationStatus__c log, Id sourceAccountId, Id destinationAccountId){
        List<AggregateResult> listAggrResult;
		if(log.XC_ActiveServiceResourcesOnAccount__c == null && sourceAccountId != null){
			listAggrResult  = new List<AggregateResult>([SELECT count(Id) CountSR
                FROM ServiceResource
                WHERE (AccountId = :sourceAccountId OR XC_Account__c = :sourceAccountId) AND IsActive = :true]);
			log.XC_ActiveServiceResourcesOnAccount__c = (Integer) listAggrResult[0].get('CountSR'); 
				
		} 
		if(log.XC_ActiveServiceResourcesOnDestAccount__c == null && destinationAccountId != null){
			listAggrResult = new List<AggregateResult>([SELECT count(Id) CountSR
                FROM ServiceResource
                WHERE (AccountId = :destinationAccountId OR XC_Account__c = :destinationAccountId) AND IsActive = :true]);
			log.XC_ActiveServiceResourcesOnDestAccount__c = (Integer) listAggrResult[0].get('CountSR');  
		} 
    }

    public static List<ServiceResource> getActiveServiceResourceByAccountId(String accountId){
        List<ServiceResource> listSr = new List<ServiceResource>([
                SELECT Id
                FROM ServiceResource
                WHERE (AccountId = :accountId OR XC_Account__c = :accountId) AND IsActive = :true
        ]);
        return listSr;
    }

    public static List<XC_ServiceResourceCoverage__c> getServiceResourceCoveragesByExternalIds(Set<String> externalIds){
        List<XC_ServiceResourceCoverage__c> listSrc = new List<XC_ServiceResourceCoverage__c>([
                SELECT Id, XC_ExternalIdForDuplication__c
                FROM XC_ServiceResourceCoverage__c
                WHERE XC_ExternalIdForDuplication__c IN :externalIds AND XC_ServiceResourceId__r.IsActive = :true
        ]);
        return listSrc;
    }

}