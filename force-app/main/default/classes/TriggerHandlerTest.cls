@isTest
private class TriggerHandlerTest {

	private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';
	private static String lastMethodCalled;
	private static TriggerHandlerTest.TestHandler handler;

	static {
		handler = new TriggerHandlerTest.TestHandler();
		handler.isTriggerExecuting = true;
	}

	// contexts tests
	@isTest
	static void testBeforeInsert() {
		beforeInsertMode();
		handler.run();
		System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
	}

	@isTest
	static void testBeforeUpdate() {
		beforeUpdateMode();
		handler.run();
		System.assertEquals('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
	}

	@isTest
	static void testBeforeDelete() {
		beforeDeleteMode();
		handler.run();
		System.assertEquals('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
	}

	@isTest
	static void testAfterInsert() {
		afterInsertMode();
		handler.run();
		System.assertEquals('afterInsert', lastMethodCalled, 'last method should be afterInsert');
	}

	@isTest
	static void testAfterUpdate() {
		afterUpdateMode();
		handler.run();
		System.assertEquals('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
	}

	@isTest
	static void testAfterDelete() {
		afterDeleteMode();
		handler.run();
		System.assertEquals('afterDelete', lastMethodCalled, 'last method should be afterDelete');
	}

	@isTest
	static void testAfterUndelete() {
		afterUndeleteMode();
		handler.run();
		System.assertEquals('afterUndelete', lastMethodCalled, 'last method should be afterUndelete');
	}

	@isTest 
	static void testNonTriggerContext() {
		try{
			handler.run();
			System.assert(false, 'the handler ran but should have thrown');
		} catch(TriggerHandler.TriggerHandlerException te) {
			System.assertEquals(TRIGGER_CONTEXT_ERROR, te.getMessage(), 'the exception message should match');
		} catch(Exception e) {
			System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
		}
	}

	@isTest
	static void testBypassAPI() {
		afterUpdateMode();

		TriggerHandler.bypass('TestHandler');
		handler.run();
		System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
		System.assertEquals(true, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
		resetTest();

		TriggerHandler.clearBypass('TestHandler');
		handler.run();
		System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
		System.assertEquals(false, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
		resetTest();

		TriggerHandler.bypass('TestHandler');
		handler.run();
		System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
		System.assertEquals(true, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
		resetTest();

		TriggerHandler.clearAllBypasses();
		handler.run();
		System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
		System.assertEquals(false, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
		resetTest();
	}

	@isTest
	static void testLoopCount() {
		beforeInsertMode();
		
		handler.setMaxLoopCount(2);

		handler.run();
		handler.run();

		// clear the tests
		resetTest();

		try {
			handler.run();
			System.assertEquals(null, lastMethodCalled, 'last method should be null');
		} catch(Exception e) {  
			System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
		}

		resetTest();

		handler.clearMaxLoopCount();

		try {
			handler.run();
			System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
		} catch(TriggerHandler.TriggerHandlerException te) {
			System.assert(false, 'running the handler after clearing the loop count should not throw');
		} catch(Exception e) {  
			System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
		}
	}

	@isTest
	static void testLoopCountClass() {
		TriggerHandler.LoopCount lc = new TriggerHandler.LoopCount();
		System.assertEquals(5, lc.getMax(), 'max should be five on init');
		System.assertEquals(0, lc.getCount(), 'count should be zero on init');

		lc.increment();
		System.assertEquals(1, lc.getCount(), 'count should be 1');
		System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 1');

		lc.increment();
		lc.increment();
		lc.increment();
		lc.increment();
		System.assertEquals(5, lc.getCount(), 'count should be 5');
		System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 5');

		lc.increment();
		System.assertEquals(6, lc.getCount(), 'count should be 6');
		System.assertEquals(true, lc.exceeded(), 'should not be exceeded with count of 6');
	}

	@isTest 
	static void testGetHandlerName() {
		System.assertEquals('TestHandler', handler.getHandlerName(), 'handler name should match class name');
	}

	@isTest
	static void testVirtualMethods() {
        //Given
        Exception ex;
        
        //When
        TriggerHandler h = new TriggerHandler();
        try {
            h.beforeInsert();
            h.beforeUpdate();
            h.beforeDelete();
            h.afterInsert();
            h.afterUpdate();
            h.afterDelete();
            h.afterUndelete(); 
        } catch (Exception exc) {
            ex = exc;
        }
		
        //Then
		System.assertEquals(null, ex);
	}

	@isTest
	static void testTriggerSwitch() {
		beforeInsertMode();
		insert new HandlerExecution__c(Name = 'TestHandler', Enabled__c = false);
		System.assertEquals(false, handler.isTriggerEnabled(), 'Trigger should be disabled');
		handler.run();
	}

	private static void resetTest() {
		lastMethodCalled = null;
	}

	private static void beforeInsertMode() {
		handler.setTriggerContext('before insert', true);
	}

	private static void beforeUpdateMode() {
		handler.setTriggerContext('before update', true);
	}

	private static void beforeDeleteMode() {
		handler.setTriggerContext('before delete', true);
	}

	private static void afterInsertMode() {
		handler.setTriggerContext('after insert', true);
	}

	private static void afterUpdateMode() {
		handler.setTriggerContext('after update', true);
	}

	private static void afterDeleteMode() {
		handler.setTriggerContext('after delete', true);
	}

	private static void afterUndeleteMode() {
		handler.setTriggerContext('after undelete', true);
	}

	private class TestHandler extends TriggerHandler {

		public override void beforeInsert() {
			TriggerHandlerTest.lastMethodCalled = 'beforeInsert';
		}

		public override void  beforeUpdate() {
			TriggerHandlerTest.lastMethodCalled = 'beforeUpdate';
		}

		public override void beforeDelete() {
			TriggerHandlerTest.lastMethodCalled = 'beforeDelete';
		}

		public override void afterInsert() {
			TriggerHandlerTest.lastMethodCalled = 'afterInsert';
		}

		public override void afterUpdate() {
			TriggerHandlerTest.lastMethodCalled = 'afterUpdate';
		}

		public override void afterDelete() {
			TriggerHandlerTest.lastMethodCalled = 'afterDelete';
		}

		public override void afterUndelete() {
			TriggerHandlerTest.lastMethodCalled = 'afterUndelete';
		}

	}
	
}