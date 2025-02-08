/**
 * @author Salvatore Barbera
 * @email sbarbera@deloitte.it
 * @create date 29-03-2021
 * @modify date 29-03-2021
 * @desc Test for class XC_FL_Provisioning_CreateCommodityBP
 */
@isTest
public class XC_IN071_CreationBP_TEST {
    
    @istest
    static void testSuccessUpdateBillingProfileOnOpportunity(){

        System.debug('start test');

        /**
         * create opportunity
         */
        /*Opportunity opportunity = XC_DF_Opportunity.createOpportunity(1, false)[0];
        insert opportunity;
        System.debug('opportunity: ' + opportunity);*/

        /**
         * create Configuration (NE__Order__c)
         */
        NE__Order__c order = XC_DF_Order.createOrder('Order');
        System.debug('order: ' + order);
        
        /**
         * create Configuration Item (NE__OrderItem__c)
         */
        NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(order);
        insert orderItem;
        System.debug('orderItem: ' + orderItem);

        /**
         * creation provisioningStep
         */
        XC_Provisioning_Step__c provisioningStep = XC_DF_ProvisioningStep.createProvisioningStep(orderItem.ID);
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
        System.debug('provisioningStep: ' + provisioningStep);

        /**
         * create billing profile
         */
        /*NE__Billing_Profile__c billingProfile = XC_DF_BillingProfile.createBillingProfile(1).get(0);
        System.debug('billingProfile: ' + billingProfile);*/
        /**
         * get billing profile line item from billing profile created just now
         */
        /*XC_BillingProfileLineItem__c bpli = [SELECT ID,XC_SoldToAddress__c,XC_Account__c, XC_SoldToAddress__r.XC_Account__c FROM  XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c = :billingProfile.ID][0];
        XC_Address__c addressId = bpli.XC_SoldToAddress__r;
        
        System.debug('bpli: ' + bpli);*/

        /**
         * Set opportunity address contact to billing profile line item address
         */
        //billingProfile.NE__Account__c= bpli.XC_SoldToAddress__r.XC_Account__c;
        //bpli.XC_Account__c = bpli.XC_SoldToAddress__r.XC_Account__c;
        //update billingProfile;
        //update bpli;
        //XC_BillingProfileLineItem__c bpli2 = [SELECT ID,XC_SoldToAddress__c,XC_Account__c, XC_SoldToAddress__r.XC_Account__c FROM  XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c = :billingProfile.ID][0];
        //System.debug('bpli.XC_Account__c: ' + bpli.XC_Account__c);
        //System.debug('bpli.XC_SoldToAddress__r.XC_Account__c: ' + bpli.XC_SoldToAddress__r.XC_Account__c);

        /**
         * update opportunity with billing profile line item previously created
         */
        //opportunity.XC_CommodityBillBPLI__c = bpli.ID;
        //update opportunity;
        //System.debug('opportunity: (updated): ' + opportunity);

        /**
         * set opportunity to order (Configuration)
         */
        //order.NE__OptyId__c = opportunity.ID;
        //update order;

        /**
         * query again to check if value is setted correctly
         */
        Opportunity opportunity = [SELECT ID,XC_CommodityBillBPLI__c FROM Opportunity WHERE ID = :order.NE__OptyId__c LIMIT 1];
        System.debug('opportunity: (queried): ' + opportunity);
        /**
         * assert that opportunity billing profile line item is setted
         */
        System.assertEquals(null, opportunity.XC_CommodityBillBPLI__c,'Billing profile not setted on Opportunity');
        ID billProfId = opportunity.XC_CommodityBillBPLI__c;
        System.debug('billProfId: ' + billProfId);
        
        /**
         * call method used from Flow
         */
        List<XC_IN071_CreationBillingProfile.InputWrapper> inputWrapperList = new List<XC_IN071_CreationBillingProfile.InputWrapper>();
        XC_IN071_CreationBillingProfile.InputWrapper iw = new XC_IN071_CreationBillingProfile.InputWrapper(provisioningStep.ID);
        System.debug('provisioningStep.ID: ' + provisioningStep.ID);
        inputWrapperList.add(iw);
        
        Test.startTest();
            XC_IN071_CreationBillingProfile.createBillingProfile(inputWrapperList);
        Test.stopTest();


        /**
         * assert that opportunity has changed billing profile line item
         */
        Opportunity opportunityUpdated = [SELECT ID,XC_CommodityBillBPLI__c FROM Opportunity WHERE ID = :order.NE__OptyId__c LIMIT 1];
        System.debug('opportunityUpdated: (queried): ' + opportunity);
        ID newBillProfId = opportunityUpdated.XC_CommodityBillBPLI__c;
        
        System.debug('billProfId: ' + billProfId);
        System.debug('newBillProfId: ' + newBillProfId);

        System.assertNotEquals(null, newBillProfId,'Billing profile not updated on Opportunity. Is null');
        System.assertNotEquals(billProfId, newBillProfId,'Billing profile not updated on Opportunity');
        

        /**
         * Check step status
         */
        XC_Provisioning_Step__c provisioningStepUpdated = [SELECT ID,XC_Status__c FROM XC_Provisioning_Step__c WHERE ID = :provisioningStep.ID];
        System.debug('provisioningStepUpdated: ' + provisioningStepUpdated);
        System.assertEquals('Completed OK', provisioningStepUpdated.XC_Status__c, 'Status on step not correctly updated');
    }


