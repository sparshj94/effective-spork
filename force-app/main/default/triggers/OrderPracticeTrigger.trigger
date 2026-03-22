trigger OrderPracticeTrigger on Order (after insert) {
	PracticePaper1.mm(Trigger.new);
}