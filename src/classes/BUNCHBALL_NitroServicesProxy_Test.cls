@isTest
public with sharing class BUNCHBALL_NitroServicesProxy_Test 
{	
	public static testmethod void test_getOldRecord_EXISTING()
	{
		Account a = testingUtils.createAccount();
		Id recordId = a.Id;
		Account b = new Account( Id=recordId );
		
		Map<Id, SObject> objectMap = new Map<Id, SObject>();
		objectMap.put( recordId, b );
		
		Schema.sObjectType targetType = a.getSObjectType();
		
		System.assertEquals( b, BUNCHBALL_NitroServicesProxy.getOldRecord(targetType, false, recordId, objectMap) );
	}
	
	public static testmethod void test_getOldRecord_NON_EXISTING()
	{
		Account a = testingUtils.createAccount();
		Id recordId = a.Id;
		
		Map<Id, SObject> objectMap = new Map<Id, SObject>();
		Schema.sObjectType targetType = a.getSObjectType();
		
		Account returned = (Account)BUNCHBALL_NitroServicesProxy.getOldRecord(targetType, true, recordId, objectMap);
		System.assertNotEquals( a.Id, returned.Id );
	}
	
	public static testmethod void test_parseNitroActions_ALL_FALSE()
	{
		Contact newContact = new Contact();
		Contact oldContact = new Contact();
		Bunchball_Settings__c settings = new Bunchball_Settings__c();
		
		for( String validAction : BUNCHBALL_NitroServicesProxy.VALID_ACTIONS )
		{
			settings.put( validAction, 'foo' );
		}
		
		Map<String, Boolean> actionResults = BUNCHBALL_NitroServicesProxy.parseNitroActions(newContact, oldContact, 'FirstName', settings );
		
		System.assertEquals( BUNCHBALL_NitroServicesProxy.VALID_ACTIONS.size(), actionResults.size() );
		for( String validAction : BUNCHBALL_NitroServicesProxy.VALID_ACTIONS )
		{
			System.assert( !actionResults.get(validAction), 'Failure: ' + validAction + ' not properly set,' );
		}
	}
	
	public static testmethod void test_parseNitroActions_ONE_ACTION()
	{
		Contact newContact = new Contact();
		Contact oldContact = new Contact();
		Bunchball_Settings__c settings = new Bunchball_Settings__c();
		
		String validAction = BUNCHBALL_NitroServicesProxy.VALID_ACTIONS[0];
		settings.put( validAction, 'foo' );
		
		Map<String, Boolean> actionResults = BUNCHBALL_NitroServicesProxy.parseNitroActions(newContact, oldContact, 'FirstName', settings );
		
		System.assertNotEquals( BUNCHBALL_NitroServicesProxy.VALID_ACTIONS.size(), actionResults.size() );
		System.assertEquals( 1, actionResults.size() );
		
	}
	
	public static testmethod void test_parseNitroActions_ONE_TRUE()
	{
		Contact newContact = new Contact(HasOptedOutOfEmail=true);
		Contact oldContact = new Contact(HasOptedOutOfEmail=false);
		Bunchball_Settings__c settings = new Bunchball_Settings__c();
		
		for( String validAction : BUNCHBALL_NitroServicesProxy.VALID_ACTIONS )
		{
			settings.put( validAction, 'foo' );
		}
		
		Map<String, Boolean> actionResults = BUNCHBALL_NitroServicesProxy.parseNitroActions(newContact, oldContact, 'HasOptedOutOfEmail', settings );
		
		System.assertEquals( BUNCHBALL_NitroServicesProxy.VALID_ACTIONS.size(), actionResults.size() );
		for( String validAction : BUNCHBALL_NitroServicesProxy.VALID_ACTIONS )
		{
			if( validAction != BUNCHBALL_NitroServicesProxy.ON_POPULATE )
				System.assert( actionResults.get(validAction), 'Failure: ' + validAction + ' not properly set,' );
			else
				System.assert( !actionResults.get(validAction), 'Failure: ' + validAction + ' not properly set,' );
		}
	}
	
	public static testmethod void test_getRewardedUser_TRUE()
	{
		User activeUser = [select Id, UserName from User where IsActive = true and Id != :UserInfo.getUserId() limit 1];
		Bunchball_Settings__c settings = new Bunchball_Settings__c( Credit_Record_Owner__c=true );
		Contact c = new Contact( OwnerId=activeUser.Id );
		
		System.assertEquals( activeUser.UserName, BUNCHBALL_NitroServicesProxy.getRewardedUser(c, settings) );
	}
	
	public static testmethod void test_getRewardedUser_FALSE()
	{
		Bunchball_Settings__c settings = new Bunchball_Settings__c();
		Contact c = new Contact();
		
		System.assertEquals( UserInfo.getUserName(), BUNCHBALL_NitroServicesProxy.getRewardedUser(c, settings) );
	}
	
	public static testmethod void test_isEmpty_TRUE()
	{
		Contact c = new Contact();
		System.assert( BUNCHBALL_NitroServicesProxy.isEmpty(c, 'FirstName') );
	}
	
	public static testmethod void test_isEmpty_FALSE()
	{
		Contact c = new Contact(FirstName='Joe');
		System.assert( !BUNCHBALL_NitroServicesProxy.isEmpty(c, 'FirstName') );
	}
	
	public static testmethod void test_fieldUpdate_TRUE()
	{
		Contact newContact = new Contact(FirstName='Joe');
		Contact oldContact = new Contact(FirstName='Larry');
		
		System.assert( BUNCHBALL_NitroServicesProxy.fieldUpdate( newContact, oldContact, 'FirstName') );
	}
	
	public static testmethod void test_fieldUpdate_FALSE()
	{
		Contact newContact = new Contact(FirstName='Joe');
		Contact oldContact = new Contact(FirstName='Joe');
		
		System.assert( !BUNCHBALL_NitroServicesProxy.fieldUpdate( newContact, oldContact, 'FirstName') );
	}
	
	public static testmethod void test_falseToTrue_TRUE()
	{
		Contact newContact = new Contact(HasOptedOutOfEmail=true);
		Contact oldContact = new Contact(HasOptedOutOfEmail=false);
		
		System.assert( BUNCHBALL_NitroServicesProxy.falseToTrue( newContact, oldContact, 'HasOptedOutOfEmail') );
	}
	
	public static testmethod void test_falseToTrue_NULL()
	{
		Contact newContact = new Contact(HasOptedOutOfEmail=true);
		Contact oldContact = new Contact();
		
		System.assert( BUNCHBALL_NitroServicesProxy.falseToTrue( newContact, oldContact, 'HasOptedOutOfEmail') );
	}
	
	public static testmethod void test_falseToTrue_FALSE()
	{
		Contact newContact = new Contact(HasOptedOutOfEmail=false);
		Contact oldContact = new Contact(HasOptedOutOfEmail=false);
		
		System.assert( !BUNCHBALL_NitroServicesProxy.falseToTrue( newContact, oldContact, 'HasOptedOutOfEmail') );
	}
	
	public static testmethod void test_onPopulate_EMPTY_STRING()
	{
		Contact newContact = new Contact(FirstName='Joe');
		Contact oldContact = new Contact(FirstName='');
		
		System.assert( BUNCHBALL_NitroServicesProxy.onPopulate( newContact, oldContact, 'FirstName') );
	}
	
	public static testmethod void test_onPopulate_FALSE()
	{
		Contact newContact = new Contact(FirstName='Joe');
		Contact oldContact = new Contact(FirstName='Larry');
		
		System.assert( !BUNCHBALL_NitroServicesProxy.onPopulate( newContact, oldContact, 'FirstName') );
	}
	
	public static testmethod void test_onPopulate_NULL()
	{
		Contact newContact = new Contact(FirstName='Joe');
		Contact oldContact = new Contact();
		
		System.assert( BUNCHBALL_NitroServicesProxy.onPopulate( newContact, oldContact, 'FirstName') );
	}
	
	public static testmethod void test_onPopulate_REVERSE()
	{
		Contact newContact = new Contact();
		Contact oldContact = new Contact(FirstName='Larry');
		
		System.assert( !BUNCHBALL_NitroServicesProxy.onPopulate( newContact, oldContact, 'FirstName') );
	}
}