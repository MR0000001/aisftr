/**
 * The Class XC_REST_CreateOrder.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 06/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse to create an Order in Zuora
 **/


public without sharing class XC_REST_CreateOrder {

    /**
     * @param subscriptionNumber the subscription number
     * @param destinationAccountNumber the destination account number
     * @return the wrapper response
     * @description method to change the owner of a subscription
     */
    public static XC_REST_CreateOrder_W.WrapperResponse ownerTransfer(String subscriptionNumber, String destinationAccountNumber) {

        XC_REST_CreateOrder_W.WrapperResponse result = new XC_REST_CreateOrder_W.WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_CreateOrder_OwnerTransfer);
		if(isActiveInterface.activeInterface) {
            
            String url = isActiveInterface.url;

            XC_REST_CreateOrder_W.WrapperRequest wrReq = new XC_REST_CreateOrder_W.WrapperRequest();
            wrReq.orderDate = String.valueOf(System.Today());
            XC_REST_CreateOrder_W.WrapperSubscription sub = new XC_REST_CreateOrder_W.WrapperSubscription();
            sub.subscriptionNumber = subscriptionNumber;
            XC_REST_CreateOrder_W.WrapperOrderActions ordAction = new XC_REST_CreateOrder_W.WrapperOrderActions();
            ordAction.type = 'OwnerTransfer';
            XC_REST_CreateOrder_W.WrapperOwnerTransfer owner = new XC_REST_CreateOrder_W.WrapperOwnerTransfer();
            owner.destinationAccountNumber = destinationAccountNumber;
            ordAction.ownerTransfer = owner;
            sub.orderActions.add(ordAction);
            wrReq.subscriptions.add(sub);
            String body =  JSON.serialize(wrReq, true);

            Map<String, String> infoZuora = XC_UTIL_Integration.getInfosForZuoraRest();
            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
            headerDefinitions.put('Authorization', 'Bearer ' + infoZuora.get('access_token'));
            headerDefinitions.put('Zuora-Entity-Ids', infoZuora.get('zuora_ids'));
            headerDefinitions.put('zuora-version', '223.0 ');

	  		HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
	  		//HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'CreateOrder_OwnerTransfer');
	  		HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'CreateOrder_OwnerTransfer');

            result = (XC_REST_CreateOrder_W.WrapperResponse) JSON.deserialize(response.getBody(), XC_REST_CreateOrder_W.WrapperResponse.class);
		} else {
            result.success = true;
            
		}

        System.debug('RESULT ---> ' + result);
        return result;
    }
}