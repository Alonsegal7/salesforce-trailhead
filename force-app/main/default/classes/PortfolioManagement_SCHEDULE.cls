global class PortfolioManagement_SCHEDULE implements Schedulable {
	
	public static String CRON_EXP = '0 0 0 3 9 ? 2022'; //Used for test class only

	global void execute(SchedulableContext sc) {
		PortfolioManagement_BATCH theBatch = new PortfolioManagement_BATCH();
		Database.executeBatch(theBatch);
	}
}