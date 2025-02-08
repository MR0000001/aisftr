//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class AutocreatedRegHandler1588063275906 implements Auth.SamlJitHandler {
	private class JitException extends Exception{}
	private void handleUser(boolean create, User u, Map<String, String> attributes,
		String federationIdentifier, boolean isStandard) {

		if(attributes.containsKey('iv_email')) {
            String attributeEmail = attributes.get('iv_email');
            if(create) {
                u.Username = attributeEmail;
            }
            u.Email = attributeEmail;

		}
		u.FederationIdentifier = federationIdentifier;

		if(attributes.containsKey('iv_mobile')) {
            String mobilePhone = attributes.get('iv_mobile');
			u.Phone = mobilePhone;
            u.MobilePhone = mobilePhone;
		}

		if(attributes.containsKey('iv_nome')) {
			u.FirstName = attributes.get('iv_nome');
		}
		if(attributes.containsKey('iv_cognome')) {
			u.LastName = attributes.get('iv_cognome');
		}

		if(attributes.containsKey('iv_nascita_nazione')) {
			u.Country__c = attributes.get('iv_nascita_nazione');
		}
		String uid = UserInfo.getUserId();
		User currentUser =
		[SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];

        if(create) {
			u.LocaleSidKey = currentUser.LocaleSidKey;
			u.LanguageLocaleKey = 'it';
            String alias = '';
            if(u.FirstName == null) {
                alias = u.LastName;
            } else {
                alias = u.FirstName.charAt(0) + u.LastName;
            }
            if(alias.length() > 5) {
                alias = alias.substring(0, 5);
            }
            u.Alias = alias;
            u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
            u.EmailEncodingKey = currentUser.EmailEncodingKey;
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User'];
            u.ProfileId = p.Id;
		}

        if(attributes.containsKey('iv_codfis')) {
            u.FiscalCode__c = attributes.get('iv_codfis');
        }
		//Handle custom fields here

		if(!create) {
			update(u);
		}else{
			//system.debug('@@@ User '+u);
			insert u;
			//system.debug('@@@ inserted User '+ [SELECT Id, FederationIdentifier FROM User WHERE Id =: u.Id]);
		}
	}
	@TestVisible
	private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
		String federationIdentifier, Map<String, String> attributes, String assertion) {
		if(communityId != null || portalId != null) {
			handleUser(create, u, attributes, federationIdentifier, false);
		} else {
			handleUser(create, u, attributes, federationIdentifier, true);
		}
	}

	global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
		String federationIdentifier, Map<String, String> attributes, String assertion) {
		/**
		system.debug('@@@ create samlSsoProviderId '+samlSsoProviderId);
		system.debug('@@@ create communityId '+communityId);
		system.debug('@@@ create portalId '+samlSsoProviderId);
		system.debug('@@@ create federationIdentifier '+federationIdentifier);
		system.debug('@@@ create attributes '+attributes);
		system.debug('@@@ create assertion '+assertion);
		system.debug('@@@ groups '+attributes.get('iv_portal_groups'));*/
		User u = new User();
		String rawFile = EncodingUtil.base64Decode(assertion).toString();
        if(attributes.containsKey('iv_codfis') && rawFile.contains('cn=Salesforce,ou=Groups,dc=cdr,dc=it')) {
            String codfis = attributes.get('iv_codfis');
            List<User> userToPass = [SELECT Id, FirstName, ContactId FROM User WHERE FiscalCode__c =:codfis];
            if(!userToPass.isEmpty()){
				u = userToPass[0];
                handleJit(false, u, samlSsoProviderId, communityId, portalId,
                        federationIdentifier, attributes, assertion);
            }else{
                handleJit(true, u, samlSsoProviderId, communityId, portalId,
                        federationIdentifier, attributes, assertion);
            }
        }

		String codfis2 = attributes.get('iv_codfis');
		User userToPass2 = [SELECT Id, FirstName, ContactId FROM User WHERE FiscalCode__c =:codfis2];
		return userToPass2;
	}

	global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
		String federationIdentifier, Map<String, String> attributes, String assertion) {
		User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];
		handleJit(false, u, samlSsoProviderId, communityId, portalId,
			federationIdentifier, attributes, assertion);
	}
}