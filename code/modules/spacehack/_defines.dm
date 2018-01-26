#define IDENTITY_UNKNOWN	0 // Nothing is known so far.
#define IDENTITY_PROPERTIES	1 // Basic function of the item, and amount of charges available if it uses them.
#define IDENTITY_BUC		2 // Blessed/Uncursed/Cursed status.
#define IDENTITY_FULL 		(IDENTITY_PROPERTIES|IDENTITY_BUC) // Know everything.

#define ITEM_ARTIFACT	 2 // Technomancer-specific, cannot degrade.
#define ITEM_BLESSED	 1 // Better than average and resists cursing.
#define ITEM_UNCURSED	 0 // Normal.
#define ITEM_CURSED		-1 // Does thing things, clothing cannot be taken off.

#define MESSAGE_NOTHING	"Nothing happens."
#define MESSAGE_UNKNOWN	"Something happened, but you're not sure what."