@isTest
public with sharing class BUNCHBALL_NitroServicesProxy_Test 
{	
	public static testmethod void test_hasFieldBeenPopulated_true()
	{
		Contact newContact = new Contact(FirstName='Leo');
		Contact oldContact = new Contact();
		
		System.assert(BUNCHBALL_NitroServicesProxy.hasFieldBeenPopulated(newContact, oldContact, 'FirstName', 'FOO'));
	}
	
	public static testmethod void test_hasFieldBeenPopulated_false()
	{
		Contact newContact = new Contact();
		Contact oldContact = new Contact();
		
		System.assert(!BUNCHBALL_NitroServicesProxy.hasFieldBeenPopulated(newContact, oldContact, 'FirstName', 'FOO'));
	}
	
	public static testmethod void test_hasFieldBeenPopulated_updated()
	{
		Contact newContact = new Contact(FirstName='Leo');
		Contact oldContact = new Contact(FirstName='John');
		
		System.assert(!BUNCHBALL_NitroServicesProxy.hasFieldBeenPopulated(newContact, oldContact, 'FirstName', 'FOO'));
	}
}