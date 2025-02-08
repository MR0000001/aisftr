/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 07/05/2019
 * @date Last Modification 13/06/2019 - Marco Ottaviano mottaviano@deloitte.it - Modifiche per visibilità testclass
 * @description XC_UTIL_NextStepOrderToProvisioning - Util class for provisioning steps
 */

public without sharing class XC_UTIL_NextStepOrderToProvisioning {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_NextStepOrderToProvisioning');

    /** @description Queue for second step */
    @TestVisible
    public class SecondNextStepQueue implements Queueable {
        
        String configurationId = '';

        /**
         * @description Costructor
         * @param configurationId - String
         */
        public SecondNextStepQueue(String configurationId) {
            this.configurationId = configurationId;
        }
        
        /**
         * @description Execute Queuable
         * @param context - QueueableContext
         */
        public void execute(QueueableContext context) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start Second step');
            XC_UTIL_ResultWrapper resultWrapper = XC_LCC099_NextStepOrderToProvisioning.implementSecondNextStep(configurationId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result second step ---> ' + resultWrapper);
            if(resultWrapper.success && resultWrapper.executeNextStep && !Test.isRunningTest()) {
                System.enqueueJob(new ThirdNextStepQueue(configurationId));
            }
        }
    }

    /** @description Queue for third step */
    @TestVisible
    public class ThirdNextStepQueue implements Queueable {

        String configurationId = '';
        
        /**
         * @description Costructor
         * @param configurationId - String
         */
        public ThirdNextStepQueue(String configurationId) {
            this.configurationId = configurationId;
        }
        
        /**
         * @description Execute Queuable
         * @param context - QueueableContext
         */
        public void execute(QueueableContext context) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start Third step');
            XC_UTIL_ResultWrapper resultWrapper = XC_LCC099_NextStepOrderToProvisioning.implementThirdNextStep(configurationId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result third step ---> ' + resultWrapper);
        }
    }


    /**
    * @description Method to first step for NextStepOrderToProvisioning
    * @param configurationId - String
    */
    public static void firstNextStep(String configurationId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start First step');
        XC_UTIL_ResultWrapper resultWrapper = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result first step ---> ' + resultWrapper);
        if(resultWrapper.success && resultWrapper.executeNextStep && !Test.isRunningTest()) {
            System.enqueueJob(new SecondNextStepQueue(configurationId));
        }
    }
}