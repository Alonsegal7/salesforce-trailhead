trigger ContractTrigger on Contract (before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        ContractEventToContract.updateContractArrChangeToOpenOps(Trigger.new, Trigger.oldMap);
    }
}