    @istest
    static void testSuccessUpdateBillingProfileOnOpportunityB2B(){

        System.debug('start test');

        /**
         * create Configuration (NE__Order__c)
         */
        NE__Order__c order = XC_DF_Order.createOrder('Order');
        order.XC_Segment__c = 'B2B';
        update order;
        System.debug('order: ' + order);
        
        /**
         * create Configuration Item (NE__OrderItem__c)
         */
        NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(order);
        insert orderItem;
        System.debug('orderItem: ' + orderItem);

        /**
         * creation provisioningStep
         */
        XC_Provisioning_Step__c provisioningStep = XC_DF_ProvisioningStep.createProvisioningStep(orderItem.ID);
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
        System.debug('provisioningStep: ' + provisioningStep);

        /**
         * query again to check if value is setted correctly
         */
        Opportunity opportunity = [SELECT ID,XC_CommodityBillBPLI__c FROM Opportunity WHERE ID = :order.NE__OptyId__c LIMIT 1];
        System.debug('opportunity: (queried): ' + opportunity);
        /**
         * assert that opportunity billing profile line item is setted
         */
        System.assertEquals(null, opportunity.XC_CommodityBillBPLI__c,'Billing profile not setted on Opportunity');
        ID billProfId = opportunity.XC_CommodityBillBPLI__c;
        System.debug('billProfId: ' + billProfId);
        
        /**
         * call method used from Flow
         */
        List<XC_IN071_CreationBillingProfile.InputWrapper> inputWrapperList = new List<XC_IN071_CreationBillingProfile.InputWrapper>();
        XC_IN071_CreationBillingProfile.InputWrapper iw = new XC_IN071_CreationBillingProfile.InputWrapper(provisioningStep.ID);
        System.debug('provisioningStep.ID: ' + provisioningStep.ID);
        inputWrapperList.add(iw);
        
        Test.startTest();
            XC_IN071_CreationBillingProfile.createBillingProfile(inputWrapperList);
        Test.stopTest();


        /**
         * assert that opportunity has changed billing profile line item
         */
        Opportunity opportunityUpdated = [SELECT ID,XC_CommodityBillBPLI__c FROM Opportunity WHERE ID = :order.NE__OptyId__c LIMIT 1];
        System.debug('opportunityUpdated: (queried): ' + opportunity);
        ID newBillProfId = opportunityUpdated.XC_CommodityBillBPLI__c;
        
        System.debug('billProfId: ' + billProfId);
        System.debug('newBillProfId: ' + newBillProfId);

        System.assertNotEquals(null, newBillProfId,'Billing profile not updated on Opportunity. Is null');
        System.assertNotEquals(billProfId, newBillProfId,'Billing profile not updated on Opportunity');
    }

}