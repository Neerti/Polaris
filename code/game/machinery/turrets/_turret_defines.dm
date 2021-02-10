// Defines for the turret state machine.
#define TURRET_OFF		 0 // Turret will do nothing until someone turns it back on.
#define TURRET_DEPOWERED 1 // Turret has no power and won't do anything until that is fixed.
#define TURRET_IDLE		 2 // Not doing anything but can react to something.
#define TURRET_TURNING	 3 // In the process of turning to face the current target.
#define TURRET_ENGAGING	 4 // Actively shooting at the target.

// Defines for the IFF datum to output and for turrets to read.
#define IFF_FRIENDLY	1 // Will never fire upon this target.
#define IFF_NEUTRAL		2 // Will fire upon if attacked first.
#define IFF_HOSTILE		4 // Will shoot on sight.